# 🔄 State Machine Diagrams — Weather App

Tài liệu mô tả **sơ đồ state machine** cho tất cả thành phần quản lý trạng thái trong ứng dụng.

---

## 📑 Mục Lục

1. [App Navigation](#1-app-navigation)
2. [WeatherNotifier](#2-weathernotifier--trạng-thái-thời-tiết-chính)
3. [SearchNotifier](#3-searchnotifier--tìm-kiếm-thành-phố)
4. [SavedCitiesNotifier](#4-savedcitiesnotifier--danh-sách-thành-phố-đã-lưu)
5. [SplashScreen Flow](#5-splashscreen--luồng-khởi-tạo)
6. [LocaleNotifier](#6-localenotifier--ngôn-ngữ)
7. [ThemeModeNotifier](#7-thememodenotifier--chế-độ-sángtối)
8. [TemperatureUnitNotifier](#8-temperatureunitnotifier--đơn-vị-nhiệt-độ)
9. [WeatherRepository Cache](#9-weatherrepository--caching-layer)
10. [SearchScreen Interaction](#10-searchscreen--luồng-tương-tác)
11. [Provider Dependency Graph](#11-provider-dependency-graph)

---

## 1. App Navigation

Luồng điều hướng giữa các màn hình chính.

```mermaid
stateDiagram-v2
    [*] --> SplashScreen : App Launch
    SplashScreen --> HomeScreen : pushReplacement\n(after loading)

    HomeScreen --> SearchScreen : pushNamed /search
    HomeScreen --> CitiesScreen : pushNamed /cities
    HomeScreen --> SettingsSheet : showModalBottomSheet

    SearchScreen --> HomeScreen : pop()\n(after city selected)
    SearchScreen --> HomeScreen : pop()\n(back button)

    CitiesScreen --> HomeScreen : pop()\n(city tapped)
    CitiesScreen --> SearchScreen : pushNamed /search\n(add city)

    SettingsSheet --> HomeScreen : dismiss
```

> **File:** `lib/core/app_router.dart`

---

## 2. WeatherNotifier — Trạng thái thời tiết chính

Quản lý việc tải dữ liệu thời tiết cho thành phố hiện tại.

```mermaid
stateDiagram-v2
    [*] --> Initial : WeatherNotifier created

    Initial --> Loading : fetchWeather()
    Loading --> Loaded : API success\n[weather != null]
    Loading --> Error : API exception\n[keeps old weather data]

    Loaded --> Loading : fetchWeather()\n(refresh / city change)
    Error --> Loading : fetchWeather()\n(retry)

    state Initial {
        [*] --> idle
        note right of idle : status = initial\nweather = null
    }

    state Loading {
        [*] --> fetching
        note right of fetching : status = loading
    }

    state Loaded {
        [*] --> displaying
        note right of displaying : status = loaded\nweather = Weather object
    }

    state Error {
        [*] --> failed
        note right of failed : status = error\nerrorMessage set\nweather may persist
    }
```

> **Provider:** `weatherNotifierProvider`
> **File:** `lib/features/weather/presentation/providers/weather_providers.dart`

---

## 3. SearchNotifier — Tìm kiếm thành phố

Quản lý trạng thái tìm kiếm thành phố qua Geocoding API.

```mermaid
stateDiagram-v2
    [*] --> Idle : SearchNotifier created

    Idle --> Loading : search(query)\n[query.length >= 2]
    Idle --> Idle : search(query)\n[query.length < 2]

    Loading --> Loaded : API success\n[results list]
    Loading --> Error : API exception

    Loaded --> Loading : search(newQuery)
    Loaded --> Idle : clear()

    Error --> Loading : search(query)\n[retry]
    Error --> Idle : clear()

    state Idle {
        [*] --> waiting
        note right of waiting : status = idle\nresults = []
    }

    state Loaded {
        [*] --> results_ready
        note right of results_ready : status = loaded\nresults = List of CitySearchResult
    }
```

> **Provider:** `searchNotifierProvider`
> **File:** `lib/features/weather/presentation/providers/weather_providers.dart`

---

## 4. SavedCitiesNotifier — Danh sách thành phố đã lưu

Quản lý CRUD cho danh sách thành phố với persistence qua SharedPreferences.

```mermaid
stateDiagram-v2
    [*] --> Empty : Notifier created\n[no saved data]
    [*] --> HasCities : Notifier created\n[loaded from SharedPreferences]

    Empty --> HasCities : addCity(weather)

    HasCities --> HasCities : addCity(weather)\n[add new / update existing]
    HasCities --> HasCities : removeCity(index)
    HasCities --> HasCities : setDefault(index)\n[moves city to position 0]
    HasCities --> HasCities : updateCity(weather)
    HasCities --> Empty : removeCity()\n[last city removed]

    state HasCities {
        [*] --> persisted
        note right of persisted : state = List of Weather\nAuto-save to SharedPreferences\non every mutation
    }
```

> **Provider:** `savedCitiesProvider`
> **File:** `lib/features/weather/presentation/providers/weather_providers.dart`

---

## 5. SplashScreen — Luồng khởi tạo

Logic quyết định khi khởi động ứng dụng.

```mermaid
stateDiagram-v2
    [*] --> AnimationStart : initState()

    AnimationStart --> CheckSavedCities : Start fade + scale animation

    state CheckSavedCities {
        [*] --> check
        check --> ReturningUser : savedCities.isNotEmpty
        check --> FirstLaunch : savedCities.isEmpty
    }

    state ReturningUser {
        [*] --> load_selected
        load_selected --> FetchWeather : fetchWeather(selectedCity)
    }

    state FirstLaunch {
        [*] --> get_gps
        get_gps --> GPS_Success : position != null
        get_gps --> GPS_Fallback : position == null\n[use default HCM coords]
        GPS_Success --> FetchWeather : fetchWeather(gps lat/lon)
        GPS_Fallback --> FetchWeather : fetchWeather(default)
    }

    FetchWeather --> WaitMinTime : Wait 2500ms total
    WaitMinTime --> Navigate : pushReplacementNamed /home
```

> **File:** `lib/features/weather/presentation/screens/splash_screen.dart`

---

## 6. LocaleNotifier — Ngôn ngữ

Chuyển đổi ngôn ngữ EN ↔ VI.

```mermaid
stateDiagram-v2
    [*] --> English : loadLocale() == 'en'
    [*] --> Vietnamese : loadLocale() == 'vi'

    English --> Vietnamese : setLocale(vi) / toggle()
    Vietnamese --> English : setLocale(en) / toggle()

    note right of English : Locale('en')\nSaved to SharedPreferences
    note right of Vietnamese : Locale('vi')\nSaved to SharedPreferences
```

> **Provider:** `localeProvider`
> **File:** `lib/features/settings/providers/settings_providers.dart`

---

## 7. ThemeModeNotifier — Chế độ sáng/tối

```mermaid
stateDiagram-v2
    [*] --> Dark : loadThemeMode() == dark\n(default)
    [*] --> Light : loadThemeMode() == light

    Dark --> Light : setThemeMode(light) / toggle()
    Light --> Dark : setThemeMode(dark) / toggle()

    note right of Dark : ThemeMode.dark\nSaved to SharedPreferences
    note right of Light : ThemeMode.light\nSaved to SharedPreferences
```

> **Provider:** `themeModeProvider`
> **File:** `lib/features/settings/providers/settings_providers.dart`

---

## 8. TemperatureUnitNotifier — Đơn vị nhiệt độ

```mermaid
stateDiagram-v2
    [*] --> Celsius : loadUnit() == 'celsius'\n(default)
    [*] --> Fahrenheit : loadUnit() == 'fahrenheit'

    Celsius --> Fahrenheit : setUnit(fahrenheit)
    Fahrenheit --> Celsius : setUnit(celsius)

    note right of Celsius : TemperatureUnit.celsius\nSaved to SharedPreferences
    note right of Fahrenheit : TemperatureUnit.fahrenheit\nSaved to SharedPreferences
```

> **Provider:** `temperatureUnitProvider`
> **File:** `lib/features/settings/providers/settings_providers.dart`

---

## 9. WeatherRepository — Caching Layer

Bộ nhớ đệm trong bộ nhớ (in-memory cache) cho dữ liệu Weather API.

```mermaid
stateDiagram-v2
    [*] --> CacheEmpty : Repository created

    state getWeather {
        [*] --> CheckCache
        CheckCache --> ReturnCached : cache hit\n[< 10 min old & !forceRefresh]
        CheckCache --> FetchFromAPI : cache miss / expired / forceRefresh

        FetchFromAPI --> UpdateCache : API success
        FetchFromAPI --> ThrowError : API failure

        UpdateCache --> ReturnFresh : return Weather
    }

    CacheEmpty --> HasCache : after first fetch
    HasCache --> HasCache : subsequent fetches
    HasCache --> CacheEmpty : clearCache()
```

> **File:** `lib/features/weather/data/weather_repository.dart`

---

## 10. SearchScreen — Luồng tương tác

Kết hợp trạng thái UI local (`_isLoadingWeather`) và `SearchNotifier`.

```mermaid
stateDiagram-v2
    [*] --> IdleSearch : Screen opened\n[auto-focus input]

    IdleSearch --> Debouncing : User types\n[query < 2 chars: stay idle]
    Debouncing --> SearchLoading : Debounce timer fires\n[query >= 2 chars]

    SearchLoading --> ResultsShown : API success\n[results not empty]
    SearchLoading --> EmptyResults : API success\n[results empty]
    SearchLoading --> SearchError : API failure

    ResultsShown --> Debouncing : User types new query
    ResultsShown --> LoadingWeather : User taps a city

    LoadingWeather --> NavigateBack : Weather fetched\n[city added, pop()]
    LoadingWeather --> ShowSnackbar : Fetch failed\n[show error snackbar]
    ShowSnackbar --> ResultsShown : Return to results

    EmptyResults --> Debouncing : User types new query
    SearchError --> SearchLoading : onRetry tapped

    ResultsShown --> IdleSearch : Clear button tapped
    EmptyResults --> IdleSearch : Clear button tapped
```

> **File:** `lib/features/weather/presentation/screens/search_screen.dart`

---

## 11. Provider Dependency Graph

Sơ đồ tổng quan cách các Provider phụ thuộc vào nhau.

```mermaid
flowchart TB
    SP["SharedPreferences\n(initialized in main)"] --> LSS["LocalStorageService"]

    LSS --> SC["SavedCitiesNotifier\n(List of Weather)"]
    LSS --> LN["LocaleNotifier\n(Locale)"]
    LSS --> TMN["ThemeModeNotifier\n(ThemeMode)"]
    LSS --> TUN["TemperatureUnitNotifier\n(TemperatureUnit)"]
    LSS --> SCI["selectedCityIndexProvider\n(int)"]

    WAS["WeatherApiService\n(HTTP Client)"] --> WR["WeatherRepository\n(with Cache)"]
    WR --> WN["WeatherNotifier\n(WeatherState)"]
    WR --> SN["SearchNotifier\n(SearchState)"]

    subgraph Screens
        SS["SplashScreen"]
        HS["HomeScreen"]
        SrS["SearchScreen"]
        CS["CitiesScreen"]
    end

    WN --> SS
    SC --> SS
    LN --> SS
    SCI --> SS

    WN --> HS
    LN --> HS
    TUN --> HS
    TMN --> HS

    SN --> SrS
    WR --> SrS
    SC --> SrS
    WN --> SrS

    SC --> CS
    SCI --> CS
    TUN --> CS
    WN --> CS

    style SP fill:#4a90d9,color:#fff
    style WAS fill:#e67e22,color:#fff
    style WR fill:#e67e22,color:#fff
    style LSS fill:#4a90d9,color:#fff
```

---

## 📄 Ghi Chú

- Tất cả sơ đồ sử dụng **Mermaid** — có thể render trực tiếp trên GitHub, GitLab, hoặc bất kỳ markdown viewer nào hỗ trợ Mermaid.
- Mỗi `StateNotifier` persist trạng thái qua `SharedPreferences` thông qua `LocalStorageService`.
- `WeatherRepository` sử dụng in-memory cache với TTL 10 phút, có thể bypass bằng `forceRefresh: true`.
