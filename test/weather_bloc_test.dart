import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weatherapp/features/home/data/repo/weather_repo.dart';
import 'package:weatherapp/features/home/data/weather_model.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_bloc.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_event.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_state.dart';

class _MockWeatherRepo extends Mock implements WeatherRepo {}

void main() {
  late WeatherRepo repo;
  final stubWeather = WeatherModel(
    temp: 25,
    condition: 'Clear',
    humidity: 40,
    dateTime: DateTime(2024, 01, 01),
    icon: '01d',
  );
  final stubForecast = List<WeatherModel>.generate(
    5,
    (index) => stubWeather.copyWith(
      temp: 20 + index.toDouble(),
      dateTime: DateTime(2024, 01, index + 1),
    ),
  );

  setUp(() {
    repo = _MockWeatherRepo();
  });

  WeatherBloc buildBloc() => WeatherBloc(repo);

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherLoaded] on successful LoadWeather',
    build: buildBloc,
    setUp: () {
      when(
        () => repo.getCurrentWeather(any(), any()),
      ).thenAnswer((_) async => stubWeather);
      when(
        () => repo.get5DayForecast(any(), any()),
      ).thenAnswer((_) async => stubForecast);
    },
    act: (bloc) =>
        bloc.add(const LoadWeather(lat: 12.9, lon: 77.6, label: 'Test')),
    expect: () => [
      const WeatherLoading(),
      WeatherLoaded(
        current: stubWeather,
        forecast: stubForecast,
        lat: 12.9,
        lon: 77.6,
        locationLabel: 'Test',
      ),
    ],
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherError] when repo throws',
    build: buildBloc,
    setUp: () {
      when(
        () => repo.getCurrentWeather(any(), any()),
      ).thenThrow(Exception('network down'));
    },
    act: (bloc) => bloc.add(const LoadWeather(lat: 0, lon: 0)),
    expect: () => [
      const WeatherLoading(),
      const WeatherError('Exception: network down'),
    ],
  );
}
