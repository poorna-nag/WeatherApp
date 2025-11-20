class WeatherModel {
  final Location location;
  final Current current;
  final Forecast forecast;

  WeatherModel({
    required this.location,
    required this.current,
    required this.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: Location.fromJson(json['location']),
      current: Current.fromJson(json['current']),
      forecast: Forecast.fromJson(json['forecast']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'forecast': forecast.toJson(),
    };
  }
}

class Location {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String tzId;
  final String localtime;

  Location({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtime,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      region: json['region'],
      country: json['country'],
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
      tzId: json['tz_id'],
      localtime: json['localtime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'lat': lat,
      'lon': lon,
      'tz_id': tzId,
      'localtime': localtime,
    };
  }
}

class Current {
  final String lastUpdated;
  final double tempC;
  final double windKph;
  final int humidity;
  final Condition condition;

  Current({
    required this.lastUpdated,
    required this.tempC,
    required this.windKph,
    required this.humidity,
    required this.condition,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      lastUpdated: json['last_updated'],
      tempC: json['temp_c']?.toDouble(),
      windKph: json['wind_kph']?.toDouble(),
      humidity: json['humidity'],
      condition: Condition.fromJson(json['condition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_updated': lastUpdated,
      'temp_c': tempC,
      'wind_kph': windKph,
      'humidity': humidity,
      'condition': condition.toJson(),
    };
  }
}

class Condition {
  final String text;
  final String icon;
  final int code;

  Condition({required this.text, required this.icon, required this.code});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'],
      icon: json['icon'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'icon': icon, 'code': code};
  }
}

class Forecast {
  final List<ForecastDay> forecastday;

  Forecast({required this.forecastday});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      forecastday: (json['forecastday'] as List)
          .map((e) => ForecastDay.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'forecastday': forecastday.map((e) => e.toJson()).toList()};
  }
}

class ForecastDay {
  final String date;
  final Day day;
  final Astro astro;
  final List<Hour> hour;

  ForecastDay({
    required this.date,
    required this.day,
    required this.astro,
    required this.hour,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      day: Day.fromJson(json['day']),
      astro: Astro.fromJson(json['astro']),
      hour: (json['hour'] as List).map((e) => Hour.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day.toJson(),
      'astro': astro.toJson(),
      'hour': hour.map((e) => e.toJson()).toList(),
    };
  }
}

class Day {
  final double maxtempC;
  final double mintempC;
  final Condition condition;

  Day({
    required this.maxtempC,
    required this.mintempC,
    required this.condition,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      maxtempC: json['maxtemp_c']?.toDouble(),
      mintempC: json['mintemp_c']?.toDouble(),
      condition: Condition.fromJson(json['condition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxtemp_c': maxtempC,
      'mintemp_c': mintempC,
      'condition': condition.toJson(),
    };
  }
}

class Astro {
  final String sunrise;
  final String sunset;

  Astro({required this.sunrise, required this.sunset});

  factory Astro.fromJson(Map<String, dynamic> json) {
    return Astro(sunrise: json['sunrise'], sunset: json['sunset']);
  }

  Map<String, dynamic> toJson() {
    return {'sunrise': sunrise, 'sunset': sunset};
  }
}

class Hour {
  final String time;
  final double tempC;
  final Condition condition;

  Hour({required this.time, required this.tempC, required this.condition});

  factory Hour.fromJson(Map<String, dynamic> json) {
    return Hour(
      time: json['time'],
      tempC: json['temp_c']?.toDouble(),
      condition: Condition.fromJson(json['condition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'time': time, 'temp_c': tempC, 'condition': condition.toJson()};
  }
}
