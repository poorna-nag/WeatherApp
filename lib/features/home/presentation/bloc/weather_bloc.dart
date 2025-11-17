import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/features/home/data/repo/weather_repo.dart';

import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepo repo;
  double? lastLat;
  double? lastLon;
  String lastLabel = 'Bengaluru, IN';

  WeatherBloc(this.repo) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<LoadWeatherByCity>(_onLoadWeatherByCity);
    on<RefreshWeather>(_onRefreshWeather);
  }

  Future<void> _emitLoaded(
    Emitter<WeatherState> emit, {
    required double lat,
    required double lon,
    required String label,
  }) async {
    final current = await repo.getCurrentWeather(lat, lon);
    final forecast = await repo.get5DayForecast(lat, lon);
    emit(
      WeatherLoaded(
        current: current,
        forecast: forecast,
        lat: lat,
        lon: lon,
        locationLabel: label,
      ),
    );
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading(message: state.toString()));
    try {
      lastLat = event.lat;
      lastLon = event.lon;
      lastLabel = event.label;
      await _emitLoaded(
        emit,
        lat: event.lat,
        lon: event.lon,
        label: event.label,
      );
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onLoadWeatherByCity(
    LoadWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading(message: 'Resolving ${event.city}...'));
    try {
      final result = await repo.resolveCity(event.city);
      lastLat = result.lat;
      lastLon = result.lon;
      lastLabel = result.label;
      await _emitLoaded(
        emit,
        lat: result.lat,
        lon: result.lon,
        label: result.label,
      );
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (lastLat == null || lastLon == null) return;
    emit(WeatherLoading(message: 'Refreshing...'));
    try {
      await _emitLoaded(emit, lat: lastLat!, lon: lastLon!, label: lastLabel);
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
