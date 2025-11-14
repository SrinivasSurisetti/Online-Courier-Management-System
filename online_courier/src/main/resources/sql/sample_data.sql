-- Sample data for OCMS
USE ocms;

-- Users: admin, two staff (Mumbai, Delhi), two users
-- Admin password: 'admin' BCrypt hash: $2a$10$X5wFuJKqFJLEbr1qA.6qOOgJqS9UdPPDveGVJJLSKdkPf.Io7CzFO
-- Others password: 'Admin@123' BCrypt hash: $2a$10$N9qo8uLOickgx2ZMRZoMye1J5hq0BREkS36vCCy8.9XjwGYvb7vv6
INSERT INTO users (name, username, email, password, role, city, status) VALUES
('Admin', 'admin', 'admin@ocms.com', '$2a$10$X5wFuJKqFJLEbr1qA.6qOOgJqS9UdPPDveGVJJLSKdkPf.Io7CzFO', 'ADMIN', NULL, 'ACTIVE'),
('Sanjay Staff Mumbai', 'staff.mumbai', 'staff.mumbai@ocms.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1J5hq0BREkS36vCCy8.9XjwGYvb7vv6', 'STAFF', 'Mumbai', 'ACTIVE'),
('Neha Staff Delhi', 'staff.delhi', 'staff.delhi@ocms.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1J5hq0BREkS36vCCy8.9XjwGYvb7vv6', 'STAFF', 'Delhi', 'ACTIVE'),
('Alice User', 'alice', 'alice@ocms.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1J5hq0BREkS36vCCy8.9XjwGYvb7vv6', 'USER', NULL, 'ACTIVE'),
('Bob User', 'bob', 'bob@ocms.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1J5hq0BREkS36vCCy8.9XjwGYvb7vv6', 'USER', NULL, 'ACTIVE');

-- Staff requests (pending)
INSERT INTO staff_requests (name, email, city, proof_path, status) VALUES
('Rohit Pending', 'rohit.pending@ocms.com', 'Bengaluru', NULL, 'PENDING');

-- Sample couriers
SET @alice := (SELECT id FROM users WHERE email='alice@ocms.com');
SET @bob := (SELECT id FROM users WHERE email='bob@ocms.com');
SET @staff_mumbai := (SELECT id FROM users WHERE email='staff.mumbai@ocms.com');
SET @staff_delhi := (SELECT id FROM users WHERE email='staff.delhi@ocms.com');

INSERT INTO couriers (courier_id, sender_id, sender_name, sender_address, sender_city,
  receiver_name, receiver_address, receiver_city, weight, notes, status, assigned_staff_id)
VALUES
('OCMS-20251102-00001', @alice, 'Alice User', '123 Marine Drive, Mumbai', 'Mumbai',
 'Bob User', '55 Connaught Place, New Delhi', 'New Delhi', 1.20, 'Documents', 'CREATED', NULL),
('OCMS-20251102-00002', @bob, 'Bob User', '91 CP, New Delhi', 'New Delhi',
 'Alice User', '123 Marine Drive, Mumbai', 'Mumbai', 2.50, 'Books', 'PICKED_UP', @staff_mumbai),
('OCMS-20251102-00003', @alice, 'Alice User', '456 Gateway, Mumbai', 'Mumbai',
 'Charlie', '78 MG Road, Bengaluru', 'Bengaluru', 3.00, 'Electronics', 'DELIVERED', @staff_mumbai);

-- Logs
SET @c1 := (SELECT id FROM couriers WHERE courier_id='OCMS-20251102-00001');
SET @c2 := (SELECT id FROM couriers WHERE courier_id='OCMS-20251102-00002');
SET @c3 := (SELECT id FROM couriers WHERE courier_id='OCMS-20251102-00003');

INSERT INTO courier_logs (courier_id, status, staff_id, note) VALUES
(@c1, 'CREATED', NULL, 'Courier created by user'),
(@c2, 'CREATED', NULL, 'Courier created'),
(@c2, 'PICKED_UP', @staff_mumbai, 'Picked up by Mumbai staff'),
(@c3, 'CREATED', NULL, 'Courier created'),
(@c3, 'PICKED_UP', @staff_mumbai, 'Picked up by Mumbai staff'),
(@c3, 'DELIVERED', @staff_mumbai, 'Delivered successfully');
