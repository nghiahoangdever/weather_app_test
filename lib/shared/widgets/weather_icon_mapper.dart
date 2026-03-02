import 'package:flutter/material.dart';

class WeatherIconMapper {
  /// Maps OpenWeather condition codes to Material Icons
  static IconData getIcon(int conditionCode) {
    if (conditionCode >= 200 && conditionCode < 300) {
      return Icons.flash_on_rounded; // Thunderstorm
    } else if (conditionCode >= 300 && conditionCode < 400) {
      return Icons.grain_rounded; // Drizzle
    } else if (conditionCode >= 500 && conditionCode < 600) {
      return Icons.water_drop_rounded; // Rain
    } else if (conditionCode >= 600 && conditionCode < 700) {
      return Icons.ac_unit_rounded; // Snow
    } else if (conditionCode >= 700 && conditionCode < 800) {
      return Icons.blur_on_rounded; // Atmosphere (fog, mist, etc.)
    } else if (conditionCode == 800) {
      return Icons.wb_sunny_rounded; // Clear sky
    } else if (conditionCode == 801) {
      return Icons.cloud_queue_rounded; // Few clouds
    } else if (conditionCode == 802) {
      return Icons.cloud_rounded; // Scattered clouds
    } else if (conditionCode >= 803) {
      return Icons.cloud_rounded; // Broken/overcast clouds
    }
    return Icons.wb_sunny_rounded;
  }

  /// Get icon color based on condition
  static Color getIconColor(int conditionCode) {
    if (conditionCode >= 200 && conditionCode < 300) {
      return const Color(0xFFFFD700); // Thunderstorm - gold
    } else if (conditionCode >= 300 && conditionCode < 500) {
      return const Color(0xFF87CEEB); // Drizzle/light rain - light blue
    } else if (conditionCode >= 500 && conditionCode < 600) {
      return const Color(0xFF4682B4); // Rain - steel blue
    } else if (conditionCode >= 600 && conditionCode < 700) {
      return const Color(0xFFE0E0E0); // Snow - white/grey
    } else if (conditionCode >= 700 && conditionCode < 800) {
      return const Color(0xFF9E9E9E); // Fog - grey
    } else if (conditionCode == 800) {
      return const Color(0xFFFFA726); // Clear - orange
    } else {
      return const Color(0xFF90CAF9); // Clouds - light blue
    }
  }

  /// Get a large weather icon widget with floating animation
  static Widget getLargeIcon(int conditionCode, {double size = 80}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -6 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Icon(
              getIcon(conditionCode),
              size: size,
              color: getIconColor(conditionCode),
            ),
          ),
        );
      },
    );
  }
}
