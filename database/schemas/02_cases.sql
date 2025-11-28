-- Cases Table
-- Medical consultation requests created by Requesting Doctors

CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requesting_doctor_id UUID NOT NULL REFERENCES users(id),
    patient_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    chief_complaint TEXT,
    history TEXT,
    physical_exam_notes TEXT,
    urgency VARCHAR(20) NOT NULL CHECK (urgency IN ('critical', 'priority', 'routine')),
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'assigned', 'in_consultation', 'completed', 'cancelled')),
    assigned_volunteer_id UUID REFERENCES users(id),
    scheduled_consultation_id UUID REFERENCES consultations(id),
    priority_score INTEGER DEFAULT 0,  -- Calculated based on urgency and time
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ,  -- For offline sync tracking
    is_offline BOOLEAN DEFAULT FALSE,
    device_id VARCHAR(255),  -- Device that created this case (for offline sync)
    metadata JSONB  -- Additional flexible data
);

-- Indexes for cases table
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_cases_urgency ON cases(urgency);
CREATE INDEX idx_cases_doctor ON cases(requesting_doctor_id);
CREATE INDEX idx_cases_volunteer ON cases(assigned_volunteer_id);
CREATE INDEX idx_cases_patient ON cases(patient_id);
CREATE INDEX idx_cases_priority ON cases(priority_score DESC, created_at);
CREATE INDEX idx_cases_offline ON cases(is_offline, device_id) WHERE is_offline = TRUE;

-- Case Status History (Audit trail)
CREATE TABLE case_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_case_status_history_case ON case_status_history(case_id);
CREATE INDEX idx_case_status_history_created ON case_status_history(created_at);

