-- =====================================================
-- V1: Core user tables, roles, and permissions (RBAC)
-- =====================================================

-- Roles lookup table
CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO roles (name, description) VALUES
    ('DENTIST',           'Junior or senior dentist seeking jobs'),
    ('CLINIC_OWNER',      'Clinic owner with full clinic management'),
    ('CLINIC_HR',         'Clinic HR staff'),
    ('CLINIC_RECRUITER',  'Clinic recruiter'),
    ('CLINIC_RECEPTION',  'Clinic reception staff'),
    ('REGIONAL_ADMIN',    'Regional administrator'),
    ('SUPER_ADMIN',       'Platform super administrator');

-- Permissions lookup table
CREATE TABLE permissions (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO permissions (name) VALUES
    ('JOB_CREATE'), ('JOB_EDIT'), ('JOB_DELETE'), ('JOB_APPROVE'),
    ('APPLICATION_VIEW'), ('APPLICATION_MANAGE'),
    ('CLINIC_MANAGE'), ('CLINIC_VERIFY'),
    ('USER_MANAGE'), ('USER_SUSPEND'),
    ('ADMIN_MANAGE'), ('REGION_MANAGE'),
    ('ANALYTICS_VIEW'), ('REPORT_EXPORT'),
    ('PLATFORM_SETTINGS');

-- Role-permission mapping
CREATE TABLE role_permissions (
    role_id       INT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Grant permissions to roles
-- CLINIC_OWNER gets job + application + clinic management
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'CLINIC_OWNER'
  AND p.name IN ('JOB_CREATE','JOB_EDIT','JOB_DELETE','APPLICATION_VIEW','APPLICATION_MANAGE','CLINIC_MANAGE');

-- CLINIC_HR gets job + application management
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'CLINIC_HR'
  AND p.name IN ('JOB_CREATE','JOB_EDIT','APPLICATION_VIEW','APPLICATION_MANAGE');

-- CLINIC_RECRUITER gets application viewing
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'CLINIC_RECRUITER'
  AND p.name IN ('APPLICATION_VIEW','APPLICATION_MANAGE');

-- REGIONAL_ADMIN gets approval + verification + analytics
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'REGIONAL_ADMIN'
  AND p.name IN ('JOB_APPROVE','CLINIC_VERIFY','ANALYTICS_VIEW','REPORT_EXPORT','USER_MANAGE');

-- SUPER_ADMIN gets everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'SUPER_ADMIN';

-- Users table
CREATE TABLE users (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(128) UNIQUE,
    email        VARCHAR(255) UNIQUE,
    phone        VARCHAR(20) UNIQUE,
    display_name VARCHAR(100),
    avatar_url   TEXT,
    role_id      INT NOT NULL REFERENCES roles(id),
    status       VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                     CHECK (status IN ('ACTIVE','SUSPENDED','DEACTIVATED')),
    last_login   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at   TIMESTAMPTZ
);

CREATE INDEX idx_users_firebase_uid ON users(firebase_uid) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_role ON users(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;

-- Regions
CREATE TABLE regions (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(100) NOT NULL UNIQUE,
    admin_id   UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

INSERT INTO regions (name) VALUES
    ('Bangalore'), ('Chennai'), ('Hyderabad'), ('Mumbai'), ('Delhi');
