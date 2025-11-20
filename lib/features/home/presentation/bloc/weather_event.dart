abstract class WeatherEvent {}

class GetForecastEvent extends WeatherEvent {
  final String? city;

  GetForecastEvent({this.city});
}

class SearchCityEvent extends WeatherEvent {
  final String city;

  SearchCityEvent(this.city);
}

class FetchWeatherEvent extends WeatherEvent {
  final double lat;
  final double lon;

  FetchWeatherEvent({required this.lat, required this.lon});
}
