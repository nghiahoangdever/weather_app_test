import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../features/settings/providers/settings_providers.dart';
import '../../../../shared/widgets/weather_error_widget.dart';
import '../../data/weather_models.dart';
import '../../domain/debounce.dart';
import '../providers/weather_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: ApiConstants.debounceDurationMs);
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (query.length >= ApiConstants.minSearchLength) {
        ref.read(searchNotifierProvider.notifier).search(query);
      } else {
        ref.read(searchNotifierProvider.notifier).clear();
      }
    });
  }

  Future<void> _onCitySelected(CitySearchResult city) async {
    setState(() => _isLoadingWeather = true);

    try {
      final locale = ref.read(localeProvider);
      final repository = ref.read(weatherRepositoryProvider);
      final weather = await repository.getWeather(
        city.lat,
        city.lon,
        lang: locale.languageCode,
      );

      // Add to saved cities
      ref.read(savedCitiesProvider.notifier).addCity(weather);

      // Update current weather display
      ref.read(weatherNotifierProvider.notifier).fetchWeather(
            city.lat,
            city.lon,
            lang: locale.languageCode,
          );

      // Find the index of the newly added city
      final savedCities = ref.read(savedCitiesProvider);
      final index = savedCities.indexWhere(
          (w) => w.location.cacheKey == weather.location.cacheKey);
      if (index >= 0) {
        ref.read(selectedCityIndexProvider.notifier).state = index;
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).failedToLoadWeather}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(context, l10n, isDark),
            // Results
            Expanded(
              child: _buildResults(searchState, l10n, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white38
                        : AppColors.textSecondaryLight,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchNotifierProvider.notifier).clear();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
      SearchState searchState, AppLocalizations l10n, bool isDark) {
    // Loading weather for selected city
    if (_isLoadingWeather) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              l10n.loading,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    switch (searchState.status) {
      case SearchStatus.idle:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: isDark ? Colors.white12 : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.searchCity,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDark ? Colors.white38 : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );

      case SearchStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );

      case SearchStatus.loaded:
        if (searchState.results.isEmpty) {
          return const EmptySearchWidget();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: searchState.results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 60,
            color: isDark ? Colors.white10 : Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            final city = searchState.results[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              title: Text(
                city.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              subtitle: Text(
                '${city.state != null ? '${city.state}, ' : ''}${city.country}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white54
                      : AppColors.textSecondaryLight,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white24 : Colors.grey[400],
              ),
              onTap: () => _onCitySelected(city),
            );
          },
        );

      case SearchStatus.error:
        return WeatherErrorWidget(
          message: searchState.errorMessage ?? l10n.apiError,
          onRetry: () {
            if (_searchController.text.isNotEmpty) {
              ref
                  .read(searchNotifierProvider.notifier)
                  .search(_searchController.text);
            }
          },
        );
    }
  }
}
