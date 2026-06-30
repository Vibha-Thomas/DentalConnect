package com.dentconnect.common.service;

import com.dentconnect.common.entity.ProfileActivityLog;
import com.dentconnect.common.repository.ProfileActivityLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

/**
 * Appends events to the profile activity timeline.
 * All writes are asynchronous — never block the main request thread.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityTimelineService {

    private final ProfileActivityLogRepository repository;

    /**
     * Record a user-initiated event (actor = the user themselves).
     */
    @Async
    public void record(UUID userId, String entityType, UUID entityId,
                       String eventType, String description) {
        record(userId, entityType, entityId, eventType, description, null, null);
    }

    /**
     * Record an admin-initiated event (actorId != userId).
     */
    @Async
    public void record(UUID userId, String entityType, UUID entityId,
                       String eventType, String description,
                       UUID actorId, String metadataJson) {
        try {
            ProfileActivityLog log = ProfileActivityLog.builder()
                    .userId(userId)
                    .entityType(entityType)
                    .entityId(entityId)
                    .eventType(eventType)
                    .description(description)
                    .actorId(actorId)
                    .metadata(metadataJson)
                    .build();
            repository.save(log);
        } catch (Exception ex) {
            // Timeline logging must never break the main flow
            log.warn("Failed to record activity timeline event: type={}, error={}", eventType, ex.getMessage());
        }
    }

    public List<ProfileActivityLog> getTimeline(String entityType, UUID entityId) {
        return repository.findByEntityTypeAndEntityIdOrderByCreatedAtDesc(entityType, entityId);
    }

    // ── Well-known event type constants ────────────────────────────────────────

    public static final String REGISTERED           = "REGISTERED";
    public static final String PHOTO_UPLOADED       = "PHOTO_UPLOADED";
    public static final String DOCUMENT_UPLOADED    = "DOCUMENT_UPLOADED";
    public static final String DOCUMENT_VERIFIED    = "DOCUMENT_VERIFIED";
    public static final String DOCUMENT_REJECTED    = "DOCUMENT_REJECTED";
    public static final String PROFILE_UPDATED      = "PROFILE_UPDATED";
    public static final String ADMIN_VIEWED         = "ADMIN_VIEWED";
    public static final String PROFILE_VERIFIED     = "PROFILE_VERIFIED";
    public static final String PROFILE_REJECTED     = "PROFILE_REJECTED";
    public static final String STATUS_CHANGED       = "STATUS_CHANGED";
    public static final String ONBOARDING_COMPLETED = "ONBOARDING_COMPLETED";
    public static final String ONBOARDING_STEP_SAVED = "ONBOARDING_STEP_SAVED";
}
