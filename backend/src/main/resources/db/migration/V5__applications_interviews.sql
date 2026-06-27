-- =====================================================
-- V5: Applications, application timeline, interviews
-- =====================================================

CREATE TABLE applications (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id       UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    dentist_id   UUID NOT NULL REFERENCES dentist_profiles(id) ON DELETE CASCADE,
    status       VARCHAR(30) NOT NULL DEFAULT 'APPLIED'
                     CHECK (status IN (
                         'APPLIED','VIEWED','SHORTLISTED',
                         'INTERVIEW_SCHEDULED','INTERVIEW_COMPLETED',
                         'OFFER_MADE','ACCEPTED','REJECTED','WITHDRAWN'
                     )),
    cover_letter TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at   TIMESTAMPTZ,
    UNIQUE (job_id, dentist_id)
);

CREATE INDEX idx_app_job ON applications(job_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_app_dentist ON applications(dentist_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_app_status ON applications(status) WHERE deleted_at IS NULL;

-- Application status change history (audit trail)
CREATE TABLE application_timeline (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id  UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    from_status     VARCHAR(30),
    to_status       VARCHAR(30) NOT NULL,
    changed_by      UUID REFERENCES users(id),
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_timeline_app ON application_timeline(application_id);

-- Interviews
CREATE TABLE interviews (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id  UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    scheduled_at    TIMESTAMPTZ NOT NULL,
    duration_mins   INT DEFAULT 30,
    type            VARCHAR(20) NOT NULL DEFAULT 'IN_PERSON'
                        CHECK (type IN ('ONLINE','IN_PERSON','HYBRID')),
    location        VARCHAR(255),
    meeting_link    TEXT,
    notes           TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED'
                        CHECK (status IN ('SCHEDULED','COMPLETED','CANCELLED','RESCHEDULED')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_interview_app ON interviews(application_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_interview_scheduled ON interviews(scheduled_at) WHERE deleted_at IS NULL AND status = 'SCHEDULED';

-- Trigger: increment applications_count on jobs when new application is created
CREATE OR REPLACE FUNCTION update_job_application_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE jobs SET applications_count = applications_count + 1 WHERE id = NEW.job_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_app_count
    AFTER INSERT ON applications
    FOR EACH ROW
    EXECUTE FUNCTION update_job_application_count();
