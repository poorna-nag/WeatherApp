import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weatherapp/core/utils/url_tile_provider.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_bloc.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_state.dart';

enum WeatherMapLayer { precipitation, temperature }

class MapScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final String locationLabel;
  const MapScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.locationLabel,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? controller;
  WeatherMapLayer layer = WeatherMapLayer.precipitation;

  String get _layerName =>
      layer == WeatherMapLayer.precipitation ? 'precipitation_new' : 'temp_new';

  @override
  Widget build(BuildContext context) {
    final owmKey = dotenv.env['OWM_API_KEY'] ?? '';
    final overlaysEnabled = owmKey.isNotEmpty;
    final weatherState = context.watch<WeatherBloc>().state;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(widget.lat, widget.lon),
        infoWindow: InfoWindow(
          title: weatherState is WeatherLoaded
              ? '${weatherState.current.temp.toStringAsFixed(1)}°C'
              : widget.locationLabel,
          snippet: weatherState is WeatherLoaded
              ? 'Humidity: ${weatherState.current.humidity.toStringAsFixed(0)}%'
              : 'Selected location',
        ),
      ),
    };

    final tileOverlays = <TileOverlay>{};
    if (overlaysEnabled) {
      final template =
          'https://tile.openweathermap.org/map/$_layerName/{z}/{x}/{y}.png?appid=$owmKey';
      tileOverlays.add(
        TileOverlay(
          tileOverlayId: TileOverlayId('owm_$_layerName'),
          tileProvider: UrlTileProvider(urlTemplate: template),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Weather Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lon),
              zoom: 8,
            ),
            onMapCreated: (c) => controller = c,
            markers: markers,
            tileOverlays: tileOverlays,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.locationLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ToggleButtons(
                      isSelected: [
                        layer == WeatherMapLayer.precipitation,
                        layer == WeatherMapLayer.temperature,
                      ],
                      borderRadius: BorderRadius.circular(16),
                      onPressed: overlaysEnabled
                          ? (index) {
                              setState(() {
                                layer = WeatherMapLayer.values[index];
                              });
                            }
                          : null,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Precipitation'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Temperature'),
                        ),
                      ],
                    ),
                    if (!overlaysEnabled) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Add OWM_API_KEY in .env to enable weather layers.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
