# AniApp — Ứng dụng Quản lý Anime Cá nhân

AniApp là ứng dụng di động xây dựng bằng **Flutter**, kết hợp kiến trúc **Feature-First** và **Riverpod**. Ứng dụng giúp người dùng khám phá, tìm kiếm, theo dõi và nhận thông báo tập mới của anime một cách tự động, hỗ trợ đa ngôn ngữ và hoạt động cả khi offline.

---

## 🛠 Công nghệ sử dụng

| Hạng mục | Công nghệ |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.11.5) |
| **State Management** | `flutter_riverpod ^2.5.1` |
| **Kiến trúc** | Feature-First + Clean Architecture |
| **Routing** | `go_router ^17.2.3` |
| **API** | Jikan API v4 (`https://api.jikan.moe/v4`) |
| **Database cục bộ** | `sqflite ^2.4.2` (Android/iOS), `sqflite_common_ffi` (Desktop) |
| **Thông báo** | `flutter_local_notifications 17.2.4` |
| **Background Task** | `workmanager ^0.5.2` (WorkManager — Android) |
| **Chọn ảnh** | `image_picker ^1.2.2` |
| **Lưu trữ ảnh** | `path_provider ^2.1.5` |
| **Cache ảnh** | `cached_network_image ^3.4.1` |
| **Biểu đồ** | `fl_chart ^1.2.0` |
| **Kết nối mạng** | `connectivity_plus ^7.1.1` |
| **Lưu cài đặt** | `shared_preferences ^2.5.5` |
| **Dịch thuật** | `translator ^1.0.4+1` |
| **Xem trailer** | `url_launcher ^6.3.2` |

---

## ✨ Chức năng nổi bật

1. **🏠 Khám phá Anime:** Danh sách anime đang chiếu, Top Anime, Sắp ra mắt — tải qua Jikan API với phân trang.
2. **🔍 Tìm kiếm Nâng cao:**
   - Tìm kiếm theo tên với **Debounce 500ms** (chống spam API).
   - Lọc theo **thể loại (Genre)**.
3. **📋 Chi tiết Anime:**
   - Thông tin đầy đủ: synopsis, trạng thái, lịch phát sóng, rating, nguồn gốc.
   - Xem **Trailer YouTube** ngay trong app.
   - **Dịch synopsis** sang Tiếng Việt/Nhật tự động (Google Translate).
4. **📝 Danh sách Cá nhân (My List):**
   - Thêm anime với trạng thái: Đang xem / Đã xem / Dự định xem.
   - Đánh giá sao (1–10), lưu số tập đã xem, ghi chú cá nhân.
   - Swipe-to-delete tiện lợi.
   - **Phân tách dữ liệu theo tài khoản** — mỗi người dùng có danh sách riêng biệt.
5. **🔔 Thông báo Tập Mới (Tự động):**
   - **Foreground:** Kiểm tra mỗi khi mở app hoặc quay lại từ background.
   - **Background:** WorkManager tự động kiểm tra mỗi **12 giờ** kể cả khi app đóng hoàn toàn.
   - Đếm số tập chính xác từ `pagination.items.total` (không bị giới hạn 25 tập/trang).
   - Nội dung thông báo **tự động theo ngôn ngữ** người dùng đang dùng.
6. **👤 Hồ sơ & Thống kê:**
   - Thay đổi avatar từ **thư viện ảnh máy** hoặc avatar có sẵn (hỗ trợ Android 10+, xử lý Activity Recreation).
   - Biểu đồ tròn phân bổ trạng thái anime.
   - Tổng số anime, tổng tập đã xem, điểm trung bình.
7. **⚙️ Cài đặt:**
   - Dark / Light Mode.
   - Chọn ngôn ngữ: **Tiếng Việt / English / 日本語** — áp dụng toàn bộ UI và thông báo.
   - Xuất danh sách sang **JSON** (copy vào Clipboard).
   - Xóa toàn bộ dữ liệu.
8. **🌐 Offline Mode:** Banner cảnh báo mất mạng, vẫn xem được My List khi offline.
9. **🔐 Xác thực cục bộ:** Đăng ký / Đăng nhập bằng email + password lưu SQLite. Có thể dùng không cần tài khoản (chế độ khách).

---

## 📁 Cấu trúc dự án

```text
lib/
├── core/
│   ├── constants/          # Hằng số cấu hình (API base URL, rate limit)
│   ├── localization/       # Hệ thống đa ngôn ngữ vi/en/ja (AppLocalizations)
│   ├── routing/            # Điều hướng GoRouter
│   ├── services/
│   │   ├── notification_service.dart   # Push notification nội bộ
│   │   ├── tracking_service.dart       # Kiểm tra tập mới (foreground)
│   │   └── background_service.dart     # WorkManager periodic task (background)
│   └── themes/             # Material 3, Light/Dark Mode
├── data/
│   ├── api/                # JikanApiService — HTTP calls
│   ├── local/              # DatabaseHelper — SQLite (version 4)
│   └── models/             # AnimeModel, WatchlistModel (có user_id), UserModel
├── domain/
│   ├── entities/
│   └── repositories/
├── features/
│   ├── auth/               # Đăng nhập / Đăng ký
│   ├── detail/             # Chi tiết anime + BottomSheet thêm vào watchlist
│   ├── home/               # Trang chủ + MainScreen (điều hướng chính)
│   ├── mylist/             # Danh sách cá nhân (lọc theo user_id)
│   ├── profile/            # Hồ sơ + sửa avatar
│   ├── search/             # Tìm kiếm
│   ├── settings/           # Cài đặt
│   └── stats/              # Thống kê biểu đồ
└── main.dart               # Entry point — khởi tạo Notification + Background task
```

---

## 🗄 Cơ sở dữ liệu (SQLite — version 4)

| Bảng | Mô tả |
|---|---|
| `users` | Tài khoản người dùng (email, password, username, avatar_path) |
| `watchlist` | Danh sách anime (có `user_id`, `UNIQUE(mal_id, user_id)`) |
| `notes` | Ghi chú cá nhân cho anime |
| `watch_history` | Lịch sử hành động |

---

## ⚙️ Cơ chế hoạt động chính

1. **Thông báo tập mới (3 cấp độ):**
   - Khi mở app → `TrackingService.checkForUpdates()`
   - Khi resume từ background → `WidgetsBindingObserver.didChangeAppLifecycleState`
   - Khi app đóng hoàn toàn → `WorkManager` gọi `BackgroundService._runEpisodeCheck()` mỗi 12h (chỉ khi có mạng và pin không yếu)

2. **Phân tách dữ liệu theo tài khoản:**
   - `WatchlistNotifier` đọc `userId` từ `authProvider`, lọc tất cả queries theo `WHERE user_id = ?`
   - Đăng nhập/đăng xuất → `ref.invalidate(watchlistProvider)` → UI tự động reload

3. **Chọn avatar từ máy (Android):**
   - Copy ảnh từ cache tạm → `ApplicationDocumentsDirectory` (vĩnh viễn)
   - `retrieveLostData()` phục hồi ảnh nếu Android kill app trong lúc mở thư viện ảnh

4. **Debounce tìm kiếm:** 500ms sau khi ngừng gõ mới gọi API — bảo vệ Rate Limit (3 req/s)

---

## 🚀 Hướng dẫn chạy dự án

**Yêu cầu:** Flutter SDK >= 3.19, Android SDK (minSdk 21)

```bash
# Bước 1: Cài đặt dependencies
flutter pub get

# Bước 2: Chạy trên thiết bị/emulator
flutter run

# Bước 3: Build APK release
flutter build apk --release
```

File APK output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔔 Quyền Android cần thiết

| Quyền | Mục đích |
|---|---|
| `INTERNET` | Kết nối Jikan API |
| `READ_EXTERNAL_STORAGE` | Đọc ảnh (Android ≤ 12) |
| `WRITE_EXTERNAL_STORAGE` | Ghi ảnh (Android ≤ 9) |
| `READ_MEDIA_IMAGES` | Đọc ảnh (Android ≥ 13) |
| `POST_NOTIFICATIONS` | Gửi thông báo (Android ≥ 13) |

---

## 📡 API

Dự án sử dụng **Jikan API v4** (miễn phí, không cần API key):
- Base URL: `https://api.jikan.moe/v4`
- Endpoints chính: `/seasons/now`, `/top/anime`, `/anime/{id}`, `/anime/{id}/episodes`, `/anime?q=...`
- Thay đổi Base URL tại: `lib/core/constants/api_constants.dart`
