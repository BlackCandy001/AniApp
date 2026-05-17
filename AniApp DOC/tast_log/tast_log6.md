# Nhật ký Nâng cấp (Tast Log 6) - Giai đoạn 2 & 3 v2

**Thời gian:** 16/05/2026

**Mục tiêu:** Tích hợp hệ thống Đăng nhập / Đăng ký Offline bằng SQLite và xây dựng Trang Thông tin Cá nhân (Info Screen).

## Chi tiết công việc đã thực hiện:

### 1. Giai đoạn 2: Hệ thống Xác thực Offline (SQLite Authentication)
- **Database (`database_helper.dart`):** Nâng cấp Database lên `version: 3`. Tạo thêm bảng `users` với các cột bảo mật (`email UNIQUE`, `password`, `username`, `avatar_path`, `created_at`) để lưu trữ tài khoản của người dùng cục bộ hoàn toàn.
- **Model (`user_model.dart`):** Tạo model phản chiếu bảng `users` giúp phân tích và đóng gói dữ liệu lấy từ SQLite.
- **State Management (`auth_providers.dart`):** Viết `AuthNotifier` sử dụng Riverpod kết hợp với `SharedPreferences` để duy trì phiên đăng nhập sau khi tắt app. Tích hợp logic xử lý Đăng nhập, Đăng ký (Validate email đã tồn tại), Cập nhật thông tin và Đăng xuất.
- **Giao diện Đăng nhập/Đăng ký:**
  - `LoginScreen`: Form tối giản và đẹp mắt, kiểm tra tính hợp lệ của email.
  - `RegisterScreen`: Bổ sung thêm các luật kiểm tra (Tên > 3 ký tự, Pass > 6 ký tự, 2 ô Pass phải trùng khớp).
- **Luồng Điều hướng Thông minh (`app_router.dart`):** Thay vì khóa ép người dùng vào màn hình Login, đã tùy biến lại hệ thống điều hướng: Cho phép lướt web như tài khoản "Khách" (Guest), và cung cấp nút Đăng nhập nếu muốn đồng bộ danh sách. Màn hình Login cũng được thêm nút quay lại (`AppBar`).

### 2. Giai đoạn 3: Màn hình Thông tin Cá nhân (Info Screen) Tích hợp Thống kê
- **Điều hướng Chính (`main_screen.dart`):** Loại bỏ tab "Thống kê" rời rạc, tinh giản thanh `BottomNavigationBar` xuống còn 4 tab gọn gàng (Trang chủ, Tìm kiếm, Danh sách, Cá nhân).
- **Trang Info (`info_screen.dart`):** Được thiết kế lại toàn diện thành 3 phân khu chính:
  - **Khu vực 1 - Định danh:** Nếu là tài khoản Khách, hiển thị nút Đăng nhập/Đăng ký. Nếu đã đăng nhập, hiển thị Avatar lớn, Tên và Email.
  - **Khu vực 2 - Thống kê Anime:** Tích hợp trực tiếp Biểu đồ phân bổ trạng thái (Pie Chart) và các thẻ báo cáo tổng số tập, điểm số trung bình (sử dụng thư viện `fl_chart`). Hoạt động mượt mà cho cả tài khoản Khách (dựa trên DB Offline). Đã khắc phục triệt để lỗi hiển thị chuỗi nội suy (string interpolation) để hiển thị chính xác các con số thực tế thay vì biến văn bản.
  - **Khu vực 3 - Quản lý Dữ liệu:** Chuyển các nút Xuất dữ liệu (Export JSON), Xóa dữ liệu (Delete) và Đăng xuất (Logout) xuống cuối trang để tối ưu UX. Tích hợp nút đổi Giao diện Sáng/Tối lên góc AppBar.
- **Trang Cập nhật Hồ sơ (`edit_profile_screen.dart`):** Người dùng có thể đổi Tên hiển thị. Tích hợp một bộ 8 Avatar mẫu có sẵn giúp người dùng thay đổi hình đại diện ngay lập tức mà không cần cấp quyền truy cập file rườm rà.

---
**Kết luận:** Ứng dụng đã hoàn chỉnh mô hình quản lý Tài khoản cục bộ thân thiện với UX. Bước tiếp theo có thể chuyển sang Giai đoạn 4: Tính năng Thông báo (Notification).
