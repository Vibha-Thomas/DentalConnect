-- =====================================================
-- V7: Subscriptions, reports, audit logs, referral codes
-- =====================================================

-- Subscriptions
CREATE TABLE subscriptions (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan       VARCHAR(30) NOT NULL CHECK (plan IN ('FREE','BASIC','PREMIUM','ENTERPRISE')),
    status     VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                   CHECK (status IN ('ACTIVE','CANCELLED','EXPIRED','TRIAL')),
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date   TIMESTAMPTZ,
    amount     DECIMAL(10, 2),
    currency   VARCHAR(3) DEFAULT 'INR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_sub_user ON subscriptions(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sub_status ON subscriptions(status) WHERE deleted_at IS NULL;

-- Reports (flagging content/users)
CREATE TABLE reports (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id         UUID NOT NULL REFERENCES users(id),
    reported_entity_type VARCHAR(20) NOT NULL CHECK (reported_entity_type IN ('USER','JOB','CLINIC')),
    reported_entity_id  UUID NOT NULL,
    reason              VARCHAR(50) NOT NULL,
    description         TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                            CHECK (status IN ('PENDING','REVIEWED','RESOLVED','DISMISSED')),
    reviewed_by         UUID REFERENCES users(id),
    reviewed_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_report_status ON reports(status) WHERE deleted_at IS NULL;

-- Audit logs (immutable, no soft delete)
CREATE TABLE audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES users(id),
    action      VARCHAR(50) NOT NULL,
    entity_type VARCHAR(30),
    entity_id   UUID,
    details     JSONB,
    ip_address  VARCHAR(45),
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- Referral codes
CREATE TABLE referral_codes (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code       VARCHAR(20) NOT NULL UNIQUE,
    uses_count INT NOT NULL DEFAULT 0,
    max_uses   INT DEFAULT 50,
    active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_referral_code ON referral_codes(code) WHERE active = TRUE;

-- Refresh tokens
CREATE TABLE refresh_tokens (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token      VARCHAR(500) NOT NULL UNIQUE,
    device_info TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_user ON refresh_tokens(user_id) WHERE revoked = FALSE;
CREATE INDEX idx_refresh_token ON refresh_tokens(token) WHERE revoked = FALSE;
