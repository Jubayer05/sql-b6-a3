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
|              |                | CHECK (end_date >= start_date)                                    |

### Relationships

- A user can have multiple bookings (one-to-many)
- A vehicle can have multiple bookings (one-to-many)
- Bookings are linked to both users and vehicles (many-to-one relationships)

## SQL Queries and Solutions

This section documents all SQL queries implemented in the project, including problem statements and their solutions.

---

### Query 1: Retrieve Booking Information with Customer and Vehicle Names

**Problem Statement**:  
Retrieve booking information along with customer name and vehicle name for better readability.

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

**Explanation**:  
This query performs an inner join across three tables to combine booking details with user and vehicle information. It retrieves the booking ID, customer name (from users table), vehicle name (from vehicles table), and booking dates and status.

**Key Concepts Used**:

- INNER JOIN to combine related data from multiple tables
- Table aliases (`b`, `u`, `v`) for cleaner code
- Column aliases (`customer_name`, `vehicle_name`) for better output readability

---

### Query 2: Find All Vehicles That Have Never Been Booked

**Problem Statement**:  
Identify vehicles in the inventory that have never been rented (no booking records).

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

**Explanation**:  
This query uses a `NOT EXISTS` subquery to filter vehicles that don't have any corresponding records in the bookings table. The subquery checks if there are any bookings for each vehicle, and the main query selects only those vehicles where no bookings exist.

**Key Concepts Used**:

- Subquery with `NOT EXISTS` for anti-join pattern
- Correlated subquery (references outer query's `v.vehicle_id`)
- `ORDER BY` clause for consistent result ordering

**Alternative Approach**:  
This could also be solved using a LEFT JOIN:

```sql
SELECT v.*
FROM vehicles v
LEFT JOIN bookings b ON v.vehicle_id = b.vehicle_id
WHERE b.vehicle_id IS NULL
ORDER BY v.vehicle_id ASC;
```

---

### Query 3: Retrieve All Available Vehicles of a Specific Type

**Problem Statement**:  
Find all available vehicles of a specific type (e.g., cars) that can be rented.

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

**Explanation**:  
A straightforward filtering query that uses the `WHERE` clause to select vehicles matching both conditions: status must be 'available' and type must be 'car'. This helps users find rentable vehicles of their preferred type.

**Key Concepts Used**:

- Simple `WHERE` clause with multiple conditions
- Using `AND` logical operator for multiple filter criteria
- Direct equality comparison for filtering

**Note**: To search for other vehicle types, simply change `'car'` to `'bike'` or `'truck'`.

---

### Query 4: Find Vehicles with More Than 2 Bookings

**Problem Statement**:  
Calculate the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.

**Solution**:

```sql
SELECT
  v.name,
  COUNT(b.vehicle_id) as booking_count
FROM
  bookings as b
  INNER JOIN vehicles as v ON v.vehicle_id = b.vehicle_id
GROUP BY
  v.vehicle_id, v.name
HAVING
  COUNT(b.vehicle_id) > 2;
```

**Explanation**:  
This query uses aggregation to count bookings per vehicle. It joins the bookings and vehicles tables, groups by vehicle, counts the bookings for each vehicle, and filters using `HAVING` to show only vehicles with more than 2 bookings.

**Key Concepts Used**:

- Aggregate function: `COUNT()` to count bookings per vehicle
- `GROUP BY` clause to group results by vehicle
- `HAVING` clause to filter aggregated results (cannot use `WHERE` with aggregate functions)
- `INNER JOIN` to combine booking and vehicle data

**Difference Between WHERE and HAVING**:

- `WHERE` filters rows before aggregation
- `HAVING` filters groups after aggregation

---

## Setup Instructions

1. **Create the Database**:

   ```sql
   CREATE DATABASE vehicle_management;
   ```

2. **Run the SQL Script**:
   Execute all statements in `queries.sql` in the following order:

   - Database creation
   - Table creation statements
   - Data insertion statements
   - Query execution statements

3. **Verify Setup**:
   You can verify the setup by running any of the query statements and checking the results.

## Sample Data

The database includes sample data for testing:

- **3 users** (2 customers, 1 admin)
- **4 vehicles** (2 cars, 1 bike, 1 truck)
- **4 bookings** with varying statuses and dates

## Database Management Notes

- **Cascade Deletion**: When a user is deleted, their bookings are automatically deleted (`ON DELETE CASCADE` on users foreign key)
- **Restrict Deletion**: Vehicles with existing bookings cannot be deleted (`ON DELETE RESTRICT` on vehicles foreign key)
- **Data Integrity**: Multiple CHECK constraints ensure data validity (valid roles, vehicle types, statuses, positive prices, etc.)

## Future Enhancements

Potential improvements for the system:

- Add payment tracking
- Implement user authentication
- Add vehicle maintenance scheduling
- Create views for common queries
- Add indexes for performance optimization
- Implement stored procedures for complex operations
