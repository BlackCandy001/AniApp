# Nhật ký Sửa lỗi - Fix Log 9

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Phát triển AniApp V4 (Chỉnh sửa UI/UX Trang Info)

## 1. Lỗi Cú pháp (Syntax Error) mất thuộc tính AppBar
- **Mô tả lỗi:** Khi tiến hành Hot Restart, Flutter báo một loạt các lỗi tại file `info_screen.dart`:
  - `Expected an identifier, but got 'if'`
  - `Too many positional arguments: 0 allowed, but 2 found`
  - `Expected ';' after this`
- **Nguyên nhân:** Trong quá trình di chuyển nút Đăng xuất lên `AppBar` và dọn dẹp các mã nguồn cũ ở phần thân (`body`), công cụ tự động (AI) đã vô tình xóa nhầm dòng khai báo `appBar: AppBar(` mở đầu của thẻ Scaffold, khiến cho cấu trúc Widget bị hỏng hoàn toàn. Flutter không biết thẻ `actions` và `title` đang thuộc về Widget nào.
- **Cách khắc phục:** 
  - Khôi phục lại đúng cấu trúc khởi tạo Scaffold: Bổ sung lại dòng `appBar: AppBar(` và thuộc tính `title` bị khuyết.
  - Sau khi bổ sung, ứng dụng đã biên dịch (Build) trở lại bình thường.

## 2. Lỗi mất Video Trailer và Thông tin Bối cảnh ở DetailScreen
- **Mô tả lỗi:** Khi vào màn hình chi tiết của một số bộ anime, người dùng không hề thấy khung phát Video Trailer cũng như mục Thông tin bối cảnh xuất hiện (bị trống trơn hoàn toàn).
- **Nguyên nhân:** 
  - *Về Trailer:* Định dạng trả về của Jikan API v4 có sự thiếu đồng nhất. Ở một số bộ anime, biến `trailer.youtube_id` trả về `null` dù thực tế vẫn có trailer, và mã ID Youtube thực chất lại nằm ẩn bên trong chuỗi URL của biến `trailer.embed_url`.
  - *Về Bối cảnh:* Không phải bộ anime nào trên MyAnimeList cũng có thông tin này (Biến `background` trả về `null`). Việc ứng dụng ẩn hoàn toàn Widget đi khi `null` khiến người dùng lầm tưởng đây là lỗi hiển thị.
- **Cách khắc phục:** 
  - **Sửa Model:** Bổ sung thêm hàm `_extractYoutubeId(embedUrl)` bằng RegEx vào `AnimeModel`. Nếu `youtube_id` bị null, hệ thống sẽ tự động bóc tách ID dự phòng từ đường dẫn `embed_url`.
  - **Sửa UI/UX:** Thay vì ẩn đi hoàn toàn, cập nhật `DetailScreen` để luôn luôn hiển thị hai mục này. Nếu dữ liệu API thực sự không tồn tại, hiển thị dòng text thông báo màu xám: *"Phim này chưa có video trailer"* và *"Không có thông tin bối cảnh từ MyAnimeList"* để người dùng hiểu rõ vấn đề là do nguồn dữ liệu.
