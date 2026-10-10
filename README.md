# Bài tập: Xây dựng cơ sở dữ liệu quản lý bán hàng

**Sinh viên:** Lò Văn Bắc  
**Lớp:** CNTT K23E

## Mục tiêu
Tạo cơ sở dữ liệu `QuanLyBanHang` và các bảng quản lý khách hàng, hóa đơn, sản phẩm và chi tiết hóa đơn.

## Các bảng
- `Customer`: lưu tất cả khách hàng, kể cả khách chưa mua hàng.
- `Order`: lưu hóa đơn; một khách hàng có thể có nhiều hóa đơn. Vì `ORDER` là từ khóa SQL, tên bảng được đặt trong dấu backtick trong MySQL.
- `Product`: lưu tên và giá sản phẩm.
- `Orderdetail`: lưu các sản phẩm thuộc từng hóa đơn và số lượng mua.

## Quan hệ và ràng buộc
- Khóa chính cho từng bảng; `Orderdetail` dùng khóa chính kép `(oID, pID)`.
- Khóa ngoại nối hóa đơn với khách hàng, chi tiết hóa đơn với hóa đơn và sản phẩm.
- `CHECK` đảm bảo tuổi không âm, giá không âm và số lượng lớn hơn 0.
- `ON DELETE RESTRICT` tránh xóa dữ liệu đang được hóa đơn/chi tiết hóa đơn tham chiếu.

## Cách chạy
1. Mở MySQL Workbench hoặc công cụ MySQL tương thích MySQL 8.0+.
2. Mở `QuanLyBanHang.sql`.
3. Chạy toàn bộ script.
4. Kiểm tra kết quả `SHOW TABLES` và các truy vấn ở cuối file.

Script có dữ liệu mẫu để kiểm tra các quan hệ và trường hợp khách hàng chưa mua hàng.

## Lưu ý khi nộp
Đây là repository riêng cho bài `QuanLyBanHang`. Không dùng báo cáo hoặc mã nguồn của dự án `HealthSync` làm nội dung chính của bài này.
