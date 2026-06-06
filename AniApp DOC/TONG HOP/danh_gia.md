# ĐÁNH GIÁ TỔNG THỂ DỰ ÁN ANIAPP SO VỚI YÊU CẦU

## 1. Điểm số dự kiến: **100/100 điểm** (Nếu nộp đủ video demo và file PDF)
Dự án được xây dựng rất bài bản, cấu trúc mã nguồn sạch sẽ theo mô hình **Feature-First** (Clean Architecture), đáp ứng đầy đủ và vượt mong đợi ở tất cả các hạng mục điểm từ cơ bản đến nâng cao.

---

## 2. Đánh giá chi tiết theo từng tiêu chí môn học

### Phần A: Nền tảng bắt buộc (80/80 điểm)

#### 1. Giao diện UI/UX & Layout (Đạt 20/20đ)
*   **Điểm mạnh:** Thiết kế giao diện hiện đại theo phong cách Material 3 với bộ màu sắc đồng bộ (Indigo làm chủ đạo, Purple làm màu phụ trợ).
*   **Hỗ trợ Responsive:** Xuất sắc. Sử dụng `LayoutBuilder` trong `home_screen.dart` để tự động chuyển đổi linh hoạt giữa giao diện cuộn ngang dạng danh sách (trên điện thoại dọc) sang dạng lưới GridView 2 cột (khi màn hình lớn hoặc xoay ngang).
*   **Theme Mode:** Hỗ trợ đầy đủ Light/Dark Mode thông qua cài đặt của thiết bị hoặc nút chuyển đổi thủ công trong màn hình cài đặt `settings_screen.dart`, lưu trạng thái bằng `SharedPreferences`.

#### 2. Xử lý Dữ liệu & Form (Đạt 20/20đ)
*   **Điểm mạnh:** Sử dụng Widget `Form` chuẩn của Flutter kết hợp với các `TextFormField` có validation chặt chẽ.
*   **Chi tiết:** 
    *   Màn hình Đăng ký/Đăng nhập kiểm tra lỗi email trống, email sai định dạng (sử dụng biểu thức Regex), mật khẩu tối thiểu 6 ký tự, và khớp mật khẩu xác nhận.
    *   Màn hình Chỉnh sửa hồ sơ cá nhân `edit_profile_screen.dart` tích hợp thay đổi thông tin an toàn (yêu cầu mật khẩu cũ khi đổi email/mật khẩu mới).

#### 3. Điều hướng, Trạng thái & Bất đồng bộ (Đạt 20/20đ)
*   **Điều hướng (Navigation):** Sử dụng thư viện `go_router` để quản lý định tuyến dạng khai báo rất chuyên nghiệp. Có tổng cộng **7 màn hình** (vượt yêu cầu tối thiểu là 3 màn hình).
*   **Quản lý Trạng thái (State Management):** Sử dụng thư viện **Riverpod** (`flutter_riverpod`) để truyền dữ liệu và cập nhật giao diện toàn cục tự động (không sử dụng truyền tham số thủ công/prop drilling).
*   **Bất đồng bộ (Async):** Xử lý tải dữ liệu từ internet bất đồng bộ mượt mà, có hiển thị hiệu ứng khung xương tải trang (Shimmer loading) và banner cảnh báo khi mất kết nối mạng.

#### 4. Lưu trữ & Kết nối (Đạt 20/20đ)
*   **REST API:** Kết nối API Jikan v4 (REST API chính thức của MyAnimeList) thông qua `http` package. Có xử lý độ trễ (delay) tránh bị chặn do giới hạn tần suất gửi yêu cầu (Rate Limit).
*   **Local Database:** Sử dụng SQLite (`sqflite` / `sqflite_common_ffi` cho Windows). Cơ sở dữ liệu đã được nâng cấp lên **Version 5** (loại bỏ hoàn toàn ràng buộc khóa ngoại cứng lỗi thời gây lỗi `foreign key mismatch` để chuyển sang cascade thủ công an toàn hơn). Dữ liệu cá nhân của người dùng được lưu trữ an toàn và phân biệt theo từng tài khoản.

---

### Phần B: Nghiên cứu nâng cao (20/20 điểm)
*Yêu cầu môn học chỉ cần sinh viên áp dụng ít nhất 1 kỹ thuật nâng cao. Dự án này đã thực hiện **nhiều kỹ thuật nâng cao cùng lúc**:*

1.  **Sliver Widgets & Custom Scroll:** Màn hình chi tiết `detail_screen.dart` sử dụng `CustomScrollView` kết hợp `SliverAppBar` để co giãn ảnh poster anime khi cuộn rất mượt mà.
2.  **Thông minh hóa hình ảnh:** Tích hợp `cached_network_image` giúp lưu bộ nhớ tạm (cache) ảnh bìa, giảm lưu lượng mạng và cải thiện tốc độ hiển thị cho lần tải sau.
3.  **Tương tác thiết bị (External Plugins):**
    *   Dùng `image_picker` để chụp/chọn ảnh trực tiếp từ thư viện máy làm avatar cá nhân (đã khắc phục lỗi Activity Recreation trên Android khi chọn ảnh).
    *   Tích hợp thông báo đẩy nội bộ bằng `flutter_local_notifications`.
4.  **Tác vụ chạy ngầm (Background Service):** Tích hợp dịch vụ chạy ngầm **WorkManager** để kiểm tra tập phim mới của danh sách theo dõi định kỳ (12 tiếng/lần) ngay cả khi ứng dụng đã đóng hoàn toàn.

---

## 3. Các điểm nổi bật về chất lượng code (Code Quality)
*   **Cấu trúc thư mục:** Chia theo tính năng (Feature-First: auth, detail, home, mylist, profile, search, settings, stats), giúp dự án cực kỳ dễ mở rộng.
*   **Đa ngôn ngữ (Localization):** Hỗ trợ đầy đủ 3 ngôn ngữ: **English (mặc định), Tiếng Việt, Tiếng Nhật**.
*   **Độ ổn định:** Bộ kiểm thử tự động (Unit test database & Widget smoke test) đã được sửa sạch lỗi và thông qua 100% khi chạy lệnh `flutter test`.

---

## 4. Khuyến nghị chuẩn bị nộp bài (Hạn chế tối đa việc bị trừ điểm)

Để tránh bị trừ điểm do sai quy cách nộp bài, bạn cần chuẩn bị:

1.  **Xuất báo cáo PDF:** Đọc lại file `AnimeTracker_TaiLieuDuAn.docx` trong thư mục tài liệu và **Xuất (Export) sang định dạng PDF**. (Giảng viên yêu cầu nộp file PDF thay vì Word).
2.  **Quay Video Demo:** Quay phim màn hình thiết bị và **bắt buộc có thuyết minh giọng nói hoặc chèn phụ đề** giới thiệu các tính năng chính.
3.  **Dọn dẹp mã nguồn trước khi nén:** Chạy lệnh `flutter clean` ở thư mục gốc của dự án để xóa thư mục `build/` (thư mục này rất nặng, nếu nén cùng sẽ khó tải lên hệ thống). Sau đó nén thư mục dự án thành file `.zip`.
