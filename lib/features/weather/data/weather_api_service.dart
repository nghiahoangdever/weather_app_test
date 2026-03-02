import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';
import 'weather_models.dart';

class WeatherApiService {
  final http.Client _client;
  String _apiKey;

  WeatherApiService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? ApiConstants.apiKey;

  void updateApiKey(String key) {
    _apiKey = key;
  }

  /// Search cities using OpenWeather Geocoding API
  Future<List<CitySearchResult>> searchCities(String query) async {
    if (query.length < ApiConstants.minSearchLength) {
      return [];
    }

    final uri = Uri.parse(ApiConstants.geocodingUrl).replace(
      queryParameters: {
        'q': query,
        'limit': ApiConstants.maxSearchResults.toString(),
        'appid': _apiKey,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CitySearchResult.fromJson(e)).toList();
    } else {
      throw WeatherApiException(
        'Failed to search cities: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Get current weather by coordinates
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon,
      {String lang = 'en'}) async {
    final uri = Uri.parse(ApiConstants.currentWeatherUrl).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'lang': lang,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw WeatherApiException(
        'Failed to fetch current weather: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Get 5-day/3-hour forecast by coordinates
  Future<Map<String, dynamic>> getForecast(double lat, double lon,
      {String lang = 'en'}) async {
    final uri = Uri.parse(ApiConstants.forecastUrl).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'lang': lang,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw WeatherApiException(
        'Failed to fetch forecast: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Fetch complete weather data (current + forecast) and parse into Weather model
  Future<Weather> getWeather(double lat, double lon, {String lang = 'en'}) async {
    // Fetch both endpoints concurrently
    final results = await Future.wait([
      getCurrentWeather(lat, lon, lang: lang),
      getForecast(lat, lon, lang: lang),
    ]);

    final currentData = results[0];
    final forecastData = results[1];

    // Parse current weather
    final location = WeatherLocation.fromJson(currentData);
    final current = CurrentWeather.fromJson(currentData);

    // Parse hourly forecast (next 24 hours = 8 entries at 3-hour intervals)
    final List<dynamic> forecastList = forecastData['list'];
    final hourlyForecast = forecastList
        .take(8)
        .map((e) => HourlyForecast.fromJson(e))
        .toList();

    // Parse daily forecast (group by day, take 7 days)
    final dailyForecast = _extractDailyForecasts(forecastList);

    return Weather(
      location: location,
      current: current,
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }

  /// Extract daily forecasts from 3-hourly data
  List<DailyForecast> _extractDailyForecasts(List<dynamic> forecastList) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in forecastList) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final dateKey = '${dt.year}-${dt.month}-${dt.day}';
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item as Map<String, dynamic>);
    }

    final dailies = <DailyForecast>[];

    for (final entry in grouped.entries) {
      final items = entry.value;
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      double totalPop = 0;

      // Find the midday entry for icon/description (or first one)
      Map<String, dynamic> representativeItem = items.first;
      for (final item in items) {
        final main = item['main'] as Map<String, dynamic>;
        final temp = (main['temp'] as num).toDouble();
        final tempMin = (main['temp_min'] as num).toDouble();
        final tempMax = (main['temp_max'] as num).toDouble();

        if (tempMin < minTemp) minTemp = tempMin;
        if (tempMax > maxTemp) maxTemp = tempMax;
        if (temp > (representativeItem['main']['temp'] as num)) {
          representativeItem = item;
        }
        totalPop += (item['pop'] as num?)?.toDouble() ?? 0;
      }

      final weather =
          (representativeItem['weather'] as List).first as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch(
          (items.first['dt'] as int) * 1000);

      dailies.add(DailyForecast(
        date: dt,
        tempMin: minTemp,
        tempMax: maxTemp,
        description: weather['description'] ?? '',
        mainCondition: weather['main'] ?? '',
        conditionCode: weather['id'] as int,
        icon: weather['icon'] ?? '01d',
        pop: items.isNotEmpty ? totalPop / items.length : null,
      ));
    }

    // Skip today, return next 7 days
    if (dailies.length > 1) {
      return dailies.sublist(1).take(7).toList();
    }
    return dailies;
  }

  void dispose() {
    _client.close();
  }
}

class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'WeatherApiException: $message (status: $statusCode)';
}
