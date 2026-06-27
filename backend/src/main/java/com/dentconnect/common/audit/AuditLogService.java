package com.dentconnect.common.audit;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

/**
 * Service for recording audit trail entries asynchronously.
 */
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository repository;

    @Async
    public void log(UUID userId, String action, String entityType, UUID entityId,
                    Map<String, Object> details, HttpServletRequest request) {
        AuditLog entry = AuditLog.builder()
                .userId(userId)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .details(details)
                .ipAddress(getClientIp(request))
                .userAgent(request != null ? request.getHeader("User-Agent") : null)
                .build();
        repository.save(entry);
    }

    @Async
    public void log(UUID userId, String action, String entityType, UUID entityId) {
        log(userId, action, entityType, entityId, null, null);
    }

    private String getClientIp(HttpServletRequest request) {
        if (request == null) return null;
        String xff = request.getHeader("X-Forwarded-For");
        return xff != null ? xff.split(",")[0].trim() : request.getRemoteAddr();
    }
}
