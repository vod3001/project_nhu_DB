CREATE TABLE building (
	building_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	address TEXT NOT NULL
);

CREATE TABLE equipment_type (
	equipment_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE organization (
	organization_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE person (
	person_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE
);

CREATE TABLE room (
	room_id SERIAL PRIMARY KEY,
	building_id INT NOT NULL REFERENCES building(building_id),
	name_or_number TEXT NOT NULL,
	capacity INT NOT NULL CHECK (capacity > 0),
	type TEXT NOT NULL CHECK (type IN ('meeting room', 'lecture room', 'studio', 'workshop room')),
	requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
	UNIQUE (building_id, name_or_number)
);

CREATE TABLE room_equipment (
	room_id INT NOT NULL REFERENCES room(room_id),
	equipment_id INT NOT NULL REFERENCES equipment_type(equipment_id),
	quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
	PRIMARY KEY (room_id, equipment_id)
);

CREATE TABLE booking_series (
	series_id SERIAL PRIMARY KEY,
	room_id INT NOT NULL REFERENCES room(room_id),
	organization_id INT REFERENCES organization(organization_id),
	created_by INT NOT NULL REFERENCES person(person_id),
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
	booking_id SERIAL PRIMARY KEY,
	room_id INT NOT NULL REFERENCES room(room_id),
	organization_id INT REFERENCES organization(organization_id),
	created_by INT NOT NULL REFERENCES person(person_id),
	series_id INT REFERENCES booking_series(series_id),
	start_datetime TIMESTAMP NOT NULL,
	end_datetime TIMESTAMP NOT NULL,
	status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'rejected')),
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	cancelled_at TIMESTAMP,
	cancellation_reason TEXT,
	requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
	approval_granted BOOLEAN,
    CHECK (
        (status = 'pending' AND requires_approval = TRUE AND approval_granted IS NULL) OR
        (status = 'confirmed' AND (requires_approval = FALSE OR approval_granted = TRUE)) OR
        (status = 'rejected' AND requires_approval = TRUE AND approval_granted = FALSE) OR
        (status = 'cancelled')
    ),
    CHECK (DATE(start_datetime) = DATE(end_datetime)),
	CHECK (end_datetime > start_datetime)
);
