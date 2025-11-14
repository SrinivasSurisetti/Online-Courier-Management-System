-- Create database and tables for OCMS
CREATE DATABASE IF NOT EXISTS ocms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ocms;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  username VARCHAR(30) NOT NULL UNIQUE,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('USER','STAFF','ADMIN') NOT NULL,
  city VARCHAR(100) NULL,
  status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Staff requests table
CREATE TABLE IF NOT EXISTS staff_requests (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  city VARCHAR(100) NOT NULL,
  proof_path VARCHAR(255) NULL,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Couriers table
CREATE TABLE IF NOT EXISTS couriers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  courier_id VARCHAR(50) NOT NULL UNIQUE,
  tracking_number VARCHAR(255) NOT NULL,
  user_id BIGINT NOT NULL,
  sender_id BIGINT NULL,
  sender_name VARCHAR(150),
  sender_address TEXT,
  sender_city VARCHAR(100),
  sender_mobile VARCHAR(20),
  pickup_address TEXT,
  pickup_city VARCHAR(100),
  pickup_pincode VARCHAR(10),
  recipient_name VARCHAR(150),
  recipient_address TEXT,
  recipient_city VARCHAR(100),
  recipient_mobile VARCHAR(20),
  destination_address TEXT,
  destination_city VARCHAR(100),
  destination_pincode VARCHAR(10),
  weight DECIMAL(8,2),
  delivery_charge DECIMAL(10,2),
  calculated_price DECIMAL(10,2),
  notes TEXT,
  status ENUM('CREATED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED') DEFAULT 'CREATED',
  assigned_staff_id BIGINT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_courier_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_courier_staff FOREIGN KEY (assigned_staff_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS idx_couriers_courier_id ON couriers(courier_id);
CREATE INDEX IF NOT EXISTS idx_couriers_sender_id ON couriers(sender_id);
CREATE INDEX IF NOT EXISTS idx_couriers_assigned_staff ON couriers(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_couriers_status ON couriers(status);

-- Courier logs table
CREATE TABLE IF NOT EXISTS courier_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  courier_id BIGINT NOT NULL,
  status ENUM('CREATED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED') NOT NULL,
  staff_id BIGINT NULL,
  note VARCHAR(255) NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_log_courier FOREIGN KEY (courier_id) REFERENCES couriers(id) ON DELETE CASCADE,
  CONSTRAINT fk_log_staff FOREIGN KEY (staff_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS idx_logs_courier_id ON courier_logs(courier_id);
