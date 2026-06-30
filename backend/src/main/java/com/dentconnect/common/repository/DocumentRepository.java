package com.dentconnect.common.repository;

import com.dentconnect.common.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DocumentRepository extends JpaRepository<Document, UUID> {

    // All current documents for a dentist (current_version = true, not deleted)
    List<Document> findByEntityTypeAndEntityIdAndCurrentVersionTrueAndDeletedAtIsNull(
            String entityType, UUID entityId);

    // All versions of a specific document type for a dentist
    List<Document> findByEntityTypeAndEntityIdAndTypeAndDeletedAtIsNullOrderByVersionNumberDesc(
            String entityType, UUID entityId, String type);

    // Count current documents for a dentist (used for completion score)
    long countByEntityTypeAndEntityIdAndCurrentVersionTrueAndDeletedAtIsNull(
            String entityType, UUID entityId);

    // Find the highest version number for a document type + entity
    @Query("""
        SELECT COALESCE(MAX(d.versionNumber), 0)
        FROM Document d
        WHERE d.entityType = :entityType
          AND d.entityId = :entityId
          AND d.type = :type
          AND d.deletedAt IS NULL
    """)
    int findMaxVersionNumber(@Param("entityType") String entityType,
                             @Param("entityId") UUID entityId,
                             @Param("type") String type);

    // Mark all previous versions of a type as non-current before inserting a new one
    @Modifying
    @Query("""
        UPDATE Document d
        SET d.currentVersion = false
        WHERE d.entityType = :entityType
          AND d.entityId = :entityId
          AND d.type = :type
          AND d.deletedAt IS NULL
    """)
    void markAllVersionsAsNotCurrent(@Param("entityType") String entityType,
                                     @Param("entityId") UUID entityId,
                                     @Param("type") String type);

    // Find approved version for reference
    Optional<Document> findByEntityTypeAndEntityIdAndTypeAndApprovedVersionTrueAndDeletedAtIsNull(
            String entityType, UUID entityId, String type);

    // Check if a specific document type has been uploaded
    boolean existsByEntityTypeAndEntityIdAndTypeAndCurrentVersionTrueAndDeletedAtIsNull(
            String entityType, UUID entityId, String type);

    // For admin: find all documents needing verification
    List<Document> findByVerificationStatusAndDeletedAtIsNull(String verificationStatus);
}
