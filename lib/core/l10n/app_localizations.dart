import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Weather',
      'subtitle': 'Forecast & Radar',
      'search': 'Search',
      'searchCity': 'Search city...',
      'searchHint': 'Enter city name',
      'noResults': 'No results found',
      'tryAgain': 'Try Again',
      'settings': 'Settings',
      'language': 'Language',
      'temperatureUnit': 'Temperature Unit',
      'darkMode': 'Dark Mode',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'about': 'About',
      'aboutApp': 'About App',
      'privacyPolicy': 'Privacy Policy',
      'version': 'Weather App v1.0.0',
      'savedCities': 'Saved Cities',
      'noCities': 'No saved cities',
      'addCity': 'Add City',
      'removeCity': 'Remove',
      'setDefault': 'Set as default',
      'hourlyForecast': '24-Hour Forecast',
      'dailyForecast': '7-Day Forecast',
      'viewAll': 'View All',
      'humidity': 'Humidity',
      'wind': 'Wind',
      'feelsLike': 'Feels Like',
      'airQuality': 'Air Quality',
      'aqiGood': 'Good',
      'aqiFair': 'Fair',
      'aqiModerate': 'Moderate',
      'aqiPoor': 'Poor',
      'aqiVeryPoor': 'Very Poor',
      'aqiAdviceGood': 'Great for outdoors',
      'aqiAdviceFair': 'Sensitive groups beware',
      'aqiAdviceModerate': 'Reduce outdoor time',
      'aqiAdvicePoor': 'Air is polluted',
      'aqiAdviceVeryPoor': 'Toxic, stay indoors',
      'sunrise': 'Sunrise',
      'sunset': 'Sunset',
      'visibility': 'Visibility',
      'pressure': 'Pressure',
      'celsius': '°C',
      'fahrenheit': '°F',
      'kmh': 'km/h',
      'mph': 'mph',
      'high': 'H',
      'low': 'L',
      'today': 'Today',
      'now': 'Now',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'noInternet': 'No internet connection',
      'apiError': 'Failed to load weather data',
      'pullToRefresh': 'Pull to refresh',
      'severeWeather': 'Severe Weather',
      'severeWeatherDesc': 'Get alerts for storms, snow, and heavy rain.',
      'rainForecast': 'Rain Forecast',
      'systemDefault': 'System Default',
      'weatherTip1': 'Use sun protection 11AM-4PM.',
      'weatherTip2': 'The dew point indicates humidity level.',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'home': 'Home',
      'locations': 'Locations',
      'weather': 'Weather',
      // New keys for localization fixes
      'cancel': 'Cancel',
      'confirmRemoveCity': 'Remove {city} from saved cities?',
      'failedToLoadWeather': 'Failed to load weather',
      'noInternetMessage':
          'No internet connection.\nPlease check your network settings.',
      'noSearchResults': 'No cities found.\nTry a different search term.',
      'setAsDefaultSnack': '{city} set as default',
      'defaultBadge': 'DEFAULT',
      'studentName': 'Name',
      'studentId': 'Student ID',
      'major': 'Major',
      'classInfo': 'Class',
      'member1': 'Member 1',
      'member2': 'Member 2',
    },
    'vi': {
      'appName': 'Thời Tiết',
      'subtitle': 'Dự Báo & Radar',
      'search': 'Tìm kiếm',
      'searchCity': 'Tìm thành phố...',
      'searchHint': 'Nhập tên thành phố',
      'noResults': 'Không tìm thấy kết quả',
      'tryAgain': 'Thử Lại',
      'settings': 'Cài Đặt',
      'language': 'Ngôn ngữ',
      'temperatureUnit': 'Đơn vị nhiệt độ',
      'darkMode': 'Chế độ tối',
      'preferences': 'Tùy chọn',
      'notifications': 'Thông báo',
      'about': 'Giới thiệu',
      'aboutApp': 'Về ứng dụng',
      'privacyPolicy': 'Chính sách bảo mật',
      'version': 'Ứng dụng Thời Tiết v1.0.0',
      'savedCities': 'Thành phố đã lưu',
      'noCities': 'Chưa có thành phố nào',
      'addCity': 'Thêm thành phố',
      'removeCity': 'Xóa',
      'setDefault': 'Đặt làm mặc định',
      'hourlyForecast': 'Dự báo 24 giờ',
      'dailyForecast': 'Dự báo 7 ngày',
      'viewAll': 'Xem tất cả',
      'humidity': 'Độ ẩm',
      'wind': 'Gió',
      'feelsLike': 'Cảm giác như',
      'airQuality': 'Chất lượng không khí',
      'aqiGood': 'Tốt',
      'aqiFair': 'Khá',
      'aqiModerate': 'Trung bình',
      'aqiPoor': 'Kém',
      'aqiVeryPoor': 'Rất kém',
      'aqiAdviceGood': 'Tuyệt vời để ra ngoài',
      'aqiAdviceFair': 'Người nhạy cảm lưu ý',
      'aqiAdviceModerate': 'Giảm thời gian ở ngoài trời',
      'aqiAdvicePoor': 'Không khí ô nhiễm',
      'aqiAdviceVeryPoor': 'Độc hại, ở trong nhà',
      'sunrise': 'Bình minh',
      'sunset': 'Hoàng hôn',
      'visibility': 'Tầm nhìn',
      'pressure': 'Áp suất',
      'celsius': '°C',
      'fahrenheit': '°F',
      'kmh': 'km/h',
      'mph': 'mph',
      'high': 'C',
      'low': 'T',
      'today': 'Hôm nay',
      'now': 'Bây giờ',
      'loading': 'Đang tải...',
      'error': 'Đã xảy ra lỗi',
      'noInternet': 'Không có kết nối internet',
      'apiError': 'Không thể tải dữ liệu thời tiết',
      'pullToRefresh': 'Kéo để làm mới',
      'severeWeather': 'Thời tiết khắc nghiệt',
      'severeWeatherDesc': 'Nhận cảnh báo bão, tuyết và mưa lớn.',
      'rainForecast': 'Dự báo mưa',
      'systemDefault': 'Mặc định hệ thống',
      'weatherTip1': 'Sử dụng kem chống nắng từ 11AM-4PM.',
      'weatherTip2': 'Điểm sương cho biết mức độ ẩm.',
      'mon': 'T2',
      'tue': 'T3',
      'wed': 'T4',
      'thu': 'T5',
      'fri': 'T6',
      'sat': 'T7',
      'sun': 'CN',
      'home': 'Trang chủ',
      'locations': 'Địa điểm',
      'weather': 'Thời tiết',
      // New keys for localization fixes
      'cancel': 'Hủy',
      'confirmRemoveCity': 'Xóa {city} khỏi danh sách đã lưu?',
      'failedToLoadWeather': 'Không thể tải dữ liệu thời tiết',
      'noInternetMessage':
          'Không có kết nối internet.\nVui lòng kiểm tra cài đặt mạng.',
      'noSearchResults': 'Không tìm thấy thành phố.\nThử từ khóa khác.',
      'setAsDefaultSnack': '{city} đã được đặt làm mặc định',
      'defaultBadge': 'MẶC ĐỊNH',
      'studentName': 'Họ tên',
      'studentId': 'Mã sinh viên',
      'major': 'Ngành',
      'classInfo': 'Lớp',
      'member1': 'Thành viên 1',
      'member2': 'Thành viên 2',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// Translate with parameter substitution
  String translateWith(String key, Map<String, String> params) {
    var result = translate(key);
    params.forEach((paramKey, value) {
      result = result.replaceAll('{$paramKey}', value);
    });
    return result;
  }

  // Convenience getters
  String get appName => translate('appName');
  String get subtitle => translate('subtitle');
  String get search => translate('search');
  String get searchCity => translate('searchCity');
  String get searchHint => translate('searchHint');
  String get noResults => translate('noResults');
  String get tryAgain => translate('tryAgain');
  String get settingsTitle => translate('settings');
  String get language => translate('language');
  String get temperatureUnit => translate('temperatureUnit');
  String get darkMode => translate('darkMode');
  String get preferences => translate('preferences');
  String get savedCities => translate('savedCities');
  String get noCities => translate('noCities');
  String get addCity => translate('addCity');
  String get hourlyForecast => translate('hourlyForecast');
  String get dailyForecast => translate('dailyForecast');
  String get viewAll => translate('viewAll');
  String get humidity => translate('humidity');
  String get wind => translate('wind');
  String get feelsLike => translate('feelsLike');
  String get airQuality => translate('airQuality');
  String get aqiGood => translate('aqiGood');
  String get aqiFair => translate('aqiFair');
  String get aqiModerate => translate('aqiModerate');
  String get aqiPoor => translate('aqiPoor');
  String get aqiVeryPoor => translate('aqiVeryPoor');
  String get aqiAdviceGood => translate('aqiAdviceGood');
  String get aqiAdviceFair => translate('aqiAdviceFair');
  String get aqiAdviceModerate => translate('aqiAdviceModerate');
  String get aqiAdvicePoor => translate('aqiAdvicePoor');
  String get aqiAdviceVeryPoor => translate('aqiAdviceVeryPoor');
  String get sunrise => translate('sunrise');
  String get sunset => translate('sunset');
  String get loading => translate('loading');
  String get error => translate('error');
  String get noInternet => translate('noInternet');
  String get apiError => translate('apiError');
  String get high => translate('high');
  String get low => translate('low');
  String get today => translate('today');
  String get now => translate('now');
  String get home => translate('home');
  String get locations => translate('locations');
  String get weather => translate('weather');
  String get cancel => translate('cancel');
  String get failedToLoadWeather => translate('failedToLoadWeather');
  String get noInternetMessage => translate('noInternetMessage');
  String get noSearchResults => translate('noSearchResults');
  String get defaultBadge => translate('defaultBadge');
  String get removeCity => translate('removeCity');
  String get setDefault => translate('setDefault');
  String get visibility => translate('visibility');
  String get pressure => translate('pressure');
  String get aboutApp => translate('aboutApp');
  String get studentName => translate('studentName');
  String get studentId => translate('studentId');
  String get major => translate('major');
  String get classInfo => translate('classInfo');
  String get member1 => translate('member1');
  String get member2 => translate('member2');

  String confirmRemoveCity(String cityName) =>
      translateWith('confirmRemoveCity', {'city': cityName});
  String setAsDefaultSnack(String cityName) =>
      translateWith('setAsDefaultSnack', {'city': cityName});
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
