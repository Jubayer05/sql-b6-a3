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