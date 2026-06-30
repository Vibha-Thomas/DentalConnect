package com.dentconnect.common.audit;

import com.dentconnect.user.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.UUID;

/**
 * AOP aspect that intercepts all methods annotated with @AdminAction
 * and writes an immutable record to audit_logs.
 *
 * Fires asynchronously — never blocks the admin request.
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class AuditLogAspect {

    private final AuditLogRepository auditLogRepository;

    @AfterReturning(
        pointcut = "@annotation(adminAction)",
        argNames = "joinPoint,adminAction"
    )
    @Async
    public void logAdminAction(JoinPoint joinPoint, AdminAction adminAction) {
        try {
            UUID actorId = extractActorId();
            String ipAddress = extractIpAddress();

            // Extract first UUID argument as entityId, if present
            UUID entityId = null;
            for (Object arg : joinPoint.getArgs()) {
                if (arg instanceof UUID uuid) {
                    entityId = uuid;
                    break;
                }
            }

            AuditLog auditLog = AuditLog.builder()
                    .userId(actorId)
                    .action(adminAction.action())
                    .entityType(adminAction.entityType().isBlank() ? null : adminAction.entityType())
                    .entityId(entityId)
                    .ipAddress(ipAddress)
                    .build();

            auditLogRepository.save(auditLog);
        } catch (Exception ex) {
            log.warn("Audit log write failed for action={}: {}", adminAction.action(), ex.getMessage());
        }
    }

    private UUID extractActorId() {
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (principal instanceof User user) {
                return user.getId();
            }
        } catch (Exception ignored) {}
        return null;
    }

    private String extractIpAddress() {
        try {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest request = attrs.getRequest();
                String forwardedFor = request.getHeader("X-Forwarded-For");
                if (forwardedFor != null && !forwardedFor.isBlank()) {
                    return forwardedFor.split(",")[0].trim();
                }
                return request.getRemoteAddr();
            }
        } catch (Exception ignored) {}
        return null;
    }
}
