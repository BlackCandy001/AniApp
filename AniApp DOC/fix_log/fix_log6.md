# Nhật ký sửa lỗi - Fix Log 6

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Phát triển V3 (Notification & UI/UX V3)

## 1. Lỗi Build APK do thiếu thư viện Desugaring cho Java 8
- **Mô tả lỗi:** Khi chạy `flutter build apk`, Gradle báo lỗi: `Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app`. Nguyên nhân là do package `flutter_local_notifications` sử dụng các hàm API Java mới, không tương thích ngược với các phiên bản Android cũ nếu chưa bật Desugaring.
- **Cách khắc phục:**
  - Chỉnh sửa file `android/app/build.gradle.kts` (Kotlin DSL).
  - Thêm cờ `isCoreLibraryDesugaringEnabled = true` vào khối `compileOptions`.
  - Bổ sung thư viện biên dịch ngược vào phần `dependencies`: `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`.
  - Kết quả: App build thành công release APK.

## 2. Crash ứng dụng do NetworkImage không đọc được File Local
- **Mô tả lỗi:** Báo lỗi `ArgumentError: Invalid argument(s): No host specified in URI file:///C:/Users/...` khi tải màn hình **Thông tin Cá nhân (InfoScreen)**.
- **Nguyên nhân:** Do ở Giai đoạn 1 của V3, ứng dụng chuyển sang sử dụng Avatar từ bộ nhớ máy (`File`) hoặc Local Assets (`assets/...`). Tuy nhiên, `InfoScreen` vẫn bị hardcode để luôn vẽ Avatar bằng `NetworkImage(user.avatarPath!)`, dẫn đến lỗi vì đây không phải là đường dẫn URL hợp lệ.
- **Cách khắc phục:**
  - Bổ sung hàm `_getAvatarImage(String? avatarPath)` vào `info_screen.dart`.
  - Logic phân loại:
    - Nếu chuỗi bắt đầu bằng `http` -> Dùng `NetworkImage`.
    - Nếu chuỗi bắt đầu bằng `assets/` -> Dùng `AssetImage`.
    - Các trường hợp còn lại -> Dùng `FileImage`.
  - Cập nhật widget `CircleAvatar` để sử dụng hàm mới. Lỗi đã được giải quyết hoàn toàn.

## 3. Các tinh chỉnh UX/UI bổ sung
- **Lỗi Reset Navigation (Nhảy về trang chủ sau khi sửa Profile):**
  - **Nguyên nhân:** Do `routerProvider` (GoRouter) có gọi `ref.watch(authProvider)`. Mỗi khi thông tin User thay đổi (Edit Profile), toàn bộ GoRouter bị khởi tạo lại, khiến Navigation Stack bị xóa và người dùng bị ném về `initialLocation: '/'`.
  - **Cách khắc phục:** Xóa bỏ lệnh `ref.watch(authProvider)` bên trong `app_router.dart`. (Vì hiện tại app không có logic chặn route bắt buộc đăng nhập).
- **Trải nghiệm Danh sách:**
  - Sắp xếp Anime trong MyList mặc định theo **Điểm đánh giá** từ cao xuống thấp. Khi cập nhật số tập, vị trí các Card sẽ không bị xáo trộn.
  - Di chuyển các nút bấm `[+]` và `[-]` tăng giảm số tập ra khỏi MyList, đưa thẳng vào trong **DetailScreen (Chi tiết phim)** để tránh bấm nhầm và giữ UI gọn gàng.
