import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ----- Locale Provider -----
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

// ----- Theme Mode Provider -----
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ----- Temperature Unit Provider -----
enum TemperatureUnit { celsius, fahrenheit }

final temperatureUnitProvider =
    StateProvider<TemperatureUnit>((ref) => TemperatureUnit.celsius);
