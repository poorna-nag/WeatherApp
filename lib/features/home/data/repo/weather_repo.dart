import 'package:weatherapp/features/home/data/weather_model.dart';

abstract class WeatherRepo {
  Future<WeatherModel> getWeatherDataFromCity(String location);
  Future<WeatherModel> getWeatherDataFromLatLong({
    required double lat,
    required double long,
  });
}
