# Nhật ký phát triển (Task Log 3) - Hoàn thành Giai đoạn 2

**Thời gian:** 14/05/2026

## Các thay đổi đã thực hiện:

1. **Màn hình Tìm kiếm (Search Screen)**:
   - Xây dựng giao diện tìm kiếm dạng lưới (Grid) 2 cột sử dụng `CachedNetworkImage`.
   - Triển khai **Debounce logic (500ms)** trong `search_providers.dart` giúp hoãn tự động gọi API, tối ưu hóa băng thông và tránh lỗi 429 Too Many Requests từ Jikan API.
   - Thêm Form Validation: Ngăn chặn tìm kiếm nếu từ khóa có độ dài dưới 2 ký tự.

2. **Màn hình Chi tiết (Detail Screen)**:
   - Tích hợp **Hero Animation** tạo chuyển động mượt mà cho ảnh poster.
   - Xây dựng layout bằng **SliverAppBar** và `FlexibleSpaceBar` với `expandedHeight` đạt 300.
   - Bổ sung **BottomSheet** (`UpdateWatchlistBottomSheet`) để thao tác cập nhật tiến độ xem:
     - Form nhập liệu có validation mạnh: số tập phải là số dương, không vượt quá tổng số tập phát hành.
     - Tích hợp package `flutter_rating_bar` yêu cầu bắt buộc chấm điểm từ 1-10 sao trước khi lưu.

3. **Màn hình Danh sách Cá nhân (My List Screen)**:
   - Tạo `TabBar` với 5 trạng thái (Tất cả, Đang xem, Đã xem, Dự định, Bỏ dở).
   - Tự động lấy dữ liệu Offline từ SQLite thông qua `watchlistProvider`.
   - Cài đặt tính năng **Swipe-to-delete** (vuốt để xóa) sử dụng widget `Dismissible`.

4. **Hệ thống Cấu trúc Màn hình (Main Navigation)**:
   - Tạo `MainScreen` làm Root cho `NavigationBar`.
   - Tối ưu hóa UI bằng `IndexedStack`, giúp chuyển qua lại giữa các tab (Trang chủ, Tìm kiếm, Danh sách) mà không làm mất trạng thái hay load lại dữ liệu không cần thiết.

**Kết quả:** Đã hoàn tất xuất sắc toàn bộ yêu cầu của Giai đoạn 2 (Tính năng Cốt lõi). Ứng dụng đã có luồng làm việc khép kín: Tìm phim -> Xem chi tiết -> Lưu vào SQLite -> Xem lại ở tab Danh sách cá nhân.
