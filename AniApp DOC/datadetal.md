# Jikan API v4 - Dữ liệu có thể khai thác (Anime Database)

Jikan API v4 là một wrapper không chính thức của MyAnimeList (MAL). Khi gọi endpoint lấy chi tiết một bộ Anime (ví dụ: `/anime/{id}` hoặc qua endpoint tìm kiếm `/anime`), API sẽ trả về một đối tượng JSON khổng lồ chứa hàng tá thông tin. Dưới đây là danh sách toàn bộ các trường dữ liệu (fields) mà chúng ta có thể trích xuất để làm phong phú thêm cho AniApp trong tương lai:

## 1. Thông tin Định danh (Identity)
*   **`mal_id`** *(int)*: ID duy nhất của anime trên MyAnimeList. Rất quan trọng để truy vấn chi tiết.
*   **`url`** *(string)*: Đường dẫn URL trỏ thẳng đến trang gốc của bộ anime trên MyAnimeList.

## 2. Hình ảnh & Đa phương tiện (Media)
*   **`images`** *(object)*: Chứa các định dạng ảnh (JPG, WebP).
    *   `image_url` *(string)*: Ảnh bìa kích thước tiêu chuẩn.
    *   `small_image_url` *(string)*: Ảnh thu nhỏ (thích hợp cho search realtime).
    *   `large_image_url` *(string)*: Ảnh bìa sắc nét (thích hợp cho DetailScreen).
*   **`trailer`** *(object)*: Thông tin video giới thiệu (nếu có).
    *   `youtube_id` *(string)*: ID của YouTube video.
    *   `url` *(string)*: Link YouTube xem trailer.
    *   `embed_url` *(string)*: Link iFrame để nhúng video thẳng vào trong app.
    *   `images` *(object)*: Ảnh bìa (thumbnail) của cái trailer đó.

## 3. Tiêu đề (Titles)
*   **`title`** *(string)*: Tên chuẩn/mặc định (Thường là Romaji).
*   **`title_english`** *(string)*: Tên tiếng Anh.
*   **`title_japanese`** *(string)*: Tên gốc bằng ký tự tiếng Nhật.
*   **`title_synonyms`** *(array[string])*: Các tên gọi khác, tên viết tắt.

## 4. Trạng thái & Lịch phát sóng (Airing / Status)
*   **`status`** *(string)*: Trạng thái phim (`Currently Airing`, `Finished Airing`, `Not yet aired`).
*   **`airing`** *(boolean)*: True nếu phim đang trong thời gian chiếu.
*   **`aired`** *(object)*: Khung thời gian chiếu.
    *   `from` / `to` *(string/ISO)*: Ngày bắt đầu và ngày kết thúc chính xác.
    *   `string` *(string)*: Chuỗi định dạng đọc được (Ví dụ: "Apr 2021 to Sep 2021").
*   **`season`** *(string)*: Mùa chiếu (spring, summer, fall, winter).
*   **`year`** *(int)*: Năm ra mắt.
*   **`broadcast`** *(object)*: Thời gian phát sóng chi tiết bên Nhật (thứ, giờ, múi giờ).

## 5. Đặc tính Bộ phim (Characteristics)
*   **`type`** *(string)*: Loại phim (`TV`, `Movie`, `OVA`, `Special`, `ONA`,...).
*   **`source`** *(string)*: Nguồn gốc gốc rễ (`Manga`, `Original`, `Light novel`, `Web manga`,...).
*   **`episodes`** *(int)*: Tổng số tập (có thể `null` nếu phim vẫn đang chiếu hoặc chưa công bố).
*   **`duration`** *(string)*: Thời lượng mỗi tập (Ví dụ: "24 min per ep").
*   **`rating`** *(string)*: Độ tuổi phù hợp (Ví dụ: "PG-13", "R", "R+").

## 6. Điểm số & Xếp hạng (Stats / Ranking)
*   **`score`** *(float)*: Điểm trung bình trên MAL (1.0 đến 10.0).
*   **`scored_by`** *(int)*: Số lượng người dùng đã chấm điểm.
*   **`rank`** *(int)*: Xếp hạng điểm số toàn cầu (Top #1, #2,...).
*   **`popularity`** *(int)*: Xếp hạng độ phổ biến (dựa trên số người đưa vào list).
*   **`members`** *(int)*: Tổng số user MAL đã thêm phim này vào bất kỳ danh sách nào.
*   **`favorites`** *(int)*: Số người đã đánh dấu phim này là yêu thích nhất.

## 7. Nội dung & Bối cảnh (Context)
*   **`synopsis`** *(string)*: Đoạn văn tóm tắt nội dung chính (Cốt truyện).
*   **`background`** *(string)*: Các thông tin bối cảnh bên lề, trivia xung quanh bộ phim.

## 8. Thành phần sản xuất (Production / Classification)
*(Mỗi mục dưới đây trả về một Array chứa các Object gồm `mal_id`, `type`, `name`, `url`)*
*   **`studios`** *(array)*: Hãng phim sản xuất (Ví dụ: MAPPA, Ufotable, Kyoto Animation).
*   **`producers`** *(array)*: Các công ty tài trợ/nhà sản xuất.
*   **`licensors`** *(array)*: Công ty nắm bản quyền phân phối quốc tế (Crunchyroll, Funimation).
*   **`genres`** *(array)*: Thể loại chính (Action, Comedy, Drama...).
*   **`explicit_genres`** *(array)*: Thể loại nhạy cảm.
*   **`themes`** *(array)*: Bối cảnh chủ đề (School, Mecha, Isekai, Vampires...).
*   **`demographics`** *(array)*: Đối tượng khán giả mục tiêu (Shounen, Shoujo, Seinen...).

## 9. Liên kết & Âm nhạc (Links / Music)
*   **`theme`** *(object)*: Nhạc phim.
    *   `openings` *(array[string])*: Danh sách bài hát Opening.
    *   `endings` *(array[string])*: Danh sách bài hát Ending.
*   **`streaming`** *(array)*: Link xem phim hợp pháp (Netflix, Crunchyroll,...).
*   **`external`** *(array)*: Các link dẫn đến web chính thức, Twitter, Wikipedia.

---
**💡 Ý tưởng phát triển ứng dụng (AniApp V4 - V5):**
Dựa vào kho dữ liệu này, chúng ta có thể làm thêm các chức năng:
1. **Trình chiếu Trailer:** Sử dụng `trailer.youtube_id` để play video ngay trong app.
2. **Khám phá Âm nhạc:** Hiển thị List nhạc OP/ED.
3. **Studio/Voice Actor Filter:** Bấm vào tên Hãng phim (`studios`) để tìm tất cả các phim do hãng đó làm.
4. **Đồng hồ đếm ngược (Countdown):** Dùng dữ liệu `broadcast` để làm tính năng nhắc nhở giờ chiếu phim mới.

---
## 10. Dữ liệu ĐANG ĐƯỢC SỬ DỤNG thực tế trong AniApp hiện tại
Mặc dù Jikan API trả về rất nhiều trường dữ liệu, nhưng ở phiên bản hiện tại (V4), AniApp đang map (ánh xạ) và hiển thị các trường sau thông qua `AnimeModel`:

*   **`mal_id`**: Dùng làm khóa chính (Primary Key) để quản lý cơ sở dữ liệu SQLite và Routing.
*   **`title`**: Hiển thị tên phim trên các Card, Carousel, Detail và Watchlist.
*   **`images.jpg.large_image_url`**: Được map thành `imageUrl`, sử dụng làm ảnh Poster (CachedNetworkImage) và Hero Animation.
*   **`score`**: Hiển thị điểm số trung bình của phim.
*   **`episodes`**: Tổng số tập phim.
*   **`synopsis`**: Hiển thị tóm tắt nội dung cốt truyện ở màn hình Chi tiết (Có hỗ trợ dịch thuật tự động).
*   **`genres[].name`**: Được bóc tách thành một danh sách (List) hiển thị các Badge/Chip thể loại.
*   **`status`**: Trạng thái phát sóng, dùng để tạo nhãn và hiển thị trong Detail.
*   **`type`**: Dạng phim (TV, Movie,...).
*   **`year`**: Năm sản xuất.
*   **`trailer.youtube_id`** *(Mới thêm ở V4)*: ID của Youtube video, dùng để phát Trailer bằng thư viện iframe.
*   **`duration`** *(Mới thêm ở V4)*: Thời lượng mỗi tập phim.
*   **`rating`** *(Mới thêm ở V4)*: Phân loại độ tuổi khán giả.
*   **`source`** *(Mới thêm ở V4)*: Nguồn gốc gốc rễ của phim (Ví dụ: Manga, Light Novel).
*   **`background`** *(Mới thêm ở V4)*: Bối cảnh, thông tin bên lề (Có hỗ trợ dịch thuật).
*   **`aired.string`** *(Mới thêm ở V4)*: Định dạng chuỗi ngày phát sóng.
*   **`broadcast.string`** *(Mới thêm ở V4)*: Thời gian chiếu cụ thể bên Nhật.
