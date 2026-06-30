package com.dentconnect.dentist.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class DentistProfileResponse {

    private UUID id;
    private UUID userId;

    // ── Personal ─────────────────────────────────────────────────────────────
    private String fullName;
    private LocalDate dateOfBirth;
    private String gender;
    private String nationality;
    private String phone;
    private String photoUrl;
    private String bio;

    // ── Address ───────────────────────────────────────────────────────────────
    private String address;
    private String city;
    private String state;
    private String country;
    private String pinCode;
    private String emergencyContactName;
    private String emergencyContactPhone;

    // ── Professional ─────────────────────────────────────────────────────────
    private String regNumber;
    private String regCouncil;
    private LocalDate regValidUntil;
    private boolean regVerified;
    private String degree;
    private String university;
    private Integer graduationYear;
    private String internshipHospital;
    private int experienceYears;
    private Integer expectedSalary;
    private Integer salaryMin;
    private Integer salaryMax;

    // ── Preferences ───────────────────────────────────────────────────────────
    private String availability;
    private String employmentPreference;
    private List<String> preferredCities;
    private List<String> languages;

    // ── Skills + Education + Experience ──────────────────────────────────────
    private List<SkillDto> skills;
    private List<EducationDto> education;
    private List<ExperienceDto> experience;

    // ── Documents (current versions only, no URLs) ────────────────────────────
    private List<DocumentSummaryDto> documents;

    // ── Completion (cached, read from DB) ────────────────────────────────────
    private int profileCompletionScore;
    private int minimumCompletionForApplication;
    private boolean canApplyToJobs;

    // ── Onboarding ────────────────────────────────────────────────────────────
    private int onboardingStep;
    private boolean onboardingCompleted;

    // ── Verification ──────────────────────────────────────────────────────────
    private String verificationStatus;

    // ── Meta ─────────────────────────────────────────────────────────────────
    private Instant createdAt;
    private Instant updatedAt;

    // ── Nested: document summary (no signed URL here — caller uses /documents/{id}/url) ──

    @Data
    @Builder
    public static class DocumentSummaryDto {
        private UUID id;
        private String type;
        private String name;
        private String mimeType;
        private Long sizeBytes;
        private int versionNumber;
        private boolean currentVersion;
        private boolean approvedVersion;
        private String verificationStatus;
        private Instant uploadedAt;
    }
}
