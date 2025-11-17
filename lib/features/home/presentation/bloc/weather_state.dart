import 'package:weatherapp/features/home/data/weather_model.dart';

class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {
  final String message;

  WeatherLoading({required this.message});
}

class WeatherLoaded extends WeatherState {
  final WeatherModel current;
  final List<WeatherModel> forecast;
  final double lat;
  final double lon;
  final String locationLabel;

  WeatherLoaded({
    required this.current,
    required this.forecast,
    required this.lat,
    required this.lon,
    required this.locationLabel,
  });
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
