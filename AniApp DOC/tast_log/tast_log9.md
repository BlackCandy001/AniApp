# Nhật ký Công việc - Task Log 9

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Phát triển AniApp V4 (Hoàn tất 4 Giai đoạn)

## 1. Giai đoạn 1: Tinh chỉnh UI/UX
- **Trang Tìm kiếm (Search Screen):** 
  - Tạo các Widget mới: `_HoverableSuggestionTile` và `_HoverableSearchCard`.
  - Tích hợp `MouseRegion` và `AnimatedContainer` để bổ sung hiệu ứng Hover (phóng to, đổi màu chữ) cho cả danh sách phim Real-time và danh sách phim Đề xuất.
- **Trang Thông tin cá nhân (Info Screen):**
  - Tái cấu trúc lại UI: Dọn dẹp không gian hiển thị bằng cách xóa các nút chức năng bên dưới cùng (Đổi theme, Xuất dữ liệu, Xóa dữ liệu).
  - Di chuyển tính năng **Đăng xuất** và thêm một nút bấm **Cài đặt** lên thanh `AppBar` ở góc trên bên phải.

## 2. Giai đoạn 2: Hệ thống Cài đặt & Ngôn ngữ (Settings & Localization)
- **Tích hợp Thư viện:** Đã cài đặt thành công package `translator` (sử dụng Google Translate API) vào `pubspec.yaml` để phục vụ Giai đoạn 3.
- **Quản lý Trạng thái:**
  - Khởi tạo `language_provider.dart` với Riverpod và `SharedPreferences` để lưu vĩnh viễn ngôn ngữ được người dùng lựa chọn.
  - Tạo file `translation_service.dart` đảm nhiệm logic dịch từ Tiếng Anh sang Tiếng Việt/Nhật.
  - Xây dựng `AppLocalizations` để cung cấp từ vựng dịch tự động cho toàn bộ Hệ thống UI (Bottom Navigation Bar, Profile, Settings) dựa trên ngôn ngữ đang chọn.
- **Màn hình Cài đặt (SettingsScreen):**
  - Khởi tạo file `settings_screen.dart` áp dụng hoàn toàn đa ngôn ngữ.
  - Gom các thiết lập phân tán về một mối: Switch bật/tắt Dark Mode, Dropdown chọn ngôn ngữ dịch thuật, và Cụm nút bấm Quản lý dữ liệu (Xuất/Xóa JSON/SQLite).
  - Tích hợp `SnackBar` thông báo ngay lập tức bằng ngôn ngữ mới mỗi khi chuyển đổi ngôn ngữ thành công.
- **Điều hướng (Router):** Đăng ký route `/settings` vào `app_router.dart` và kết nối thành công với nút Bánh răng ở trang cá nhân.
## 3. Giai đoạn 3: Làm phong phú Dữ liệu & Dịch thuật
- **Cập nhật `AnimeModel`:** Ánh xạ thêm 7 trường dữ liệu mới từ Jikan API: `duration`, `rating`, `source`, `airedString`, `broadcastString`, `background`, `trailerYoutubeId`.
- **Nâng cấp `DetailScreen`:**
  - Thiết kế thêm thẻ (Card) thông tin để hiển thị các đặc tính và lịch phát sóng của phim.
  - Áp dụng `FutureBuilder` kết hợp với `translationServiceProvider` để dịch tự động các đoạn văn bản tiếng Anh sang tiếng Việt/Nhật (như Nội dung chính, Bối cảnh) theo tùy chọn của người dùng.

## 4. Giai đoạn 4: Tích hợp Trình chiếu Trailer (Tối ưu hóa)
- **Tích hợp Thư viện:** Cài đặt `url_launcher` và loại bỏ các thư viện WebView cồng kềnh để tối đa hóa hiệu năng và tránh rò rỉ RAM.
- **Tạo Widget `TrailerPlayerWidget`:** 
  - Xây dựng một Component sử dụng `CachedNetworkImage` tải **Ảnh Thumbnail chất lượng cao** của Youtube (hqdefault.jpg).
  - Phủ một giao diện tối giả lập một trình phát video có nút Play đỏ.
  - Bọc Widget bằng `GestureDetector` gọi đến `launchUrl` (chế độ externalApplication) để mở trực tiếp App Youtube có sẵn trên điện thoại, đem lại trải nghiệm video siêu mượt (0ms load).
- **Tích hợp UI:** Gắn Widget vào màn hình Chi tiết. Ứng dụng tự động kiểm tra biến `trailerYoutubeId` (hỗ trợ Regex tự động bóc tách ID từ `embed_url` nếu API bị thiếu `youtube_id`) để quyết định việc render hình ảnh trailer hay hiển thị dòng chữ "Không có video".
