# Nhật ký Sửa lỗi Android APK (Fix Log)

**Thời gian:** 14/05/2026

**Vấn đề:** Lỗi không thể tải dữ liệu ("Lỗi tải dữ liệu" trên giao diện / Lỗi `SocketException` trên console) khi cài đặt ứng dụng Flutter lên điện thoại thật dưới định dạng file APK.

## Lỗi Mạng (SocketException: Failed host lookup)
- **Mô tả:** Khi xuất bản dự án bằng lệnh `flutter build apk` và cài đặt vào thiết bị di động, ứng dụng không thể kết nối tới server (`api.jikan.moe`), nhận mã lỗi DNS `errno = 7` (No address associated with hostname).
- **Nguyên nhân:** Khác với môi trường Debug trên máy tính/giả lập, Android thiết lập cơ chế bảo mật nghiêm ngặt đối với ứng dụng được Release. Mặc định, nếu nhà phát triển không chủ động xin cấp quyền, hệ điều hành Android sẽ chặn 100% mọi kết nối mạng từ ứng dụng này đi ra ngoài.
- **Cách khắc phục:**
  - Cần chỉnh sửa file khai báo cấu hình cốt lõi của ứng dụng Android tại đường dẫn: `android/app/src/main/AndroidManifest.xml`.
  - Bổ sung đoạn mã xin cấp quyền mạng ở ngay phía trên thẻ `<application>`: 
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    ```
  - Thao tác này sẽ nói với hệ điều hành Android rằng ứng dụng cần sử dụng mạng Wifi/4G để tải danh sách ảnh và thông tin Anime.

**Kết quả:**
Ứng dụng đã có quyền truy cập Internet thành công. Khi build lại APK mới, nội dung sẽ được tải và hiển thị mượt mà trên môi trường điện thoại thật.
