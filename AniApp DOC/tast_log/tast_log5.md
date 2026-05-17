# Nhật ký Nâng cấp (Tast Log 5) - Giai đoạn 1 v2

**Thời gian:** 16/05/2026

**Mục tiêu:** Hoàn thành Giai đoạn 1 của bản nâng cấp v2 bao gồm:
1. Loại bỏ trạng thái "Bỏ dở", đổi tên "Dự định" thành "Theo dõi".
2. Bổ sung đề xuất anime ở Trang chủ và Trang tìm kiếm.

## Chi tiết công việc đã thực hiện:

### 1. Cập nhật Trạng thái (Watchlist)
- **Database (SQLite):** Nâng cấp cấu trúc cơ sở dữ liệu (`version: 2`) trong `database_helper.dart`. Thêm cơ chế tự động chuyển đổi các anime đang có trạng thái `plan` thành `following`, đồng thời xóa bỏ toàn bộ các anime mang trạng thái `dropped` khỏi bảng `watchlist`.
- **Thống kê (`StatsScreen` & `stats_providers.dart`):** Xóa dữ liệu "Bỏ dở" (màu đỏ) khỏi biểu đồ hình tròn (PieChart) và nhãn chú thích. Thay thế trạng thái "Dự định" thành "Theo dõi".
- **Danh sách (`MyListScreen`):** Gỡ bỏ tab "Bỏ dở" và đổi tên tab "Dự định" thành "Theo dõi" để người dùng dễ dàng quản lý.
- **Cập nhật tiến độ (`update_watchlist_bottom_sheet.dart`):** Bỏ tùy chọn "Bỏ dở" trong Menu thả xuống (Dropdown) và đổi mặc định từ "Dự định xem" thành "Theo dõi". Sửa lỗi hiển thị chữ `\${widget.anime.title}` thành nội suy chuỗi chuẩn.

### 2. Mở rộng Khám phá & Gợi ý
- **API (`jikan_api_service.dart`):** Bổ sung hàm `getSeasonsUpcoming()` gọi tới endpoint `/seasons/upcoming` để lấy danh sách các phim chuẩn bị ra mắt. (Đồng thời tiện tay fix các lỗi thiếu biến `$` rải rác trong file).
- **Trang chủ (`HomeScreen`):** Gọi thêm `seasonsUpcomingProvider` và tạo ra danh sách vuốt ngang thứ 2 với tựa đề "Sắp ra mắt", giúp giao diện chính có thêm chiều sâu và nhiều nội dung hiển thị hơn.
- **Tìm kiếm (`SearchScreen`):** Thay vì hiển thị màn hình tĩnh "Nhập ít nhất 2 ký tự..." buồn tẻ, mình đã lập trình để khi thanh tìm kiếm trống, ứng dụng sẽ tự động gọi danh sách "Top Anime" và hiển thị dưới dạng một list "Gợi ý cho bạn" với UI cực kì trực quan (có ảnh, tiêu đề, và điểm đánh giá).

---
**Kết luận:** Giai đoạn 1 đã hoàn thiện mỹ mãn. App đã sẵn sàng bước sang kiến trúc xác thực (Đăng ký/Đăng nhập) bằng SQLite cục bộ ở Giai đoạn 2.
