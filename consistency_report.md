# consistency_report.md — HealthSync Gap Analysis

Thiết kế cũ không phản ánh đầy đủ quy trình nghiệp vụ trong Activity Diagram. Có ba điểm vênh nghiêm trọng:

1. **Sai mô hình trạng thái:** `is_active BOOLEAN` chỉ biểu diễn bật/tắt, không thể phân biệt `PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED` và `CANCELLED`. Vì vậy hệ thống không biết lịch đang ở bước nào, dễ xử lý sai luồng nghiệp vụ. Thay bằng `status ENUM` với tập giá trị hợp lệ.
2. **Thiếu dữ liệu tài chính và kiểm toán hủy:** Bảng `Appointments` không có `deposit_amount`, `penalty_fee` và `cancel_reason`. Hệ thống không thể ghi nhận tiền cọc, phí phạt hoặc lý do hủy; kế toán không thể đối soát số tiền còn lại từ tiền cọc. Dùng `DECIMAL(12,2)` để lưu tiền, kèm ràng buộc không âm và phí phạt không vượt tiền cọc.
3. **Thiếu mô hình đơn thuốc:** Không có bảng `Prescriptions`, nên không thể liên kết đơn thuốc với lịch khám đã hoàn tất. Tạo bảng có khóa chính, khóa ngoại `appointment_id` và `UNIQUE(appointment_id)` cho quan hệ 1–1. Trigger `BEFORE INSERT` ngăn tạo đơn thuốc nếu lịch hẹn chưa ở trạng thái `COMPLETED`.

Thiết kế mới dùng khóa ngoại với `ON DELETE RESTRICT` để tránh xóa bệnh nhân, bác sĩ hoặc lịch hẹn đang được tham chiếu. ERD và lưu đồ nghiệp vụ cần nhất quán để BA và Dev thống nhất trạng thái, dữ liệu bắt buộc và quy tắc chuyển bước trước khi triển khai.
