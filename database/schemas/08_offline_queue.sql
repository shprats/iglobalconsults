-- Offline Queue Table
-- Mobile app offline actions that need to sync when connection is restored

CREATE TABLE offline_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    action_type VARCHAR(50) NOT NULL,  -- 'create_case', 'update_case', 'upload_file', 'delete_file'
    payload JSONB NOT NULL,
    priority INTEGER DEFAULT 0,  -- Higher number = higher priority (critical cases first)
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'syncing', 'completed', 'failed', 'conflict')),
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    error_message TEXT,
    conflict_resolution VARCHAR(50),  -- 'server_wins', 'client_wins', 'manual'
    server_version_id UUID,  -- If conflict detected, store server version
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ,
    last_retry_at TIMESTAMPTZ
);

-- Indexes for offline_queue
CREATE INDEX idx_offline_queue_user ON offline_queue(user_id, status);
CREATE INDEX idx_offline_queue_device ON offline_queue(device_id, status);
CREATE INDEX idx_offline_queue_priority ON offline_queue(priority DESC, created_at) WHERE status = 'pending';
CREATE INDEX idx_offline_queue_status ON offline_queue(status, created_at);

-- Sync Conflicts Table
-- Track conflicts that need manual resolution
CREATE TABLE sync_conflicts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    queue_item_id UUID NOT NULL REFERENCES offline_queue(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID NOT NULL,
    client_version JSONB NOT NULL,
    server_version JSONB NOT NULL,
    conflict_fields TEXT[],  -- Array of field names that conflict
    resolution_status VARCHAR(50) DEFAULT 'pending' CHECK (resolution_status IN ('pending', 'resolved', 'ignored')),
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sync_conflicts_queue ON sync_conflicts(queue_item_id);
CREATE INDEX idx_sync_conflicts_user ON sync_conflicts(user_id, resolution_status) WHERE resolution_status = 'pending';

