# 🌤️ Weather App — Ứng Dụng Thời Tiết

Ứng dụng dự báo thời tiết Flutter với giao diện Glassmorphism hiện đại, hỗ trợ đa ngôn ngữ (Tiếng Việt / Tiếng Anh), và tự động phát hiện vị trí GPS.

## ✨ Tính Năng

- 🌡️ **Thời tiết hiện tại** — Nhiệt độ, độ ẩm, gió, cảm giác thực, bình minh/hoàng hôn
- 📍 **Tự động phát hiện vị trí** — Lấy GPS của thiết bị để hiển thị thời tiết tại khu vực hiện tại
- ⏰ **Dự báo 24 giờ** — Dự báo theo từng 3 giờ trong ngày
- 📅 **Dự báo 7 ngày** — Nhiệt độ cao/thấp, xác suất mưa
- 🔍 **Tìm kiếm thành phố** — Tìm kiếm với debounce, thêm vào danh sách đã lưu
- 💾 **Lưu trữ cục bộ** — Danh sách thành phố và cài đặt được lưu qua SharedPreferences
- 🌐 **Đa ngôn ngữ** — Hỗ trợ Tiếng Việt và Tiếng Anh
- 🌙 **Chế độ tối/sáng** — Chuyển đổi theme theo sở thích
- 🔄 **Kéo để làm mới** — Pull-to-refresh cập nhật dữ liệu mới nhất
- 🎨 **Glassmorphism UI** — Giao diện kính mờ hiện đại với animation mượt mà

## 🛠️ Công Nghệ Sử Dụng

| Công nghệ | Mô tả |
|---|---|
| **Flutter** | Framework UI đa nền tảng |
| **Riverpod** | Quản lý trạng thái (State Management) |
| **OpenWeatherMap API** | Nguồn dữ liệu thời tiết |
| **Geolocator** | Lấy vị trí GPS thiết bị |
| **SharedPreferences** | Lưu trữ dữ liệu cục bộ |
| **Google Fonts** | Typography hiện đại |
| **Shimmer** | Hiệu ứng loading skeleton |

## 📁 Cấu Trúc Dự Án

```
lib/
├── main.dart                          # Entry point, khởi tạo SharedPreferences
├── core/
│   ├── app_router.dart                # Routing với custom transition
│   ├── app_theme.dart                 # Theme sáng/tối, màu sắc
│   ├── constants.dart                 # API keys, cấu hình
│   └── l10n/
│       └── app_localizations.dart     # Đa ngôn ngữ VI/EN
├── features/
│   ├── settings/
│   │   └── providers/
│   │       └── settings_providers.dart # Locale, theme, đơn vị nhiệt độ
│   └── weather/
│       ├── data/
│       │   ├── local_storage_service.dart  # Đọc/ghi SharedPreferences
│       │   ├── location_service.dart      # GPS & quyền vị trí
│       │   ├── weather_api_service.dart   # Gọi API OpenWeather
│       │   ├── weather_models.dart        # Models + JSON serialization
│       │   └── weather_repository.dart    # Cache layer
│       ├── domain/
│       │   └── debounce.dart              # Debounce cho tìm kiếm
│       └── presentation/
│           ├── providers/
│           │   └── weather_providers.dart  # State: Weather, Search, Cities
│           └── screens/
│               ├── splash_screen.dart     # Splash + GPS detection
│               ├── home_screen.dart       # Màn hình chính
│               ├── search_screen.dart     # Tìm kiếm thành phố
│               └── cities_screen.dart     # Quản lý thành phố đã lưu
└── shared/
    └── widgets/
        ├── glass_container.dart        # Widget Glassmorphism
        ├── shimmer_loading.dart        # Skeleton loading
        ├── weather_error_widget.dart   # Widget hiển thị lỗi
        └── weather_icon_mapper.dart    # Map mã thời tiết → icon
```

## 🚀 Cài Đặt & Chạy

### Yêu cầu
- Flutter SDK >= 3.10.4
- Dart >= 3.10.4
- API Key từ [OpenWeatherMap](https://openweathermap.org/api) (miễn phí)

### Các bước

1. **Clone dự án**
   ```bash
   git clone <repo-url>
   cd mobile_weather_app
   ```

2. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

3. **Cấu hình API Key**

   Mở `lib/core/constants.dart` và thay đổi API key:
   ```dart
   static const String apiKey = 'YOUR_API_KEY_HERE';
   ```

4. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

## 📱 Màn Hình

| Màn hình | Mô tả |
|---|---|
| **Splash** | Logo + animation, xin quyền GPS, tải dữ liệu ban đầu |
| **Home** | Hero section (nhiệt độ lớn), dự báo giờ, dự báo ngày, stats grid |
| **Search** | Tìm kiếm thành phố với debounce, hiển thị kết quả real-time |
| **Cities** | Danh sách thành phố đã lưu, swipe xóa, long-press đặt mặc định |
| **Settings** | Bottom sheet: ngôn ngữ, đơn vị nhiệt độ, chế độ tối |

## 🔧 Kiến Trúc

Dự án sử dụng kiến trúc **Feature-First** với các layer:

```
Presentation (Screens + Providers)
        ↓
    Domain (Business Logic)
        ↓
    Data (API + Repository + Storage)
```

**State Management**: Riverpod `StateNotifier` cho các trạng thái chính:
- `WeatherNotifier`: initial → loading → loaded / error
- `SearchNotifier`: idle → loading → loaded / error
- `SavedCitiesNotifier`: quản lý danh sách với auto-persist
- Settings: locale, theme, temperature unit — đều persist qua SharedPreferences

## 📄 Giấy Phép

Dự án này được phát triển cho mục đích học tập.
