import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Mencari lokasi berdasarkan nama kota menggunakan Geocoding API Open-Meteo.
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(queryParameters: {
      'name': query.trim(),
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'];
      if (results == null) return [];
      return (results as List)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal mencari lokasi: HTTP ${response.statusCode}');
    }
  }

  /// Mengambil data cuaca dari Weather Forecast API Open-Meteo.
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_weatherBaseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'precipitation',
        'weather_code',
        'wind_speed_10m',
      ].join(','),
      'daily': [
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_max',
        'weather_code',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data cuaca: HTTP ${response.statusCode}');
    }
  }
}
