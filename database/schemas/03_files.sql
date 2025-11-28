-- Files Table
-- Medical images, documents, and other files associated with cases

CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    file_name VARCHAR(255) NOT NULL,
    original_file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,  -- 'xray', 'lab_result', 'photo', 'document', 'dicom'
    file_size BIGINT NOT NULL,
    s3_key VARCHAR(500) NOT NULL,
    s3_bucket VARCHAR(100) NOT NULL,
    s3_region VARCHAR(50) NOT NULL,
    mime_type VARCHAR(100),
    upload_status VARCHAR(50) DEFAULT 'pending' CHECK (upload_status IN ('pending', 'uploading', 'completed', 'failed', 'cancelled')),
    tus_upload_id VARCHAR(255) UNIQUE,  -- For resumable uploads (TUS protocol)
    upload_progress DECIMAL(5,2) DEFAULT 0.00,  -- 0.00 to 100.00
    quality_score DECIMAL(3,2),  -- 0.00 to 1.00 (image quality assessment)
    quality_issues TEXT[],  -- Array of quality issues found
    quality_analysis_at TIMESTAMPTZ,
    is_analyzed BOOLEAN DEFAULT FALSE,
    metadata JSONB,  -- DICOM metadata, image dimensions, etc.
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    error_message TEXT
);

-- Indexes for files table
CREATE INDEX idx_files_case ON files(case_id);
CREATE INDEX idx_files_upload_status ON files(upload_status);
CREATE INDEX idx_files_tus_id ON files(tus_upload_id) WHERE tus_upload_id IS NOT NULL;
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_quality ON files(quality_score) WHERE quality_score IS NOT NULL;

-- File Access Log (HIPAA compliance - track who accessed which files)
CREATE TABLE file_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    accessed_by UUID NOT NULL REFERENCES users(id),
    access_type VARCHAR(50) NOT NULL,  -- 'view', 'download', 'delete'
    ip_address INET,
    user_agent TEXT,
    accessed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_file_access_logs_file ON file_access_logs(file_id);
CREATE INDEX idx_file_access_logs_user ON file_access_logs(accessed_by);
CREATE INDEX idx_file_access_logs_accessed ON file_access_logs(accessed_at);

