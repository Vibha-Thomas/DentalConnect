package com.dentconnect.common.service;

import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.dentist.repository.DentistProfileRepository;
import com.dentconnect.clinic.entity.Clinic;
import com.dentconnect.clinic.repository.ClinicRepository;
import com.dentconnect.common.entity.Document;
import com.dentconnect.common.repository.DocumentRepository;
import com.dentconnect.common.exception.ResourceNotFoundException;
import com.dentconnect.common.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

/**
 * Centralized Verification Engine.
 * Handles state transitions for profile and document verifications.
 * Writes immutable activity timeline events and triggers notifications.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class VerificationService {

    private final DentistProfileRepository dentistProfileRepo;
    private final ClinicRepository clinicRepo;
    private final DocumentRepository documentRepo;
    private final ActivityTimelineService activityTimeline;

    /**
     * Verify or reject a Dentist Profile.
     * Transitions status to VERIFIED, REJECTED, UNDER_REVIEW, or SUSPENDED.
     */
    public void verifyDentist(UUID dentistId, String status, String notes, UUID adminId) {
        DentistProfile profile = dentistProfileRepo.findById(dentistId)
                .filter(p -> p.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Dentist profile not found"));

        String oldStatus = profile.getVerificationStatus();
        validateDentistTransition(oldStatus, status);

        profile.setVerificationStatus(status);
        profile.setVerificationNotes(notes);
        profile.setVerifiedBy(adminId);
        profile.setVerifiedAt(Instant.now());

        if ("VERIFIED".equals(status)) {
            profile.setRegVerified(true);
        } else if ("REJECTED".equals(status) || "SUSPENDED".equals(status)) {
            profile.setRegVerified(false);
        }

        dentistProfileRepo.save(profile);

        String eventType = "VERIFIED".equals(status) ? ActivityTimelineService.PROFILE_VERIFIED :
                           "REJECTED".equals(status) ? ActivityTimelineService.PROFILE_REJECTED :
                           ActivityTimelineService.STATUS_CHANGED;

        activityTimeline.record(profile.getUserId(), "DENTIST", profile.getId(),
                eventType,
                String.format("Dentist profile status transitioned from %s to %s. Notes: %s",
                        oldStatus, status, notes != null ? notes : "None"),
                adminId,
                String.format("{\"oldStatus\":\"%s\",\"newStatus\":\"%s\"}", oldStatus, status));

        log.info("Dentist profile {} status updated from {} to {} by admin {}", dentistId, oldStatus, status, adminId);
    }

    /**
     * Verify or reject a Clinic.
     * Transitions status to APPROVED, REJECTED, etc.
     */
    public void verifyClinic(UUID clinicId, String status, UUID adminId) {
        Clinic clinic = clinicRepo.findById(clinicId)
                .filter(c -> c.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Clinic not found"));

        String oldStatus = clinic.getVerificationStatus();
        clinic.setVerificationStatus(status);
        clinic.setVerifiedBy(adminId);
        clinic.setVerifiedAt(Instant.now());

        clinicRepo.save(clinic);

        activityTimeline.record(clinic.getOwnerId(), "CLINIC", clinic.getId(),
                "VERIFIED".equals(status) ? "CLINIC_VERIFIED" : "CLINIC_REJECTED",
                String.format("Clinic status transitioned from %s to %s", oldStatus, status),
                adminId,
                String.format("{\"oldStatus\":\"%s\",\"newStatus\":\"%s\"}", oldStatus, status));

        log.info("Clinic {} status updated from {} to {} by admin {}", clinicId, oldStatus, status, adminId);
    }

    /**
     * Verify or reject an individual profile document.
     * Document verification is independent of the overall profile status.
     */
    public void verifyDocument(UUID documentId, String status, String reason, UUID adminId) {
        Document doc = documentRepo.findById(documentId)
                .filter(d -> d.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        String oldStatus = doc.getVerificationStatus();
        doc.setVerificationStatus(status);
        doc.setVerifiedBy(adminId);
        doc.setVerifiedAt(Instant.now());

        if ("REJECTED".equals(status)) {
            doc.setRejectionReason(reason);
            doc.setApprovedVersion(false);
        } else if ("VERIFIED".equals(status)) {
            doc.setApprovedVersion(true);
            doc.setRejectionReason(null);
        }

        documentRepo.save(doc);

        String eventType = "VERIFIED".equals(status) ? ActivityTimelineService.DOCUMENT_VERIFIED :
                           ActivityTimelineService.DOCUMENT_REJECTED;

        activityTimeline.record(doc.getUserId(), doc.getEntityType(), doc.getEntityId(),
                eventType,
                String.format("Document %s (%s) transitioned from %s to %s. Reason: %s",
                        doc.getName(), doc.getType(), oldStatus, status, reason != null ? reason : "None"),
                adminId,
                String.format("{\"documentId\":\"%s\",\"type\":\"%s\",\"status\":\"%s\"}",
                        doc.getId(), doc.getType(), status));

        log.info("Document {} verification status updated from {} to {} by admin {}", documentId, oldStatus, status, adminId);
    }

    private void validateDentistTransition(String from, String to) {
        if (from.equals(to)) {
            return;
        }
        if ("SUSPENDED".equals(from) && !"ACTIVE".equals(to) && !"UNDER_REVIEW".equals(to) && !"VERIFIED".equals(to)) {
            throw new BadRequestException("Suspended dentist can only transition to active, under review, or verified state");
        }
    }
}
