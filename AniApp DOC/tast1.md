# KẾ HOẠCH PHÁT TRIỂN DỰ ÁN ANIMETRACKER

Kế hoạch này được xây dựng dựa trên các yêu cầu chi tiết từ tài liệu thiết kế (doc.md), đảm bảo bao phủ toàn bộ kiến trúc, UI/UX, xử lý lỗi và các tính năng nâng cao.

## Giai đoạn 1: Khởi tạo, Nền tảng & Cơ sở dữ liệu (Tuần 1 - 2)
**Mục tiêu:** Thiết lập khung kiến trúc dự án, cấu trúc cơ sở dữ liệu local và tích hợp API.

1. **Khởi tạo & Cấu trúc Dự án (Clean Architecture)**
   - Khởi tạo dự án Flutter. Cấu hình `pubspec.yaml` với đầy đủ các package: `http`, `flutter_riverpod`, `sqflite`, `path_provider`, `cached_network_image`, `fl_chart`, `shimmer`, `flutter_rating_bar`, `go_router`, `intl`, `shared_preferences`, `connectivity_plus`.
   - Xây dựng cấu trúc thư mục Clean Architecture: `core/`, `features/`, `data/`, `domain/`.
   - Thiết lập Design System (Material 3): Primary Color (#4F46B8), Secondary (#7C3AED), font Inter/Roboto, Border Radius 12px/8px.
   - Thiết lập `go_router` cho hệ thống điều hướng (navigation & deep links).

2. **Cơ sở dữ liệu Local (sqflite)**
   - Viết `DatabaseHelper` để khởi tạo 3 bảng với ràng buộc khóa ngoại (FOREIGN KEY):
     - `watchlist`: Quản lý danh sách anime (id, mal_id, title, poster_url, status, episodes_total, episodes_watched, score_user, genres, timestamps).
     - `notes`: Ghi chú cá nhân (id, mal_id tham chiếu watchlist, content, created_at).
     - `watch_history`: Lịch sử hoạt động (id, mal_id tham chiếu watchlist, action, action_at).
   - Viết các hàm CRUD cơ bản cho 3 bảng.

3. **Tích hợp Jikan API (Data Layer)**
   - Khởi tạo `ApiConstants` (Base URL: api.jikan.moe/v4).
   - Xây dựng `JikanApiService` gọi HTTP GET cho 6 endpoints: `seasons/now`, `top/anime`, `anime/{id}`, `anime?q=...`, `anime?genres=...`, `genres/anime`.
   - Xử lý mã lỗi HTTP: 400 (Bad Request), 404 (Not Found), 429 (Rate limit - xử lý Retry-After), 500+ (Server error).

4. **Giao diện Trang chủ (Home Screen) & UI/UX cơ bản**
   - Thiết kế LayoutResponsive: dùng `LayoutBuilder` để chia Grid 2 cột (điện thoại) và 3 cột (tablet > 600px). Xử lý Safe area cho màn hình tai thỏ.
   - Home Screen: Hiển thị section "Đang chiếu mùa này", "Top Anime" từ API và "Xem tiếp" từ Local DB.
   - Tích hợp `shimmer` để làm skeleton loading khi chờ dữ liệu API.

---

## Giai đoạn 2: Tính năng cốt lõi & Form Validation (Tuần 3 - 4)
**Mục tiêu:** Xây dựng màn hình Tìm kiếm, Chi tiết và Danh sách cá nhân với các ràng buộc dữ liệu nghiêm ngặt.

1. **Màn hình Tìm kiếm (Search Screen)**
   - TextField với `debounce` (500ms) để không dồn dập gọi API (tránh lỗi 429 Rate Limit 3 req/s).
   - Form Validation: Cảnh báo/Khóa nút tìm kiếm nếu từ khóa < 2 ký tự.
   - Tích hợp bộ lọc (Filter) theo thể loại và năm. Phân trang (Pagination) xử lý API trả về 25 kết quả/trang (Infinite scroll).

2. **Màn hình Chi tiết (Detail Screen)**
   - Triển khai `SliverAppBar` (expandedHeight: 300) với `FlexibleSpaceBar` thu gọn poster khi cuộn.
   - Tích hợp **Hero Animation** cho poster (chuyển động mượt từ màn hình trước sang màn hình chi tiết bằng tag `anime-poster-${mal_id}`).
   - BottomSheet "Thêm/Cập nhật": 
     - Nhập số tập đã xem: Bắt buộc số nguyên dương, không vượt quá tổng số tập.
     - Đánh giá sao: Dùng `flutter_rating_bar` yêu cầu bắt buộc 1-10 sao trước khi lưu.
     - Ghi chú: Giới hạn 500 ký tự, đếm ngược số ký tự còn lại.

3. **Màn hình Danh sách Cá nhân (My List Screen)**
   - TabBar 5 tabs: Tất cả | Đang xem | Đã xem | Dự định | Bỏ dở.
   - Tương tác: Vuốt trái để xóa anime, nhấn giữ để đổi trạng thái nhanh.
   - Sorting: Sắp xếp theo Tên A-Z, Ngày thêm, Điểm cá nhân.

4. **Quản lý Trạng thái (Riverpod)**
   - Kết nối toàn bộ giao diện với `flutter_riverpod`.
   - Đảm bảo dữ liệu đồng bộ thời gian thực: Cập nhật tập phim ở Detail -> màn hình My List và Home tự động thay đổi theo.

---

## Giai đoạn 3: Tính năng Nâng cao, Offline & Nghiệm thu (Tuần 5)
**Mục tiêu:** Hoàn thiện đồ họa thống kê, chế độ ngoại tuyến và kiểm thử toàn diện.

1. **Màn hình Thống kê (Stats Screen)**
   - Tích hợp `fl_chart` có animation:
     - PieChart: Tỷ lệ các thể loại anime đang xem.
     - BarChart: Thống kê số lượng anime được thêm vào theo từng tháng.
   - Summary cards dùng `intl` để format các con số tổng hợp thống kê.

2. **Hỗ trợ Offline & Xử lý Trạng thái Lỗi**
   - Tích hợp `cached_network_image`: Lưu cache poster để hiển thị mượt và dùng được khi mất mạng.
   - Dùng `connectivity_plus` giám sát mạng. Nếu offline: Hiển thị banner cảnh báo, cho phép đọc thông tin local từ `sqflite`, khóa các tính năng gọi API mới.
   - Xử lý Empty States (Hình ảnh thông báo khi danh sách rỗng) và Error States (Nút "Thử lại" khi lỗi mạng hoặc Pull-to-refresh khi lỗi 500 Server Error).

3. **Cài đặt Hệ thống (Profile Screen)**
   - Chức năng chuyển đổi Theme (Light/Dark mode) lưu vào `shared_preferences`. Tự động nhận diện độ sáng hệ thống.
   - Tính năng "Xuất dữ liệu" (Export JSON từ sqflite) và "Xóa toàn bộ dữ liệu".

4. **Kiểm thử và Triển khai**
   - Test ứng dụng trên thiết bị ảo và thiết bị thật để kiểm tra Layout Responsive.
   - Rà soát các edge cases: Dữ liệu API trả về null (poster/episodes rỗng).
   - Tối ưu hiệu năng, loại bỏ build thừa. Build file release: `flutter build apk --release`.
