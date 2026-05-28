-- Q1: How many bookings has each room had?
SELECT 
    r.id AS room_id,
    b.name AS building_name,
    r.name_or_number AS room_name,
    COUNT(bk.id) AS total_bookings
FROM room r
JOIN building b ON r.building_id = b.id
LEFT JOIN booking bk ON r.id = bk.room_id
GROUP BY r.id, b.name, r.name_or_number
ORDER BY total_bookings DESC;


-- Q2: Which organizations use the service most?
-- "Use" is defined as confirmed bookings only
SELECT 
    org.id AS organization_id,
    org.name AS organization_name,
    COUNT(bk.id) AS confirmed_bookings
FROM organization org
LEFT JOIN booking bk ON org.id = bk.organization_id
    AND bk.status = 'confirmed'
GROUP BY org.id, org.name
ORDER BY confirmed_bookings DESC;


-- Q3: Which rooms are most heavily used (by total hours booked)?
SELECT 
    r.id AS room_id,
    b.name AS building_name,
    r.name_or_number AS room_name,
    ROUND(EXTRACT(EPOCH FROM SUM(bk.end_datetime - bk.start_datetime)) / 3600, 2) AS total_hours_booked
FROM room r
JOIN building b ON r.building_id = b.id
JOIN booking bk ON r.id = bk.room_id
WHERE bk.status = 'confirmed'
GROUP BY r.id, b.name, r.name_or_number
ORDER BY total_hours_booked DESC;


-- Q4: Which equipment types appear most often in booked rooms?
-- Counts total quantity per equipment type across rooms that have at least one confirmed booking.
-- Avoid counting the same room's equipment multiple times when that room has >= 1 confirmed booking.
SELECT 
    eq.id AS equipment_id,
    eq.name AS equipment_name,
    SUM(re.quantity) AS total_quantity_in_used_rooms
FROM equipment_type eq
JOIN room_equipment re ON eq.id = re.equipment_id
JOIN (
    SELECT DISTINCT room_id
    FROM booking
    WHERE status = 'confirmed'
) confirmed_rooms ON re.room_id = confirmed_rooms.room_id
GROUP BY eq.id, eq.name
ORDER BY total_quantity_in_used_rooms DESC;


-- Q5: How many bookings were cancelled?
SELECT COUNT(*) AS total_cancelled_bookings
FROM booking
WHERE status = 'cancelled';


-- Q6: Which bookings required approval, and was it granted?
SELECT 
    id AS booking_id,
    room_id,
    start_datetime,
    status,
    CASE 
        WHEN approval_granted IS NULL THEN 'Pending Decision'
        WHEN approval_granted = TRUE  THEN 'Approved'
        ELSE                               'Rejected'
    END AS approval_status
FROM booking
WHERE requires_approval = TRUE;


-- Q7: List all occurrences of a given booking series
SELECT 
    id AS booking_id,
    start_datetime,
    end_datetime,
    status
FROM booking
-- Could use any other series_id as long as the row is seeded
WHERE series_id = 1  
ORDER BY start_datetime ASC;


-- Q8: Which bookings were made by a given organization within a date range?
SELECT 
    bk.id AS booking_id,
    r.name_or_number AS room_name,
    bk.start_datetime,
    bk.end_datetime,
    bk.status
FROM booking bk
JOIN room r ON bk.room_id = r.id
-- Could use any other organization_id, start_datetime, end_datetime as long as the rows are seeded
WHERE bk.organization_id = 1
  AND bk.start_datetime >= '2027-07-02 14:00:00'
  AND bk.end_datetime   <= '2027-07-09 18:00:00'
ORDER BY bk.start_datetime ASC;