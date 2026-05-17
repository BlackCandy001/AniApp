# Nhật ký Sửa lỗi (Fix Log 4)

**Thời gian:** 14/05/2026

**Vấn đề:** Có thêm 2 lỗi xảy ra trong quá trình sử dụng:
1. Giao diện Thống kê (`StatsScreen`) bị sập hoàn toàn (`RenderBox was not laid out: RenderRepaintBoundary`).
2. Lỗi trùng Hero Tag xuất hiện trở lại ở danh sách "Đang chiếu mùa này" với cùng 1 ID anime.

## 1. Lỗi Layout trên màn hình StatsScreen
- **Nguyên nhân:** Lỗi xảy ra do Widget `Expanded` được sử dụng sai mục đích. Cụ thể, hàm `_buildStatCard` bọc một `Card` bên trong `Expanded`. Việc này hoạt động tốt khi thẻ Card nằm trong `Row` (chiều ngang). Nhưng khi bạn đưa trực tiếp `_buildStatCard` vào trong một `Column` (để hiển thị điểm TB) và `Column` đó lại nằm trong `SingleChildScrollView` (không giới hạn chiều dọc), `Expanded` cố gắng phình to ra vô hạn dẫn đến Flutter không thể tính toán được kích thước (`hasSize` failed).
- **Cách khắc phục:**
  - Mình đã tháo `Expanded` ra khỏi hàm `_buildStatCard`.
  - Thay vào đó, ở dòng code tạo `Row` phía trên, mình trực tiếp dùng thẻ `Expanded` bọc lấy lời gọi hàm. Đối với thẻ hiển thị Điểm TB nằm trong Column, nó không bị ép bọc Expanded nữa nên giao diện hoạt động bình thường và thẻ tự động co giãn theo kích thước tĩnh.

## 2. Lỗi Hero Tag vì dữ liệu API bị trùng lặp
- **Nguyên nhân:** Dù đã thêm ngữ cảnh (Prefix như `now`, `top`) để phân biệt ảnh giữa các danh sách, nhưng API của Jikan đôi khi trả về nhiều bản ghi (record) cùng ID trong cùng một danh sách "Đang chiếu" (Ví dụ: 1 bộ Anime có 2 phiên bản hoặc do API cache lỗi). Điều này làm cho trong cùng 1 danh sách vẫn xuất hiện 2 tag `'anime-poster-now-62568'`.
- **Cách khắc phục:**
  - Cập nhật thêm chỉ số vòng lặp `index` vào mã tạo Hero Tag trong `home_screen` và `search_screen`.
  - Cấu trúc Tag cuối cùng giờ là: `anime-poster-$prefix-${anime.malId}-$index`.
  - Giờ đây, dù API có trả về 100 kết quả có ID giống hệt nhau ở cạnh nhau, mỗi kết quả vẫn có 1 Hero Tag độc nhất và an toàn.

## 3. Lỗi hiển thị sai chữ (String Interpolation) trên màn hình Chi tiết và Thống kê
- **Nguyên nhân:** Khi tìm và xoá hàng loạt các dấu `\` chặn nội suy chuỗi để sửa lỗi Router ở đợt trước, mình đã bỏ sót 2 màn hình là `detail_screen` (phần điểm số và số tập) và `stats_screen` (phần chữ nhãn `$value` của PieChart). Do dấu `\` vẫn còn nên Flutter hiểu đó là chuỗi tĩnh chứ không phải biến.
- **Cách khắc phục:**
  - Sửa `"\${anime.score ?? 'N/A'}"` thành `"${anime.score ?? 'N/A'}"`.
  - Sửa `"\${anime.episodes ?? '?'}"` thành `"${anime.episodes ?? '?'}"`.
  - Sửa `'\$value'` thành `'$value'`.
  - Giờ đây các biến đã có thể trích xuất ra giá trị thật và hiển thị đúng lên màn hình.

**Tình trạng:**
Cả 3 vấn đề đều đã được khắc phục hoàn toàn. Bạn có thể tự do xem ảnh, mở Thống kê và Vuốt xem các phim Đang chiếu mà không gặp hiện tượng crash hay hiển thị sai nữa.
