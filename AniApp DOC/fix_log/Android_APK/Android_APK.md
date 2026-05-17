## 2. Vấn đề Hiệu suất (Performance) khi load video nhúng trên Android
- **Mô tả lỗi:** Khi Test thử trên thiết bị di động (Android), ứng dụng mất rất nhiều thời gian (rất lâu) chỉ để khởi tạo được một khung trình phát video nhúng của `youtube_player_iframe`, đôi khi bị giật lag và không thể xem mượt mà.
- **Nguyên nhân:** Việc nhúng toàn bộ bộ máy duyệt web khổng lồ (WebView) chỉ để phát một đoạn video ngắn trong màn hình chi tiết là một sự lãng phí tài nguyên khổng lồ, đặc biệt là trên các thiết bị Android phổ thông. WebView tốn nhiều RAM và thời gian khởi tạo.
- **Cách khắc phục:** 
  - **Loại bỏ thư viện nặng:** Tiến hành gỡ cài đặt package `youtube_player_iframe` khỏi `pubspec.yaml` để giảm dung lượng file APK.
  - **Giải pháp Thay thế Siêu nhẹ (Lightweight):**
    - Thiết kế lại `TrailerPlayerWidget` bằng cách hiển thị **Ảnh Thumbnail chất lượng cao** của video đó thông qua API ảnh của Youtube: `https://img.youtube.com/vi/$youtubeId/hqdefault.jpg`.
    - Phủ một hiệu ứng tối (Overlay mờ) cùng với Icon nút "Play" đỏ rực ở chính giữa bức ảnh để tạo cảm giác giống hệt một video player thực thụ.
    - Áp dụng `GestureDetector` vào toàn bộ bức ảnh. Khi người dùng bấm (Tap) vào, lập tức sử dụng thư viện `url_launcher` (với chế độ `LaunchMode.externalApplication`) để gọi thẳng **ứng dụng Youtube có sẵn** trên điện thoại lên (hoặc mở trình duyệt Web nếu máy không cài app Youtube).
  - **Kết quả:** Giao diện load nhanh tức thì (0ms), không hề có độ trễ hay tiêu tốn RAM, trải nghiệm xem video lại vô cùng mượt mà vì tận dụng được Native App của YouTube. Đồng thời, giải quyết triệt để lỗi "Red Screen of Death" trên cả hệ điều hành Windows vì cơ chế này tương thích 100% đa nền tảng.
