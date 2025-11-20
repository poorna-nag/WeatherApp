import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/core/utils/location_service.dart';
import 'package:weatherapp/features/home/data/repo/weather_repo_impl.dart';
import 'package:weatherapp/features/home/data/weather_model.dart';

import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final repo = WeatherRepoImpl();

  WeatherBloc(WeatherRepoImpl weatherRepoImpl) : super(WeatherInitial()) {
    on<GetForecastEvent>((event, emit) async {
   
      try {
        emit(WeatherLoading());

        final city = event.city;
        WeatherModel data;
        if (city != null) {
          data = await repo.getWeatherDataFromCity(city);
        } else {
          final currentLocation = await LocationService.determinePosition();
          final lat = currentLocation.latitude;
          final long = currentLocation.longitude;
          data = await repo.getWeatherDataFromLatLong(lat: lat, long: long);
        }

        emit(WeatherLoaded(data));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
    on<FetchWeatherEvent>((event, emit) async {
      emit(WeatherLoading());

      try {
        final weatherData = await repo.getWeatherDataFromLatLong(
          lat: event.lat,
          long: event.lon,
        );

        emit(WeatherLoaded(weatherData));
      } catch (e) {
        emit(WeatherError("Failed to load weather"));
      }
    });
  }
}
