package com.dentconnect.common.audit;

import java.lang.annotation.*;

/**
 * Marks an admin method for automatic audit logging via AOP.
 *
 * Usage:
 *   @AdminAction(action = "DENTIST_SUSPENDED", entityType = "DENTIST")
 *   public void suspendDentist(UUID dentistId, ...) { ... }
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AdminAction {
    String action();
    String entityType() default "";
}
