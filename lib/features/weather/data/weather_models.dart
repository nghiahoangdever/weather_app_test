class CitySearchResult {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  CitySearchResult({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });

  factory CitySearchResult.fromJson(Map<String, dynamic> json) {
    return CitySearchResult(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}

class WeatherLocation {
  final String name;
  final String country;
  final double lat;
  final double lon;

  WeatherLocation({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    return WeatherLocation(
      name: json['name'] ?? '',
      country: sys['country'] ?? '',
      lat: (json['coord']?['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['coord']?['lon'] as num?)?.toDouble() ?? 0,
    );
  }

  factory WeatherLocation.fromStoredJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
      };

  String get cacheKey => '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
}

class CurrentWeather {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final int conditionCode;
  final String icon;
  final double? uvIndex;
  final int sunrise;
  final int sunset;
  final int visibility;
  final double? pressure;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.conditionCode,
    required this.icon,
    this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.visibility,
    this.pressure,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;

    return CurrentWeather(
      temp: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      description: weather['description'] ?? '',
      mainCondition: weather['main'] ?? '',
      conditionCode: weather['id'] as int,
      icon: weather['icon'] ?? '01d',
      sunrise: sys['sunrise'] as int,
      sunset: sys['sunset'] as int,
      visibility: json['visibility'] as int? ?? 10000,
      pressure: (main['pressure'] as num?)?.toDouble(),
    );
  }

  factory CurrentWeather.fromStoredJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      description: json['description'] ?? '',
      mainCondition: json['mainCondition'] ?? '',
      conditionCode: json['conditionCode'] as int,
      icon: json['icon'] ?? '01d',
      uvIndex: (json['uvIndex'] as num?)?.toDouble(),
      sunrise: json['sunrise'] as int,
      sunset: json['sunset'] as int,
      visibility: json['visibility'] as int? ?? 10000,
      pressure: (json['pressure'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'feelsLike': feelsLike,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'description': description,
        'mainCondition': mainCondition,
        'conditionCode': conditionCode,
        'icon': icon,
        'uvIndex': uvIndex,
        'sunrise': sunrise,
        'sunset': sunset,
        'visibility': visibility,
        'pressure': pressure,
      };

  /// Convert Kelvin to Celsius
  double get tempCelsius => temp - 273.15;
  double get feelsLikeCelsius => feelsLike - 273.15;
  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;

  /// Convert Kelvin to Fahrenheit
  double get tempFahrenheit => (temp - 273.15) * 9 / 5 + 32;
  double get feelsLikeFahrenheit => (feelsLike - 273.15) * 9 / 5 + 32;
  double get tempMinFahrenheit => (tempMin - 273.15) * 9 / 5 + 32;
  double get tempMaxFahrenheit => (tempMax - 273.15) * 9 / 5 + 32;
}

class HourlyForecast {
  final DateTime dateTime;
  final double temp;
  final String description;
  final String mainCondition;
  final int conditionCode;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double? pop; // probability of precipitation

  HourlyForecast({
    required this.dateTime,
    required this.temp,
    required this.description,
    required this.mainCondition,
    required this.conditionCode,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.pop,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temp: (main['temp'] as num).toDouble(),
      description: weather['description'] ?? '',
      mainCondition: weather['main'] ?? '',
      conditionCode: weather['id'] as int,
      icon: weather['icon'] ?? '01d',
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      pop: (json['pop'] as num?)?.toDouble(),
    );
  }

  factory HourlyForecast.fromStoredJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] as int),
      temp: (json['temp'] as num).toDouble(),
      description: json['description'] ?? '',
      mainCondition: json['mainCondition'] ?? '',
      conditionCode: json['conditionCode'] as int,
      icon: json['icon'] ?? '01d',
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pop: (json['pop'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dt': dateTime.millisecondsSinceEpoch,
        'temp': temp,
        'description': description,
        'mainCondition': mainCondition,
        'conditionCode': conditionCode,
        'icon': icon,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'pop': pop,
      };

  double get tempCelsius => temp - 273.15;
  double get tempFahrenheit => (temp - 273.15) * 9 / 5 + 32;
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String mainCondition;
  final int conditionCode;
  final String icon;
  final double? pop;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.mainCondition,
    required this.conditionCode,
    required this.icon,
    this.pop,
  });

  factory DailyForecast.fromStoredJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      description: json['description'] ?? '',
      mainCondition: json['mainCondition'] ?? '',
      conditionCode: json['conditionCode'] as int,
      icon: json['icon'] ?? '01d',
      pop: (json['pop'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'description': description,
        'mainCondition': mainCondition,
        'conditionCode': conditionCode,
        'icon': icon,
        'pop': pop,
      };

  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;
  double get tempMinFahrenheit => (tempMin - 273.15) * 9 / 5 + 32;
  double get tempMaxFahrenheit => (tempMax - 273.15) * 9 / 5 + 32;
}

class Weather {
  final WeatherLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final DateTime fetchedAt;

  Weather({
    required this.location,
    required this.current,
    required this.hourlyForecast,
    required this.dailyForecast,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory Weather.fromStoredJson(Map<String, dynamic> json) {
    return Weather(
      location: WeatherLocation.fromStoredJson(
          json['location'] as Map<String, dynamic>),
      current: CurrentWeather.fromStoredJson(
          json['current'] as Map<String, dynamic>),
      hourlyForecast: (json['hourlyForecast'] as List?)
              ?.map((e) =>
                  HourlyForecast.fromStoredJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyForecast: (json['dailyForecast'] as List?)
              ?.map((e) =>
                  DailyForecast.fromStoredJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fetchedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'current': current.toJson(),
        'hourlyForecast': hourlyForecast.map((e) => e.toJson()).toList(),
        'dailyForecast': dailyForecast.map((e) => e.toJson()).toList(),
        'fetchedAt': fetchedAt.millisecondsSinceEpoch,
      };

  String get cacheKey => location.cacheKey;
}
