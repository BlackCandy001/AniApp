# Fix Log 5 - Sửa lỗi luồng Xác thực và Hiển thị (Authentication & Navigation)

**Thời gian:** 16/05/2026

## 1. Lỗi sai đường dẫn Import (Build Error)
*   **Mô tả:** Lỗi `The system cannot find the path specified` và `The getter 'authProvider' isn't defined` khi build ứng dụng.
*   **Nguyên nhân:** File `info_screen.dart` và `edit_profile_screen.dart` nằm ở độ sâu 3 cấp thư mục (`lib/features/profile/presentation/screens`), nhưng lệnh import file `auth_providers.dart` lại chỉ lùi ra 2 cấp (`../../auth/...`).
*   **Cách khắc phục:** Cập nhật lại chính xác đường dẫn tương đối thành `../../../auth/presentation/auth_providers.dart`.

## 2. Trải nghiệm bắt buộc Đăng nhập tồi (UX/Redirect Bug)
*   **Mô tả:** Người dùng bị kẹt ở màn hình Login, ép buộc phải đăng ký tài khoản thì mới dùng được tính năng tìm kiếm và xem phim. Đồng thời, khi đăng nhập xong router không tự điều hướng.
*   **Nguyên nhân:** Hàm `redirect` của `GoRouter` được cài đặt để khóa tất cả đường dẫn (ngoại trừ `/login` và `/register`) khi `user == null`.
*   **Cách khắc phục:** 
    *   Loại bỏ hoàn toàn cơ chế `redirect` khắt khe trong `app_router.dart`.
    *   Sử dụng `context.go('/')` trực tiếp sau khi xác thực thành công ở `login_screen.dart`.
    *   Bổ sung nút Quay lại (`AppBar` trong suốt) ở `login_screen.dart` để quay về app.

## 3. Lỗi Infinite Loading ở InfoScreen (StateNotifier Bug)
*   **Mô tả:** Khi vào trang Cá nhân lúc chưa đăng nhập, giao diện hiện `CircularProgressIndicator` xoay liên tục không điểm dừng.
*   **Nguyên nhân:** `StateNotifier` của Riverpod sẽ không kích hoạt hàm vẽ lại giao diện (`build`) nếu trạng thái mới gán có giá trị giống hệt trạng thái cũ (cụ thể là `null` vẫn hoàn `null`). Việc dùng một biến `bool _isInit` bên trong class sẽ không có tác dụng thông báo sự thay đổi lên UI.
*   **Cách khắc phục:** 
    *   Tách biến trạng thái Loading ra thành một Provider riêng biệt: `final authInitProvider = StateProvider<bool>((ref) => false);`.
    *   Trong `InfoScreen`, gọi `ref.watch(authInitProvider)`.
    *   Tại `auth_providers.dart`, dùng `ref.read(authInitProvider.notifier).state = true` để báo hiệu đã load Database xong, ngay lập tức tắt vòng xoay Loading.

## 4. Lỗi gọi hàm notifyListeners sai cấu trúc
*   **Mô tả:** Sử dụng nhầm `ref.notifyListeners()` bên trong lớp `AuthNotifier` kế thừa `StateNotifier`.
*   **Cách khắc phục:** Xóa bỏ lời gọi hàm không tồn tại này, tuân thủ đúng kiến trúc Reactive của Riverpod.
