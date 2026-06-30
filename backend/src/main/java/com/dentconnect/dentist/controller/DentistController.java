package com.dentconnect.dentist.controller;

import com.dentconnect.common.dto.ApiResponse;
import com.dentconnect.common.entity.Document;
import com.dentconnect.dentist.dto.*;
import com.dentconnect.dentist.service.DentistService;
import com.dentconnect.dentist.service.DocumentService;
import com.dentconnect.dentist.service.ProfileCompletionService;
import com.dentconnect.user.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/dentists")
@RequiredArgsConstructor
@Tag(name = "Dentist Profile", description = "Dentist profile management and document uploads")
public class DentistController {

    private final DentistService dentistService;
    private final DocumentService documentService;
    private final ProfileCompletionService completionService;

    private User currentUser() {
        return (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    // ── Profile existence check (for splash screen routing) ──────────────────

    @GetMapping("/me/exists")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Check if profile exists (used by splash screen to route to onboarding)")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> profileExists() {
        boolean exists = dentistService.profileExists(currentUser().getId());
        return ResponseEntity.ok(ApiResponse.success(Map.of("exists", exists)));
    }

    // ── Profile CRUD ─────────────────────────────────────────────────────────

    @GetMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Get my full profile")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> getMyProfile() {
        return ResponseEntity.ok(ApiResponse.success(
                dentistService.getMyProfile(currentUser().getId())));
    }

    @PostMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Create profile (first-time onboarding)")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> createProfile(
            @Valid @RequestBody DentistProfileRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        dentistService.createProfile(currentUser().getId(), req)));
    }

    @PutMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Update profile (partial update — only non-null fields are applied)")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> updateProfile(
            @Valid @RequestBody DentistProfileRequest req) {
        return ResponseEntity.ok(ApiResponse.success(
                dentistService.updateProfile(currentUser().getId(), req)));
    }

    @DeleteMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Delete (soft) my profile")
    public ResponseEntity<ApiResponse<Void>> deleteProfile() {
        dentistService.deleteProfile(currentUser().getId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Onboarding wizard autosave ────────────────────────────────────────────

    @PutMapping("/me/onboarding-step")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Save wizard progress (step 0–6)")
    public ResponseEntity<ApiResponse<Void>> updateOnboardingStep(@RequestBody Map<String, Integer> body) {
        int step = body.getOrDefault("step", 0);
        dentistService.updateOnboardingStep(currentUser().getId(), step);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Profile completion ────────────────────────────────────────────────────

    @GetMapping("/me/completion")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Get detailed profile completion breakdown")
    public ResponseEntity<ApiResponse<ProfileCompletionService.CompletionBreakdown>> getCompletion() {
        return ResponseEntity.ok(ApiResponse.success(
                dentistService.getCompletion(currentUser().getId())));
    }

    // ── Photo upload ─────────────────────────────────────────────────────────

    @PostMapping(value = "/me/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Upload profile photo to Firebase Storage")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadPhoto(
            @RequestParam("file") MultipartFile file) {
        String storagePath = documentService.uploadPhoto(currentUser().getId(), file);
        return ResponseEntity.ok(ApiResponse.success(Map.of("storagePath", storagePath)));
    }

    @GetMapping("/me/photo/url")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Get a signed download URL for the profile photo")
    public ResponseEntity<ApiResponse<Map<String, String>>> getPhotoUrl() {
        String signedUrl = documentService.getSignedPhotoUrl(currentUser().getId());
        return ResponseEntity.ok(ApiResponse.success(Map.of("url", signedUrl)));
    }

    // ── Document management ───────────────────────────────────────────────────

    @PostMapping(value = "/me/documents", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Upload a document (RESUME, LICENSE, DEGREE_CERT, GOVT_ID, ADDITIONAL)")
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("type") String docType,
            @RequestParam(value = "name", required = false) String name) {
        Document doc = documentService.uploadDocument(currentUser().getId(), file, docType, name);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(Map.of(
                        "id", doc.getId(),
                        "type", doc.getType(),
                        "versionNumber", doc.getVersionNumber(),
                        "storagePath", doc.getStoragePath()
                )));
    }

    @GetMapping("/me/documents")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "List current document versions for my profile")
    public ResponseEntity<ApiResponse<List<Document>>> getMyDocuments() {
        return ResponseEntity.ok(ApiResponse.success(
                documentService.getMyDocuments(currentUser().getId())));
    }

    @GetMapping("/me/documents/{id}/url")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Get a signed, time-limited download URL for a document")
    public ResponseEntity<ApiResponse<Map<String, String>>> getDocumentUrl(@PathVariable UUID id) {
        String signedUrl = documentService.getSignedDownloadUrl(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(Map.of("url", signedUrl)));
    }

    @GetMapping("/me/documents/versions")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Get all versions of a document type (version history)")
    public ResponseEntity<ApiResponse<List<Document>>> getVersionHistory(
            @RequestParam("type") String docType) {
        return ResponseEntity.ok(ApiResponse.success(
                documentService.getDocumentVersions(currentUser().getId(), docType)));
    }

    @DeleteMapping("/me/documents/{id}")
    @PreAuthorize("hasAuthority('DENTIST')")
    @Operation(summary = "Soft-delete a document")
    public ResponseEntity<ApiResponse<Void>> deleteDocument(@PathVariable UUID id) {
        documentService.deleteDocument(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Education & Experience ────────────────────────────────────────────────

    @PostMapping("/me/education")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> addEducation(
            @Valid @RequestBody EducationRequest req) {
        return ResponseEntity.ok(ApiResponse.success(
                dentistService.addEducation(currentUser().getId(), req)));
    }

    @DeleteMapping("/me/education/{id}")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<Void>> deleteEducation(@PathVariable UUID id) {
        dentistService.deleteEducation(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/me/experience")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> addExperience(
            @Valid @RequestBody ExperienceRequest req) {
        return ResponseEntity.ok(ApiResponse.success(
                dentistService.addExperience(currentUser().getId(), req)));
    }

    @DeleteMapping("/me/experience/{id}")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<Void>> deleteExperience(@PathVariable UUID id) {
        dentistService.deleteExperience(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ── Public profile by ID ──────────────────────────────────────────────────

    @GetMapping("/{id}")
    @Operation(summary = "Get a dentist profile by ID (public, no auth required)")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(dentistService.getProfileById(id)));
    }
}
