-- Q1: How many bookings has each room had?
SELECT 
    r.room_id,
    b.name AS building_name,
    r.name_or_number AS room_name,
    COUNT(bk.booking_id) AS total_bookings
FROM room r
JOIN building b ON r.building_id = b.building_id
LEFT JOIN booking bk ON r.room_id = bk.room_id
GROUP BY r.room_id, b.name, r.name_or_number
ORDER BY total_bookings DESC;

-- Q2: Which organizations use the service most?
SELECT 
    org.organization_id,
    org.name AS organization_name,
    COUNT(bk.booking_id) AS confirmed_bookings
FROM organization org
LEFT JOIN booking bk ON org.organization_id = bk.organization_id 
    AND bk.status = 'confirmed'
GROUP BY org.organization_id, org.name
ORDER BY confirmed_bookings DESC;

-- Q3: Which rooms are most heavily used (by total hours booked)?
SELECT 
    r.room_id,
    bl.name AS building_name,
    r.name_or_number AS room_name,
    ROUND(EXTRACT(EPOCH FROM SUM(bk.end_datetime - bk.start_datetime)) / 3600, 2) AS total_hours_booked
FROM room r
JOIN building bl ON r.building_id = bl.building_id
JOIN booking bk ON r.room_id = bk.room_id
WHERE bk.status = 'confirmed'
GROUP BY r.room_id, bl.name, r.name_or_number
ORDER BY total_hours_booked DESC;

-- Q4: Which equipment types appear most often in booked rooms?
SELECT 
    eq.equipment_id,
    eq.name AS equipment_name,
    SUM(re.quantity) AS total_quantity_in_used_rooms
FROM equipment_type eq
JOIN room_equipment re ON eq.equipment_id = re.equipment_id
JOIN booking bk ON re.room_id = bk.room_id
WHERE bk.status = 'confirmed'
GROUP BY eq.equipment_id, eq.name
ORDER BY total_quantity_in_used_rooms DESC;

-- Q5: How many bookings were cancelled?
SELECT COUNT(*) AS total_cancelled_bookings
FROM booking
WHERE status = 'cancelled';

-- Q6: Which bookings required approval, and was it granted?
SELECT 
    booking_id,
    room_id,
    start_datetime,
    status,
    CASE 
        WHEN approval_granted IS NULL THEN 'Pending Decision'
        WHEN approval_granted = TRUE THEN 'Approved'
        ELSE 'Rejected'
    END AS approval_status
FROM booking
WHERE requires_approval = TRUE;

-- Q7: List all occurrences of a given booking series
-- Replace :target_series_id with the id of the series to be searched
SELECT 
    booking_id,
    start_datetime,
    end_datetime,
    status
FROM booking
WHERE series_id = :target_series_id
ORDER BY start_datetime ASC;

-- Q8: Which bookings were made by a given organization within a date range?
-- Replace :organization_id, :start_date, và :end_date with real values
SELECT 
    bk.booking_id,
    r.name_or_number AS room_name,
    bk.start_datetime,
    bk.end_datetime,
    bk.status
FROM booking bk
JOIN room r ON bk.room_id = r.room_id
WHERE bk.organization_id = :organization_id
  AND bk.start_datetime >= :start_date
  AND bk.end_datetime <= :end_date
ORDER BY bk.start_datetime ASC;