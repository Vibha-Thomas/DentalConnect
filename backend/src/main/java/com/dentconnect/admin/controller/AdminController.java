package com.dentconnect.admin.controller;

import com.dentconnect.admin.service.AdminService;
import com.dentconnect.admin.service.DashboardStatisticsService;
import com.dentconnect.common.dto.ApiResponse;
import com.dentconnect.common.dto.PagedResponse;
import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.clinic.entity.Clinic;
import com.dentconnect.job.entity.Job;
import com.dentconnect.application.entity.Application;
import com.dentconnect.common.audit.AuditLog;
import com.dentconnect.common.service.SearchService;
import com.dentconnect.common.service.VerificationService;
import com.dentconnect.common.audit.AdminAction;
import com.dentconnect.user.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasAnyAuthority('SUPER_ADMIN', 'REGIONAL_ADMIN')")
@Tag(name = "Admin Operations", description = "Enterprise admin endpoints for verification, moderation, search, statistics, and audit logs")
public class AdminController {

    private final AdminService adminService;
    private final DashboardStatisticsService statsService;
    private final SearchService searchService;
    private final VerificationService verificationService;

    private User currentAdmin() {
        return (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    // ── Dashboard stats (cached) ─────────────────────────────────────────────

    @GetMapping("/stats/kpis")
    @Operation(summary = "Get cached SaaS dashboard KPI metrics")
    public ResponseEntity<ApiResponse<DashboardStatisticsService.DashboardKpis>> getKpis() {
        return ResponseEntity.ok(ApiResponse.success(statsService.getKpis()));
    }

    @GetMapping("/analytics/registrations")
    @Operation(summary = "Get dentist registration numbers month-over-month")
    public ResponseEntity<ApiResponse<List<DashboardStatisticsService.MonthlyDataPoint>>> getMonthlyRegistrations(
            @RequestParam(value = "months", defaultValue = "6") int months) {
        return ResponseEntity.ok(ApiResponse.success(statsService.getMonthlyDentistRegistrations(months)));
    }

    @GetMapping("/analytics/top-cities")
    @Operation(summary = "Get top cities by dentist count")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getTopCities() {
        return ResponseEntity.ok(ApiResponse.success(statsService.getTopCitiesByDentistCount(5)));
    }

    // ── Dentist Management ───────────────────────────────────────────────────

    @GetMapping("/dentists")
    @Operation(summary = "Get paginated, filterable dentists list")
    public ResponseEntity<ApiResponse<PagedResponse<DentistProfile>>> getDentists(
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "completionMin", required = false) Integer completionMin,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(
                PagedResponse.from(adminService.getDentists(search, status, completionMin, pageable))));
    }

    @PutMapping("/dentists/{id}/status")
    @AdminAction(action = "DENTIST_STATUS_CHANGED", entityType = "DENTIST")
    @Operation(summary = "Suspend, activate, or deactivate a dentist profile")
    public ResponseEntity<ApiResponse<Void>> updateDentistStatus(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status");
        adminService.updateDentistStatus(id, status, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/dentists/bulk-action")
    @AdminAction(action = "DENTIST_BULK_ACTION", entityType = "DENTIST")
    @Operation(summary = "Perform bulk action (suspend, activate, delete) on multiple dentists")
    public ResponseEntity<ApiResponse<Void>> bulkActionDentists(
            @RequestBody Map<String, Object> body) {
        List<String> idsStr = (List<String>) body.get("ids");
        List<UUID> ids = idsStr.stream().map(UUID::fromString).toList();
        String action = (String) body.get("action");
        adminService.bulkActionDentists(ids, action, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Verification Engine (Dentist, Clinic, Documents) ────────────────────

    @PutMapping("/dentists/{id}/verify")
    @AdminAction(action = "DENTIST_VERIFIED", entityType = "DENTIST")
    @Operation(summary = "Approve or reject a dentist profile verification request")
    public ResponseEntity<ApiResponse<Void>> verifyDentist(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status"); // VERIFIED | REJECTED | UNDER_REVIEW
        String notes = body.get("notes");
        verificationService.verifyDentist(id, status, notes, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PutMapping("/clinics/{id}/verify")
    @AdminAction(action = "CLINIC_VERIFIED", entityType = "CLINIC")
    @Operation(summary = "Approve or reject a clinic profile verification request")
    public ResponseEntity<ApiResponse<Void>> verifyClinic(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status"); // APPROVED | REJECTED
        verificationService.verifyClinic(id, status, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PutMapping("/documents/{id}/verify")
    @AdminAction(action = "DOCUMENT_VERIFIED", entityType = "DOCUMENT")
    @Operation(summary = "Verify or reject an individual profile document")
    public ResponseEntity<ApiResponse<Void>> verifyDocument(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status"); // VERIFIED | REJECTED
        String reason = body.get("reason");
        verificationService.verifyDocument(id, status, reason, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Clinic Management ────────────────────────────────────────────────────

    @GetMapping("/clinics")
    @Operation(summary = "Get paginated, filterable clinics list")
    public ResponseEntity<ApiResponse<PagedResponse<Clinic>>> getClinics(
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "verified", required = false) String verified,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(
                PagedResponse.from(adminService.getClinics(search, verified, pageable))));
    }

    // ── Job Management ───────────────────────────────────────────────────────

    @GetMapping("/jobs")
    @Operation(summary = "Get paginated list of jobs for moderation")
    public ResponseEntity<ApiResponse<PagedResponse<Job>>> getJobs(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(
                PagedResponse.from(adminService.getJobs(status, pageable))));
    }

    @PutMapping("/jobs/{id}/verify")
    @AdminAction(action = "JOB_VERIFIED", entityType = "JOB")
    @Operation(summary = "Moderate job posting (approve to PUBLISHED, reject, or archive)")
    public ResponseEntity<ApiResponse<Void>> verifyJob(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status"); // PUBLISHED | REJECTED | ARCHIVED
        adminService.verifyJob(id, status, currentAdmin().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Application Management ────────────────────────────────────────────────

    @GetMapping("/applications")
    @Operation(summary = "Get paginated list of applications")
    public ResponseEntity<ApiResponse<PagedResponse<Application>>> getApplications(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(
                PagedResponse.from(adminService.getApplications(status, pageable))));
    }

    @GetMapping("/applications/export")
    @Operation(summary = "Export all applications as a CSV file")
    public ResponseEntity<byte[]> exportApplications() {
        byte[] csvData = adminService.exportApplicationsCsv();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=applications.csv")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(csvData);
    }

    // ── Global Search (Ctrl + K) ─────────────────────────────────────────────

    @GetMapping("/search")
    @Operation(summary = "Unified multi-entity global search for dentist, clinic, job, or application (Ctrl+K)")
    public ResponseEntity<ApiResponse<List<SearchService.SearchResult>>> globalSearch(
            @RequestParam("q") String query,
            @RequestParam(value = "limit", defaultValue = "10") int limit) {
        return ResponseEntity.ok(ApiResponse.success(searchService.search(query, limit)));
    }

    // ── Audit Logs ───────────────────────────────────────────────────────────

    @GetMapping("/audit-logs")
    @Operation(summary = "Get filterable system audit logs")
    public ResponseEntity<ApiResponse<PagedResponse<AuditLog>>> getAuditLogs(
            @RequestParam(value = "action", required = false) String action,
            @RequestParam(value = "adminId", required = false) UUID adminId,
            @RequestParam(value = "entityType", required = false) String entityType,
            @RequestParam(value = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant from,
            @RequestParam(value = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant to,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(
                PagedResponse.from(adminService.getAuditLogs(action, adminId, entityType, from, to, pageable))));
    }
}
