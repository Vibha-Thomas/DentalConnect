-- =====================================================
-- V8: Dentist profile extended fields
--     Adds: extended personal/professional fields,
--           cached completion score, verification status,
--           onboarding progress tracking
-- =====================================================

-- Extended personal information
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS nationality      VARCHAR(50);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS phone            VARCHAR(20);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS photo_url        TEXT;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS address          TEXT;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS city             VARCHAR(100);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS state            VARCHAR(100);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS country          VARCHAR(100);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS pin_code         VARCHAR(20);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS emergency_contact_name  VARCHAR(100);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS emergency_contact_phone VARCHAR(20);

-- Extended professional information
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS reg_valid_until       DATE;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS degree                VARCHAR(100);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS university            VARCHAR(200);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS graduation_year       INT;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS internship_hospital   VARCHAR(200);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS expected_salary       INT;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS employment_preference VARCHAR(20)
    CHECK (employment_preference IN ('FULL_TIME','PART_TIME','LOCUM','CONSULTANT','INTERNSHIP'));

-- Onboarding wizard progress
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS onboarding_step      INT     DEFAULT 0;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE;

-- Cached completion score (computed on write, NOT on every read)
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS profile_completion_score       INT        DEFAULT 0;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS profile_completion_updated_at TIMESTAMPTZ;

-- Verification state machine: PENDING → UNDER_REVIEW → VERIFIED | REJECTED | SUSPENDED
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS verification_status  VARCHAR(20) DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING','UNDER_REVIEW','VERIFIED','REJECTED','SUSPENDED'));
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS verification_notes   TEXT;
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS verified_by          UUID REFERENCES users(id);
ALTER TABLE dentist_profiles ADD COLUMN IF NOT EXISTS verified_at          TIMESTAMPTZ;

-- Clinic type (added early as jobs depend on it)
ALTER TABLE clinics ADD COLUMN IF NOT EXISTS clinic_type VARCHAR(20) DEFAULT 'PRIVATE'
    CHECK (clinic_type IN ('PRIVATE','CORPORATE','HOSPITAL','DENTAL_CHAIN','UNIVERSITY'));

-- Indexes
CREATE INDEX IF NOT EXISTS idx_dentist_verification_status ON dentist_profiles(verification_status)
    WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_dentist_completion_score ON dentist_profiles(profile_completion_score)
    WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_dentist_onboarding_completed ON dentist_profiles(onboarding_completed)
    WHERE deleted_at IS NULL;
