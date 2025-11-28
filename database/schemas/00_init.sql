-- GlobalHealth Connect Database Initialization
-- Run this file first to set up the database

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";  -- For encryption functions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search (if needed)

-- Set timezone to UTC for all operations
SET timezone = 'UTC';

-- Create custom types if needed
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('requesting_doctor', 'requesting_patient', 'volunteer_physician', 'site_admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE case_status AS ENUM ('draft', 'submitted', 'assigned', 'in_consultation', 'completed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE consultation_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Note: Individual tables will have triggers created in their respective schema files

