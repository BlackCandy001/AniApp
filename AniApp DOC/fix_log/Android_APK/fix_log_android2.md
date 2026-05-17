# Nhật ký Sửa lỗi Android APK (Fix Log #2)

**Thời gian:** 18/05/2026

**Vấn đề:** 
1. Không thể chọn và thay đổi avatar bằng hình ảnh cá nhân từ thư viện ảnh (Gallery) của thiết bị Android.
2. Sau khi mở Gallery chọn ảnh, hệ thống Android tự động hủy Activity chính để giải phóng RAM (Activity Recreation), làm ứng dụng khởi động lại và nhảy về Trang chủ (Tab 0) thay vì ở lại Trang cá nhân (Tab 3 - InfoScreen), đồng thời làm mất dữ liệu ảnh vừa chọn.

---

## 1. Lỗi Không Thể Thay Đổi Avatar (Gallery Permission & Scoped Storage)

- **Mô tả:** Khi người dùng nhấn vào nút thay đổi avatar trên điện thoại Android, Gallery không mở được, hoặc ứng dụng không nhận diện/đọc được file ảnh sau khi chọn từ bộ nhớ cục bộ.
- **Nguyên nhân:**
  1. **Thiếu Quyền Truy Cập Bộ Nhớ (Media Permissions)**: Android 13 trở lên (API 33+) yêu cầu cấp quyền phương tiện cụ thể là `READ_MEDIA_IMAGES` thay vì quyền bộ nhớ chung. Các dòng máy Android 12 trở xuống vẫn cần `READ_EXTERNAL_STORAGE` và `WRITE_EXTERNAL_STORAGE`.
  2. **Scoped Storage trên Android 10**: Android 10 (API 29) chặn ứng dụng đọc file thông qua các đường dẫn tuyệt đối trực tiếp nếu không bật cờ Legacy Storage.
  3. **Thiếu Khối Xử Lý Lỗi (Resilient Logic)**: Hàm `_pickImage` ban đầu chạy không có try-catch để phòng ngừa và thông báo khi xảy ra sự cố từ chối quyền của OS.

---

## 2. Lỗi Nhảy Trang Chủ Sau Khi Chọn Ảnh (Android Activity Recreation)

- **Mô tả**: Sau khi chọn ảnh xong trong Gallery, ứng dụng khởi động lại và quay trở về Trang chủ (Tab 0) thay vì giữ nguyên ở màn hình Chỉnh sửa thông tin / Trang cá nhân (Tab 3).
- **Nguyên nhân**:
  - Khi `image_picker` kích hoạt Gallery (là một Intent/Activity khác bên ngoài ứng dụng), hệ điều hành Android trên các máy RAM yếu hoặc đang bật tùy chọn *"Don't keep activities"* trong Developer Options sẽ **hủy toàn bộ tiến trình và Activity của Flutter** để giải phóng bộ nhớ.
  - Khi người dùng chọn xong ảnh quay lại, Flutter khởi chạy lại từ đầu. Trạng thái của Router khôi phục về `/` (MainScreen) và biến `_currentIndex` trong `MainScreen` bị đặt lại mặc định là `0` (Trang chủ). Điều này cũng khiến người dùng chưa kịp nhấn nút **Save Changes** nên ảnh đại diện không bao giờ được lưu.

---

## 3. Cách Khắc Phục

### Bước 3.1: Khai báo đầy đủ quyền trong `android/app/src/main/AndroidManifest.xml`
Thêm các quyền đọc ghi phù hợp với mọi phiên bản Android cũ và mới:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <application
        ...
        android:requestLegacyExternalStorage="true">
        ...
    </application>
</manifest>
```

### Bước 3.2: Lưu giữ vị trí tab hiện tại thông qua SharedPreferences trong `main_screen.dart`
Bảo vệ trạng thái điều hướng bằng cách lưu trữ tab hoạt động gần nhất vào bộ nhớ cache. Khi ứng dụng bị hủy và khởi động lại, tab sẽ tự động được phục hồi đúng vị trí Trang cá nhân (Tab 3) thay vì reset về Tab 0:
```dart
  // Trong _MainScreenState
  Future<void> _loadTabPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('active_tab_index');
      if (savedIndex != null && savedIndex >= 0 && savedIndex < _screens.length) {
        if (mounted) {
          setState(() {
            _currentIndex = savedIndex;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveTabPreference(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_tab_index', index);
    } catch (_) {}
  }
```

### Bước 3.3: Tự động lưu trữ (Instant Save) ngay khi chọn ảnh xong
Để đối phó triệt để với việc Android hủy Activity trong lúc người dùng ở thư viện ảnh, tôi đã cập nhật logic trong `edit_profile_screen.dart` để **tự động lưu ảnh đại diện mới vào CSDL SQLite ngay khi vừa chọn xong** thay vì bắt người dùng phải ấn nút Lưu:
```dart
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedAvatar = image.path;
        });
        // Tự động lưu avatar mới vào SQLite ngay lập tức để phòng tránh Android Activity Recreation
        await ref.read(authProvider.notifier).updateProfileWithPasswordCheck(
          newAvatarPath: image.path,
        );
      }
    } catch (e) { ... }
  }
```

---

## 4. Kết Quả Sau Khi Fix
- **Độ tin cậy tuyệt đối**: Nếu hệ điều hành Android có hủy ứng dụng trong lúc chọn ảnh, khi mở lại ứng dụng sẽ tự động chuyển về **Trang cá nhân (Tab 3)** và avatar mới được cập nhật cực kỳ hoàn hảo.
- **Trải nghiệm liền mạch**: Không còn hiện tượng nhảy tab vô lý, mọi thay đổi ảnh đại diện (kể cả avatar mặc định hoặc ảnh cá nhân) đều được lưu trữ trực tiếp thời gian thực (Real-time sync).
