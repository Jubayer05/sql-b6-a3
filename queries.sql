CREATE DATABASE vehicle_management;

-- CREATE USERS TABLES
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL,
    email varchar(50) UNIQUE NOT NULL,
    phone varchar(25) NOT NULL,
    role varchar(20) CHECK (role IN ('Customer', 'Admin')) NOT NULL
)

  -- CREATE VEHICLES TABLES
CREATE TABLE vehicles (
    vehicle_id serial PRIMARY KEY,
    name varchar(50) NOT NULL,
    type varchar(20) CHECK (type IN ('car', 'bike', 'truck')) NOT NULL,
    model varchar(10) NOT NULL,
    registration_number varchar(25) UNIQUE NOT NULL,
    rental_price decimal(10, 0) NOT NULL CHECK (rental_price > 0),
    status varchar(25) CHECK (status IN ('available', 'rented', 'maintenance')) NOT NULL
)

  -- CREATE BOOKING TABLES
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vehicle_id INT NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('completed', 'pending', 'confirmed')) NOT NULL,
    total_cost DECIMAL(10, 0) NOT NULL CHECK (total_cost > 0),
    CHECK (end_date >= start_date)
);


-- INSERT USERS DATA
INSERT INTO users (name, email, phone, role)
VALUES
('Alice', 'alice@example.com', '1234567890', 'Customer'),
('Bob', 'bob@example.com', '0987654321', 'Admin'),
('Charlie', 'charlie@example.com', '1122334455', 'Customer');

-- INSERT VEHICLES DATA
INSERT INTO vehicles (name, type, model, registration_number, rental_price, status)
VALUES
('Toyota Corolla', 'car', '2022', 'ABC-123', 50, 'available'),
('Honda Civic', 'car', '2021', 'DEF-456', 60, 'rented'),
('Yamaha R15', 'bike', '2023', 'GHI-789', 30, 'available'),
('Ford F-150', 'truck', '2020', 'JKL-012', 100, 'maintenance');

-- INSERT BOOKING DATA
INSERT INTO bookings (user_id, vehicle_id, start_date, end_date, status, total_cost)
VALUES
(7, 9, '2023-10-01', '2023-10-05', 'completed', 240),
(1, 2, '2023-11-01', '2023-11-03', 'completed', 120),
(3, 2, '2023-12-01', '2023-12-02', 'confirmed', 60),
(1, 1, '2023-12-10', '2023-12-12', 'pending', 100);

-- QUESTION - 1: Retrieve booking information along with Customer name and Vehicle name.
SELECT
  b.booking_id,
  u.name as customer_name,
  v.name as vehicle_name,
  b.start_date,
  b.end_date,
  b.status
FROM
  bookings as b
  inner join users as u ON b.user_id = u.user_id
  inner join vehicles as v on b.vehicle_id = v.vehicle_id
  
  
  -- QUESTION - 2: Find all vehicles that have never been booked
SELECT
  *
FROM
  vehicles as v
where
  not exists (
    select
      *
    from
      bookings as b
    where
      v.vehicle_id = b.vehicle_id
  )
order by
  vehicle_id asc

  
  -- QUESTION - 3: Retrieve all available vehicles of a specific type (e.g. cars)
SELECT
  *
FROM
  vehicles AS v
WHERE
  v.status = 'available'
  and v.type = 'car'

  
  -- QUESTION - 4: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.
SELECT
  v.name,
  count(b.vehicle_id) as booking_count
FROM
  bookings as b
  inner join vehicles as v on v.vehicle_id = b.vehicle_id
group by
  v.vehicle_id
having
  count(b.vehicle_id) > 2