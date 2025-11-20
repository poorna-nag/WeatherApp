import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/features/home/presentation/map_screen.dart';
import '../data/repo/weather_repo_impl.dart';
import 'bloc/weather_bloc.dart';
import 'bloc/weather_event.dart';
import 'bloc/weather_state.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc(WeatherRepoImpl()),
      child: _WeatherUiState(),
    );
  }
}

class _WeatherUiState extends StatefulWidget {
  const _WeatherUiState();

  @override
  State<_WeatherUiState> createState() => __WeatherUiStateState();
}

class __WeatherUiStateState extends State<_WeatherUiState> {
  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(GetForecastEvent());
  }

  void _searchCity(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController cityController = TextEditingController();

        return AlertDialog(
          title: Text("Search City"),
          content: TextField(
            controller: cityController,
            decoration: InputDecoration(
              hintText: "Enter city name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newCity = cityController.text.trim();

                if (newCity.isNotEmpty) {
                  context.read<WeatherBloc>().add(
                    GetForecastEvent(city: newCity),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Weather App"),
        actions: [
          IconButton(
            onPressed: () {
              _searchCity(context);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is WeatherError) {
              return Center(child: Text(state.message));
            }

            if (state is WeatherLoaded) {
              final currentWeat = state.data.current;
              final forecaseWeat = state.data.forecast;
              final currentLocation = state.data.location;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentLocation.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            currentWeat.condition.text,

                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Image.network(
                                "https:${currentWeat.condition.icon}",
                                width: 70,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "${currentWeat.tempC.toStringAsFixed(0)}°C",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Coming Next 5 Days",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecaseWeat.forecastday.length,
                      itemBuilder: (context, i) {
                        final day = forecaseWeat.forecastday[i];
                        return Container(
                          width: 120,
                          margin: EdgeInsets.only(left: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.date,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 10),

                              SizedBox(height: 10),
                              Image.network(
                                "https:${day.day.condition.icon}",
                                width: 50,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "${day.day.maxtempC.toStringAsFixed(0)}°",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                day.day.condition.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text('🌄${day.astro.sunrise}'),
                              SizedBox(height: 10),
                              Text('🌆${day.astro.sunset}'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return SizedBox();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoaded) {
            final currentLocation = state.data.location;

            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      lat: currentLocation.lat,
                      lon: currentLocation.lon,
                      locationLabel: currentLocation.country,
                    ),
                  ),
                );
              },
              child: Icon(Icons.map),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
