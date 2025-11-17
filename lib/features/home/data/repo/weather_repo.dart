import 'package:weatherapp/features/home/data/weather_model.dart';

abstract class WeatherRepo {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
  Future<List<WeatherModel>> get5DayForecast(double lat, double lon);
  Future<({double lat, double lon, String label})> resolveCity(String cityName);
}
