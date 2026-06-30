-- =====================================================
-- V9: Document extended verification, profile activity
--     timeline, enriched notifications
-- =====================================================

-- Extend documents table with storage path (not public URL),
-- SHA-256 hash for integrity, versioning, per-doc verification
ALTER TABLE documents ADD COLUMN IF NOT EXISTS storage_path        TEXT;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS sha256_hash         VARCHAR(64);
ALTER TABLE documents ADD COLUMN IF NOT EXISTS version_number      INT     DEFAULT 1;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS current_version     BOOLEAN DEFAULT TRUE;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS approved_version    BOOLEAN DEFAULT FALSE;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS verification_status VARCHAR(20) DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING','UNDER_REVIEW','VERIFIED','REJECTED'));
ALTER TABLE documents ADD COLUMN IF NOT EXISTS verified_by         UUID REFERENCES users(id);
ALTER TABLE documents ADD COLUMN IF NOT EXISTS verified_at         TIMESTAMPTZ;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS rejection_reason    TEXT;

-- Extend type check to include new document types
ALTER TABLE documents DROP CONSTRAINT IF EXISTS documents_type_check;
ALTER TABLE documents ADD CONSTRAINT documents_type_check
    CHECK (type IN ('RESUME','CERTIFICATE','LICENSE','PHOTO','VERIFICATION_DOC','GOVT_ID','DEGREE_CERT','ADDITIONAL'));

-- Version history index (find all versions of a document for a dentist)
CREATE INDEX IF NOT EXISTS idx_doc_entity_type_version
    ON documents(entity_type, entity_id, type, version_number)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_doc_verification_status
    ON documents(verification_status)
    WHERE deleted_at IS NULL;

-- ── Profile Activity Timeline ──────────────────────────────────────────────
-- Append-only event log. Every significant action on a dentist/clinic profile
-- is recorded here for the admin activity feed and profile view.
CREATE TABLE profile_activity_log (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('DENTIST','CLINIC','DOCUMENT')),
    entity_id   UUID NOT NULL,
    event_type  VARCHAR(60) NOT NULL,
    -- Event types: REGISTERED, PHOTO_UPLOADED, DOCUMENT_UPLOADED, DOCUMENT_VERIFIED,
    --              DOCUMENT_REJECTED, PROFILE_UPDATED, ADMIN_VIEWED, PROFILE_VERIFIED,
    --              PROFILE_REJECTED, STATUS_CHANGED, ONBOARDING_COMPLETED, etc.
    description TEXT,
    actor_id    UUID REFERENCES users(id),  -- NULL means the user themselves
    metadata    JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pal_user       ON profile_activity_log(user_id, created_at DESC);
CREATE INDEX idx_pal_entity     ON profile_activity_log(entity_type, entity_id, created_at DESC);
CREATE INDEX idx_pal_event_type ON profile_activity_log(event_type);

-- ── Notification enrichment ────────────────────────────────────────────────
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read_at          TIMESTAMPTZ;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS clicked_at       TIMESTAMPTZ;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS delivery_status  VARCHAR(20) DEFAULT 'DELIVERED'
    CHECK (delivery_status IN ('PENDING','DELIVERED','FAILED','EXPIRED'));
