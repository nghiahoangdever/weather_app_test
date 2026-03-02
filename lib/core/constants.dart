class ApiConstants {
  // OpenWeather API - user will provide their key
  static const String apiKey = '14c0ddd49719054ae81bc724880fd0a9';
  static const String baseUrl = 'https://api.openweathermap.org';

  // Endpoints
  static const String geocodingUrl = '$baseUrl/geo/1.0/direct';
  static const String reverseGeocodingUrl = '$baseUrl/geo/1.0/reverse';
  static const String currentWeatherUrl = '$baseUrl/data/2.5/weather';
  static const String forecastUrl = '$baseUrl/data/2.5/forecast';

  // Cache
  static const int cacheDurationMinutes = 15;

  // Debounce
  static const int debounceDurationMs = 300;

  // Search
  static const int minSearchLength = 2;
  static const int maxSearchResults = 5;

  // Default city
  static const String defaultCity = 'Ho Chi Minh City';
  static const double defaultLat = 10.8231;
  static const double defaultLon = 106.6297;
}
