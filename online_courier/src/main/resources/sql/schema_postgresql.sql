-- Create tables for OCMS - PostgreSQL version optimized for Neon DB (1GB RAM, 0.5GB storage)

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100),
  username VARCHAR(30) NOT NULL UNIQUE,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(10) NOT NULL CHECK (role IN ('USER','STAFF','ADMIN')),
  city VARCHAR(100) NULL,
  status VARCHAR(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff requests table
CREATE TABLE IF NOT EXISTS staff_requests (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  city VARCHAR(100) NOT NULL,
  proof_path VARCHAR(255) NULL,
  status VARCHAR(10) DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','REJECTED')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Couriers table
CREATE TABLE IF NOT EXISTS couriers (
  id BIGSERIAL PRIMARY KEY,
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
  status VARCHAR(15) DEFAULT 'CREATED' CHECK (status IN ('CREATED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED')),
  assigned_staff_id BIGINT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_courier_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_courier_staff FOREIGN KEY (assigned_staff_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Optimized indexes for PostgreSQL
CREATE INDEX IF NOT EXISTS idx_couriers_courier_id ON couriers(courier_id);
CREATE INDEX IF NOT EXISTS idx_couriers_sender_id ON couriers(sender_id);
CREATE INDEX IF NOT EXISTS idx_couriers_assigned_staff ON couriers(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_couriers_status ON couriers(status);
CREATE INDEX IF NOT EXISTS idx_couriers_user_id ON couriers(user_id);

-- Courier logs table
CREATE TABLE IF NOT EXISTS courier_logs (
  id BIGSERIAL PRIMARY KEY,
  courier_id BIGINT NOT NULL,
  status VARCHAR(15) NOT NULL CHECK (status IN ('CREATED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED')),
  staff_id BIGINT NULL,
  note VARCHAR(255) NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_log_courier FOREIGN KEY (courier_id) REFERENCES couriers(id) ON DELETE CASCADE,
  CONSTRAINT fk_log_staff FOREIGN KEY (staff_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_logs_courier_id ON courier_logs(courier_id);

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for auto-updating updated_at
CREATE TRIGGER update_couriers_updated_at 
    BEFORE UPDATE ON couriers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
