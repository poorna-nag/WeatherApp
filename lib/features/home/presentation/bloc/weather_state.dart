import 'package:equatable/equatable.dart';

import '../../data/weather_model.dart';

abstract class WeatherState extends Equatable {}

class WeatherInitial extends WeatherState {
  @override
  List<Object?> get props => [];
}

class WeatherLoading extends WeatherState {
  @override
  List<Object?> get props => [];
}

class WeatherLoaded extends WeatherState {
  final WeatherModel data;
  WeatherLoaded(this.data);
  @override
  List<Object?> get props => [
    data.location.lat,
    data.location.lon,
    data.location.country,
  ];
}

class WeatherLocationResolved extends WeatherState {
  final double lat;
  final double lon;
  final String label;

  WeatherLocationResolved({
    required this.lat,
    required this.lon,
    required this.label,
  });

  @override
  List<Object?> get props => [];
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);

  @override
  List<Object?> get props => [];
}
