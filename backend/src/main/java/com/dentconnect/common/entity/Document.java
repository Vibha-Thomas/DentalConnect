package com.dentconnect.common.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

/**
 * A stored document for a dentist or clinic.
 *
 * Key design decisions:
 * - storage_path is stored, NOT a public URL. Signed URLs are generated on demand.
 * - sha256_hash ensures file integrity and deduplication.
 * - version_number + current_version + approved_version track the full document lifecycle.
 * - verification_status is INDEPENDENT of the profile verification_status.
 *   A document can be VERIFIED while the overall profile is still PENDING.
 */
@Entity
@Table(name = "documents")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "entity_type", nullable = false)
    private String entityType;          // DENTIST | CLINIC

    @Column(name = "entity_id", nullable = false)
    private UUID entityId;

    @Column(nullable = false)
    private String type;
    // RESUME | CERTIFICATE | LICENSE | PHOTO | VERIFICATION_DOC | GOVT_ID | DEGREE_CERT | ADDITIONAL

    private String name;                // user-visible filename

    /** Deprecated: use storage_path + FileService.getSignedUrl() */
    @Column(columnDefinition = "text")
    private String url;

    /** Firebase Storage path. Use FileService.getSignedUrl(storagePath) to get a download URL. */
    @Column(name = "storage_path", columnDefinition = "text")
    private String storagePath;

    @Column(name = "sha256_hash", length = 64)
    private String sha256Hash;

    @Column(name = "mime_type", length = 50)
    private String mimeType;

    @Column(name = "size_bytes")
    private Long sizeBytes;

    // ── Versioning ────────────────────────────────────────────────────────────

    /** Monotonically increasing version number for this document type + entity. */
    @Column(name = "version_number")
    @Builder.Default
    private int versionNumber = 1;

    /** True for the most recently uploaded version of this document type. */
    @Column(name = "current_version")
    @Builder.Default
    private boolean currentVersion = true;

    /**
     * True for the version that an admin has explicitly approved.
     * DIFFERENT from current_version: the dentist may re-upload a newer version
     * that is pending review while the old approved version is still referenced.
     */
    @Column(name = "approved_version")
    @Builder.Default
    private boolean approvedVersion = false;

    // ── Document-level Verification ──────────────────────────────────────────

    /** PENDING → UNDER_REVIEW → VERIFIED | REJECTED */
    @Column(name = "verification_status")
    @Builder.Default
    private String verificationStatus = "PENDING";

    @Column(name = "verified_by")
    private UUID verifiedBy;

    @Column(name = "verified_at")
    private Instant verifiedAt;

    @Column(name = "rejection_reason", columnDefinition = "text")
    private String rejectionReason;

    // ── Timestamps ────────────────────────────────────────────────────────────

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
    }

    public void softDelete() {
        this.deletedAt = Instant.now();
    }
}
