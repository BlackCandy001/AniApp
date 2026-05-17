# Nhật ký tiến độ - Task Log 7

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Khởi động Giai đoạn V3 - Nâng cấp Trải nghiệm Cá nhân & UI Trang Chủ

## 1. Công việc đã thực hiện
### Nâng cấp Trang Cá nhân & Bảo mật (Giai đoạn 1 V3)
- Tích hợp package `image_picker` để cho phép người dùng up ảnh đại diện từ Gallery của thiết bị (lưu dưới dạng đường dẫn File cục bộ).
- Cấu hình thư mục `assets/images/avatars` trong `pubspec.yaml`, đưa 4 ảnh mặc định (ava1 đến ava4) vào mã nguồn để load siêu nhanh qua `AssetImage`.
- Viết lại hàm `updateProfileWithPasswordCheck()` trong `AuthNotifier` để siết chặt tính năng bảo mật: Nếu người dùng thay đổi Email hoặc Mật khẩu, hệ thống bắt buộc phải xác thực Mật khẩu Cũ hợp lệ.
- Nâng cấp giao diện `EditProfileScreen`, thêm biểu tượng Camera và form thay đổi mật khẩu/email.

### Lột xác Trang Chủ (Giai đoạn 2 V3)
- Cài đặt package `carousel_slider`.
- Tạo **Hero Carousel** ở đầu màn hình Home: Hiển thị 5 bộ Anime "Đang chiếu" HOT nhất theo dạng băng chuyền vô cực (Auto play).
- Thiết kế lại AppBar trong suốt (Transparent AppBar) đè lên Carousel để mang lại cảm giác Immersive như Netflix.
- Tái cấu trúc lại UI của các Card Anime (`_AnimeCardWidget`):
  - Tăng độ rộng card để giải tỏa không gian hiển thị (Spacing tốt hơn).
  - Bổ sung hiệu ứng Hover (chuột) và Chạm: Phóng to (Scale) 1.05 lần.
  - Sử dụng Black Gradient mờ dưới đáy ảnh để hiển thị Điểm số (Score) và Tựa phim nổi bật.

## 2. Kết quả đạt được
- Hệ thống User an toàn và linh hoạt hơn, cho phép upload ảnh offline.
- Giao diện Trang chủ trở nên hiện đại, mượt mà và cao cấp hơn đáng kể.

## 3. Bước tiếp theo
- Triển khai **Giai đoạn 3 V3**: Chuyển đổi màn hình Tìm kiếm (Search Screen) sang dạng Streaming App với tính năng Debounce (Real-time suggestion) và màn hình Khám phá.
- Triển khai **Giai đoạn 4 V3**: Cải thiện tương tác thêm/xóa khỏi danh sách và phím tắt tăng giảm nhanh tiến độ tập phim.
