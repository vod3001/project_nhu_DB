INSERT INTO building (name, address)
VALUES 
    ('TUAS', 'Maarintie 8'),
    ('Undergraduate Center', 'Otakaari 1'),
    ('Computer Science Building', 'Konemiehentie 2');

INSERT INTO room (building_id, name_or_number, capacity, type, requires_approval)
VALUES
    (
        (SELECT building_id FROM building WHERE name = 'TUAS'),
        'AS1', 100, 'lecture room', TRUE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'TUAS'),
        '2519', 6, 'studio', FALSE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'TUAS'),
        'Odeion', 30, 'meeting room', FALSE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Undergraduate Center'),
        'U250a', 20, 'workshop room', TRUE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Undergraduate Center'),
        'M3', 24, 'lecture room', FALSE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Undergraduate Center'),
        'Mylly', 12, 'meeting room', TRUE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Computer Science Building'),
        'T3', 48, 'lecture room', TRUE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Computer Science Building'),
        'C227', 12, 'studio', TRUE
    ),
    (
        (SELECT building_id FROM building WHERE name = 'Computer Science Building'),
        'B223', 8, 'studio', FALSE
    );


INSERT INTO equipment_type(name)
VALUES 
    ('Whiteboard'),
    ('Projector'),
    ('Microphone'),
    ('Video camera');

INSERT INTO room_equipment(room_id, equipment_id)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'AS1'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Projector')
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = '2519'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Video camera')
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'Odeion'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Microphone')
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'B223'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Whiteboard')
    );


INSERT INTO room_equipment(room_id, equipment_id, quantity)
VALUES 
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = '2519'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Whiteboard'),

        2
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'Odeion'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Video camera'),

        3
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'U250a'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Whiteboard'),

        2
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'M3'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Whiteboard'),
        4
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'M3'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Microphone'),

        6
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'Mylly'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Projector'),
        
        2
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'T3'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Projector'),

        3
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'C227'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Video camera'),

        5
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'C227'),

        (SELECT equipment_id FROM equipment_type WHERE name = 'Whiteboard'),
        
        6
    );

INSERT INTO organization (name)
VALUES
    ('AYY'),
    ('HOAS'),
    ('ELEC');

INSERT INTO person (name, email)
VALUES
    ('James', 'james@gmail.com'),
    ('To Lam', 'tolam@gmail.com'),
    ('Luka', 'luka@gmail.com');

INSERT INTO booking_series (room_id, organization_id, created_by, recurrence_rule, day_of_week, start_time, end_time, series_start_date, series_end_date)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'AS1'),

        (SELECT organization_id FROM organization WHERE name = 'AYY'),

        (SELECT person_id FROM person WHERE name = 'To Lam'),

        'Every friday for 2 weeks',
        
        'Friday',

        '14:30',

        '16:00',

        '2027-7-2',

        '2027-7-9'
    );

INSERT INTO booking_series (room_id, created_by, recurrence_rule, day_of_week, start_time, end_time, series_start_date, series_end_date)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'U250a'),

        (SELECT person_id FROM person WHERE name = 'James'),

        'Every sunday for 2 weeks',
        
        'Sunday',

        '16:15',

        '18:00',

        '2027-7-4',

        '2027-7-11'
    );

INSERT INTO booking(room_id, organization_id, created_by, series_id, start_datetime, end_datetime, status, requires_approval, approval_granted)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'AS1'),

        (SELECT organization_id FROM organization WHERE name = 'AYY'),

        (SELECT person_id FROM person WHERE name = 'To Lam'),

        (SELECT series_id 
        FROM booking_series AS bs
        INNER JOIN person AS p ON bs.created_by = p.person_id
        WHERE bs.series_start_date = '2027-7-2' AND bs.series_end_date ='2027-7-9' AND p.name = 'To Lam'),

        '2027-7-2 14:30',

        '2027-7-2 16:00',

        'confirmed',

        TRUE,

        TRUE
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = 'AS1'),

        (SELECT organization_id FROM organization WHERE name = 'AYY'),

        (SELECT person_id FROM person WHERE name = 'To Lam'),

        (SELECT series_id 
        FROM booking_series AS bs
        INNER JOIN person AS p ON bs.created_by = p.person_id
        WHERE bs.series_start_date = '2027-7-2' AND bs.series_end_date ='2027-7-9' AND p.name = 'To Lam'),

        '2027-7-9 14:30',

        '2027-7-9 16:00',

        'confirmed',

        TRUE,

        TRUE
    );

INSERT INTO booking(room_id, created_by, series_id, start_datetime, end_datetime, requires_approval)
VALUES 
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'U250a'),

        (SELECT person_id FROM person WHERE name = 'James'),

        (SELECT series_id 
        FROM booking_series AS bs
        INNER JOIN person AS p ON bs.created_by = p.person_id
        WHERE bs.series_start_date = '2027-7-4' AND bs.series_end_date ='2027-7-11' AND p.name = 'James'),

        '2027-7-4 16:15',

        '2027-7-4 18:00',

        TRUE
    ),
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Undergraduate Center' AND r.name_or_number = 'U250a'),

        (SELECT person_id FROM person WHERE name = 'James'),

        (SELECT series_id 
        FROM booking_series AS bs
        INNER JOIN person AS p ON bs.created_by = p.person_id
        WHERE bs.series_start_date = '2027-7-4' AND bs.series_end_date = '2027-7-11' AND p.name = 'James'),

        '2027-7-11 16:15',

        '2027-7-11 18:00',

        TRUE
    );

INSERT INTO booking (room_id, created_by, start_datetime, end_datetime, status, cancelled_at, cancellation_reason, requires_approval)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'C227'),

        (SELECT person_id FROM person WHERE name = 'Luka'),

        '2026-11-11 16:15',

        '2026-11-11 19:15',

        'cancelled',

        '2026-11-11 11:15',

        'Sick',

        TRUE
    );

INSERT INTO booking (room_id, created_by, start_datetime, end_datetime, status, requires_approval, approval_granted)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'Computer Science Building' AND r.name_or_number = 'T3'),

        (SELECT person_id FROM person WHERE name = 'Luka'),

        '2026-11-11 16:15',

        '2026-11-11 19:15',

        'rejected',

        TRUE,

        FALSE
    );


INSERT INTO booking (room_id, created_by, start_datetime, end_datetime, status)
VALUES
    (
        (SELECT r.room_id 
        FROM room AS r 
        INNER JOIN building AS b  ON r.building_id = b.building_id
        WHERE b.name = 'TUAS' AND r.name_or_number = '2519'),

        (SELECT person_id FROM person WHERE name = 'To Lam'),

        '2026-9-11 16:15',

        '2026-9-11 19:15',

        'confirmed'
    );
