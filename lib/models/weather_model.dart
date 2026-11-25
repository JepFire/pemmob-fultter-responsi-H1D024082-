class CurrentWeather {
  final double temperature2m;
  final double relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final DateTime time;

  CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: json['weather_code'] as int,
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final double precipitationProbabilityMax;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final CurrentWeather current;
  final List<DailyWeather> daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final cur = CurrentWeather.fromJson(json['current'] as Map<String, dynamic>);

    final dailyJson = json['daily'] as Map<String, dynamic>;
    final times = (dailyJson['time'] as List).cast<String>();
    final tempMax = (dailyJson['temperature_2m_max'] as List).cast<num>();
    final tempMin = (dailyJson['temperature_2m_min'] as List).cast<num>();
    final rainProb = (dailyJson['precipitation_probability_max'] as List).cast<num>();
    final codes = (dailyJson['weather_code'] as List).cast<int>();

    final dailyList = List.generate(
      times.length,
      (i) => DailyWeather(
        date: DateTime.parse(times[i]),
        temperatureMax: tempMax[i].toDouble(),
        temperatureMin: tempMin[i].toDouble(),
        precipitationProbabilityMax: rainProb[i].toDouble(),
        weatherCode: codes[i],
      ),
    );

    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      current: cur,
      daily: dailyList,
    );
  }
}
