import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weatherapp/features/home/data/repo/weather_repo_impl.dart';

import 'package:weatherapp/features/home/presentation/bloc/weather_bloc.dart';
import 'package:weatherapp/features/home/presentation/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => WeatherBloc(WeatherRepoImpl()))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),

        home: WeatherScreen(),
      ),
    );
  }
}
