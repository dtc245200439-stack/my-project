# ai_prompt_log.md — Nhật ký sử dụng AI

## Prompt 1 — Phân tích lỗ hổng
“Trong thiết kế cơ sở dữ liệu quan hệ, vì sao `is_active BOOLEAN` không phù hợp để theo dõi vòng đời lịch hẹn? Hãy chỉ ra các trường dữ liệu còn thiếu khi đối chiếu với quy trình HealthSync.”

**Kết quả sử dụng:** Xác định thiếu trạng thái đa bước, tiền cọc, phí phạt, lý do hủy và bảng đơn thuốc.

## Prompt 2 — Kiểu dữ liệu tài chính
“Khi lưu `deposit_amount` và `penalty_fee` trong MySQL, nên dùng FLOAT, DOUBLE hay DECIMAL? Giải thích rủi ro sai số làm tròn.”

**Kết quả sử dụng:** Chọn `DECIMAL(12,2)` vì lưu số thập phân chính xác theo chữ số thập phân đã định; FLOAT/DOUBLE biểu diễn nhị phân gần đúng, có thể gây sai số trong đối soát tiền.

## Prompt 3 — ENUM và ALTER TABLE
“Cho ví dụ cú pháp MySQL để thêm cột `status ENUM('PENDING','CONFIRMED','CHECKED_IN','COMPLETED','CANCELLED')` vào bảng đã tồn tại; lưu ý cách triển khai khi bảng đang có dữ liệu.”

**Kết quả sử dụng:** Xác định cách dùng `ALTER TABLE`, cần gán giá trị mặc định phù hợp và sao lưu/kiểm tra dữ liệu trước khi xóa cột cũ.

## Prompt 4 — Toàn vẹn đơn thuốc
“Làm thế nào ngăn chèn đơn thuốc cho lịch hẹn chưa COMPLETED ngay tại tầng cơ sở dữ liệu? So sánh trigger với kiểm tra ở ứng dụng.”

**Kết quả sử dụng:** Dùng `BEFORE INSERT` trigger và `SIGNAL SQLSTATE '45000'`; ứng dụng vẫn cần kiểm tra nghiệp vụ để đưa thông báo thân thiện.

## Prompt 5 — Khóa ngoại và xóa dữ liệu
“Khi liên kết Prescriptions với Appointments, nên dùng ON DELETE CASCADE hay RESTRICT cho dữ liệu y tế? Nêu đánh đổi.”

**Kết quả sử dụng:** Chọn `ON DELETE RESTRICT` để tránh xóa dây chuyền hồ sơ y tế; việc lưu trữ/lưu trữ lâu dài cần tuân theo chính sách dữ liệu của hệ thống.
