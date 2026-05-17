# Nhật ký Sửa lỗi (Fix Log 3)

**Thời gian:** 14/05/2026

**Vấn đề:** Ứng dụng đã vượt qua khâu biên dịch (Compile) nhưng lại dính "Runtime Error" (Lỗi trong lúc ứng dụng đang chạy). Cụ thể, khi người dùng click vào một Anime để xem chi tiết, ứng dụng bị ngắt kết nối và văng lỗi (Crash).

---

## 1. Phân tích các lỗi từ Log Runtime

Quá trình quét Stack Trace trên Debug Terminal đã tiết lộ 2 Exception xảy ra cùng một thời điểm:

1. **Lỗi FormatException (`Invalid radix-10 number`)**:
   - **Mô tả:** Hệ thống bị sập khi thư viện `go_router` kích hoạt hàm `int.parse()` ở dòng 21 file `app_router.dart`.
   - **Nguyên nhân:** Việc điều hướng sử dụng cú pháp nội suy chuỗi vô tình chứa ký tự Escape (`\`) trước ký hiệu đô la (`$`). Cụ thể, thay vì truyền một đường dẫn hợp lệ kiểu `/detail/123`, ứng dụng lại truyền chuỗi nguyên văn là `/detail/${anime.malId}` vào bộ xử lý của Router. Khi thuật toán đọc thấy chữ `$`, nó không thể phân tích chuỗi đó thành số nguyên, dẫn đến lỗi.

2. **Lỗi xung đột Hero Animation (`multiple heroes that share the same tag`)**:
   - **Mô tả:** Lỗi phát sinh từ thư viện nội bộ Widget của Flutter liên quan đến hoạt cảnh (Animation).
   - **Nguyên nhân:** Tính năng Hero Animation yêu cầu mỗi bức ảnh (Poster) được vẽ trên màn hình phải sở hữu một định danh (Tag) duy nhất độc nhất để hệ thống tạo hiệu ứng phóng to. Do ảnh hưởng từ lỗi số 1, toàn bộ các poster trên `home_screen` và `search_screen` đều bị nhận chung một tag tĩnh bằng chữ là `'anime-poster-${anime.malId}'`. Phát hiện có 2+ đối tượng trùng một tag, Flutter báo lỗi và hủy quá trình dựng hình (Rendering).

---

## 2. Phương án đã xử lý

Để gỡ rối Runtime, mình đã chỉnh sửa lại toàn bộ cú pháp ép chuỗi (String Interpolation) trong 4 file giao diện chính của ứng dụng:

- **Loại bỏ ký tự chặn chuỗi (Escape Character)**: Dò và xóa tất cả các dấu gạch chéo ngược (`\`) đứng trước dấu `$` trong các hàm điều hướng `context.push` và thuộc tính `tag` của Widget `Hero`.
  - *Ví dụ trước khi sửa:* `path: '/detail/\${anime.malId}'`
  - *Ví dụ sau khi sửa:* `path: '/detail/${anime.malId}'`

- **Các file được cập nhật**:
  1. `lib/features/home/presentation/screens/home_screen.dart`
  2. `lib/features/search/presentation/screens/search_screen.dart`
  3. `lib/features/detail/presentation/screens/detail_screen.dart`
  4. `lib/features/mylist/presentation/screens/mylist_screen.dart`
  
*(Lưu ý: Mình cũng đồng thời mở khóa hiển thị lỗi biến `$err` trong các hàm bẫy Catch Error trên màn hình `search_screen` và `detail_screen`).*

**Kết quả Giai đoạn 1:**
Việc nội suy chuỗi đã hoạt động theo đúng cơ chế của Dart. ID của anime được chèn chuẩn xác vào URL để lấy dữ liệu từ API (`/detail/21`).

---

## 3. Các lỗi Runtime phát sinh thêm (Giai đoạn 2)

Sau khi fix lỗi ép chuỗi, mình tiếp tục chạy thử và phát hiện thêm 2 lỗi Crash mới:

1. **Lỗi Database FFI (`Bad state: databaseFactory not initialized`)**:
   - **Mô tả:** Ứng dụng sập khi tải danh sách (Watchlist) từ SQLite.
   - **Nguyên nhân:** Thư viện `sqflite` mặc định chỉ hỗ trợ hệ điều hành di động (iOS/Android). Khi chạy ứng dụng trên Desktop (Windows), Dart VM báo lỗi không tìm thấy luồng xử lý Database.
   - **Giải pháp:** 
     - Tải thêm thư viện hỗ trợ Desktop: `flutter pub add sqflite_common_ffi`.
     - Cập nhật `database_helper.dart` để chèn lệnh khởi tạo FFI dành riêng cho Windows/Linux/MacOS trước khi mở kết nối Database.

2. **Lỗi trùng lặp Hero Tag nâng cao (`multiple heroes that share the same tag`)**:
   - **Mô tả:** Dù đã sửa cấu trúc biến ID, ứng dụng vẫn báo trùng tag (Ví dụ: `anime-poster-62568`).
   - **Nguyên nhân:** Do ở màn hình `home_screen`, một tựa Anime (ví dụ mã 62568) có thể xuất hiện đồng thời ở cả danh sách "Đang chiếu mùa này" VÀ danh sách "Top Anime". Do đó, có tới 2 Widget ảnh cùng nhận tag `'anime-poster-62568'`.
   - **Giải pháp:**
     - Thiết kế lại cơ chế truyền Hero Tag. Thêm "tiền tố" (prefix) để phân biệt ngữ cảnh danh sách.
     - Ví dụ: `'anime-poster-now-62568'`, `'anime-poster-top-62568'`, `'anime-poster-search-62568'`, `'anime-poster-mylist-62568'`.
     - Chỉnh sửa `app_router.dart` và `detail_screen.dart` để có thể nhận `heroTag` từ các trang gốc thông qua tính năng `queryParameters` của Router.

**Tình trạng hiện tại:**
Ứng dụng đã xử lý trọn vẹn cả vấn đề tương thích Desktop của Database lẫn cơ chế hoạt ảnh đa tuyến của Hero Animation. Có thể chạy Debug mượt mà.
