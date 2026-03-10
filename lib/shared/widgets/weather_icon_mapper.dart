import 'package:flutter/material.dart';

class WeatherIconMapper {
  /// Maps OpenWeather icon codes (e.g., '01d', '01n', '02d') to PNG asset paths
  static String getIconAsset(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/images/sun_774669.png'; // Clear sky (day)
      case '01n':
        return 'assets/images/moon_3614882.png'; // Clear sky (night)
      case '02d':
        return 'assets/images/cloud_15114062.png'; // Few clouds (day)
      case '02n':
        return 'assets/images/cloudy-night_5454103.png'; // Few clouds (night)
      case '03d':
      case '03n':
        return 'assets/images/fewcloud_18176588.png'; // Scattered clouds
      case '04d':
      case '04n':
        return 'assets/images/overcast_5421263.png'; // Broken/Overcast clouds
      case '09d':
      case '09n':
        return 'assets/images/drizzle_16273845.png'; // Shower rain
      case '10d':
      case '10n':
        return 'assets/images/rain_7925375.png'; // Rain
      case '11d':
      case '11n':
        return 'assets/images/thunderstorm_2766177.png'; // Thunderstorm
      case '13d':
      case '13n':
        return 'assets/images/snowfall_6235533.png'; // Snow
      case '50d':
      case '50n':
        return 'assets/images/overcast_5421263.png'; // Mist/Fog
      default:
        return 'assets/images/sun_774669.png'; // Fallback
    }
  }

  /// Get icon color for fallback material icon
  static Color getIconColor(String iconCode) {
    if (iconCode.startsWith('01')) return const Color(0xFFFFA726); // Clear
    if (iconCode.startsWith('02') ||
        iconCode.startsWith('03') ||
        iconCode.startsWith('04'))
      return const Color(0xFF90CAF9); // Clouds
    if (iconCode.startsWith('09') || iconCode.startsWith('10'))
      return const Color(0xFF4682B4); // Rain
    if (iconCode.startsWith('11')) return const Color(0xFFFFD700); // Thunder
    if (iconCode.startsWith('13')) return const Color(0xFFE0E0E0); // Snow
    return const Color(0xFF9E9E9E); // Default/Fog
  }

  /// Get a large weather icon widget with floating animation using PNG assets
  static Widget getLargeIcon(String iconCode, {double size = 80}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -6 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Image.asset(
              getIconAsset(iconCode),
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                iconCode.endsWith('n')
                    ? Icons.nightlight_round
                    : Icons.wb_sunny_rounded,
                size: size,
                color: getIconColor(iconCode),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get a small weather icon widget (for list items, etc.)
  static Widget getSmallIcon(String iconCode, {double size = 40}) {
    return Image.asset(
      getIconAsset(iconCode),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        iconCode.endsWith('n')
            ? Icons.nightlight_round
            : Icons.wb_sunny_rounded,
        size: size,
        color: getIconColor(iconCode),
      ),
    );
  }
}
