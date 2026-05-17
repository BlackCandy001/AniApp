Dưới đây là toàn bộ nội dung văn bản đã được trích xuất từ đoạn code, loại bỏ hoàn toàn cú pháp JavaScript và giữ nguyên định dạng văn bản thuần (TXT) để bạn dễ dàng copy hoặc lưu lại:

---

Tài liệu Dự án Flutter | App Theo dõi Anime / Phim
Trang

TÀI LIỆU DỰ ÁN
Flutter Mobile Application

AnimeTracker
App Theo dõi Anime & Phim Cá nhân

Danh mục: Giải trí
Độ khó: Trung bình
Lưu trữ: REST API + sqflite
Phiên bản: 1.0.0 | 2025

Mục lục

1. Tổng quan dự án
   1.1. Mô tả
   AnimeTracker là ứng dụng di động được xây dựng bằng Flutter, cho phép người dùng quản lý danh sách anime và phim đang theo dõi một cách tiện lợi. Ứng dụng kết hợp Jikan API (cơ sở dữ liệu MyAnimeList) với lưu trữ local để mang lại trải nghiệm mượt mà, có thể sử dụng cả khi ngoài mạng.
   Dự án được thiết kế nhằm đáp ứng đầy đủ các yêu cầu kỹ thuật của assignment Flutter, bao gồm UI/UX có responsive design, form validation, navigation nhiều màn hình, state management, xử lý dữ liệu bất đồng bộ (async), REST API và cơ sở dữ liệu local.

1.2. Mục tiêu chức năng

- Xem danh sách anime đang phát hành, top xếp hạng, theo thể loại
- Tìm kiếm anime theo tên với kết quả theo thời gian thực
- Xem thông tin chi tiết: poster, synopsis, số tập, studio, điểm MAL
- Thêm anime vào danh sách cá nhân với các trạng thái: Đang xem, Đã xem, Dự định xem, Tạm dừng, Bỏ dở
- Ghi chép tiến độ xem tập, đánh giá cá nhân (1-10 sao)
- Xem thống kê cá nhân: biểu đồ theo thể loại, tổng số tập, hoạt động theo tháng

  1.3. Thông tin dự án
  Tên dự án: AnimeTracker - Theo dõi Anime & Phim
  Nền tảng: Flutter (Dart) - Android & iOS
  API chính: Jikan API v4 (api.jikan.moe) - Miễn phí, không cần API key
  Cơ sở dữ liệu: sqflite (local) + cached_network_image
  State Management: Riverpod hoặc Provider
  Số màn hình: 6 màn hình chính + các dialog

2. Các màn hình và chức năng
   2.1. Màn hình Trang chủ (Home Screen)
   Màn hình chính hiển thị tổng quan nội dung anime:

- Section 'Đang chiếu mùa này': lấy từ Jikan API /seasons/now
- Section 'Top Anime': lấy từ /top/anime, hiển thị top 10
- Section 'Xem tiếp': lấy từ local DB, các anime có trạng thái 'Đang xem'
- Navigation bar dưới cùng: Home, Tìm kiếm, Danh sách, Thống kê
- Nút chuyển Light/Dark mode ở thanh AppBar

  2.2. Màn hình Tìm kiếm (Search Screen)

- TextField tìm kiếm với debounce 500ms, tránh gọi API liên tục
- Kết quả hiển thị theo Grid 2 cột, mỗi item là anime card với poster và tên
- Bộ lọc theo thể loại (Action, Romance, Sci-Fi...) và năm phát hành
- Xử lý trạng thái: loading skeleton, empty state, error state
- Form validation: cảnh báo khi từ khóa quá ngắn (dưới 2 ký tự)

  2.3. Màn hình Chi tiết (Detail Screen)

- SliverAppBar: poster mở rộng khi ở đầu, thu gọn khi cuộn xuống
- Hero animation: poster bay từ màn hình danh sách vào chi tiết
- Thông tin đầy đủ: synopsis, thể loại, số tập, studio, điểm MAL, năm phát hành
- Nút Thêm vào danh sách: mở BottomSheet chọn trạng thái
- Nếu đã có trong danh sách: hiển thị trạng thái hiện tại, nút Cập nhật tiến độ
- Các tập đã xem: progress bar hiển thị X / tổng số tập

  2.4. Màn hình Danh sách (My List Screen)

- TabBar 5 tab: Tất cả | Đang xem | Đã xem | Dự định | Bỏ dở
- Mỗi anime card hiển thị: poster, tên, trạng thái, tiến độ tập
- Vuốt trái để xóa, nhấn giữ để đổi trạng thái
- Sắp xếp theo: Tên A-Z, Ngày thêm, Điểm cá nhân
- Tìm kiếm nhanh trong danh sách local

  2.5. Màn hình Thống kê (Stats Screen)

- Tổng số: anime đã xem, tổng số tập, điểm trung bình cá nhân
- Biểu đồ tròn (Pie Chart): phân bổ theo thể loại
- Biểu đồ cột (Bar Chart): số anime thêm vào theo từng tháng
- Danh sách: Top 5 anime điểm cao nhất của bản thân

  2.6. Màn hình Hồ sơ (Profile Screen)

- Tên hiển thị, avatar (có thể chỉnh sửa)
- Thống kê ngắn gọn: tổng anime, tập đã xem
- Cài đặt: Light/Dark mode, ngôn ngữ, thông báo
- Nút Xuất dữ liệu (export JSON) và Xóa toàn bộ dữ liệu

3. Kiến trúc kỹ thuật
   3.1. Sơ đồ kiến trúc tổng thể
   Dự án sử dụng kiến trúc Clean Architecture kết hợp với Pattern Repository để tách biệt logic nghiệp vụ khỏi giao diện:

Tầng | Thành phần
Presentation | Screens, Widgets, Providers (Riverpod)
Domain | Use Cases, Entities, Repository Interface
Data | Repository Impl, API Service, Local DB Service
Infrastructure | Jikan API (HTTP), sqflite (local), SharedPreferences

3.2. Cấu trúc thư mục
Cấu trúc dự án theo Clean Architecture:

Đường dẫn | Mô tả
lib/main.dart | Điểm khởi đầu, cấu hình Riverpod, Router
lib/core/ | Constants, Themes, Router, Dependency Injection
lib/features/home/ | Màn hình trang chủ: screens, providers, widgets
lib/features/search/ | Màn hình tìm kiếm và bộ lọc
lib/features/detail/ | Màn hình chi tiết anime
lib/features/mylist/ | Màn hình danh sách cá nhân
lib/features/stats/ | Màn hình thống kê biểu đồ
lib/data/api/ | JikanApiService: các hàm gọi HTTP
lib/data/local/ | DatabaseHelper: sqflite CRUD
lib/data/models/ | AnimeModel, WatchlistModel (JSON mapping)
lib/domain/entities/ | Anime, WatchItem (pure Dart classes)
lib/domain/repositories/ | Interface cho API và Local DB

4. Thiết kế cơ sở dữ liệu
   4.1. Bảng watchlist
   Bảng lưu trữ danh sách anime đang theo dõi của người dùng:

Trường | Kiểu dữ liệu | Ràng buộc | Mô tả
id | INTEGER | PRIMARY KEY | Khóa chính tự động tăng
mal_id | INTEGER | UNIQUE, NOT NULL | ID anime trên MyAnimeList
title | TEXT | NOT NULL | Tên anime (tiếng Anh)
title_japanese | TEXT | NULL | Tên anime (tiếng Nhật)
poster_url | TEXT | NOT NULL | URL ảnh poster
status | TEXT | NOT NULL | watching/completed/plan/hold/dropped
episodes_total | INTEGER | NULL | Tổng số tập (null = chưa rõ)
episodes_watched | INTEGER | DEFAULT 0 | Số tập đã xem
score_user | REAL | NULL, 1-10 | Điểm đánh giá cá nhân
genres | TEXT | NULL | JSON array các thể loại
added_at | TEXT | NOT NULL | ISO8601 ngày thêm vào
updated_at | TEXT | NOT NULL | ISO8601 lần cập nhật cuối

4.2. Bảng notes
Bảng lưu ghi chú cá nhân cho từng anime:

Trường | Kiểu dữ liệu | Ràng buộc | Mô tả
id | INTEGER | PRIMARY KEY | Khóa chính tự động tăng
mal_id | INTEGER | FOREIGN KEY | Tham chiếu đến watchlist.mal_id
content | TEXT | NOT NULL | Nội dung ghi chú
created_at | TEXT | NOT NULL | ISO8601 ngày tạo

4.3. Bảng watch_history
Bảng ghi lại lịch sử hoạt động của người dùng:

Trường | Kiểu dữ liệu | Ràng buộc | Mô tả
id | INTEGER | PRIMARY KEY | Khóa chính tự động tăng
mal_id | INTEGER | FOREIGN KEY | Tham chiếu đến watchlist.mal_id
action | TEXT | NOT NULL | added/status_changed/episode_updated
action_at | TEXT | NOT NULL | ISO8601 thời điểm thực hiện

5. Jikan API - Tài liệu sử dụng
   5.1. Thông tin chung
   Base URL: https://api.jikan.moe/v4
   Xác thực: Không cần API key - truy cập công khai
   Rate Limit: 3 request/giây - cần xử lý debounce khi tìm kiếm
   Format trả về: JSON - trường data chứa kết quả chính

5.2. Các endpoint sử dụng
Endpoint | Method | Chức năng
/anime?q={query}&page={n} | GET | Tìm kiếm anime theo tên, phân trang
/anime/{id} | GET | Lấy chi tiết một anime theo mal_id
/seasons/now | GET | Anime đang phát hành mùa này
/top/anime | GET | Top anime xếp theo điểm số
/anime?genres={id} | GET | Lọc anime theo ID thể loại
/genres/anime | GET | Lấy danh sách tất cả thể loại

5.3. Xử lý lỗi API

- 200 OK: thành công, đọc trường data
- 400 Bad Request: tham số không hợp lệ, hiện thông báo cho người dùng
- 404 Not Found: anime không tồn tại
- 429 Too Many Requests: vượt rate limit - xử lý bằng Retry-After header
- 500+ Server Error: hiện empty state, cho phép pull-to-refresh

6. Flutter Packages và thư viện
   Package | Phiên bản | Mục đích sử dụng
   http | ^1.2.0 | Gọi REST API đến Jikan - HTTP GET requests
   flutter_riverpod | ^2.5.0 | State management - quản lý trạng thái toàn cục
   sqflite | ^2.3.3 | Cơ sở dữ liệu SQL local - lưu watchlist, notes
   path_provider | ^2.1.3 | Lấy đường dẫn thư mục lưu sqflite
   cached_network_image | ^3.3.1 | Cache poster anime, placeholder skeleton
   fl_chart | ^0.68.0 | Biểu đồ tròn và biểu đồ cột cho màn hình Stats
   shimmer | ^3.0.0 | Hiệu ứng loading skeleton khi chờ API trả về
   flutter_rating_bar | ^4.0.1 | Widget đánh giá sao (1-10) cá nhân
   go_router | ^13.2.0 | Quản lý navigation, deep link, named routes
   intl | ^0.19.0 | Định dạng ngày giờ, số theo locale
   shared_preferences | ^2.2.3 | Lưu cài đặt người dùng: dark mode, ngôn ngữ
   connectivity_plus | ^6.0.3 | Kiểm tra kết nối mạng, hiện cảnh báo offline

7. Tính năng nâng cao
   7.1. Hero Animation
   Hero animation được áp dụng khi người dùng nhấn vào poster anime:

- Wrap widget Image.network bằng Hero(tag: 'anime-poster-${mal_id}')
- Màn hình Detail sử dụng cùng tag Hero để kích hoạt animation
- Flutter tự động xử lý animation bay poster giữa 2 màn hình
- Tạo cảm giác mượt mà và chuyên nghiệp, tương tự Netflix/Crunchyroll

  7.2. SliverAppBar trên màn hình Detail
  SliverAppBar tạo hiệu ứng cuộn poster chuyên nghiệp:

- SliverAppBar với expandedHeight: 300 và flexibleSpace: FlexibleSpaceBar
- Poster hiển thị đầy đủ khi ở đầu màn hình
- AppBar thu gọn với tên anime hiện ra khi người dùng cuộn xuống
- Nút quay lại và nút thêm vào danh sách luôn hiển thị

  7.3. Offline Support
  Ứng dụng hoạt động được khi không có mạng:

- cached_network_image lưu poster vào cache local
- Danh sách cá nhân (watchlist) lấy từ sqflite - không cần mạng
- Hiện cảnh báo 'Đang offline' qua connectivity_plus
- Pull-to-refresh để cập nhật khi có kết nối trở lại

  7.4. Thống kê với fl_chart
  Màn hình thống kê hiển thị dữ liệu trực quan:

- PieChart: phân bổ thể loại anime trong watchlist (chia theo genres)
- BarChart: số lượng anime thêm vào theo từng tháng trong năm
- Summary cards: tổng số anime, tổng số tập đã xem, điểm trung bình
- Biểu đồ có animation khi lần đầu load và khi dữ liệu thay đổi

8. Thiết kế UI/UX
   8.1. Design System
   Ứng dụng sử dụng Material Design 3 (Material You) làm nền tảng:

Thành phần | Giá trị | Chú thích
Primary Color | #4F46B8 (Indigo) | Màu chính - button, icon, accent
Secondary Color | #7C3AED (Purple) | Màu phụ - badge, chip, tags
Font chính | Inter / Roboto | Font hệ thống, hiển thị rõ ràng
Border Radius | 12px (card), 8px (button) | Góc bo nhẹ, hiện đại
Spacing | 8px grid system | Khoảng cách theo bội số của 8
Elevation | 0dp (flat design) | Không box-shadow, dùng border

8.2. Light / Dark Mode

- ThemeData.light() và ThemeData.dark() định nghĩa đầy đủ
- SharedPreferences lưu lựa chọn của người dùng
- Riverpod Provider quản lý trạng thái theme toàn ứng dụng
- Chuyển đổi tức thời không cần restart app
- System theme tự động theo cài đặt điện thoại (MediaQuery.platformBrightness)

  8.3. Responsive Design

- LayoutBuilder kiểm tra chiều rộng màn hình
- Grid 2 cột trên điện thoại, 3 cột trên tablet (>600px)
- Text scale theo font size cài đặt của hệ điều hành
- Safe area xử lý notch và gesture bar

9. Xử lý lỗi và trạng thái
   9.1. Các trạng thái hiển thị
   Trạng thái | Xử lý
   Loading | Shimmer skeleton animation thay thế cho nội dung
   Success | Hiển thị dữ liệu bình thường
   Empty | Hình minh họa + thông báo + nút hành động
   Error (mạng) | Thông báo lỗi + nút 'Thử lại' + dữ liệu cache nếu có
   Error (server) | Thông báo 'Hệ thống đang bảo trì', log lỗi
   Offline | Banner cảnh báo trên đầu, vẫn dùng được với dữ liệu local

9.2. Form Validation

- Tìm kiếm: cảnh báo nếu nhập dưới 2 ký tự
- Đánh giá sao: bắt buộc chọn 1-10 trước khi lưu
- Ghi chú: giới hạn 500 ký tự, hiện đếm ký tự còn lại
- Nhập số tập: chỉ nhập số nguyên dương, không vượt quá tổng số tập

10. Lộ trình phát triển
    10.1. Giai đoạn 1 - Nền tảng (Tuần 1-2)
1. Cấu hình dự án: pubspec.yaml, cấu trúc thư mục, theme
1. Triển khai Jikan API Service: các hàm gọi HTTP có xử lý lỗi
1. Tạo models: AnimeModel, WatchlistModel với JSON parsing
1. Cài đặt sqflite: tạo bảng, CRUD cơ bản
1. Màn hình Home: hiển thị danh sách từ API

   10.2. Giai đoạn 2 - Tính năng chính (Tuần 3-4)

1. Màn hình Search: tìm kiếm với debounce, bộ lọc
1. Màn hình Detail: SliverAppBar, thông tin đầy đủ, Hero animation
1. Màn hình My List: TabBar, CRUD watchlist
1. State management: Riverpod providers cho toàn bộ app
1. Navigation: go_router cấu hình route đầy đủ

   10.3. Giai đoạn 3 - Nâng cao và hoàn thiện (Tuần 5)

1. Màn hình Stats: fl_chart biểu đồ tròn và cột
1. Dark/Light mode và lưu cài đặt
1. Offline support: cached_network_image, kiểm tra mạng
1. UI polish: animation, loading states, empty states
1. Test trên thiết bị thật, sửa lỗi, tối ưu hiệu suất

1. Hướng dẫn chạy dự án
   11.1. Yêu cầu hệ thống

- Flutter SDK >= 3.19.0 (flutter --version để kiểm tra)
- Dart SDK >= 3.3.0 (kèm theo Flutter)
- Android Studio hoặc VS Code với Flutter extension
- Android Emulator hoặc thiết bị thật (Android >= 5.0, iOS >= 12.0)

  11.2. Cài đặt và chạy

1. Clone dự án: git clone https://github.com/username/anime-tracker.git
2. Vào thư mục: cd anime-tracker
3. Cài đặt packages: flutter pub get
4. Chạy app: flutter run
5. Build release Android: flutter build apk --release

   11.3. Cấu hình môi trường
   Tạo file lib/core/constants/api_constants.dart:
   class ApiConstants {
   static const String baseUrl = 'https://api.jikan.moe/v4';
   static const int rateLimit = 3; // req per second
   static const int pageSize = 25;
   }

6. Tiêu chí đánh giá và điểm số
   Tiêu chí | Triển khai trong dự án | Mức độ đáp ứng
   UI/UX responsive, đẹp mắt | Material 3, Hero anim, SliverAppBar | Đầy đủ
   Light / Dark mode | ThemeData + SharedPreferences | Đầy đủ
   Form có validation | Tìm kiếm, đánh giá, ghi chú | Đầy đủ
   > =3 màn hình, navigation | 6 màn hình + go_router | Vượt yêu cầu
   > State management | Riverpod Providers | Đầy đủ
   > Xử lý async / loading | FutureProvider, debounce, skeleton | Đầy đủ
   > REST API | Jikan API v4 - 6 endpoints | Đầy đủ
   > Cơ sở dữ liệu local | sqflite - 3 bảng, CRUD đầy đủ | Đầy đủ
   > Tính năng nâng cao | fl_chart + Hero animation + Offline | Nhiều hơn yêu cầu

12.1. Điểm mạnh của dự án

- Jikan API hoàn toàn miễn phí, không cần đăng ký, dữ liệu phong phú (25.000+ anime)
- Poster anime đẹp tự nhiên - Hero animation và cached_image tạo ấn tượng mạnh
- Dễ thuyết trình: đề tài quen thuộc với sinh viên, demo trực quan
- Nhiều tính năng nâng cao có thể chọn thêm tùy sức (Firebase sync, notification, ...)

  12.2. Những lưu ý khi triển khai

- Phải xử lý debounce khi gọi API tìm kiếm để tránh bị block (rate limit 3 req/s)
- Một số trường API có thể trả về null (poster, episodes) - cần xử lý null safety
- Pagination: API trả về 25 kết quả/trang - nên implement infinite scroll
- Cache ảnh poster để app dùng được offline và load nhanh hơn

---

Tài liệu này được tạo tự động bởi công cụ hỗ trợ dự án Flutter.
Phiên bản 1.0.0 | 2025
