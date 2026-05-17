# KẾ HOẠCH THIẾT KẾ ỨNG DỤNG ANIMETRACKER

Dựa trên tài liệu yêu cầu dự án, dưới đây là bản kế hoạch tổng thể về **Thiết kế Kỹ thuật (Technical Design)** và **Thiết kế Giao diện (UI/UX Design)** để làm cơ sở cho quá trình lập trình ứng dụng AnimeTracker.

## 1. Thiết Kế UI/UX (Design System)
- **Nền tảng:** Material Design 3 (Material You).
- **Màu sắc chủ đạo:**
  - **Primary Color:** `#4F46B8` (Indigo) - Sử dụng cho các nút bấm (buttons), icon, và các thành phần mang tính hành động chính.
  - **Secondary Color:** `#7C3AED` (Purple) - Sử dụng cho các badge trạng thái, chip thể loại (genres).
  - Hỗ trợ đầy đủ chế độ **Light Mode / Dark Mode** (Quản lý qua `ThemeData` và lưu lựa chọn bằng `SharedPreferences`).
- **Typography (Chữ viết):**
  - Font chữ: **Inter** hoặc **Roboto** để mang lại sự hiện đại và dễ đọc trên các thiết bị di động.
- **Kích thước & Hình khối:**
  - Border Radius: `12px` cho các thẻ (Cards), `8px` cho nút bấm.
  - Hệ thống lưới (Grid System): Khoảng cách dựa trên bội số của `8px` (8, 16, 24).
  - Elevation: Thiết kế phẳng (Flat design), tập trung vào đường viền mỏng thay vì bóng đổ dày.
- **Motion & Animation (Hiệu ứng động):**
  - **Hero Animation:** Tạo hiệu ứng chuyển cảnh liền mạch khi nhấn vào ảnh poster từ danh sách bay vào màn hình chi tiết.
  - **SliverAppBar:** Hiệu ứng thu phóng poster nghệ thuật khi cuộn trang ở màn hình chi tiết.
  - **Shimmer Effect:** Hiển thị khung xương (skeleton loading) đẹp mắt trong lúc chờ gọi dữ liệu API.

## 2. Thiết Kế Kiến Trúc Hệ Thống (Architecture Design)
Dự án được xây dựng theo chuẩn **Clean Architecture**, phân chia rõ ràng trách nhiệm để dễ bảo trì và mở rộng:
- **Presentation Layer (Tầng Giao diện):** 
  - Quản lý UI/UX và State. Sử dụng `flutter_riverpod` để làm State Management.
  - Quản lý điều hướng (Routing) bằng `go_router`.
- **Domain Layer (Tầng Nghiệp vụ):** 
  - Chứa các Model (Entities) chuẩn bằng Dart (vd: `Anime`, `WatchItem`) và Interface của các Repository. Độc lập hoàn toàn với Flutter.
- **Data Layer (Tầng Dữ liệu):** 
  - Triển khai cụ thể các lệnh gọi API thông qua `JikanApiService` (dùng package `http`).
  - Quản lý tương tác với SQLite thông qua `DatabaseHelper`.

## 3. Thiết Kế Dữ Liệu & Quản lý Trạng Thái
### 3.1. Local Storage (SQLite - sqflite)
Cơ sở dữ liệu cục bộ đóng vai trò là "Single Source of Truth" cho dữ liệu cá nhân của user:
- **Bảng `watchlist`:** Lưu trữ thông tin anime user đưa vào danh sách cá nhân (ID, Tên, Ảnh URL, Trạng thái xem, Số tập đã xem, Điểm đánh giá...).
- **Bảng `notes`:** Lưu ghi chú cá nhân của user cho từng bộ anime.
- **Bảng `watch_history`:** Ghi nhận lịch sử tương tác (thêm/sửa trạng thái) theo dạng logs để vẽ biểu đồ thống kê.

### 3.2. Sơ đồ Riverpod State
- `theme_provider`: Chuyển đổi trạng thái giao diện Sáng/Tối.
- `watchlist_provider`: Lấy và tự động phản hồi dữ liệu mỗi khi bảng `watchlist` trong database thay đổi.
- `anime_search_provider`: Nhận query tìm kiếm, xử lý độ trễ (debounce), và gọi API kết quả tìm kiếm.

## 4. Thiết Kế Luồng Màn Hình (Screen Flow)
1. **Trang Chủ (Home Screen):** 
   - Phân chia theo Section dọc: "Xem tiếp" (từ Local DB), "Đang chiếu" (API), "Top Anime" (API).
   - Nội dung hiển thị dạng vuốt ngang (Horizontal ListView).
2. **Trang Tìm Kiếm (Search Screen):**
   - Thanh tìm kiếm nhạy bén có tích hợp Debounce (500ms).
   - Kết quả trả về dạng lưới (Grid 2 cột), có thông báo validation khi nhập từ khóa quá ngắn.
3. **Trang Chi Tiết (Detail Screen):**
   - Tận dụng tối đa không gian màn hình với SliverAppBar.
   - Tương tác chính là nút **Thêm vào danh sách**, mở ra một Bottom Sheet đẹp mắt để người dùng chấm điểm (rating bar), điền số tập và ghi chú.
4. **Trang Danh Sách Cá Nhân (My List Screen):**
   - Quản lý thông qua TabBar (Tất cả / Đang xem / Đã xem...).
   - Trải nghiệm mượt mà với tính năng: Vuốt ngang (Swipe) để xóa và Nhấn giữ (Long press) để đổi trạng thái nhanh.
5. **Trang Thống Kê & Hồ Sơ (Stats/Profile Screen):**
   - Trực quan hóa tiến độ cày phim qua `fl_chart` (Biểu đồ phân bổ thể loại, Biểu đồ thanh lịch sử theo tháng).
   - Cài đặt hệ thống: Đổi giao diện, Export dữ liệu ra file JSON.

## 5. Thiết Kế Trải Nghiệm Ngoại Tuyến & Hiệu Năng (Offline & Performance)
- **Hỗ trợ Offline:** Ứng dụng tích hợp `cached_network_image` lưu tạm poster và `connectivity_plus` báo trạng thái mạng. Nếu rớt mạng, phần "My List" từ cơ sở dữ liệu local vẫn hoạt động hoàn hảo.
- **Tối ưu Network:** Bắt buộc áp dụng kỹ thuật Debounce trong thanh tìm kiếm để không dồn dập request API, tránh bị Jikan API chặn do quy định Rate Limit (3 request/giây).
- **Thiết kế Thích ứng (Responsive Design):** Ứng dụng tự động điều chỉnh Layout từ lưới 2 cột sang 3 cột nếu phát hiện đang mở trên Tablet hoặc chế độ xoay ngang.
