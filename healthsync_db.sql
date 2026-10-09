-- HEALTHSYNC: CSDL toi uu cho quy trinh dat lich va kham benh
-- LUU Y: Script nay dung de tao moi bo du lieu mau. DROP TABLE se xoa cac bang
-- cung ten va du lieu hien co. Hay sao luu truoc khi chay tren he thong that.

CREATE DATABASE IF NOT EXISTS healthsync_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE healthsync_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    CONSTRAINT uq_patients_phone UNIQUE (phone)
) ENGINE=InnoDB;

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED')
        NOT NULL DEFAULT 'PENDING',
    deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    CONSTRAINT chk_appointment_deposit CHECK (deposit_amount >= 0),
    CONSTRAINT chk_appointment_penalty CHECK (penalty_fee >= 0),
    CONSTRAINT chk_penalty_not_over_deposit CHECK (penalty_fee <= deposit_amount),
    CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_prescription_appointment UNIQUE (appointment_id),
    CONSTRAINT fk_prescriptions_appointment FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Chi cho phep tao don thuoc neu lich hen da COMPLETED.
DELIMITER //
CREATE TRIGGER trg_prescription_only_completed
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status
    FROM Appointments
    WHERE appointment_id = NEW.appointment_id;

    IF v_status IS NULL OR v_status <> 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi duoc tao don thuoc khi lich hen da COMPLETED';
    END IF;
END//
DELIMITER ;

-- Du lieu mau
INSERT INTO Patients (full_name, phone) VALUES
('Nguyen Van An', '0901000001'),
('Tran Thi Binh', '0901000002');

INSERT INTO Doctors (full_name, specialty) VALUES
('Le Minh Chau', 'Noi tong quat'),
('Pham Quoc Huy', 'Da lieu');

-- KICH BAN 1: dat lich, den kham, hoan tat, ke don thuoc
INSERT INTO Appointments
(patient_id, doctor_id, appointment_date, status, deposit_amount, penalty_fee)
VALUES
(1, 1, '2026-10-10 09:00:00', 'PENDING', 500000.00, 0.00);
SET @appointment_success := LAST_INSERT_ID();

UPDATE Appointments
SET status = 'CONFIRMED'
WHERE appointment_id = @appointment_success AND status = 'PENDING';

UPDATE Appointments
SET status = 'CHECKED_IN'
WHERE appointment_id = @appointment_success AND status = 'CONFIRMED';

UPDATE Appointments
SET status = 'COMPLETED'
WHERE appointment_id = @appointment_success AND status = 'CHECKED_IN';

INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (@appointment_success,
        'Paracetamol 500mg: theo chi dinh bac si; tai kham neu trieu chung khong giam.');

-- KICH BAN 2: da xac nhan, benh nhan huy va bi tru tien coc
INSERT INTO Appointments
(patient_id, doctor_id, appointment_date, status, deposit_amount, penalty_fee)
VALUES
(2, 2, '2026-10-11 14:30:00', 'CONFIRMED', 300000.00, 0.00);
SET @appointment_cancelled := LAST_INSERT_ID();

UPDATE Appointments
SET status = 'CANCELLED',
    cancel_reason = 'Ban viec dot xuat',
    penalty_fee = 150000.00
WHERE appointment_id = @appointment_cancelled AND status = 'CONFIRMED';

-- KIEM TRA 1: lich hen, tien coc, phi phat, ly do huy
SELECT appointment_id, patient_id, doctor_id, status,
       deposit_amount, penalty_fee,
       (deposit_amount - penalty_fee) AS deposit_remaining,
       cancel_reason
FROM Appointments
ORDER BY appointment_id;

-- KIEM TRA 2: lich hen da hoan tat va don thuoc
SELECT a.appointment_id, p.full_name AS patient_name,
       d.full_name AS doctor_name, a.status,
       a.deposit_amount, rx.prescription_id,
       rx.medication_details, rx.issued_date
FROM Appointments AS a
JOIN Patients AS p ON p.patient_id = a.patient_id
JOIN Doctors AS d ON d.doctor_id = a.doctor_id
LEFT JOIN Prescriptions AS rx ON rx.appointment_id = a.appointment_id
WHERE a.status = 'COMPLETED';
