# Kế hoạch Phát triển AniApp V4

Dựa trên yêu cầu từ `tast4.md`, quá trình phát triển phiên bản V4 sẽ được chia thành 4 giai đoạn cụ thể để đảm bảo ứng dụng hoạt động ổn định và tối ưu hóa tốt nhất.

---

## Giai đoạn 1: Tinh chỉnh UI/UX (Trang Info & Search)
**Mục tiêu:** Cải thiện trải nghiệm thao tác và đồng bộ thiết kế toàn ứng dụng.
1. **Trang Info (Thông tin cá nhân):**
   - Thiết kế lại bố cục (Layout): Đưa nút **Đăng xuất (Logout)** và nút **Cài đặt (Settings)** lên thanh `AppBar` (Góc trên cùng bên phải).
   - Loại bỏ các nút chức năng cũ (Chủ đề, Xuất dữ liệu, Xóa dữ liệu) đang nằm rải rác dưới màn hình để làm trống không gian.
2. **Trang Tìm Kiếm (Search Screen):**
   - Áp dụng widget/hiệu ứng `Hover / Scale-up` vào các kết quả tìm kiếm (cả danh sách khám phá và danh sách realtime) để đồng bộ trải nghiệm "nổi lên khi di chuột/chạm" giống như các Card ở Trang chủ.

## Giai đoạn 2: Xây dựng Hệ thống Cài đặt (Settings & Localization)
**Mục tiêu:** Quản lý các cấu hình cốt lõi của người dùng một cách tập trung.
1. **Tạo màn hình `SettingsScreen`:**
   - Di chuyển và tái thiết lập các tính năng cũ: **Chuyển đổi Sáng/Tối** (Theme), **Xuất dữ liệu Anime** (Export SQLite sang JSON), **Xóa toàn bộ danh sách** (Clear SQLite) vào màn hình này.
2. **Hệ thống Đa ngôn ngữ (Localization):**
   - Thêm phần chọn Ngôn ngữ: `Tiếng Anh`, `Tiếng Việt`, `Tiếng Nhật`.
   - Lưu lựa chọn ngôn ngữ vào `SharedPreferences` bằng Riverpod.
   - *Giải pháp dịch thuật:* Cài đặt package `translator` (Google Translate API miễn phí) để xử lý việc dịch "Real-time" các thông tin từ Jikan API (Vốn mặc định trả về tiếng Anh) sang ngôn ngữ được chọn.

## Giai đoạn 3: Làm phong phú Dữ liệu Chi tiết (Anime Data)
**Mục tiêu:** Khai thác tối đa Jikan API v4 để hiển thị thông tin chuyên sâu.
1. **Cập nhật `AnimeModel` và API Service:**
   - Bổ sung việc lấy các trường: `trailer`, `aired`, `broadcast`, `duration`, `rating`, `source`, `background`.
2. **Thiết kế lại `DetailScreen`:**
   - **Đặc tính bộ phim:** Thời lượng mỗi tập (`duration`), Nguồn gốc (`source`), Phân loại độ tuổi (`rating`).
   - **Trạng thái & Lịch phát:** Ngày phát sóng (`aired`), Khung giờ chiếu (`broadcast`).
   - **Nội dung & Bối cảnh:** Ngoài `synopsis` (Cốt truyện), hiển thị thêm `background` (Bối cảnh/Trivia).
   - *Tích hợp Dịch thuật:* Tự động dịch Synopsis và Background sang ngôn ngữ người dùng đã thiết lập ở Giai đoạn 2.

## Giai đoạn 4: Trình chiếu Trailer
**Mục tiêu:** Tăng tính trực quan bằng Video Trailer gốc.
1. **Tích hợp Video Player:**
   - Cài đặt package `youtube_player_iframe` (hoặc `youtube_player_flutter`) tương thích với đa nền tảng.
2. **Hiển thị trên DetailScreen:**
   - Sử dụng `trailer.youtube_id` lấy được từ Giai đoạn 3 để nhúng khung Video Player thẳng vào màn hình Chi tiết phim (Hoặc tạo một nút "Xem Trailer" mở ra pop-up Video).

---
**Các thư viện (Packages) dự kiến cần bổ sung vào `pubspec.yaml`:**
- `translator`: Phục vụ chức năng dịch thông tin linh hoạt Anh/Nhật/Việt.
- `youtube_player_iframe`: Phục vụ việc xem trailer ngay trong app.
