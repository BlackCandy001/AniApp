# Nhật ký Sửa lỗi (Fix Log 2)

**Thời gian:** 14/05/2026

**Vấn đề:** Ứng dụng tiếp tục vấp phải một số lỗi biên dịch (Compile Errors) bổ sung ở lần chạy thứ 2. Các lỗi này chủ yếu tập trung vào cú pháp nội suy chuỗi của Dart và lỗi thiếu liên kết Import của các thư mục mới.

---

## 1. Xác định các lỗi từ Log biên dịch lần 2

Qua phân tích Log, có 2 nhóm lỗi chính phát sinh:

1. **Lỗi đứt gãy liên kết Import Provider (`The system cannot find the path specified`)**:
   - **Chi tiết:** File `stats_providers.dart` không thể nạp file `mylist_providers.dart`.
   - **Nguyên nhân:** Đường dẫn tương đối (relative path) được khai báo là `../../../mylist/presentation/mylist_providers.dart` đã lùi lại quá số cấp thư mục cần thiết (bị vượt ra khỏi thư mục `features`).
   - **Hệ quả:** Dẫn đến hiệu ứng domino gây lỗi `Undefined name 'watchlistProvider'` bên trong `stats_screen.dart` và chính `stats_providers.dart`.

2. **Lỗi cú pháp lồng chuỗi (String Interpolation Parsing Error)**:
   - **Chi tiết:** Các thông báo lỗi như `Expected ',' before this`, `Expected ':'`, hay `The operator '-' isn't defined` xuất hiện đồng loạt trong các file `detail_screen`, `mylist_screen` và `stats_screen`.
   - **Nguyên nhân:** Khi thực hiện nội suy chuỗi trong Dart với toán tử `??`, nếu chuỗi bên ngoài và chuỗi cung cấp giá trị mặc định bên trong dùng cùng một loại dấu nháy (nháy đơn `' '`), trình biên dịch sẽ hiểu sai điểm kết thúc của chuỗi. 
     - *Ví dụ sai:* `'Số tập: ${anime.episodes ?? '?'}'`. Compiler tưởng chuỗi đã kết thúc ở `'Số tập: ${anime.episodes ?? '`, phần `?` và `'}'` đằng sau biến thành cú pháp sai.

---

## 2. Các biện pháp đã xử lý

Để khắc phục dứt điểm, mình đã thực hiện các điều chỉnh sau:

- **Sửa đường dẫn tương đối (Relative Path)**: Cập nhật lại đường dẫn trong `stats_providers.dart` thành đúng chuẩn cấp bậc `../../mylist/presentation/mylist_providers.dart`. Đồng thời, thêm dòng import provider này vào `stats_screen.dart` để màn hình thống kê có thể trích xuất dữ liệu độ dài anime.
- **Thay đổi định dạng chuỗi (String Formatting)**: Dò tìm toàn bộ các dòng code sử dụng nội suy chuỗi có chứa nháy đơn lồng nhau (trong 3 file: `detail_screen`, `mylist_screen`, `stats_screen`) và đổi ký tự bao bọc chuỗi cha sang **nháy kép** (`" "`).
  - *Ví dụ đã sửa:* `"Số tập: ${anime.episodes ?? '?'}"`. Điều này tạo ra sự phân tách rõ ràng cho Parser của Dart, giúp việc biên dịch thành công ngay lập tức.
  - Xử lý tương tự đối với việc truy xuất key của Map trong `stats_screen`: Đổi thành `"${stats['totalAnime']}"`.

**Kết quả:**
Đã vá hoàn chỉnh tất cả các "lỗ hổng" cú pháp cuối cùng của project. Ứng dụng hiện tại đã Compile thành công 100% trên Windows Desktop.
