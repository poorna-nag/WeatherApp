class WeatherEvent {}

class LoadWeather extends WeatherEvent {
  final double lat;
  final double lon;
  final String label;

  LoadWeather({
    required this.lat,
    required this.lon,
    this.label = 'Selected location',
  });
}

class LoadWeatherByCity extends WeatherEvent {
  final String city;

  LoadWeatherByCity(this.city);
}

class RefreshWeather extends WeatherEvent {
  RefreshWeather();
}
