# 📋 Kế Hoạch Sửa Lỗi Trước Khi Nộp Bài
**Dự án:** AniApp V4  
**Mục tiêu:** Đảm bảo đáp ứng 100% yêu cầu đề bài trong `YEU_CAU.md`  
**Ngày lập:** 2026-05-17

---

## Danh Sách Công Việc

---

### Task 1 — Sửa Offline Banner Hard-code Tiếng Việt
**File:** `lib/features/home/presentation/screens/main_screen.dart` (dòng ~61)  
**Mức độ:** 🟡 Dễ  
**Ưu tiên:** Cao (liên quan đến Localization)  
**Trạng thái:** [ ] Chưa làm

**Vấn đề:**
```dart
// Hiện tại — hard-code tiếng Việt
child: const Text(
  'Mất kết nối mạng. Bạn đang xem dữ liệu Offline.',
  ...
),
```

**Kế hoạch sửa:**
1. Thêm key `'offline_banner'` vào `AppLocalizations` cho cả 3 ngôn ngữ (VI/EN/JA)
2. Thay thế text cứng bằng `AppLocalizations.get(currentLang, 'offline_banner')`

**Nội dung cần thêm vào `app_localizations.dart`:**
```
vi: 'Mất kết nối mạng. Bạn đang xem dữ liệu Offline.'
en: 'No internet connection. You are viewing Offline data.'
ja: 'インターネット接続がありません。オフラインデータを表示しています。'
```

---

### Task 2 — Thêm Responsive Layout (LayoutBuilder / OrientationBuilder)
**File:** `lib/features/home/presentation/screens/home_screen.dart`  
**Mức độ:** 🟠 Trung bình  
**Ưu tiên:** Cao (đây là tiêu chí bắt buộc trong đề)  
**Trạng thái:** [x] Đã hoàn thành ✅
Đề bài yêu cầu: *"Hỗ trợ Responsive (Xử lý được chế độ Xoay ngang/Dọc hoặc các kích thước màn hình khác nhau)"*.  
Hiện tại app chưa có `OrientationBuilder` hay `LayoutBuilder` rõ ràng để giám khảo dễ nhận biết.

**Kế hoạch sửa:**  
Áp dụng `LayoutBuilder` vào phần danh sách ngang trong `HomeScreen`:
- Nếu chiều rộng **≥ 600px** (tablet/landscape): hiển thị dạng **Grid 2 cột**
- Nếu chiều rộng **< 600px** (phone/portrait): hiển thị dạng **danh sách ngang** như hiện tại

**Vị trí áp dụng:** Hàm `_buildHorizontalList()` trong `home_screen.dart`

```dart
// Pseudocode
Widget _buildHorizontalList(...) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 600) {
        // Hiển thị GridView 2 cột cho tablet/landscape
        return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2));
      } else {
        // Hiển thị ListView ngang như cũ
        return SizedBox(height: 220, child: ListView.builder(scrollDirection: Axis.horizontal, ...));
      }
    },
  );
}
```

---

### Task 3 — (Tùy chọn) Thêm Comment Vào Các File Quan Trọng
**Files:** Tất cả các `*_providers.dart`, `database_helper.dart`, `notification_service.dart`  
**Mức độ:** 🟢 Dễ  
**Ưu tiên:** Trung bình (yêu cầu: "code rõ ràng, có comment cơ bản")  
**Trạng thái:** [ ] Chưa làm

**Kế hoạch:**  
Thêm block comment tổng quan ở đầu mỗi file, ví dụ:

```dart
/// [AuthNotifier] - Quản lý trạng thái xác thực người dùng.
/// Sử dụng SQLite để lưu thông tin user và SharedPreferences để
/// duy trì phiên đăng nhập giữa các lần mở app.
```

**Danh sách file cần comment:**
- [ ] `lib/features/auth/presentation/auth_providers.dart`
- [ ] `lib/data/local/database_helper.dart`
- [ ] `lib/core/services/notification_service.dart`
- [ ] `lib/core/services/tracking_service.dart`
- [ ] `lib/core/localization/app_localizations.dart`

---

### Task 4 — Chuẩn Bị Deliverables (Tài liệu Nộp Bài)
**Mức độ:** 🔴 Quan trọng nhất  
**Ưu tiên:** Rất cao  
**Trạng thái:** [ ] Chưa làm

Theo yêu cầu đề bài, cần nộp 3 thứ:

#### 4.1 — Source Code Sạch
- [ ] Xóa thư mục `build/` trước khi nén
- [ ] Kiểm tra `flutter analyze` không có lỗi
- [ ] Đặt tên file nén: `AniApp_[TenSinhVien].zip`

#### 4.2 — Báo Cáo Kỹ Thuật (PDF)
Cần bao gồm các mục sau:

| Mục | Nội dung |
|---|---|
| Ý tưởng | Ứng dụng theo dõi Anime cá nhân, tra cứu từ MyAnimeList API |
| Workflow | Sơ đồ luồng: Splash → Auth → Main (Home/Search/MyList/Profile) → Detail |
| Chức năng hoàn thành | Xem danh sách đầy đủ tại `tast4.md` |
| Mô hình CSDL | Schema 4 bảng: `users`, `watchlist`, `notes`, `watch_history` |
| Kỹ thuật nâng cao | Localization 3 ngôn ngữ, Push Notification, Image Picker, Translation API |

#### 4.3 — Video Demo
- [ ] Quay màn hình trên thiết bị thật (Android) hoặc giả lập
- [ ] Thời lượng: 3–5 phút
- [ ] Cần trình bày rõ:
  - Màn hình Home với Carousel và danh sách
  - Tìm kiếm Anime theo tên
  - Thêm anime vào danh sách, cập nhật tiến độ
  - Đăng ký / Đăng nhập tài khoản
  - Chuyển đổi Dark/Light mode
  - **Chuyển đổi ngôn ngữ** (VI → EN → JA)
  - Màn hình Thống kê cá nhân

---

## Thứ Tự Thực Hiện

```
Task 1 (15 phút) → Task 2 (1 giờ) → Task 3 (30 phút) → Task 4 (2–3 giờ)
```

**Tổng thời gian ước tính:** ~4–5 giờ

---

## Kiểm Tra Cuối Cùng Trước Khi Nộp

- [ ] `flutter analyze` — 0 errors, 0 warnings
- [ ] Build Android APK thành công (`flutter build apk`)
- [ ] Test trên thiết bị thật: Offline banner, Push Notification, Image Picker
- [ ] Chuyển đổi ngôn ngữ hoạt động trên toàn bộ màn hình
- [ ] Dark/Light mode không có lỗi hiển thị
- [ ] Tất cả Form Validation hoạt động đúng
