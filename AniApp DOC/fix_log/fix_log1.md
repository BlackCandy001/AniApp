# Nhật ký Sửa lỗi (Fix Log 1)

**Thời gian:** 14/05/2026

**Vấn đề:** Ứng dụng không thể khởi chạy trên môi trường Windows Debug Mode do gặp hàng loạt lỗi Compile (biên dịch) liên quan đến đường dẫn file, Type Safety và thư viện.

---

## 1. Xác định các lỗi chính từ Log biên dịch

Qua việc phân tích log build của Flutter, các lỗi được nhóm lại thành 6 vấn đề chính:

1. **Lỗi thiếu class Riverpod (`Type 'StateNotifier' not found`)**:
   - **Nguyên nhân:** File `pubspec.yaml` cài đặt `flutter_riverpod` phiên bản `^3.3.1`. Ở thế hệ 3.x, tác giả thư viện đã xóa sổ hoàn toàn class `StateNotifier` và `StateNotifierProvider` (chuyển qua `Notifier`). Điều này khiến hàng loạt logic quản lý State bị gãy.

2. **Lỗi sai đường dẫn Import (`The system cannot find the path specified`)**:
   - **Nguyên nhân:** Trong lúc tổ chức lại thư mục theo chuẩn Clean Architecture, các đường dẫn tương đối (relative path) như `../../../` bị chỉ định sai cấp thư mục ở các file: `main_screen.dart`, `search_providers.dart`, `detail_providers.dart`, `detail_screen.dart`. Do đó, compiler không tìm thấy các màn hình và provider liên quan.

3. **Lỗi thiếu thư viện GoRouter (`The method 'push' isn't defined`)**:
   - **Nguyên nhân:** File `search_screen.dart` gọi hàm `context.push` để chuyển trang, nhưng thiếu khai báo `import 'package:go_router/go_router.dart';`.

4. **Lỗi Cú pháp chuỗi (`Expected ',' before this`)**:
   - **Nguyên nhân:** Trong `detail_screen.dart`, việc dùng dấu nháy đơn `'?'` bên trong biểu thức nội suy chuỗi vốn cũng được bao bọc bởi nháy đơn `'Số tập: ${anime.episodes ?? '?'}'` gây nhầm lẫn cho compiler.

5. **Lỗi Ép kiểu dữ liệu tự động (`List<dynamic>` không tương thích `List<Widget>`)**:
   - **Nguyên nhân:** Biến `_screens` trong `main_screen.dart` tự động bị ép kiểu thành `List<dynamic>` vì một số Màn hình bên trong nó bị lỗi import (bước 2), dẫn đến không tương thích với widget IndexedStack.

6. **Lỗi Type Safety cho ThemeData (`CardTheme` không tương thích `CardThemeData?`)**:
   - **Nguyên nhân:** Trong `app_theme.dart`, việc tùy biến Theme cho Material 3 gặp xung đột type data của framework.

---

## 2. Các biện pháp đã xử lý

Để khắc phục triệt để, mình đã thực hiện các bước sau:

- **Hạ cấp Riverpod**: Chỉnh sửa file `pubspec.yaml`, đưa `flutter_riverpod` về phiên bản `^2.5.1`. Sau đó chạy lệnh `flutter pub get` để tải lại. Bản 2.x vẫn hỗ trợ mạnh mẽ `StateNotifier` mà không cần đập đi xây lại toàn bộ cấu trúc logic.
- **Fix lại hệ thống Import**: Dò và sửa lại chuẩn đường dẫn tương đối (từ `lib/features/...`) trong tất cả các file bị lỗi để hệ thống tìm đúng các Provider và Widget.
- **Sửa cú pháp nháy kép**: Sửa dòng lỗi trong màn hình chi tiết thành `'Số tập: ${anime.episodes ?? "?"}'`.
- **Tối giản Theme**: Xóa bỏ các khai báo Theme rườm rà gây lỗi của `Card` và `ElevatedButton` trong `app_theme.dart`. Khai báo `useMaterial3: true` mặc định đã bo góc và đổ màu rất chuẩn cho Card.
- **Bổ sung thư viện**: Import trực tiếp package `go_router` vào màn hình Search.
- **Chỉ định kiểu dữ liệu rõ ràng**: Thêm từ khóa `List<Widget>` vào biến `_screens` ở `main_screen.dart` để code an toàn (Type-safe) hơn.

**Kết quả:** 
Dự án đã dọn dẹp sạch toàn bộ lỗi đỏ, các file được liên kết đúng với nhau và ứng dụng có thể build thành công.
