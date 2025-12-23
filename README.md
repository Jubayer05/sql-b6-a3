# Vehicle Management System - SQL Assignment

## Project Overview

This project implements a **Vehicle Management System** database designed to handle vehicle rental operations. The system manages users (customers and administrators), vehicles (cars, bikes, and trucks), and bookings between users and vehicles.

The database schema includes three main entities:

- **Users**: Store customer and admin information
- **Vehicles**: Store vehicle inventory with rental details
- **Bookings**: Track rental bookings with dates, costs, and status

## Database Schema

### Tables

#### 1. `users` Table

Stores user information including customers and administrators.

| Column    | Type        | Constraints                                     |
| --------- | ----------- | ----------------------------------------------- |
| `user_id` | SERIAL      | PRIMARY KEY                                     |
| `name`    | VARCHAR(50) | NOT NULL                                        |
| `email`   | VARCHAR(50) | UNIQUE, NOT NULL                                |
| `phone`   | VARCHAR(25) | NOT NULL                                        |
| `role`    | VARCHAR(20) | CHECK (role IN ('Customer', 'Admin')), NOT NULL |

#### 2. `vehicles` Table

Stores vehicle inventory with rental information.

| Column                | Type           | Constraints                                                        |
| --------------------- | -------------- | ------------------------------------------------------------------ |
| `vehicle_id`          | SERIAL         | PRIMARY KEY                                                        |
| `name`                | VARCHAR(50)    | NOT NULL                                                           |
| `type`                | VARCHAR(20)    | CHECK (type IN ('car', 'bike', 'truck')), NOT NULL                 |
| `model`               | VARCHAR(10)    | NOT NULL                                                           |
| `registration_number` | VARCHAR(25)    | UNIQUE, NOT NULL                                                   |
| `rental_price`        | DECIMAL(10, 0) | NOT NULL, CHECK (rental_price > 0)                                 |
| `status`              | VARCHAR(25)    | CHECK (status IN ('available', 'rented', 'maintenance')), NOT NULL |

#### 3. `bookings` Table

Tracks rental bookings with relationships to users and vehicles.

| Column       | Type           | Constraints                                                       |
| ------------ | -------------- | ----------------------------------------------------------------- |
| `booking_id` | SERIAL         | PRIMARY KEY                                                       |
| `user_id`    | INT            | NOT NULL, FOREIGN KEY (users.user_id) ON DELETE CASCADE           |
| `vehicle_id` | INT            | NOT NULL, FOREIGN KEY (vehicles.vehicle_id) ON DELETE RESTRICT    |
| `start_date` | DATE           | NOT NULL                                                          |
| `end_date`   | DATE           | NOT NULL                                                          |
| `status`     | VARCHAR(20)    | CHECK (status IN ('completed', 'pending', 'confirmed')), NOT NULL |
| `total_cost` | DECIMAL(10, 0) | NOT NULL, CHECK (total_cost > 0)                                  |

### Relationships

- A user can have multiple bookings (one-to-many)
- A vehicle can have multiple bookings (one-to-many)
- Bookings are linked to both users and vehicles (many-to-one relationships)

## SQL Queries and Solutions

This section documents all SQL queries implemented in the project, including problem statements and their solutions.

---

### Query 1: JOIN - Retrieve Booking Information with Customer and Vehicle Names

**Requirement**:  
Retrieve booking information along with Customer name and Vehicle name.

**Solution**:

```sql
SELECT
  b.booking_id,
  u.name as customer_name,
  v.name as vehicle_name,
  b.start_date,
  b.end_date,
  b.status
FROM
  bookings as b
  INNER JOIN users as u ON b.user_id = u.user_id
  INNER JOIN vehicles as v ON b.vehicle_id = v.vehicle_id;
```

**Expected Output**:

| booking_id | customer_name | vehicle_name   | start_date | end_date   | status    |
| ---------- | ------------- | -------------- | ---------- | ---------- | --------- |
| 1          | Alice         | Honda Civic    | 2023-10-01 | 2023-10-05 | completed |
| 2          | Alice         | Honda Civic    | 2023-11-01 | 2023-11-03 | completed |
| 3          | Charlie       | Honda Civic    | 2023-12-01 | 2023-12-02 | confirmed |
| 4          | Alice         | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending   |

**Explanation**:  
This query performs an inner join across three tables to combine booking details with user and vehicle information.

**Key Concepts Used**:

- INNER JOIN to combine related data from multiple tables
- Table aliases (`b`, `u`, `v`) for cleaner code
- Column aliases (`customer_name`, `vehicle_name`) for better output readability

---

### Query 2: EXISTS - Find All Vehicles That Have Never Been Booked

**Requirement**:  
Find all vehicles that have never been booked.

**Solution**:

```sql
SELECT
  *
FROM
  vehicles as v
WHERE
  NOT EXISTS (
    SELECT
      *
    FROM
      bookings as b
    WHERE
      v.vehicle_id = b.vehicle_id
  )
ORDER BY
  vehicle_id ASC;
```

**Expected Output**:

| vehicle_id | name       | type  | model | registration_number | rental_price | status      |
| ---------- | ---------- | ----- | ----- | ------------------- | ------------ | ----------- |
| 3          | Yamaha R15 | bike  | 2023  | GHI-789             | 30           | available   |
| 4          | Ford F-150 | truck | 2020  | JKL-012             | 100          | maintenance |

**Explanation**:  
This query uses a `NOT EXISTS` subquery to filter vehicles that don't have any corresponding records in the bookings table.

**Key Concepts Used**:

- Subquery with `NOT EXISTS` for anti-join pattern
- Correlated subquery (references outer query's `v.vehicle_id`)
- `ORDER BY` clause for consistent result ordering

---

### Query 3: WHERE - Retrieve All Available Vehicles of a Specific Type

**Requirement**:  
Retrieve all available vehicles of a specific type (e.g. cars).

**Solution**:

```sql
SELECT
  *
FROM
  vehicles AS v
WHERE
  v.status = 'available'
  AND v.type = 'car';
```

**Expected Output**:

| vehicle_id | name           | type | model | registration_number | rental_price | status    |
| ---------- | -------------- | ---- | ----- | ------------------- | ------------ | --------- |
| 1          | Toyota Corolla | car  | 2022  | ABC-123             | 50           | available |

**Explanation**:  
This query uses the `WHERE` clause to filter vehicles with status 'available' and type 'car'.

**Key Concepts Used**:

- Simple `WHERE` clause with multiple conditions
- Using `AND` logical operator for multiple filter criteria
- Direct equality comparison for filtering

---

### Query 4: GROUP BY and HAVING - Find Vehicles with More Than 2 Bookings

**Requirement**:  
Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.

**Solution**:

```sql
SELECT
  v.name as vehicle_name,
  COUNT(b.vehicle_id) as total_bookings
FROM
  bookings as b
  INNER JOIN vehicles as v ON v.vehicle_id = b.vehicle_id
GROUP BY
  v.vehicle_id, v.name
HAVING
  COUNT(b.vehicle_id) > 2;
```

**Expected Output**:

| vehicle_name | total_bookings |
| ------------ | -------------- |
| Honda Civic  | 3              |

**Explanation**:  
This query uses aggregation to count bookings per vehicle. It joins the bookings and vehicles tables, groups by vehicle, and filters using `HAVING` to show only vehicles with more than 2 bookings.

**Key Concepts Used**:

- Aggregate function: `COUNT()` to count bookings per vehicle
- `GROUP BY` clause to group results by vehicle
- `HAVING` clause to filter aggregated results (cannot use `WHERE` with aggregate functions)
- `INNER JOIN` to combine booking and vehicle data
- Column aliases (`vehicle_name`, `total_bookings`) for clearer output

---
