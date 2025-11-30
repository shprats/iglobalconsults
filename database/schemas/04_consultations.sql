-- Consultations Table
-- Scheduled and completed video consultations

CREATE TABLE consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id),
    volunteer_id UUID NOT NULL REFERENCES users(id),
    patient_id UUID REFERENCES users(id),
    requesting_doctor_id UUID NOT NULL REFERENCES users(id),
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,
    duration_minutes INTEGER,
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled')),
    agora_channel_name VARCHAR(255),
    agora_app_id VARCHAR(255),
    connection_quality VARCHAR(20),  -- 'high', 'medium', 'low', 'critical'
    fallback_mode VARCHAR(50),  -- 'full_video', 'audio_only', 'text_chat'
    volunteer_notes TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_notes TEXT,
    recording_url TEXT,  -- If consultation was recorded (with consent)
    recording_consent_given BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT
);

-- Indexes for consultations table
CREATE INDEX idx_consultations_case ON consultations(case_id);
CREATE INDEX idx_consultations_volunteer ON consultations(volunteer_id);
CREATE INDEX idx_consultations_patient ON consultations(patient_id);
CREATE INDEX idx_consultations_scheduled ON consultations(scheduled_start);
CREATE INDEX idx_consultations_status ON consultations(status);
-- Note: Partial index with NOW() cannot be created directly
-- Will be created as a regular index, filtering can be done in queries
CREATE INDEX idx_consultations_upcoming ON consultations(scheduled_start, status) WHERE status = 'scheduled';

-- Consultation Participants (for multi-party consultations if needed)
CREATE TABLE consultation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id UUID NOT NULL REFERENCES consultations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    role VARCHAR(50) NOT NULL,  -- 'volunteer', 'patient', 'requesting_doctor', 'observer'
    joined_at TIMESTAMPTZ,
    left_at TIMESTAMPTZ,
    connection_quality VARCHAR(20),
    UNIQUE(consultation_id, user_id)
);

CREATE INDEX idx_consultation_participants_consultation ON consultation_participants(consultation_id);
CREATE INDEX idx_consultation_participants_user ON consultation_participants(user_id);

-- Consultation Quality Metrics (for monitoring and improvement)
CREATE TABLE consultation_quality_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id UUID NOT NULL REFERENCES consultations(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ NOT NULL,
    bandwidth_kbps INTEGER,
    packet_loss_percent DECIMAL(5,2),
    latency_ms INTEGER,
    video_quality VARCHAR(20),
    audio_quality VARCHAR(20),
    fallback_mode_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_consultation_quality_consultation ON consultation_quality_metrics(consultation_id);
CREATE INDEX idx_consultation_quality_timestamp ON consultation_quality_metrics(timestamp);

