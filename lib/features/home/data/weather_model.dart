import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final double temp;
  final String condition;
  final double humidity;
  final DateTime dateTime;
  final String? icon;

  const WeatherModel({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.dateTime,
    this.icon,
  });

  WeatherModel copyWith({
    double? temp,
    String? condition,
    double? humidity,
    DateTime? dateTime,
    String? icon,
  }) {
    return WeatherModel(
      temp: temp ?? this.temp,
      condition: condition ?? this.condition,
      humidity: humidity ?? this.humidity,
      dateTime: dateTime ?? this.dateTime,
      icon: icon ?? this.icon,
    );
  }

  factory WeatherModel.fromOpenWeatherMap(Map<String, dynamic> json) {
    // Handles both current weather and forecast item shapes.
    final main = json['main'] ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final weatherEntry = weatherList.isNotEmpty
        ? weatherList[0] as Map<String, dynamic>
        : {};
    final condition = weatherEntry['main'] as String? ?? 'Unknown';
    final icon = weatherEntry['icon'] as String?;
    final temp = (main['temp'] is num) ? (main['temp'] as num).toDouble() : 0.0;
    final humidity = (main['humidity'] is num)
        ? (main['humidity'] as num).toDouble()
        : 0.0;
    DateTime dt = DateTime.now();
    if (json.containsKey('dt')) {
      final d = json['dt'];
      if (d is int) dt = DateTime.fromMillisecondsSinceEpoch(d * 1000);
    } else if (json.containsKey('dt_txt')) {
      dt = DateTime.tryParse(json['dt_txt']) ?? dt;
    }

    return WeatherModel(
      temp: temp,
      condition: condition,
      humidity: humidity,
      dateTime: dt,
      icon: icon,
    );
  }

  @override
  List<Object?> get props => [temp, condition, humidity, dateTime, icon];
}
