import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../core/constants.dart';
import '../../../../core/responsive_helper.dart';
import '../../data/location_service.dart';
import '../providers/weather_providers.dart';
import '../../../../features/settings/providers/settings_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Navigate to home after loading weather
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    final locale = ref.read(localeProvider);
    final lang = locale.languageCode;
    final savedCities = ref.read(savedCitiesProvider);

    if (savedCities.isNotEmpty) {
      // Returning user: load weather for selected city
      final selectedIndex = ref.read(selectedCityIndexProvider);
      final cityIndex = selectedIndex < savedCities.length ? selectedIndex : 0;
      final city = savedCities[cityIndex];
      ref.read(weatherNotifierProvider.notifier).fetchWeather(
            city.location.lat,
            city.location.lon,
            lang: lang,
          );
    } else {
      // First launch: try to get current GPS location
      double lat = ApiConstants.defaultLat;
      double lon = ApiConstants.defaultLon;

      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
      }

      // Fetch weather for current location (or fallback to HCM)
      ref.read(weatherNotifierProvider.notifier).fetchWeather(
            lat,
            lon,
            lang: lang,
          );

      // Wait for weather to load, then add to saved cities
      await Future.delayed(const Duration(milliseconds: 2000));
      final weatherState = ref.read(weatherNotifierProvider);
      if (weatherState.weather != null) {
        ref.read(savedCitiesProvider.notifier).addCity(weatherState.weather!);
      }
    }

    // Wait for animation + minimum splash time
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
              Color(0xFF283593),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: ResponsiveCenter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 32),
                // App Name
                const Text(
                  'Weather',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Forecast & Radar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),
                // Loading indicator
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
