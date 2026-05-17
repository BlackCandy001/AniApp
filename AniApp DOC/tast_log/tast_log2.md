# Nhật ký phát triển (Task Log 2) - Hoàn thành Giai đoạn 1

**Thời gian:** 14/05/2026

## Các thay đổi đã thực hiện:

1. **Triển khai Tầng Dữ liệu (Data Layer - API & Models)**:
   - `lib/data/models/anime_model.dart`: Khởi tạo model lưu trữ dữ liệu trả về từ API (malId, title, imageUrl, synopsis, episodes, genres, v.v.) và hàm parse `fromJson` an toàn.
   - `lib/data/models/watchlist_model.dart`: Khởi tạo model phản ánh cấu trúc bảng trong CSDL SQLite.
   - `lib/data/api/jikan_api_service.dart`: Xây dựng service gọi HTTP GET tới Jikan API. Đã triển khai các hàm `getSeasonsNow`, `getTopAnime`, `searchAnime`, `getAnimeDetails`, và `getGenres` kèm xử lý mã lỗi (200, 429).

2. **Triển khai Giao diện Trang chủ (Home Presentation)**:
   - `lib/features/home/presentation/home_providers.dart`: Tạo Riverpod providers (`jikanApiServiceProvider`, `seasonsNowProvider`, `topAnimeProvider`) để lấy dữ liệu bất đồng bộ từ API một cách gọn gàng.
   - `lib/features/home/presentation/screens/home_screen.dart`: Thiết kế giao diện Trang chủ sử dụng `ConsumerWidget`. Xây dựng danh sách trượt ngang (Horizontal ListView) cho 2 section "Đang chiếu mùa này" và "Top Anime". Tích hợp `CachedNetworkImage` để hiển thị poster anime mượt mà và xử lý loading state.
   - `lib/core/routing/app_router.dart`: Cập nhật route gốc (`/`) để điều hướng tới `HomeScreen`.

**Kết quả:** Đã hoàn tất 100% Giai đoạn 1 của kế hoạch phát triển. Ứng dụng hiện tại có thể chạy được, tự động kết nối đến Jikan API và hiển thị danh sách anime trực quan trên màn hình chính.
