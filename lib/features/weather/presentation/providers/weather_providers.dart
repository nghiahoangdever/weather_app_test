import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/weather_api_service.dart';
import '../../data/weather_repository.dart';
import '../../data/weather_models.dart';
import '../../data/local_storage_service.dart';

// ----- SharedPreferences Provider -----

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// ----- Core Service Providers -----

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  final service = WeatherApiService();
  ref.onDispose(() => service.dispose());
  return service;
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiService = ref.watch(weatherApiServiceProvider);
  return WeatherRepository(apiService);
});

// ----- Weather State -----

enum WeatherStatus { initial, loading, loaded, error }

class WeatherState {
  final WeatherStatus status;
  final Weather? weather;
  final String? errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.errorMessage,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage,
    );
  }
}

// ----- Current Weather Provider -----

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const WeatherState());

  Future<void> fetchWeather(double lat, double lon,
      {bool forceRefresh = false, String lang = 'en'}) async {
    state = state.copyWith(status: WeatherStatus.loading);
    try {
      final weather = await _repository.getWeather(
        lat,
        lon,
        forceRefresh: forceRefresh,
        lang: lang,
      );
      state = WeatherState(status: WeatherStatus.loaded, weather: weather);
    } on WeatherApiException catch (e) {
      state = WeatherState(
        status: WeatherStatus.error,
        errorMessage: e.message,
        weather: state.weather, // Keep old data if available
      );
    } catch (e) {
      state = WeatherState(
        status: WeatherStatus.error,
        errorMessage: e.toString(),
        weather: state.weather,
      );
    }
  }
}

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repository);
});

// ----- Saved Cities Provider -----

class SavedCitiesNotifier extends StateNotifier<List<Weather>> {
  final LocalStorageService _storage;

  SavedCitiesNotifier(this._storage) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    state = _storage.loadCities();
  }

  void _saveToStorage() {
    _storage.saveCities(state);
  }

  void addCity(Weather weather) {
    // Check if city already exists
    final exists = state.any((w) =>
        w.location.cacheKey == weather.location.cacheKey);
    if (!exists) {
      state = [...state, weather];
    } else {
      // Update existing
      state = state.map((w) {
        if (w.location.cacheKey == weather.location.cacheKey) {
          return weather;
        }
        return w;
      }).toList();
    }
    _saveToStorage();
  }

  void removeCity(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state]..removeAt(index);
      _saveToStorage();
    }
  }

  void setDefault(int index) {
    if (index >= 0 && index < state.length) {
      final city = state[index];
      final newList = [...state]..removeAt(index);
      state = [city, ...newList];
      _saveToStorage();
    }
  }

  void updateCity(Weather weather) {
    state = state.map((w) {
      if (w.location.cacheKey == weather.location.cacheKey) {
        return weather;
      }
      return w;
    }).toList();
    _saveToStorage();
  }
}

final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, List<Weather>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SavedCitiesNotifier(storage);
});

final selectedCityIndexProvider = StateProvider<int>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.loadSelectedCityIndex();
});

// ----- Search Providers -----

enum SearchStatus { idle, loading, loaded, error }

class SearchState {
  final SearchStatus status;
  final List<CitySearchResult> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.results = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<CitySearchResult>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final WeatherRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.length < 2) {
      state = const SearchState(status: SearchStatus.idle);
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final results = await _repository.searchCities(query);
      state = SearchState(
        status: SearchStatus.loaded,
        results: results,
      );
    } catch (e) {
      state = SearchState(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    state = const SearchState(status: SearchStatus.idle);
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return SearchNotifier(repository);
});
