-- =====================================================
-- V2: Dentist profiles, education, experience, skills
-- =====================================================

-- Skills lookup table
CREATE TABLE skills (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(100) NOT NULL UNIQUE,
    category   VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO skills (name, category) VALUES
    ('General Dentistry', 'Clinical'),
    ('Orthodontics', 'Specialization'),
    ('Endodontics', 'Specialization'),
    ('Periodontics', 'Specialization'),
    ('Prosthodontics', 'Specialization'),
    ('Oral Surgery', 'Specialization'),
    ('Pediatric Dentistry', 'Specialization'),
    ('Implantology', 'Specialization'),
    ('Cosmetic Dentistry', 'Specialization'),
    ('Root Canal Treatment', 'Clinical'),
    ('Teeth Whitening', 'Clinical'),
    ('Dental X-Ray', 'Diagnostic'),
    ('Crown and Bridge', 'Clinical'),
    ('Dentures', 'Clinical'),
    ('Scaling and Polishing', 'Clinical'),
    ('Tooth Extraction', 'Clinical'),
    ('Laser Dentistry', 'Advanced'),
    ('CAD/CAM', 'Technology'),
    ('Digital Smile Design', 'Technology');

-- Dentist profiles
CREATE TABLE dentist_profiles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name           VARCHAR(150) NOT NULL,
    date_of_birth       DATE,
    gender              VARCHAR(10) CHECK (gender IN ('MALE','FEMALE','OTHER')),
    bio                 TEXT,
    reg_number          VARCHAR(50),
    reg_council         VARCHAR(100),
    reg_verified        BOOLEAN NOT NULL DEFAULT FALSE,
    experience_years    INT DEFAULT 0,
    salary_min          INT,
    salary_max          INT,
    availability        VARCHAR(20) DEFAULT 'IMMEDIATE'
                            CHECK (availability IN ('IMMEDIATE','15_DAYS','30_DAYS','60_DAYS')),
    preferred_cities    TEXT[],
    languages           TEXT[],
    resume_url          TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_dentist_user ON dentist_profiles(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_dentist_availability ON dentist_profiles(availability) WHERE deleted_at IS NULL;

-- Education
CREATE TABLE education (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dentist_id      UUID NOT NULL REFERENCES dentist_profiles(id) ON DELETE CASCADE,
    degree          VARCHAR(100) NOT NULL,
    institution     VARCHAR(200) NOT NULL,
    start_year      INT,
    end_year        INT,
    grade           VARCHAR(20),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- Experience
CREATE TABLE experience (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dentist_id      UUID NOT NULL REFERENCES dentist_profiles(id) ON DELETE CASCADE,
    title           VARCHAR(100) NOT NULL,
    organization    VARCHAR(200) NOT NULL,
    location        VARCHAR(100),
    start_date      DATE NOT NULL,
    end_date        DATE,
    is_current      BOOLEAN DEFAULT FALSE,
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- Dentist skills (many-to-many)
CREATE TABLE dentist_skills (
    dentist_id UUID REFERENCES dentist_profiles(id) ON DELETE CASCADE,
    skill_id   UUID REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (dentist_id, skill_id)
);
