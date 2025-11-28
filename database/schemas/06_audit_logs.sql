-- Audit Logs Table
-- HIPAA/GDPR compliance - track all PHI access and modifications

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,  -- 'view', 'create', 'update', 'delete', 'download', 'export'
    resource_type VARCHAR(50) NOT NULL,  -- 'case', 'file', 'consultation', 'user'
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    request_method VARCHAR(10),  -- 'GET', 'POST', 'PUT', 'DELETE'
    request_path TEXT,
    request_body_hash VARCHAR(64),  -- SHA-256 hash of request body (for privacy)
    response_status INTEGER,
    details JSONB,  -- Additional context (non-PHI)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Partition by month for performance (large table)
-- Note: This requires PostgreSQL 10+
-- CREATE TABLE audit_logs_2025_11 PARTITION OF audit_logs
--     FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

-- Indexes for audit_logs
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_ip ON audit_logs(ip_address);

-- Composite index for common queries
CREATE INDEX idx_audit_logs_user_resource ON audit_logs(user_id, resource_type, created_at DESC);

