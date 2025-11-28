-- Users Table
-- Stores all user accounts (Requesting Doctors, Patients, Volunteer Physicians, Site Admins)

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('requesting_doctor', 'requesting_patient', 'volunteer_physician', 'site_admin')),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    license_number VARCHAR(100),  -- For doctors
    license_verified BOOLEAN DEFAULT FALSE,
    license_expiry DATE,
    license_verification_document_url TEXT,  -- URL to uploaded license document
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMPTZ
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_license ON users(license_number) WHERE license_number IS NOT NULL;
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = TRUE;

-- User Profiles (Extended information)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    specialization VARCHAR(255),  -- For volunteer physicians
    languages_spoken TEXT[],  -- Array of language codes
    profile_image_url TEXT,
    organization_name VARCHAR(255),  -- Clinic/hospital name for requesting doctors
    organization_address TEXT,
    years_of_experience INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

