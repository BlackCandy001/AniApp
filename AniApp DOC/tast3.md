Kế hoạch cập nhật V3.

Yêu cầu chỉnh sửa:

- Trang info:

* có thể up ảnh từ máy để làm ảnh đại diện
* loại bỏ các hình ảnh có sẵn ở hiện tại và thay thế bằng 4 bức ảnh ở C:\Users\DELL\Downloads\AniApp\AniApp DOC\avatar
* bổ sung phần chỉnh sửa thông tin: Email, mật khẩu (cần nhập lại mật khẩu cũ để thay đổi)

- Trang chủ:

* bổ sung giao diện hiển thị: Carousel ở đầu trang một vài bộ anime đang HOT
* tăng spacing, giảm số card ngang, thêm gradient overlay, thêm hover/focus state
*

- search:

* Hiện search của bạn khá “database style”, Bạn nên làm kiểu streaming app:
  Khi chưa nhập:
  trending
  recently updated
  seasonal
  Khi đang nhập:
  realtime suggestion
  debounce 300ms

- trang danh sách:

* cần sửa lại hiển thị nút "Thêm vào danh sách" thành "Đã thêm vào danh sách" đối với các bộ anime đã được thêm.
* thêm phím tắt tăng và giảm số tập với các bộ anime có trong danh sách
