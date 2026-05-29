CREATE TABLE building (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	address TEXT NOT NULL
);

CREATE TABLE equipment_type (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE organization (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE person (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE
);

CREATE TABLE room (
	id SERIAL PRIMARY KEY,
	building_id INT NOT NULL REFERENCES building(id),
	name_or_number TEXT NOT NULL,
	capacity INT NOT NULL CHECK (capacity > 0),
	type TEXT NOT NULL CHECK (type IN ('meeting room', 'lecture room', 'studio', 'workshop room')),
	requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
	UNIQUE (building_id, name_or_number)
);

CREATE TABLE room_equipment (
	room_id INT NOT NULL REFERENCES room(id),
	equipment_id INT NOT NULL REFERENCES equipment_type(id),
	quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
	PRIMARY KEY (room_id, equipment_id)
);

CREATE TABLE booking_series (
	id SERIAL PRIMARY KEY,
	room_id INT NOT NULL REFERENCES room(id),
	organization_id INT REFERENCES organization(id),									-- Organization ID is nullable because a person should be able to book a room for themselves only
	created_by INT NOT NULL REFERENCES person(id),
	recurrence_rule TEXT NOT NULL,
	day_of_week TEXT NOT NULL,
	start_time TIME NOT NULL,
	end_time TIME NOT NULL,
	series_start_date DATE NOT NULL,
	series_end_date DATE NOT NULL,
    CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
	CHECK (series_end_date >= series_start_date),
	CHECK (end_time > start_time)
);

CREATE TABLE booking (
	id SERIAL PRIMARY KEY,
	room_id INT NOT NULL REFERENCES room(id),
	organization_id INT REFERENCES organization(id),									-- Organization ID is nullable because a person should be able to book a room for themselves only
	created_by INT NOT NULL REFERENCES person(id),
	series_id INT REFERENCES booking_series(id),
	start_datetime TIMESTAMP NOT NULL,
	end_datetime TIMESTAMP NOT NULL,
	status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'rejected')),
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	cancelled_at TIMESTAMP,
	cancellation_reason TEXT,
	requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
	approval_granted BOOLEAN,


	CHECK (
		(requires_approval = FALSE AND approval_granted IS NULL  AND status IN ('confirmed', 'cancelled'))  -- no approval needed, so of course status is confirmed or cancelled
		OR
		(requires_approval = TRUE  AND approval_granted IS NULL  AND status IN ('pending', 'cancelled'))    -- awaiting decision: may be cancelled before decision is made
		OR
		(requires_approval = TRUE  AND approval_granted = TRUE   AND status IN ('confirmed', 'cancelled'))  -- approved: could still be cancelled afterwards
		OR
		(requires_approval = TRUE  AND approval_granted = FALSE  AND status = 'rejected')                   -- rejected: last status, could not be cancelled 
	),


    CHECK (DATE(start_datetime) = DATE(end_datetime)),	-- The booking start time and end time must be in the same day (no overnight session)
	CHECK (end_datetime > start_datetime)				-- And the booking end time must be after start time
);
