-- =====================================================
-- V6: Documents, verification requests, notifications,
--     device tokens, notification preferences
-- =====================================================

-- Documents (resumes, certificates, licenses)
CREATE TABLE documents (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('DENTIST','CLINIC')),
    entity_id   UUID NOT NULL,
    type        VARCHAR(30) NOT NULL
                    CHECK (type IN ('RESUME','CERTIFICATE','LICENSE','PHOTO','VERIFICATION_DOC')),
    name        VARCHAR(255),
    url         TEXT NOT NULL,
    mime_type   VARCHAR(50),
    size_bytes  BIGINT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_doc_user ON documents(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_doc_entity ON documents(entity_type, entity_id) WHERE deleted_at IS NULL;

-- Verification requests
CREATE TABLE verification_requests (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('DENTIST','CLINIC')),
    entity_id   UUID NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    reviewer_id UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_verify_status ON verification_requests(status);
CREATE INDEX idx_verify_entity ON verification_requests(entity_type, entity_id);

-- Notifications
CREATE TABLE notifications (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       VARCHAR(50) NOT NULL,
    title      VARCHAR(255) NOT NULL,
    body       TEXT,
    data       JSONB,
    read       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_notif_user ON notifications(user_id, read) WHERE deleted_at IS NULL;
CREATE INDEX idx_notif_created ON notifications(created_at DESC) WHERE deleted_at IS NULL;

-- Device tokens for push notifications
CREATE TABLE device_tokens (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token      TEXT NOT NULL,
    platform   VARCHAR(10) NOT NULL CHECK (platform IN ('ANDROID','IOS','WEB')),
    active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_device_user ON device_tokens(user_id) WHERE active = TRUE;
CREATE UNIQUE INDEX idx_device_token ON device_tokens(token);

-- Notification preferences
CREATE TABLE notification_preferences (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       VARCHAR(50) NOT NULL,
    enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (user_id, type)
);
