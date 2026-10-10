-- BAI TAP: XAY DUNG CO SO DU LIEU QUAN LY BAN HANG
-- He quan tri: MySQL 8.0+
-- Cac bang: Customer, Order, Orderdetail, Product

CREATE DATABASE IF NOT EXISTS QuanLyBanHang
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE QuanLyBanHang;

-- Xoa bang theo thu tu phu thuoc neu can chay lai script
DROP TABLE IF EXISTS Orderdetail;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Customer;

-- 1. Khach hang: bao gom ca khach mua va khach khong mua
CREATE TABLE Customer (
    cID INT NOT NULL,
    cName VARCHAR(100) NOT NULL,
    cAge INT NULL,
    CONSTRAINT PK_Customer PRIMARY KEY (cID),
    CONSTRAINT CK_Customer_cAge CHECK (cAge IS NULL OR cAge >= 0)
) ENGINE=InnoDB;

-- 2. Hoa don: mot khach hang co the co nhieu hoa don
CREATE TABLE `Order` (
    oID INT NOT NULL,
    cID INT NOT NULL,
    oDate DATE NOT NULL,
    CONSTRAINT PK_Order PRIMARY KEY (oID),
    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (cID) REFERENCES Customer(cID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. San pham
CREATE TABLE Product (
    pID INT NOT NULL,
    pName VARCHAR(100) NOT NULL,
    pPrice DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_Product PRIMARY KEY (pID),
    CONSTRAINT CK_Product_pPrice CHECK (pPrice >= 0)
) ENGINE=InnoDB;

-- 4. Chi tiet hoa don: mot hoa don co the co nhieu san pham
CREATE TABLE Orderdetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL,
    CONSTRAINT PK_Orderdetail PRIMARY KEY (oID, pID),
    CONSTRAINT FK_Orderdetail_Order
        FOREIGN KEY (oID) REFERENCES `Order`(oID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT FK_Orderdetail_Product
        FOREIGN KEY (pID) REFERENCES Product(pID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT CK_Orderdetail_odQTY CHECK (odQTY > 0)
) ENGINE=InnoDB;

-- DU LIEU MAU DE KIEM TRA
INSERT INTO Customer (cID, cName, cAge) VALUES
(1, 'Nguyen Van An', 22),
(2, 'Tran Thi Binh', 30),
(3, 'Le Van Cuong', 25); -- Khach hang chua mua hang

INSERT INTO Product (pID, pName, pPrice) VALUES
(101, 'But bi', 5000.00),
(102, 'Vo ghi', 12000.00),
(103, 'Thuoc ke', 8000.00);

INSERT INTO `Order` (oID, cID, oDate) VALUES
(1001, 1, '2026-10-01'),
(1002, 1, '2026-10-05'),
(1003, 2, '2026-10-06');

INSERT INTO Orderdetail (oID, pID, odQTY) VALUES
(1001, 101, 3),
(1001, 102, 2),
(1002, 103, 1),
(1003, 101, 5),
(1003, 102, 1);

-- KIEM TRA 4 BANG DA DUOC TAO
SHOW TABLES;

-- Kiem tra khach hang, ke ca khach chua mua hang
SELECT * FROM Customer;

-- Kiem tra hoa don kem ten khach hang
SELECT o.oID, c.cName, o.oDate
FROM `Order` AS o
JOIN Customer AS c ON c.cID = o.cID
ORDER BY o.oID;

-- Kiem tra chi tiet hoa don va thanh tien tung dong
SELECT od.oID, p.pName, p.pPrice, od.odQTY,
       p.pPrice * od.odQTY AS lineTotal
FROM Orderdetail AS od
JOIN Product AS p ON p.pID = od.pID
ORDER BY od.oID, p.pID;

-- Kiem tra khach hang chua mua hang (van ton tai trong Customer)
SELECT c.cID, c.cName
FROM Customer AS c
LEFT JOIN `Order` AS o ON o.cID = c.cID
WHERE o.oID IS NULL;
