package com.dentconnect.dentist.service;

import com.dentconnect.common.entity.Document;
import com.dentconnect.common.exception.ResourceNotFoundException;
import com.dentconnect.common.exception.UnauthorizedException;
import com.dentconnect.common.repository.DocumentRepository;
import com.dentconnect.common.service.ActivityTimelineService;
import com.dentconnect.common.service.FileService;
import com.dentconnect.dentist.repository.DentistProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class DocumentService {

    private final DocumentRepository documentRepo;
    private final DentistProfileRepository profileRepo;
    private final FileService fileService;
    private final ProfileCompletionService completionService;
    private final ActivityTimelineService activityTimeline;

    /**
     * Upload a document for a dentist.
     * - Marks all previous versions of this type as non-current
     * - Uploads to Firebase Storage via FileService (stores path, not URL)
     * - Stores metadata in documents table
     * - Recalculates completion score if this is a scored document type
     *
     * @param userId   the authenticated user's UUID
     * @param file     the uploaded file
     * @param docType  RESUME | LICENSE | DEGREE_CERT | GOVT_ID | ADDITIONAL | etc.
     * @param name     user-visible filename
     * @return the saved Document entity
     */
    public Document uploadDocument(UUID userId, MultipartFile file, String docType, String name) {
        var profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found — complete basic info first"));

        // Determine the next version number
        int nextVersion = documentRepo.findMaxVersionNumber("DENTIST", profile.getId(), docType) + 1;

        // Mark all previous versions as non-current
        documentRepo.markAllVersionsAsNotCurrent("DENTIST", profile.getId(), docType);

        // Build storage path and upload
        String storagePath = fileService.buildDentistDocPath(userId.toString(), docType, file.getOriginalFilename(), nextVersion);
        FileService.StoredFile stored = fileService.upload(file, storagePath);

        // Persist metadata (no public URL)
        Document document = Document.builder()
                .userId(userId)
                .entityType("DENTIST")
                .entityId(profile.getId())
                .type(docType)
                .name(name != null ? name : file.getOriginalFilename())
                .storagePath(stored.storagePath())
                .sha256Hash(stored.sha256Hash())
                .mimeType(stored.contentType())
                .sizeBytes(stored.sizeBytes())
                .versionNumber(nextVersion)
                .currentVersion(true)
                .approvedVersion(false)
                .verificationStatus("PENDING")
                .build();
        document = documentRepo.save(document);

        // Recalculate completion score (documents section contributes 20%)
        completionService.recalculateAndCache(profile);
        profileRepo.save(profile);

        // Log to activity timeline
        activityTimeline.record(userId, "DENTIST", profile.getId(),
                ActivityTimelineService.DOCUMENT_UPLOADED,
                String.format("Uploaded %s (v%d)", docType, nextVersion));

        return document;
    }

    /**
     * Upload a profile photo.
     * Photo is stored in Firebase and the URL (storage path) is saved to the profile.
     * Returns the storage path (not a signed URL).
     */
    public String uploadPhoto(UUID userId, MultipartFile file) {
        var profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));

        String storagePath = fileService.buildPhotoPath(userId.toString());
        fileService.upload(file, storagePath);

        // Store storage path as photo "URL" (caller can get signed URL via /profile/photo/url)
        profile.setPhotoUrl(storagePath);
        completionService.recalculateAndCache(profile);
        profileRepo.save(profile);

        activityTimeline.record(userId, "DENTIST", profile.getId(),
                ActivityTimelineService.PHOTO_UPLOADED, "Profile photo uploaded");

        return storagePath;
    }

    /**
     * Get all current documents for the authenticated dentist.
     */
    @Transactional(readOnly = true)
    public List<Document> getMyDocuments(UUID userId) {
        var profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return documentRepo.findByEntityTypeAndEntityIdAndCurrentVersionTrueAndDeletedAtIsNull(
                "DENTIST", profile.getId());
    }

    /**
     * Get all versions of a specific document type for the authenticated dentist.
     */
    @Transactional(readOnly = true)
    public List<Document> getDocumentVersions(UUID userId, String docType) {
        var profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return documentRepo.findByEntityTypeAndEntityIdAndTypeAndDeletedAtIsNullOrderByVersionNumberDesc(
                "DENTIST", profile.getId(), docType);
    }

    /**
     * Generate a signed, time-limited download URL for a document.
     * Documents are private — no public URLs are stored.
     */
    @Transactional(readOnly = true)
    public String getSignedDownloadUrl(UUID userId, UUID documentId) {
        Document doc = documentRepo.findById(documentId)
                .filter(d -> d.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));
        if (!doc.getUserId().equals(userId)) {
            throw new UnauthorizedException("Access denied");
        }
        return fileService.getSignedUrl(doc.getStoragePath());
    }

    /**
     * Generate a signed URL for the profile photo.
     */
    @Transactional(readOnly = true)
    public String getSignedPhotoUrl(UUID userId) {
        var profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        if (profile.getPhotoUrl() == null || profile.getPhotoUrl().isBlank()) {
            throw new ResourceNotFoundException("No photo uploaded yet");
        }
        return fileService.getSignedUrl(profile.getPhotoUrl());
    }

    /**
     * Soft-delete a document. Does not remove from Firebase Storage.
     */
    public void deleteDocument(UUID userId, UUID documentId) {
        Document doc = documentRepo.findById(documentId)
                .filter(d -> d.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));
        if (!doc.getUserId().equals(userId)) {
            throw new UnauthorizedException("Access denied");
        }
        doc.softDelete();
        documentRepo.save(doc);
        log.info("Soft-deleted document: userId={}, docId={}", userId, documentId);
    }
}
