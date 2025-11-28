-- Scheduling Tables
-- Volunteer availability and appointment slots

-- Availability Blocks Table
-- Volunteers set availability in blocks (e.g., "2 hours on Monday")
CREATE TABLE availability_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    slot_duration_minutes INTEGER DEFAULT 10,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern JSONB,  -- For recurring availability (e.g., "every Monday")
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (end_time > start_time)
);

-- Indexes for availability_blocks
CREATE INDEX idx_availability_blocks_volunteer ON availability_blocks(volunteer_id);
CREATE INDEX idx_availability_blocks_time ON availability_blocks(start_time, end_time);
CREATE INDEX idx_availability_blocks_active ON availability_blocks(volunteer_id, status) WHERE status = 'active';

-- Appointment Slots Table
-- Auto-generated slots from availability blocks
CREATE TABLE appointment_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    availability_block_id UUID REFERENCES availability_blocks(id) ON DELETE CASCADE,
    volunteer_id UUID NOT NULL REFERENCES users(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'available' CHECK (status IN ('available', 'booked', 'cancelled', 'expired')),
    consultation_id UUID REFERENCES consultations(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (end_time > start_time)
);

-- Indexes for appointment_slots
CREATE INDEX idx_appointment_slots_volunteer ON appointment_slots(volunteer_id);
CREATE INDEX idx_appointment_slots_time ON appointment_slots(start_time, end_time);
CREATE INDEX idx_appointment_slots_status ON appointment_slots(status, start_time) WHERE status = 'available';
CREATE INDEX idx_appointment_slots_consultation ON appointment_slots(consultation_id) WHERE consultation_id IS NOT NULL;

-- Time Zone Conversions Cache (for performance)
CREATE TABLE timezone_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    utc_time TIMESTAMPTZ NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    local_time TIMESTAMPTZ NOT NULL,
    offset_seconds INTEGER NOT NULL,
    is_dst BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(utc_time, timezone)
);

CREATE INDEX idx_timezone_cache_utc ON timezone_cache(utc_time);
CREATE INDEX idx_timezone_cache_timezone ON timezone_cache(timezone);

