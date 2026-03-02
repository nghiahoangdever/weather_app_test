import '../../../core/constants.dart';
import 'weather_api_service.dart';
import 'weather_models.dart';

class WeatherRepository {
  final WeatherApiService _apiService;

  // In-memory cache
  final Map<String, Weather> _cache = {};
  final Map<String, DateTime> _timestamps = {};

  WeatherRepository(this._apiService);

  /// Get weather for coordinates with caching
  /// If [forceRefresh] is true, bypasses cache (used by pull-to-refresh)
  Future<Weather> getWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
    String lang = 'en',
  }) async {
    final cacheKey =
        '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

    // Check cache validity
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final lastUpdated = _timestamps[cacheKey];
      if (lastUpdated != null) {
        final elapsed = DateTime.now().difference(lastUpdated);
        if (elapsed.inMinutes < ApiConstants.cacheDurationMinutes) {
          return _cache[cacheKey]!;
        }
      }
    }

    // Fetch from API
    final weather = await _apiService.getWeather(lat, lon, lang: lang);

    // Update cache
    _cache[cacheKey] = weather;
    _timestamps[cacheKey] = DateTime.now();

    return weather;
  }

  /// Search cities (no caching for search - always fresh)
  Future<List<CitySearchResult>> searchCities(String query) {
    return _apiService.searchCities(query);
  }

  /// Clear all cached weather data
  void clearCache() {
    _cache.clear();
    _timestamps.clear();
  }

  /// Remove a specific city from cache
  void removeFromCache(double lat, double lon) {
    final cacheKey =
        '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    _cache.remove(cacheKey);
    _timestamps.remove(cacheKey);
  }
}
