import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/data/local_storage_service.dart';
import '../../weather/presentation/providers/weather_providers.dart';

// ----- Locale Provider -----

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocaleNotifier(storage);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocalStorageService _storage;

  LocaleNotifier(this._storage)
      : super(Locale(_storage.loadLocale()));

  void setLocale(Locale locale) {
    state = locale;
    _storage.saveLocale(locale.languageCode);
  }

  void toggle() {
    final newLocale = state.languageCode == 'en'
        ? const Locale('vi')
        : const Locale('en');
    setLocale(newLocale);
  }
}

// ----- Theme Mode Provider -----

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeModeNotifier(this._storage)
      : super(_storage.loadThemeMode());

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _storage.saveThemeMode(mode);
  }

  void toggle() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

// ----- Temperature Unit Provider -----

enum TemperatureUnit { celsius, fahrenheit }

final temperatureUnitProvider =
    StateNotifierProvider<TemperatureUnitNotifier, TemperatureUnit>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TemperatureUnitNotifier(storage);
});

class TemperatureUnitNotifier extends StateNotifier<TemperatureUnit> {
  final LocalStorageService _storage;

  TemperatureUnitNotifier(this._storage)
      : super(_storage.loadTemperatureUnit() == 'fahrenheit'
            ? TemperatureUnit.fahrenheit
            : TemperatureUnit.celsius);

  void setUnit(TemperatureUnit unit) {
    state = unit;
    _storage.saveTemperatureUnit(unit.name);
  }
}
