-- 1. Database yaratish
CREATE DATABASE IF NOT EXISTS LittleLemonDB;
USE LittleLemonDB;

-- 2. Customers (Mijozlar) jadvali
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NOT NULL
);

-- 3. Bookings (Band qilish) jadvali
CREATE TABLE IF NOT EXISTS Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    Date DATE NOT NULL,
    TableNumber INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Menu (Menyu) jadvali
CREATE TABLE IF NOT EXISTS Menu (
    MenuID INT PRIMARY KEY,
    MenuName VARCHAR(100) NOT NULL,
    Cuisine VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

-- 5. Orders (Buyurtmalar) jadvali
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    MenuID INT,
    Quantity INT NOT NULL,
    TotalCost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. DeliveryStatus (Yetkazib berish holati) jadvali
CREATE TABLE IF NOT EXISTS DeliveryStatus (
    DeliveryID INT PRIMARY KEY,
    OrderID INT,
    DeliveryDate DATE NOT NULL,
    Status VARCHAR(50) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE
);


DELIMITER //

-- 1. GetMaxQuantity: Buyurtmalardagi eng yuqori miqdorni qaytaradi
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity FROM Orders;
END //

-- 2. ManageBooking: Stol band qilinganligini tekshiradi va tranzaksiya orqali qo'shadi
CREATE PROCEDURE ManageBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE existing_booking INT DEFAULT 0;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO existing_booking 
    FROM Bookings 
    WHERE Date = booking_date AND TableNumber = table_number;
    
    IF existing_booking > 0 THEN
        SELECT CONCAT('Table ', table_number, ' is already booked - booking cancelled') AS Status;
        ROLLBACK;
    ELSE
        INSERT INTO Bookings (BookingID, CustomerID, Date, TableNumber) 
        VALUES ((SELECT IFNULL(MAX(BookingID), 0) + 1 FROM Bookings b), 1, booking_date, table_number);
        SELECT CONCAT('Table ', table_number, ' successfully booked') AS Status;
        COMMIT;
    END IF;
END //

-- 3. AddBooking: Yangi bron qo'shish
CREATE PROCEDURE AddBooking(
    IN booking_id INT, 
    IN customer_id INT, 
    IN booking_date DATE, 
    IN table_number INT
)
BEGIN
    INSERT INTO Bookings (BookingID, CustomerID, Date, TableNumber) 
    VALUES (booking_id, customer_id, booking_date, table_number);
    SELECT "New booking added" AS Confirmation;
END //

-- 4. UpdateBooking: Bron sanasini o'zgartirish
CREATE PROCEDURE UpdateBooking(IN booking_id INT, IN booking_date DATE)
BEGIN
    UPDATE Bookings 
    SET Date = booking_date 
    WHERE BookingID = booking_id;
    
    SELECT CONCAT('Booking ', booking_id, ' updated') AS Confirmation;
END //

-- 5. CancelBooking: Bronni bekor qilish (o'chirish)
CREATE PROCEDURE CancelBooking(IN booking_id INT)
BEGIN
    DELETE FROM Bookings 
    WHERE BookingID = booking_id;
    
    SELECT CONCAT('Booking ', booking_id, ' cancelled') AS Confirmation;
END //

DELIMITER ;