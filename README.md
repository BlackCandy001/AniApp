# AnimeTracker - Quản lý Danh sách Anime Cá nhân

AnimeTracker là ứng dụng di động được xây dựng bằng **Flutter**, kết hợp kiến trúc **Clean Architecture** và **Riverpod**. Ứng dụng giúp người dùng khám phá, tìm kiếm và quản lý danh sách anime/phim cá nhân một cách sinh động, tiện lợi và hỗ trợ sử dụng ngay cả khi không có kết nối mạng (Offline Mode).

---

## 🛠 Công nghệ sử dụng
- **Framework:** Flutter (Dart)
- **State Management:** `flutter_riverpod`
- **Kiến trúc:** Clean Architecture (Core, Features, Data, Domain)
- **Routing:** `go_router`
- **Network & API:** `http` kết nối với **Jikan API v4** (Cơ sở dữ liệu MyAnimeList)
- **Database (Local Storage):** `sqflite` (Hỗ trợ SQLite trên Android/iOS) và `sqflite_common_ffi` (Hỗ trợ SQLite trên Desktop/Windows).
- **UI/UX & Hoạt ảnh:** Material 3, Hero Animations, SliverAppBar, Hiệu ứng Hover/Scale động trên Desktop/Web.
- **Tiện ích:** `cached_network_image`, `fl_chart`, `connectivity_plus`, `shared_preferences`, `flutter_rating_bar`
- **Tích hợp mở rộng:** `translator` (Google Translate API), `youtube_player_iframe` (Trình phát video nhúng).

---

## ✨ Chức năng nổi bật
1. **Khám phá Anime:** Tự động gọi API lấy danh sách Anime đang chiếu (Seasons Now) và Top Anime hiển thị bằng danh sách trượt ngang.
2. **Tìm kiếm Nâng cao:** 
   - Tìm kiếm theo tên với thuật toán **Debounce** (tự động hoãn 500ms chống spam API).
   - Form Validation chặn từ khóa quá ngắn.
3. **Giao diện Chi tiết Sinh động:** 
   - Sử dụng `SliverAppBar` cho ảnh nền tự động thu phóng nghệ thuật.
   - Hiệu ứng `Hero Animation` giúp poster bay mượt mà giữa các màn hình.
4. **Quản lý Danh sách Cá nhân (My List):** 
   - Thêm phim vào danh sách với 5 trạng thái (Đang xem, Đã xem, Dự định, Bỏ dở).
   - Đánh giá sao (1-10) bằng RatingBar, lưu số tập đã xem, tiến độ xem nhanh (`Quick Progress`).
   - Thao tác vuốt để xóa (`Swipe-to-delete`) tiện lợi.
5. **Đa ngôn ngữ & Dịch thuật Tự động (Localization):**
   - Hỗ trợ dịch Tóm tắt nội dung (Synopsis) và Bối cảnh (Background) từ Tiếng Anh sang Tiếng Việt/Nhật hoàn toàn tự động thông qua Google Translate API.
6. **Trình chiếu Trailer Tích hợp:** Xem trực tiếp Trailer phim/Video giới thiệu ngay bên trong ứng dụng bằng `youtube_player_iframe`.
7. **Thống kê Trực quan:** Xem biểu đồ tròn phân tích tỷ lệ phim đã xem thông qua thư viện `fl_chart`.
8. **Hỗ trợ Offline (Ngoại tuyến):** 
   - Tự động nhận diện rớt mạng bằng `connectivity_plus` và hiện dải Banner cảnh báo.
   - Khi mất mạng vẫn xem lại được toàn bộ phim trong "My List". Hình ảnh được lưu Cache.
9. **Cài đặt Tùy biến & Bảo mật:**
   - Quản lý giao diện (Dark/Light mode).
   - Xuất dữ liệu cá nhân ra định dạng JSON hoặc Xóa vĩnh viễn (Clear Data).
10. **Hỗ trợ Đa nền tảng:** 
   - Chạy mượt mà trên **Android** (chuẩn Material 3) và **Windows/Desktop** (có tích hợp hiệu ứng di chuột MouseRegion).

---

## 📁 Cấu trúc dự án (Clean Architecture)
Dự án được phân chia thư mục theo từng tính năng (Feature-first) kết hợp kiến trúc Clean để đảm bảo dễ bảo trì:

```text
lib/
├── core/                       # Chứa các thành phần cốt lõi dùng chung
│   ├── constants/              # Chứa các hằng số cấu hình (vd: api_constants.dart)
│   ├── routing/                # Quản lý điều hướng màn hình bằng go_router
│   └── themes/                 # Quản lý Light/Dark Mode (Material 3)
├── data/                       # Tầng xử lý Dữ liệu (Network & Local)
│   ├── api/                    # Dịch vụ gọi HTTP request (JikanApiService)
│   ├── local/                  # SQLite Database Helper quản lý bảng watchlist
│   └── models/                 # Model chuẩn hóa JSON & Map (AnimeModel)
├── domain/                     # Tầng Nghiệp vụ (Logic & Entities)
│   ├── entities/               # Lớp mô hình thuần túy độc lập với Framework
│   └── repositories/           # Interface định nghĩa giao thức gọi Data
├── features/                   # Chứa giao diện & logic phân chia theo tính năng
│   ├── detail/                 # Màn hình Chi tiết + BottomSheet đánh giá
│   ├── home/                   # Màn hình Trang chủ + Main Navigation Bar
│   ├── mylist/                 # Màn hình Danh sách + Provider SQLite
│   ├── search/                 # Màn hình Tìm kiếm + Xử lý Debounce API
│   └── stats/                  # Màn hình Thống kê + Biểu đồ fl_chart
└── main.dart                   # Điểm khởi chạy (Entry point) bọc ProviderScope
```

---

## ⚙️ Cách hoạt động

1. **State Management (Riverpod):** 
   - Dữ liệu API (Trang chủ, Tìm kiếm) được gọi qua `FutureProvider`. 
   - Dữ liệu local (SQLite) được quản lý qua `StateNotifierProvider`. Giao diện màn hình "My List" và "Stats" tự động lắng nghe (Reactive) và thay đổi ngay khi database SQLite có cập nhật (thêm/sửa/xóa anime).
2. **Cơ chế Debounce Tìm kiếm:** Thay vì gọi API liên tục mỗi khi gõ 1 chữ, thuật toán trong `search_providers.dart` sẽ "đợi" 500ms sau khi người dùng ngừng gõ phím mới tiến hành gửi Request. Điều này giúp bảo vệ ứng dụng không bị hệ thống Jikan API chặn (vì API này có Rate Limit: 3 request/giây).
3. **Cơ sở dữ liệu Cục bộ (Local Database):** Khi nhấn "Lưu thông tin" ở màn hình Chi tiết, `WatchlistModel` sẽ được ánh xạ xuống bảng `watchlist` của thư viện `sqflite`.

---

## 🚀 Hướng dẫn cấu hình và chạy dự án

**Bước 1: Cài đặt các Package phụ thuộc**
Hãy chắc chắn bạn đã cài đặt Flutter SDK >= 3.19. Mở terminal tại thư mục gốc của dự án:
```bash
flutter pub get
```

**Bước 2: Cấu hình Jikan API**
Mặc định dự án đang sử dụng Jikan API v4 miễn phí. Bạn có thể thay đổi Base URL nếu muốn tự host API tại:
`lib/core/constants/api_constants.dart`

**Bước 3: Chạy ứng dụng**
Mở Emulator (Android/iOS) hoặc kết nối thiết bị thật:
```bash
flutter run
```

**Bước 4: Build file cài đặt (APK)**
Để tạo file ứng dụng Android nhẹ và tối ưu nhất:
```bash
flutter build apk --release
```
