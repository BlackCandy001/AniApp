# Nhật ký Sửa lỗi - Fix Log 10

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Phát triển AniApp V4 (Tính năng Youtube Trailer)

## Lỗi Đỏ màn hình (Red Screen of Death) khi vào DetailScreen trên Windows
- **Mô tả lỗi:** 
  - Người dùng gửi hình ảnh màn hình đỏ với dòng chữ lỗi: `Failed assertion... WebViewPlatform.instance != null: A platform implementation for webview_flutter has not been set`. 
  - Ứng dụng bị Crash (Văng/Đứng hình) ngay lập tức khi vào xem chi tiết của một bộ Anime.
- **Nguyên nhân:** 
  - Thư viện `youtube_player_iframe` hoạt động dựa trên `webview_flutter` để tạo khung nhúng.
  - Tuy nhiên, `webview_flutter` chỉ hỗ trợ chính thức Web, Android, iOS và macOS. Trên môi trường **Windows (Desktop)**, nền tảng này hoàn toàn không có Implementation (Trình khởi tạo) mặc định, dẫn đến lỗi chưa cấp phát `WebViewPlatform` và sập app.
- **Cách khắc phục:** 
  - Thay vì cố gắng khắc phục lỗi của thư viện `youtube_player_iframe` trên từng nền tảng, chúng ta đã **gỡ bỏ hoàn toàn** thư viện này khỏi dự án (`pubspec.yaml`).
  - Xây dựng lại `TrailerPlayerWidget` bằng cách lấy ảnh Thumbnail của YouTube (`https://img.youtube.com/vi/$youtubeId/hqdefault.jpg`) làm giao diện đại diện.
  - Sử dụng package `url_launcher` bọc ngoài tấm ảnh. Khi người dùng bấm vào, ứng dụng sẽ dùng phương thức `LaunchMode.externalApplication` để mở đoạn Trailer đó bằng Native App của Youtube (hoặc trình duyệt web mặc định của Windows/Android/iOS).
  - Kết quả: App chạy mượt mà, siêu nhẹ, và lỗi Crash "Đỏ màn hình" trên Windows bị triệt tiêu 100%.

## 2. Thiếu sót Dịch thuật (UI Localization) trên một số màn hình
- **Mô tả lỗi:** Sau khi ra mắt tính năng chọn ngôn ngữ hệ thống ở mục Settings, một số màn hình như `HomeScreen`, `SearchScreen`, `MyListScreen` và `DetailScreen` vẫn còn hiển thị chữ cứng (Hard-coded text) bằng Tiếng Việt.
- **Nguyên nhân:** Quên chưa thay thế các chuỗi String tĩnh bằng biến `AppLocalizations.get(currentLang, 'key')`.
- **Cách khắc phục:** 
  - Bổ sung toàn bộ các khóa (keys) còn thiếu (VD: `seasons_now`, `synopsis_title`, `filter_watching`...) vào từ điển ngôn ngữ `app_localizations.dart`.
  - Cập nhật lại logic của 4 màn hình nói trên, thêm `final currentLang = ref.watch(languageProvider);` để chúng có thể tự động render (phản ứng) theo ngôn ngữ người dùng lựa chọn.
