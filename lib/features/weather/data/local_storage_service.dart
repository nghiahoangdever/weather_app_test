import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_models.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  // Storage keys
  static const String _savedCitiesKey = 'saved_cities';
  static const String _selectedCityIndexKey = 'selected_city_index';
  static const String _localeKey = 'locale';
  static const String _themeModeKey = 'theme_mode';
  static const String _temperatureUnitKey = 'temperature_unit';

  LocalStorageService(this._prefs);

  // ----- Saved Cities -----

  Future<void> saveCities(List<Weather> cities) async {
    final jsonList = cities.map((w) => jsonEncode(w.toJson())).toList();
    await _prefs.setStringList(_savedCitiesKey, jsonList);
  }

  List<Weather> loadCities() {
    final jsonList = _prefs.getStringList(_savedCitiesKey);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList
          .map((s) => Weather.fromStoredJson(
              jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading saved cities: $e');
      return [];
    }
  }

  // ----- Selected City Index -----

  Future<void> saveSelectedCityIndex(int index) async {
    await _prefs.setInt(_selectedCityIndexKey, index);
  }

  int loadSelectedCityIndex() {
    return _prefs.getInt(_selectedCityIndexKey) ?? 0;
  }

  // ----- Locale -----

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
  }

  String loadLocale() {
    return _prefs.getString(_localeKey) ?? 'en';
  }

  // ----- Theme Mode -----

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode loadThemeMode() {
    final name = _prefs.getString(_themeModeKey);
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  // ----- Temperature Unit -----

  Future<void> saveTemperatureUnit(String unit) async {
    await _prefs.setString(_temperatureUnitKey, unit);
  }

  String loadTemperatureUnit() {
    return _prefs.getString(_temperatureUnitKey) ?? 'celsius';
  }
}
