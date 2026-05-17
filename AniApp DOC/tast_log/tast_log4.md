# Nhật ký phát triển (Task Log 4) - Hoàn thành Giai đoạn 3 (Kết thúc)

**Thời gian:** 14/05/2026

## Các thay đổi đã thực hiện:

1. **Màn hình Thống kê (Stats Screen)**:
   - Xây dựng trang tổng quan thống kê số liệu cá nhân: Tổng số Anime đã lưu, Tổng số tập đã cày, và Điểm trung bình.
   - Tích hợp thư viện `fl_chart` để render biểu đồ tròn (Pie Chart) đầy màu sắc, phân tích tỷ lệ các bộ anime theo trạng thái (Đang xem, Đã xem, Dự định, Bỏ dở).
   
2. **Cơ chế Chuyển đổi Theme (Light / Dark Mode)**:
   - Viết `theme_provider.dart` quản lý Theme. Mặc định đọc theo hệ thống, nhưng cho phép gạt công tắc chuyển đổi (nút mặt trăng/mặt trời) ở màn hình Thống kê.
   - Lưu trữ lại lựa chọn của người dùng qua `shared_preferences` để ghi nhớ cho lần mở app sau.

3. **Công cụ Quản lý Dữ liệu**:
   - Chức năng **Xuất dữ liệu (JSON)**: Cho phép chuyển toàn bộ thông tin SQLite thành JSON và copy thẳng vào bộ nhớ tạm (Clipboard) của điện thoại để sao lưu.
   - Chức năng **Xóa toàn bộ dữ liệu**: Hiển thị Hộp thoại Cảnh báo (`AlertDialog`) yêu cầu xác nhận 2 lần trước khi xóa sạch dữ liệu trong local DB.

4. **Trải nghiệm Ngoại tuyến (Offline Mode)**:
   - Lắng nghe trạng thái mạng liên tục qua package `connectivity_plus` ngay tại trang gốc (`MainScreen`).
   - Ngay khi người dùng bị rớt mạng, một dải Banner thông báo màu đỏ sẽ xuất hiện, đồng thời dữ liệu hình ảnh (poster) vẫn load bình thường nhờ cache từ `cached_network_image`. Các API bị chặn an toàn.

**Kết luận:** Đã triển khai xong 100% Giai đoạn 3 và hoàn thiện toàn bộ tính năng của dự án AnimeTracker như bản kế hoạch đã vạch ra. Ứng dụng đã sẵn sàng để kiểm thử thực tế và build ra file cài đặt (.apk / .ipa).
