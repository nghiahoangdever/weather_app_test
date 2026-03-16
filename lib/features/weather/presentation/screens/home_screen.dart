import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../core/constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/responsive_helper.dart';
import '../../../../features/settings/providers/settings_providers.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/weather_error_widget.dart';
import '../../../../shared/widgets/weather_icon_mapper.dart';
import '../providers/weather_providers.dart';
import '../../data/weather_models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroController;
  late final AnimationController _cardsController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );


    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final savedCities = ref.read(savedCitiesProvider);
    final selectedIndex = ref.read(selectedCityIndexProvider);
    final locale = ref.read(localeProvider);

    if (savedCities.isNotEmpty && selectedIndex < savedCities.length) {
      final city = savedCities[selectedIndex];
      await ref.read(weatherNotifierProvider.notifier).fetchWeather(
            city.location.lat,
            city.location.lon,
            forceRefresh: true,
            lang: locale.languageCode,
          );
    } else {
      await ref.read(weatherNotifierProvider.notifier).fetchWeather(
            ApiConstants.defaultLat,
            ApiConstants.defaultLon,
            forceRefresh: true,
            lang: locale.languageCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final locale = ref.watch(localeProvider);
    final tempUnit = ref.watch(temperatureUnitProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.primaryDark,
                    AppColors.primaryDark.withValues(alpha: 0.8),
                    const Color(0xFF040924), // Even darker for bottom
                  ]
                : [
                    const Color(0xFF1E88E5), // Blue top
                    const Color(0xFF42A5F5), // Lighter middle
                    const Color(0xFF64B5F6), // Soft sky blue bottom
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, weatherState, l10n, locale),
              // Content
              Expanded(
                child: _buildContent(
                    context, weatherState, l10n, tempUnit, isDark),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n),
    );
  }

  Widget _buildHeader(BuildContext context, WeatherState weatherState,
      AppLocalizations l10n, Locale locale) {
    final cityName = weatherState.weather?.location.name ?? '---';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City name
          Expanded(
            child: Text(
              cityName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Language toggle
          GestureDetector(
            onTap: () {
              final newLocale = locale.languageCode == 'en'
                  ? const Locale('vi')
                  : const Locale('en');
              ref.read(localeProvider.notifier).setLocale(newLocale);
              // Re-fetch weather with new language
              if (weatherState.weather != null) {
                ref.read(weatherNotifierProvider.notifier).fetchWeather(
                      weatherState.weather!.location.lat,
                      weatherState.weather!.location.lon,
                      forceRefresh: true,
                      lang: newLocale.languageCode,
                    );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                locale.languageCode.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search icon
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.search),
            icon: const Icon(Icons.search_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState weatherState,
      AppLocalizations l10n, TemperatureUnit tempUnit, bool isDark) {
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    final isWide = !ResponsiveHelper.isMobile(context);

    if (weatherState.status == WeatherStatus.loading &&
        weatherState.weather == null) {
      return ResponsiveCenter(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            children: const [
              WeatherShimmerHero(),
              WeatherShimmerCards(),
            ],
          ),
        ),
      );
    }

    if (weatherState.status == WeatherStatus.error &&
        weatherState.weather == null) {
      return WeatherErrorWidget(
        message: weatherState.errorMessage ?? l10n.apiError,
        onRetry: _onRefresh,
      );
    }

    final weather = weatherState.weather;
    if (weather == null) {
      return WeatherErrorWidget(
        message: l10n.apiError,
        onRetry: _onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ResponsiveCenter(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(weather, tempUnit, l10n),
              const SizedBox(height: 24),
              // On tablet/desktop: hourly & daily side by side
              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHourlyForecast(weather, tempUnit, l10n, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDailyForecast(weather, tempUnit, l10n, isDark),
                    ),
                  ],
                ),
              ] else ...[
                // Mobile: stacked
                _buildHourlyForecast(weather, tempUnit, l10n, isDark),
                const SizedBox(height: 20),
                _buildDailyForecast(weather, tempUnit, l10n, isDark),
              ],
              const SizedBox(height: 20),
              // Weather Stats Grid
              _buildStatsGrid(weather, l10n, isDark, context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      Weather weather, TemperatureUnit tempUnit, AppLocalizations l10n) {
    final current = weather.current;
    final isCelsius = tempUnit == TemperatureUnit.celsius;
    final temp = isCelsius ? current.tempCelsius : current.tempFahrenheit;
    
    // Use today's daily forecast for accurate high/low, fallback to current
    final hasDaily = weather.dailyForecast.isNotEmpty;
    final high = isCelsius 
        ? (hasDaily ? weather.dailyForecast.first.tempMaxCelsius : current.tempMaxCelsius)
        : (hasDaily ? weather.dailyForecast.first.tempMaxFahrenheit : current.tempMaxFahrenheit);
    final low = isCelsius 
        ? (hasDaily ? weather.dailyForecast.first.tempMinCelsius : current.tempMinCelsius)
        : (hasDaily ? weather.dailyForecast.first.tempMinFahrenheit : current.tempMinFahrenheit);
        
    final unit = isCelsius ? '°C' : '°F';

    return FadeTransition(
      opacity: _heroController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _heroController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Weather Icon
            WeatherIconMapper.getLargeIcon(current.icon, size: 72),
            const SizedBox(height: 12),
            // Temperature
            Text(
              '${temp.round()}$unit',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            // Condition
            Text(
              current.description.isNotEmpty
                  ? current.description[0].toUpperCase() +
                      current.description.substring(1)
                  : '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            // High / Low
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.high}: ${high.round()}$unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${l10n.low}: ${low.round()}$unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(Weather weather, TemperatureUnit tempUnit,
      AppLocalizations l10n, bool isDark) {
    return _buildStaggeredCard(
      index: 0,
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  l10n.hourlyForecast,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.hourlyForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final hourly = weather.hourlyForecast[index];
                  final isCelsius = tempUnit == TemperatureUnit.celsius;
                  final temp = isCelsius
                      ? hourly.tempCelsius
                      : hourly.tempFahrenheit;
                  final timeStr =
                      index == 0 ? l10n.now : DateFormat.Hm().format(hourly.dateTime);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.white70,
                        ),
                      ),
                      WeatherIconMapper.getSmallIcon(
                        hourly.icon,
                        size: 28,
                      ),
                      Text(
                        '${temp.round()}°',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecast(Weather weather, TemperatureUnit tempUnit,
      AppLocalizations l10n, bool isDark) {
    final locale = ref.read(localeProvider);
    return _buildStaggeredCard(
      index: 1,
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  l10n.dailyForecast,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Weather tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.translate('weatherTip1'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...weather.dailyForecast.asMap().entries.map((entry) {
              final daily = entry.value;
              final isCelsius = tempUnit == TemperatureUnit.celsius;
              final high =
                  isCelsius ? daily.tempMaxCelsius : daily.tempMaxFahrenheit;
              final low =
                  isCelsius ? daily.tempMinCelsius : daily.tempMinFahrenheit;
              final dayName = DateFormat.E(locale.languageCode)
                  .format(daily.date);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    WeatherIconMapper.getSmallIcon(
                      daily.icon,
                      size: 22,
                    ),
                    if (daily.pop != null && daily.pop! > 0.1) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${(daily.pop! * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${low.round()}°',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.white60,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Temperature bar
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF64B5F6),
                            AppColors.accent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${high.round()}°',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
      Weather weather, AppLocalizations l10n, bool isDark, BuildContext context) {
    final current = weather.current;
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(
        current.sunrise * 1000);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(
        current.sunset * 1000);

    final gridColumns = ResponsiveHelper.statsGridColumns(context);
    final aspectRatio = ResponsiveHelper.statsChildAspectRatio(context);

    final stats = [
      _StatItem(l10n.humidity, '${current.humidity}%', Icons.water_drop_rounded),
      _StatItem(l10n.wind, '${current.windSpeed.toStringAsFixed(1)} m/s',
          Icons.air_rounded),
      _StatItem(
          l10n.feelsLike,
          '${current.feelsLikeCelsius.round()}°',
          Icons.thermostat_rounded),
      _StatItem(
          l10n.airQuality,
          _aqiLabel(current.aqi, l10n),
          Icons.air_outlined,
          valueColor: _aqiColor(current.aqi),
          advice: _aqiAdvice(current.aqi, l10n)),
      _StatItem(l10n.sunrise, DateFormat.Hm().format(sunriseTime),
          Icons.wb_twilight_rounded),
      _StatItem(l10n.sunset, DateFormat.Hm().format(sunsetTime),
          Icons.nights_stay_rounded),
    ];

    return _buildStaggeredCard(
      index: 2,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      stat.icon,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        stat.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.white60,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: stat.valueColor ?? Colors.white,
                  ),
                ),
                if (stat.advice != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        stat.advice!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaggeredCard({required int index, required Widget child}) {
    final delay = index * 0.15;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _cardsController,
        curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _cardsController,
          curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryDark.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.wb_sunny_rounded,
                label: l10n.weather,
                isSelected: true,
                isDark: isDark,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.format_list_bulleted_rounded,
                label: l10n.locations,
                isSelected: false,
                isDark: isDark,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.cities),
              ),
              _buildNavItem(
                icon: Icons.settings_rounded,
                label: l10n.settingsTitle,
                isSelected: false,
                isDark: isDark,
                onTap: () {
                  _showSettingsSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? AppColors.accent
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final l10n = AppLocalizations.of(context);
          final locale = ref.watch(localeProvider);
          final themeMode = ref.watch(themeModeProvider);
          final tempUnit = ref.watch(temperatureUnitProvider);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.settingsTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // Language
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'vi', label: Text('VI')),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (selected) {
                      ref.read(localeProvider.notifier)
                          .setLocale(Locale(selected.first));
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                // Temperature Unit
                ListTile(
                  leading: const Icon(Icons.thermostat_rounded),
                  title: Text(l10n.temperatureUnit),
                  trailing: SegmentedButton<TemperatureUnit>(
                    segments: const [
                      ButtonSegment(
                          value: TemperatureUnit.celsius, label: Text('°C')),
                      ButtonSegment(
                          value: TemperatureUnit.fahrenheit, label: Text('°F')),
                    ],
                    selected: {tempUnit},
                    onSelectionChanged: (selected) {
                      ref.read(temperatureUnitProvider.notifier)
                          .setUnit(selected.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                // Dark Mode
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: Text(l10n.darkMode),
                  value: themeMode == ThemeMode.dark,
                  activeTrackColor: AppColors.accent,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier)
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.aboutApp),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.of(context).pushNamed(AppRouter.aboutUs);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  /// AQI level label (localized)
  String _aqiLabel(int? aqi, AppLocalizations l10n) {
    switch (aqi) {
      case 1: return l10n.aqiGood;
      case 2: return l10n.aqiFair;
      case 3: return l10n.aqiModerate;
      case 4: return l10n.aqiPoor;
      case 5: return l10n.aqiVeryPoor;
      default: return '--';
    }
  }

  /// AQI health advice (localized)
  String? _aqiAdvice(int? aqi, AppLocalizations l10n) {
    switch (aqi) {
      case 1: return l10n.aqiAdviceGood;
      case 2: return l10n.aqiAdviceFair;
      case 3: return l10n.aqiAdviceModerate;
      case 4: return l10n.aqiAdvicePoor;
      case 5: return l10n.aqiAdviceVeryPoor;
      default: return null;
    }
  }

  /// AQI level color
  Color _aqiColor(int? aqi) {
    switch (aqi) {
      case 1: return const Color(0xFF4CAF50); // Green
      case 2: return const Color(0xFFCDDC39); // Yellow-green
      case 3: return const Color(0xFFFF9800); // Orange
      case 4: return const Color(0xFFF44336); // Red
      case 5: return const Color(0xFF9C27B0); // Purple
      default: return Colors.white70;
    }
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final String? advice;

  _StatItem(this.label, this.value, this.icon, {this.valueColor, this.advice});
}
