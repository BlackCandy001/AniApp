# Kế Hoạch Phát Triển AniApp v2 (Bản Nâng Cấp)

Dựa trên các yêu cầu cập nhật v2, dưới đây là lộ trình chi tiết để triển khai các tính năng mới một cách khoa học, đảm bảo không phá vỡ cấu trúc Clean Architecture hiện tại của ứng dụng.

## Giai đoạn 1: Điều chỉnh Logic hiện tại & Nâng cấp Khám phá (Hiển thị)
**1.1. Cập nhật Trạng thái Watchlist (Yêu cầu thay đổi)**
*   **Mô tả:** Thay đổi danh sách trạng thái khi người dùng thêm phim vào danh sách.
*   **Công việc:**
    *   Xóa bỏ tùy chọn "Bỏ dở" (Dropped) khỏi Model, Database và UI.
    *   Đổi tên hiển thị của trạng thái "Dự định" thành "Theo dõi" (Following).
    *   Cập nhật lại biểu đồ thống kê (`PieChart`) trong `StatsScreen` để chỉ hiển thị 3 trạng thái: *Đang xem, Đã xem, Theo dõi*.

**1.2. Mở rộng Đề xuất Anime (Trang chủ & Tìm kiếm)**
*   **Mô tả:** Làm cho ứng dụng sinh động hơn khi người dùng vừa mở app hoặc đang ở trang tìm kiếm nhưng chưa biết tìm gì.
*   **Công việc:**
    *   **Trang chủ (`HomeScreen`):** Gọi thêm Jikan API để hiển thị thêm 1-2 danh sách ngang (ví dụ: *Anime sắp ra mắt (Upcoming)* hoặc *Anime được yêu thích nhất (Popular)*).
    *   **Trang tìm kiếm (`SearchScreen`):** Sửa logic để khi thanh tìm kiếm trống, tự động hiển thị một danh sách "Anime Đề Xuất" (Gợi ý ngẫu nhiên hoặc Top Anime) thay vì để màn hình đen tĩnh lặng.

---

## Giai đoạn 2: Hệ thống Định danh (Authentication)
**2.1. Xây dựng Luồng Đăng nhập / Đăng ký**
*   **Mô tả:** Cho phép người dùng tạo tài khoản để cá nhân hóa trải nghiệm.
*   **Công việc:**
    *   Tạo màn hình `LoginScreen`: Gồm trường nhập Email, Mật khẩu và nút Đăng nhập.
    *   Tạo màn hình `RegisterScreen`: Gồm trường nhập Tên tài khoản, Email, Mật khẩu, Xác nhận mật khẩu. Viết hàm Validate (kiểm tra email hợp lệ, độ dài mật khẩu, 2 mật khẩu phải khớp nhau).
    *   Thiết lập Database cục bộ (SQLite) hoặc tích hợp nền tảng (Firebase Auth) để lưu trữ và xác thực thông tin User an toàn.

**2.2. Xử lý Đăng xuất & Phiên hoạt động (Session)**
*   **Công việc:** 
    *   Tạo `auth_provider` để quản lý trạng thái: Nếu chưa đăng nhập thì tự động chuyển hướng (Redirect) về `LoginScreen` thay vì vào Trang chủ.
    *   Cấu hình nút Đăng xuất để xóa phiên làm việc và đưa người dùng về trang Đăng nhập.

---

## Giai đoạn 3: Màn hình Thông tin Cá nhân (Info Screen)
**3.1. Thiết kế Trang Info**
*   **Mô tả:** Nơi hiển thị và chỉnh sửa thông tin người dùng.
*   **Công việc:**
    *   Thêm tab "Cá nhân" (Info) vào thanh điều hướng dưới cùng (`BottomNavigationBar`).
    *   Thiết kế giao diện hiển thị: Avatar to ở giữa, Tên tài khoản, Email bên dưới. Cung cấp nút chuyển tới màn hình "Chỉnh sửa thông tin".
    *   Chuyển nút chức năng "Xuất dữ liệu", "Xóa dữ liệu" từ trang Thống kê sang trang Info cho hợp lý về UX.

**3.2. Tính năng Cập nhật Hồ sơ**
*   **Công việc:**
    *   Cho phép người dùng nhập lại Tên tài khoản.
    *   Tích hợp tính năng chọn Avatar: Cung cấp một bộ ảnh Avatar có sẵn (hoặc cho phép chọn ảnh từ thư viện thiết bị bằng package `image_picker`).

---

## Giai đoạn 4: Hệ thống Thông báo (Tính năng thông minh)
**4.1. Cơ chế theo dõi (Tracking Mechanism)**
*   **Mô tả:** Thông báo cho người dùng khi bộ anime họ "Theo dõi" hoặc "Đang xem" có cập nhật mới.
*   **Công việc:**
    *   **Logic:** Vì Jikan API không có tính năng Push Notification, ứng dụng sẽ chạy nền hoặc chạy ngầm mỗi khi người dùng mở App. Hệ thống sẽ lấy danh sách các anime thuộc trạng thái "Theo dõi/Đang xem", kiểm tra số tập hiện tại trên mạng so với số tập đã lưu cục bộ.
    *   **Tạo chuông:** Nếu trên mạng có số tập mới cao hơn, ứng dụng sẽ tự động sinh ra một "Thông báo" mới.

**4.2. Giao diện Thông báo**
*   **Công việc:**
    *   Thêm biểu tượng "Cái chuông" ở góc trên cùng bên phải của `HomeScreen`. (Có chấm đỏ nếu có thông báo chưa đọc).
    *   Tạo màn hình `NotificationScreen` hiển thị lịch sử thông báo (ví dụ: *"Bộ phim Solo Leveling vừa ra mắt tập 12!"*).

---
*Lưu ý cho Developer: Bạn có muốn sử dụng cơ sở dữ liệu nội bộ cục bộ (Local SQLite) cho hệ thống Đăng nhập/Đăng ký để app hoàn toàn Offline, hay muốn tích hợp Backend thực thụ như Firebase để đồng bộ danh sách lên đám mây? Hãy xác nhận trước khi code Giai đoạn 2.*
