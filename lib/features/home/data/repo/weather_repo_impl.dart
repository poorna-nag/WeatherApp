import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/features/home/data/weather_model.dart';

import 'weather_repo.dart';

class WeatherRepoImpl implements WeatherRepo {
  final String _apiKey = dotenv.env['OWM_API_KEY'] ?? '';

  WeatherRepoImpl();

  Uri _currentUrl(double lat, double lon) {
    return Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
  }

  Uri _forecastUrl(double lat, double lon) {
    return Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
  }

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API key not set in .env');
    }
    final res = await http.get(_currentUrl(lat, lon));
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch current weather (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherModel.fromOpenWeatherMap(data);
  }

  @override
  Future<List<WeatherModel>> get5DayForecast(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API key not set in .env');
    }
    final res = await http.get(_forecastUrl(lat, lon));
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch forecast (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>? ?? [];
    // Simplest approach: pick one forecast per day by taking every 8th item (3-hour intervals * 8 = 24h)
    final chosen = <WeatherModel>[];
    for (var i = 0; i < list.length && chosen.length < 5; i += 8) {
      chosen.add(
        WeatherModel.fromOpenWeatherMap(list[i] as Map<String, dynamic>),
      );
    }
    // Fallback: if not enough, take first 5
    if (chosen.length < 5) {
      chosen.clear();
      for (var i = 0; i < list.length && chosen.length < 5; i++) {
        chosen.add(
          WeatherModel.fromOpenWeatherMap(list[i] as Map<String, dynamic>),
        );
      }
    }
    return chosen;
  }

  Uri _geocodeUrl(String city) {
    return Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$_apiKey',
    );
  }

  @override
  Future<({double lat, double lon, String label})> resolveCity(
    String cityName,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API key not set in .env');
    }
    final sanitized = cityName.trim();
    if (sanitized.isEmpty) {
      throw Exception('Please enter a valid city name');
    }
    final res = await http.get(_geocodeUrl(Uri.encodeComponent(sanitized)));
    if (res.statusCode != 200) {
      throw Exception('Unable to resolve $sanitized (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    if (data.isEmpty) {
      throw Exception('City not found. Try a different name.');
    }
    final first = data.first as Map<String, dynamic>;
    final lat = (first['lat'] as num).toDouble();
    final lon = (first['lon'] as num).toDouble();
    final label = [
      if (first['name'] != null) first['name'],
      if (first['state'] != null) first['state'],
      if (first['country'] != null) first['country'],
    ].whereType<String>().join(', ');
    return (lat: lat, lon: lon, label: label.isEmpty ? sanitized : label);
  }
}
