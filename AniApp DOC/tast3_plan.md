# Kế hoạch triển khai AniApp V3

Dựa trên yêu cầu từ file `tast3.md`, quá trình phát triển V3 sẽ tập trung vào việc làm cho ứng dụng trở nên cá nhân hóa hơn, mượt mà hơn (chuẩn Streaming App) và nâng cấp mạnh mẽ về UI/UX. Kế hoạch được chia thành 4 giai đoạn tương ứng với 4 màn hình:

## Giai đoạn 1: Nâng cấp Trang Cá nhân & Bảo mật (Info & Edit Profile)
1. **Quản lý Avatar (Image Picker & Local Assets):**
   - Thêm thư viện `image_picker` để cho phép người dùng tải ảnh từ thư viện máy lên làm Avatar (Lưu đường dẫn ảnh vào SQLite).
   - Di chuyển 4 ảnh có sẵn từ `AniApp DOC/avatar` vào thư mục `assets/images/avatars` của dự án, cấu hình `pubspec.yaml` để đọc local assets, thay thế 8 link ảnh mạng cũ.
2. **Nâng cấp Form đổi thông tin:**
   - Mở rộng chức năng cho phép đổi Email và Mật khẩu.
   - Bổ sung trường "Mật khẩu cũ" để tăng tính bảo mật khi đổi Mật khẩu mới/Email. Cập nhật `AuthNotifier` để xử lý logic kiểm tra này.

## Giai đoạn 2: Lột xác Trang Chủ (Home Screen UI/UX)
1. **Hero Carousel:** 
   - Sử dụng thư viện `carousel_slider` để tạo băng chuyền hiển thị 5 bộ Anime HOT nhất trên đỉnh màn hình Trang chủ.
   - Thêm hiệu ứng Gradient chuyển màu mượt mà cho Banner.
2. **Tinh chỉnh Anime Card:**
   - Điều chỉnh tỷ lệ khung hình và kích thước (Grid/List) để giảm bớt số lượng card chen chúc trên một hàng (tăng Spacing).
   - Bổ sung hiệu ứng Hover/Scale-up khi người dùng tương tác. Thêm Gradient Overlay để text trên Card dễ đọc hơn.

## Giai đoạn 3: Trải nghiệm Tìm kiếm "Chuẩn Streaming" (Search Screen)
1. **Màn hình Khám phá (Trạng thái rỗng):**
   - Khi chưa nhập từ khóa, hiển thị giao diện đẹp mắt với các phân mục:
     * 🔥 Trending (Anime đang hot)
     * 📅 Seasonal (Anime mùa hiện tại)
     * 🆕 Recently Updated (Mới cập nhật)
2. **Tìm kiếm thời gian thực (Realtime Search):**
   - Cài đặt cơ chế **Debounce (300ms)** bằng `Timer` để khi người dùng đang gõ, ứng dụng không gọi API liên tục mà sẽ đợi 0.3s sau phím cuối cùng.
   - Hiển thị kết quả gợi ý trực tiếp (Suggestion) ngay bên dưới thanh tìm kiếm.

## Giai đoạn 4: Tối ưu Trải nghiệm Quản lý Danh sách (My List & Detail)
1. **Nút Tương tác thông minh (Detail Screen):**
   - Tại màn hình Chi tiết, nút "Thêm vào danh sách" sẽ tự động chuyển thành "Đã thêm vào danh sách" (đổi màu/icon) nếu bộ phim đó đã nằm trong Local SQLite.
2. **Tiến độ nhanh (Quick Progress):**
   - Tại Trang Danh sách (MyList), trên mỗi Card anime sẽ được bổ sung hai nút bấm nhanh `[ - ]` và `[ + ]`.
   - Người dùng có thể nhấn `+` để tăng ngay 1 tập (ví dụ: đang xem tập 5 lên tập 6) mà không cần phải bấm vào chi tiết phim.
   - Cập nhật số tập ngay lập tức vào SQLite và đồng bộ UI.

---
**Các package dự kiến cần cài thêm:**
- `image_picker` (Chọn ảnh từ máy)
- `carousel_slider` (Hiệu ứng băng chuyền)
- `rxdart` hoặc `Timer` (Để xử lý Debounce)
