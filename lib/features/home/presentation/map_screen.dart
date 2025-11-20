import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weatherapp/core/utils/url_tile_provider.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_bloc.dart';
import 'package:weatherapp/features/home/presentation/bloc/weather_event.dart';
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

  late double _lat;
  late double _long;

  double? temp;
  double? humidity;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _long = widget.lon;
  }

  String get _layerName =>
      layer == WeatherMapLayer.precipitation ? 'precipitation_new' : 'temp_new';

  @override
  Widget build(BuildContext context) {
    final weatherState = context.watch<WeatherBloc>().state;

    if (weatherState is WeatherLoaded) {
      temp = weatherState.data.current.tempC;
      humidity = weatherState.data.current.humidity.toDouble();
    }

    final owmKey = dotenv.env['MAP_API_KEY'] ?? '';
    final overlaysEnabled = owmKey.isNotEmpty;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('userLocation'),
        position: LatLng(_lat, _long),
        onTap: () {
          controller?.showMarkerInfoWindow(const MarkerId('userLocation'));
        },
        infoWindow: temp != null
            ? InfoWindow(
                title: "${temp?.toStringAsFixed(1)}°C",
                snippet: "Humidity: ${humidity?.toStringAsFixed(0)}%",
              )
            : const InfoWindow(title: "Loading weather..."),
      ),
    };

    final tileOverlays = <TileOverlay>{};

    if (overlaysEnabled) {
      final urlTemplate =
          "https://tile.openweathermap.org/map/$_layerName/{z}/{x}/{y}.png?appid=$owmKey";

      tileOverlays.add(
        TileOverlay(
          tileOverlayId: TileOverlayId("weather_layer_$_layerName"),
          tileProvider: UrlTileProvider(urlTemplate: urlTemplate),
          transparency: 0.4,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Weather Map")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lon),
              zoom: 7.6,
            ),
            onMapCreated: (c) => controller = c,
            markers: markers,
            tileOverlays: tileOverlays,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            onTap: (LatLng tappedPosition) {
              setState(() {
                _lat = tappedPosition.latitude;
                _long = tappedPosition.longitude;
              });

              context.read<WeatherBloc>().add(
                FetchWeatherEvent(
                  lat: tappedPosition.latitude,
                  lon: tappedPosition.longitude,
                ),
              );

              controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: tappedPosition, zoom: 10),
                ),
              );

              controller?.showMarkerInfoWindow(markers.first.markerId);
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 74,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ToggleButtons(
                      isSelected: [
                        layer == WeatherMapLayer.precipitation,
                        layer == WeatherMapLayer.temperature,
                      ],
                      borderRadius: BorderRadius.circular(14),
                      onPressed: overlaysEnabled
                          ? (index) {
                              setState(() {
                                layer = WeatherMapLayer.values[index];
                              });
                            }
                          : null,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text("Precipitation"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text("Temperature"),
                        ),
                      ],
                    ),

                    if (!overlaysEnabled) ...[
                      const SizedBox(height: 14),
                      Text(
                        "Missing OpenWeather API key.",
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
