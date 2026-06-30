package com.dentconnect.common.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Append-only activity timeline for dentist and clinic profiles.
 * Records every significant event: registrations, document uploads/verifications,
 * admin actions, status changes, and onboarding milestones.
 *
 * This table is NEVER soft-deleted — it is an immutable audit trail.
 */
@Entity
@Table(name = "profile_activity_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileActivityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "entity_type", nullable = false)
    private String entityType;   // DENTIST | CLINIC | DOCUMENT

    @Column(name = "entity_id", nullable = false)
    private UUID entityId;

    @Column(name = "event_type", nullable = false)
    private String eventType;    // REGISTERED | PHOTO_UPLOADED | DOCUMENT_UPLOADED | etc.

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "actor_id")
    private UUID actorId;        // NULL = the user themselves; non-null = admin who acted

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String metadata;     // JSON string with extra context (e.g. document type, version)

    @Column(name = "created_at", updatable = false, nullable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
    }
}
