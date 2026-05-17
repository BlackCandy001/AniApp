# Nhật ký phát triển (Task Log 1) - Giai đoạn 1

**Thời gian:** 14/05/2026

## Các thay đổi đã thực hiện:

1. **Cập nhật `pubspec.yaml`**:
   - Đã cài đặt các dependencies quan trọng cho dự án: `http`, `flutter_riverpod`, `sqflite`, `path_provider`, `cached_network_image`, `fl_chart`, `shimmer`, `flutter_rating_bar`, `go_router`, `intl`, `shared_preferences`, `connectivity_plus`.

2. **Thiết lập Cấu trúc thư mục chuẩn Clean Architecture**:
   - **Core**: `lib/core/constants`, `lib/core/themes`, `lib/core/routing`.
   - **Features**: Khởi tạo thư mục `presentation` cho các tính năng: `home`, `search`, `detail`, `mylist`, `stats`, `profile`.
   - **Data**: `lib/data/api`, `lib/data/local`, `lib/data/models`.
   - **Domain**: `lib/domain/entities`, `lib/domain/repositories`.

3. **Cấu hình Nền tảng (Core Setup)**:
   - `lib/core/constants/api_constants.dart`: Khởi tạo cấu hình cho Jikan API v4 (Base URL, Rate Limit = 3, Page Size = 25).
   - `lib/core/themes/app_theme.dart`: Thiết kế Material 3 Design System. Định nghĩa hệ thống màu (Primary: Indigo, Secondary: Purple), bo góc (`BorderRadius`), thiết kế riêng biệt và đồng bộ cho Light Mode và Dark Mode.
   - `lib/core/routing/app_router.dart`: Tích hợp `go_router` làm hệ thống điều hướng chính, thiết lập route gốc (`/`).

4. **Cấu trúc Cơ sở dữ liệu Cục bộ (Local Database)**:
   - `lib/data/local/database_helper.dart`: Triển khai `sqflite` và tạo cấu trúc cho 3 bảng dữ liệu có ràng buộc khóa ngoại (Foreign Keys):
     - `watchlist`: Quản lý danh sách lưu trữ của người dùng.
     - `notes`: Lưu các ghi chú cá nhân của người dùng.
     - `watch_history`: Lưu lịch sử tương tác.

5. **Khởi tạo Ứng dụng**:
   - `lib/main.dart`: Cập nhật `main()` để bọc toàn bộ ứng dụng trong `ProviderScope` (sử dụng Riverpod). Kết nối ứng dụng với cấu hình Router và Theme đã tạo.
