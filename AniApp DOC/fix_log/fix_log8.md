# Nhật ký sửa lỗi - Fix Log 8

**Ngày thực hiện:** 17/05/2026
**Giai đoạn:** Hoàn thiện UI/UX V3 (Detail Screen)

## 1. Lỗi sai đường dẫn Import (Path Not Found)
- **Mô tả lỗi:** Khi build ứng dụng, gặp lỗi `Error when reading 'lib/features/detail/mylist/presentation/mylist_providers.dart': The system cannot find the path specified`.
- **Nguyên nhân:** Khi tích hợp `watchlistProvider` vào `DetailScreen`, đường dẫn file import tương đối bị thiếu một cấp thư mục (`../../` thay vì `../../../`), dẫn đến trình biên dịch tìm sai thư mục (tìm bên trong thư mục detail thay vì nhảy ra ngoài tính từ thư mục hiện tại).
- **Cách khắc phục:** Chỉnh sửa đường dẫn import thành:
  `import '../../../mylist/presentation/mylist_providers.dart';`

## 2. Lỗi Crash do gọi hàm copyWith() không tồn tại
- **Mô tả lỗi:** Lỗi `The method 'copyWith' isn't defined for the type 'WatchlistModel'` khi người dùng nhấn nút tăng/giảm `[+]` hoặc `[-]` số tập bên trong trang Chi tiết phim.
- **Nguyên nhân:** Khác với một số class Model khác, `WatchlistModel` không được định nghĩa phương thức `copyWith`. Do đó, khi cố gắng tạo bản sao chép bằng hàm này, hệ thống sẽ báo lỗi.
- **Cách khắc phục:** Thay vì dùng `copyWith`, chuyển sang tạo thẳng một đối tượng `WatchlistModel` mới hoàn toàn và truyền thủ công các thuộc tính cũ của `watchlistItem` vào, chỉ cập nhật riêng thuộc tính `episodesWatched` và `updatedAt`.

## 3. Lỗi thiếu Import Class (Method Not Defined)
- **Mô tả lỗi:** Khi tiến hành tạo mới đối tượng `WatchlistModel` như ở bước 2, trình biên dịch tiếp tục báo lỗi `The method 'WatchlistModel' isn't defined for the type 'DetailScreen'`.
- **Nguyên nhân:** File `detail_screen.dart` sử dụng Class `WatchlistModel` nhưng lại quên import thư viện chứa Class đó.
- **Cách khắc phục:** Bổ sung dòng import vào đầu file `detail_screen.dart`:
  `import '../../../../data/models/watchlist_model.dart';`

*Tất cả các lỗi liên quan đến chức năng Tăng/Giảm tập phim trong DetailScreen đã được khắc phục hoàn toàn.*
