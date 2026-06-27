-- =====================================================
-- V4: Jobs, job_skills, saved_jobs with Full Text Search
-- =====================================================

CREATE TABLE jobs (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id         UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    title             VARCHAR(200) NOT NULL,
    slug              VARCHAR(250),
    employment_type   VARCHAR(20) NOT NULL
                          CHECK (employment_type IN ('INTERNSHIP','LOCUM','PART_TIME','FULL_TIME')),
    experience_min    INT DEFAULT 0,
    experience_max    INT,
    salary_min        INT,
    salary_max        INT,
    salary_negotiable BOOLEAN DEFAULT FALSE,
    benefits          TEXT,
    description       TEXT NOT NULL,
    location          VARCHAR(200),
    city              VARCHAR(100),
    state             VARCHAR(100),
    interview_type    VARCHAR(20) DEFAULT 'IN_PERSON'
                          CHECK (interview_type IN ('ONLINE','IN_PERSON','HYBRID')),
    deadline          DATE,
    openings          INT DEFAULT 1,
    status            VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
                          CHECK (status IN ('DRAFT','PENDING_APPROVAL','PUBLISHED','CLOSED','ARCHIVED')),
    approved_by       UUID REFERENCES users(id),
    approved_at       TIMESTAMPTZ,
    region_id         UUID REFERENCES regions(id),
    views_count       INT DEFAULT 0,
    applications_count INT DEFAULT 0,

    -- Full Text Search vector
    search_vector     TSVECTOR,

    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at        TIMESTAMPTZ
);

-- Indexes for job search performance
CREATE INDEX idx_job_clinic ON jobs(clinic_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_status ON jobs(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_city ON jobs(city) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_type ON jobs(employment_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_region ON jobs(region_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_deadline ON jobs(deadline) WHERE deleted_at IS NULL AND status = 'PUBLISHED';
CREATE INDEX idx_job_search ON jobs USING GIN(search_vector);

-- Auto-update search_vector on insert/update
CREATE OR REPLACE FUNCTION update_job_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.location, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.city, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.benefits, '')), 'D');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_search_vector
    BEFORE INSERT OR UPDATE OF title, description, location, city, benefits
    ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_job_search_vector();

-- Job required skills (many-to-many)
CREATE TABLE job_skills (
    job_id   UUID REFERENCES jobs(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (job_id, skill_id)
);

-- Saved/bookmarked jobs
CREATE TABLE saved_jobs (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dentist_id UUID NOT NULL REFERENCES dentist_profiles(id) ON DELETE CASCADE,
    job_id     UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    saved_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (dentist_id, job_id)
);
