import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/core/utils/location_service.dart';
import 'package:weatherapp/features/home/data/weather_model.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_bloc.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_event.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_state.dart';
import 'package:weatherapp/features/home/presentation/widgets/forecast_chart.dart';

import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loadingLocation = false;
  final _dateFormat = DateFormat('EEE, MMM d');

  Future<void> _loadForCurrentLocation() async {
    setState(() => loadingLocation = true);
    try {
      final pos = await LocationService.determinePosition();
      if (!mounted) return;
      context.read<WeatherBloc>().add(
        LoadWeather(
          lat: pos.latitude,
          lon: pos.longitude,
          label: 'Your location',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loadingLocation = false);
    }
  }

  Future<void> _refreshWeather(BuildContext context) async {
    final bloc = context.read<WeatherBloc>();
    bloc.add(RefreshWeather());
    await bloc.stream.firstWhere((state) => state is! WeatherLoading);
  }

  Future<void> _promptCitySearch() async {
    final controller = TextEditingController();
    final city = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search city'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Bengaluru, London',
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
    if (city != null && city.trim().isNotEmpty && mounted) {
      context.read<WeatherBloc>().add(LoadWeatherByCity(city.trim()));
    }
  }

  void _openMap(WeatherLoaded state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          lat: state.lat,
          lon: state.lon,
          locationLabel: state.locationLabel,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WeatherBloc>().add(LoadWeatherByCity('Bengaluru'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Planner'),
        actions: [
          IconButton(
            tooltip: 'Search by city',
            onPressed: _promptCitySearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: loadingLocation
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            onPressed: loadingLocation ? null : _loadForCurrentLocation,
            tooltip: 'Use current location',
          ),
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Open map',
                onPressed: state is WeatherLoaded
                    ? () => _openMap(state)
                    : null,
                icon: const Icon(Icons.map),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is WeatherLoading) {
            return _Loading(message: state.message);
          } else if (state is WeatherLoaded) {
            return RefreshIndicator(
              onRefresh: () => _refreshWeather(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _LocationHeader(
                    label: state.locationLabel,
                    onMapTap: () => _openMap(state),
                  ),
                  const SizedBox(height: 16),
                  _CurrentWeatherCard(model: state.current),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    color: Colors.indigo.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ForecastChart(items: state.forecast),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Next 5 days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...state.forecast.map(
                    (f) => Card(
                      child: ListTile(
                        leading: _ForecastIcon(icon: f.icon),
                        title: Text(_dateFormat.format(f.dateTime)),
                        subtitle: Text(
                          '${f.condition} • Humidity ${f.humidity.toStringAsFixed(0)}%',
                        ),
                        trailing: Text('${f.temp.toStringAsFixed(1)}°C'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is WeatherError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<WeatherBloc>().add(
                LoadWeatherByCity('Bengaluru'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.label, required this.onMapTap});
  final String label;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forecast for',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onMapTap,
          icon: const Icon(Icons.map),
          label: const Text('Map'),
        ),
      ],
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.model});
  final WeatherModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (model.icon != null)
              Image.network(
                'https://openweathermap.org/img/wn/${model.icon}@4x.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            Text(
              '${model.temp.toStringAsFixed(1)}°C',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              model.condition,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MetricTile(
                  icon: Icons.air,
                  label: 'Feels',
                  value: '${model.temp.toStringAsFixed(0)}°',
                ),
                _MetricTile(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${model.humidity.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ForecastIcon extends StatelessWidget {
  const _ForecastIcon({this.icon});
  final String? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return const Icon(Icons.cloud_queue);
    }
    return Image.network(
      'https://openweathermap.org/img/wn/$icon@2x.png',
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
