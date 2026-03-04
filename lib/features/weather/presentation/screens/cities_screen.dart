import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../features/settings/providers/settings_providers.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/weather_icon_mapper.dart';
import '../providers/weather_providers.dart';

class CitiesScreen extends ConsumerWidget {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCities = ref.watch(savedCitiesProvider);
    final selectedIndex = ref.watch(selectedCityIndexProvider);
    final tempUnit = ref.watch(temperatureUnitProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(l10n.savedCities),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.search),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: savedCities.isEmpty
          ? _buildEmptyState(context, l10n, isDark)
          : _buildCityList(
              context, ref, savedCities, selectedIndex, tempUnit, l10n, isDark),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.location_city_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noCities,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.search),
            icon: const Icon(Icons.search_rounded),
            label: Text(l10n.addCity),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityList(
    BuildContext context,
    WidgetRef ref,
    List savedCities,
    int selectedIndex,
    TemperatureUnit tempUnit,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedCities.length,
      itemBuilder: (context, index) {
        final weather = savedCities[index];
        final current = weather.current;
        final isCelsius = tempUnit == TemperatureUnit.celsius;
        final temp =
            isCelsius ? current.tempCelsius : current.tempFahrenheit;
        final isDefault = index == selectedIndex;

        return Dismissible(
          key: ValueKey(weather.location.cacheKey),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.translate('removeCity')),
                    content: Text(
                        l10n.confirmRemoveCity(weather.location.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: Text(l10n.translate('removeCity')),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (direction) {
            ref.read(savedCitiesProvider.notifier).removeCity(index);
            if (selectedIndex >= savedCities.length - 1) {
              ref.read(selectedCityIndexProvider.notifier).state = 0;
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () {
              // Set as selected city and go back
              ref.read(selectedCityIndexProvider.notifier).state = index;
              final storage = ref.read(localStorageServiceProvider);
              storage.saveSelectedCityIndex(index);
              ref.read(weatherNotifierProvider.notifier).fetchWeather(
                    weather.location.lat,
                    weather.location.lon,
                    lang: ref.read(localeProvider).languageCode,
                  );
              Navigator.of(context).pop();
            },
            onLongPress: () {
              // Set as default
              ref.read(savedCitiesProvider.notifier).setDefault(index);
              ref.read(selectedCityIndexProvider.notifier).state = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(l10n.setAsDefaultSnack(weather.location.name)),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                backgroundColor: isDefault
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.8)),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Weather icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: WeatherIconMapper.getIconColor(
                                current.conditionCode)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        WeatherIconMapper.getIcon(current.conditionCode),
                        color: WeatherIconMapper.getIconColor(
                            current.conditionCode),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // City info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  weather.location.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l10n.defaultBadge,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            current.description.isNotEmpty
                                ? current.description[0].toUpperCase() +
                                    current.description.substring(1)
                                : '',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Temperature
                    Text(
                      '${temp.round()}°',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
