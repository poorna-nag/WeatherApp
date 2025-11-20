import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/features/home/data/weather_model.dart';

import 'weather_repo.dart';

class WeatherRepoImpl implements WeatherRepo {
  final String _apiKey = dotenv.env['OWM_API_KEY'] ?? '';

  WeatherRepoImpl();

  Uri _forecastUrl(String city) {
    return Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?q=$city&days=5&key=$_apiKey',
    );
  }

  @override
  Future<WeatherModel> getWeatherDataFromCity(String location) async {
    if (_apiKey.isEmpty) {
      throw Exception("API key not found in .env file");
    }

    final res = await http.get(_forecastUrl(location));
    if (res.statusCode != 200) {
      throw Exception("Failed to fetch forecast (${res.statusCode})");
    }

    final json = jsonDecode(res.body);

    return WeatherModel.fromJson(json);
  }

  @override
  Future<WeatherModel> getWeatherDataFromLatLong({
    required double lat,
    required double long,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("API key not found in .env file");
    }

    final res = await http.get(
      Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?q=$lat,$long&days=5&key=$_apiKey',
      ),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to fetch forecast (${res.statusCode})");
    }

    final json = jsonDecode(res.body);

    return WeatherModel.fromJson(json);
  }
  

}
