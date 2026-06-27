-- =====================================================
-- V3: Clinics, clinic staff, clinic photos
-- =====================================================

CREATE TABLE clinics (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id             UUID NOT NULL REFERENCES users(id),
    name                 VARCHAR(200) NOT NULL,
    slug                 VARCHAR(200) UNIQUE,
    logo_url             TEXT,
    address              TEXT,
    city                 VARCHAR(100),
    state                VARCHAR(100),
    country              VARCHAR(100) DEFAULT 'India',
    pincode              VARCHAR(10),
    latitude             DECIMAL(10, 8),
    longitude            DECIMAL(11, 8),
    phone                VARCHAR(20),
    email                VARCHAR(255),
    website              VARCHAR(255),
    description          TEXT,
    specialties          TEXT[],
    working_hours        JSONB,
    chairs_count         INT DEFAULT 1,
    verification_status  VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                             CHECK (verification_status IN ('PENDING','VERIFIED','REJECTED')),
    verified_by          UUID REFERENCES users(id),
    verified_at          TIMESTAMPTZ,
    region_id            UUID REFERENCES regions(id),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at           TIMESTAMPTZ
);

CREATE INDEX idx_clinic_owner ON clinics(owner_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_clinic_city ON clinics(city) WHERE deleted_at IS NULL;
CREATE INDEX idx_clinic_verification ON clinics(verification_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_clinic_region ON clinics(region_id) WHERE deleted_at IS NULL;

-- Clinic staff (multiple users per clinic)
CREATE TABLE clinic_staff (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id  UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role       VARCHAR(20) NOT NULL
                   CHECK (role IN ('OWNER','HR','RECRUITER','RECEPTION')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (clinic_id, user_id)
);

-- Clinic photos
CREATE TABLE clinic_photos (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id  UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    url        TEXT NOT NULL,
    caption    VARCHAR(255),
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);
