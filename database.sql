-- Create Database
CREATE DATABASE IF NOT EXISTS SmartCityDB;
USE SmartCityDB;

-- 1. Users Table
-- Added the 'username' column to match the frontend login logic
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Parking Slots Master Data
-- Unique constraint on slot_code + area_name prevents conflicts between locations
CREATE TABLE ParkingSlots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    slot_code VARCHAR(10) NOT NULL, 
    area_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_slot_area (slot_code, area_name) 
);

-- 3. EV Stations Master Data
CREATE TABLE EVStations (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    station_code VARCHAR(10) NOT NULL,
    location_name VARCHAR(50) NOT NULL,
    connector_type VARCHAR(50) DEFAULT 'Type 2',
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_station_location (station_code, location_name)
);

-- 4. Parking Bookings Table
-- Added 'total_cost' to store payment values
CREATE TABLE ParkingBookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    slot_id INT NOT NULL,
    car_reg_no VARCHAR(20) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    booking_status ENUM('Confirmed', 'Completed', 'Cancelled') DEFAULT 'Confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (slot_id) REFERENCES ParkingSlots(slot_id)
);

-- 5. EV Charging Bookings Table
CREATE TABLE EVBookings (
    ev_booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    station_id INT NOT NULL,
    car_reg_no VARCHAR(20) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    booking_status ENUM('Confirmed', 'Completed', 'Cancelled') DEFAULT 'Confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (station_id) REFERENCES EVStations(station_id)
);

-- --- DEFAULT DATA ---

-- 1. Insert Test Users (password is 'password123' for all)
INSERT INTO Users (username, full_name, email, phone_number, password_hash) VALUES 
('user1', 'Alice Smith', 'alice@smartcity.com', '+1 234-567-0001', 'password123'),
('user2', 'Bob Johnson', 'bob@smartcity.com', '+1 234-567-0002', 'password123'),
('user3', 'Charlie Davis', 'charlie@smartcity.com', '+1 234-567-0003', 'password123'),
('user4', 'Diana Evans', 'diana@smartcity.com', '+1 234-567-0004', 'password123'),
('user5', 'Ethan Foster', 'ethan@smartcity.com', '+1 234-567-0005', 'password123'),
('user6', 'Fiona Garcia', 'fiona@smartcity.com', '+1 234-567-0006', 'password123'),
('user7', 'George Harris', 'george@smartcity.com', '+1 234-567-0007', 'password123'),
('user8', 'Hannah Irwin', 'hannah@smartcity.com', '+1 234-567-0008', 'password123'),
('user9', 'Ian Jones', 'ian@smartcity.com', '+1 234-567-0009', 'password123'),
('user10', 'Julia King', 'julia@smartcity.com', '+1 234-567-0010', 'password123');

-- 2. Insert Parking Slots for various zones
INSERT INTO ParkingSlots (slot_code, area_name) VALUES 
('A1', 'Mall Level 1'), ('A2', 'Mall Level 1'), ('A3', 'Mall Level 1'), ('A4', 'Mall Level 1'), ('A5', 'Mall Level 1'),
('B1', 'Mall Level 1'), ('B2', 'Mall Level 1'), ('B3', 'Mall Level 1'), ('B4', 'Mall Level 1'), ('B5', 'Mall Level 1'),
('C1', 'Mall Level 1'), ('C2', 'Mall Level 1'), ('C3', 'Mall Level 1'), ('C4', 'Mall Level 1'), ('C5', 'Mall Level 1'),
('A1', 'City Center A'), ('A2', 'City Center A'), ('A3', 'City Center A'), ('A4', 'City Center A'), ('A5', 'City Center A'),
('A1', 'Airport Zone'), ('A2', 'Airport Zone'), ('A3', 'Airport Zone'), ('A4', 'Airport Zone'), ('A5', 'Airport Zone');

-- 3. Insert EV Points for various stations
INSERT INTO EVStations (station_code, location_name) VALUES 
('CP-1', 'Tech Park Hub'), ('CP-2', 'Tech Park Hub'), ('CP-3', 'Tech Park Hub'), ('CP-4', 'Tech Park Hub'),
('CP-5', 'Tech Park Hub'), ('CP-6', 'Tech Park Hub'), ('CP-7', 'Tech Park Hub'), ('CP-8', 'Tech Park Hub'),
('CP-1', 'Highway Stop 4'), ('CP-2', 'Highway Stop 4'), ('CP-3', 'Highway Stop 4'), ('CP-4', 'Highway Stop 4'),
('CP-1', 'Downtown EV Zone'), ('CP-2', 'Downtown EV Zone'), ('CP-3', 'Downtown EV Zone'), ('CP-4', 'Downtown EV Zone');