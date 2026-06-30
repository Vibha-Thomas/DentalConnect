package com.dentconnect.dentist.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "dentist_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DentistProfile extends BaseEntity {

    // ── Ownership ─────────────────────────────────────────────────────────────

    @Column(name = "user_id", unique = true, nullable = false)
    private UUID userId;

    // ── Personal Information ──────────────────────────────────────────────────

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private String gender;              // MALE | FEMALE | OTHER

    private String nationality;

    private String phone;

    @Column(name = "photo_url")
    private String photoUrl;

    @Column(columnDefinition = "text")
    private String bio;

    // ── Address ───────────────────────────────────────────────────────────────

    @Column(columnDefinition = "text")
    private String address;

    private String city;

    private String state;

    private String country;

    @Column(name = "pin_code")
    private String pinCode;

    @Column(name = "emergency_contact_name")
    private String emergencyContactName;

    @Column(name = "emergency_contact_phone")
    private String emergencyContactPhone;

    // ── Professional Information ──────────────────────────────────────────────

    @Column(name = "reg_number")
    private String regNumber;

    @Column(name = "reg_council")
    private String regCouncil;

    @Column(name = "reg_valid_until")
    private LocalDate regValidUntil;

    @Column(name = "reg_verified", columnDefinition = "boolean default false")
    private boolean regVerified;

    private String degree;

    private String university;

    @Column(name = "graduation_year")
    private Integer graduationYear;

    @Column(name = "internship_hospital")
    private String internshipHospital;

    @Column(name = "experience_years")
    private int experienceYears;

    @Column(name = "expected_salary")
    private Integer expectedSalary;

    // ── Salary Range (kept from Sprint 2.1) ──────────────────────────────────

    @Column(name = "salary_min")
    private Integer salaryMin;

    @Column(name = "salary_max")
    private Integer salaryMax;

    // ── Preferences ───────────────────────────────────────────────────────────

    private String availability;        // IMMEDIATE | 15_DAYS | 30_DAYS | 60_DAYS

    @Column(name = "employment_preference")
    private String employmentPreference; // FULL_TIME | PART_TIME | LOCUM | CONSULTANT | INTERNSHIP

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "preferred_cities", columnDefinition = "text[]")
    private List<String> preferredCities;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "languages", columnDefinition = "text[]")
    private List<String> languages;

    // ── Legacy resume URL (kept for backward compat; prefer documents table) ──

    @Column(name = "resume_url")
    private String resumeUrl;

    // ── Skills (many-to-many) ─────────────────────────────────────────────────

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "dentist_skills",
        joinColumns = @JoinColumn(name = "dentist_id"),
        inverseJoinColumns = @JoinColumn(name = "skill_id")
    )
    private Set<Skill> skills;

    // ── Onboarding Wizard State ───────────────────────────────────────────────

    @Column(name = "onboarding_step")
    @Builder.Default
    private int onboardingStep = 0;     // 0–6 (which step was last completed)

    @Column(name = "onboarding_completed")
    @Builder.Default
    private boolean onboardingCompleted = false;

    // ── Cached Completion Score (computed on write, read cheaply) ─────────────

    /**
     * Profile completion percentage (0–100).
     * Recalculated by ProfileCompletionService whenever profile fields change.
     * NEVER computed on read — dashboard reads this integer directly.
     */
    @Column(name = "profile_completion_score")
    @Builder.Default
    private int profileCompletionScore = 0;

    @Column(name = "profile_completion_updated_at")
    private Instant profileCompletionUpdatedAt;

    // ── Verification State Machine ────────────────────────────────────────────

    /**
     * PENDING → UNDER_REVIEW → VERIFIED | REJECTED | SUSPENDED
     */
    @Column(name = "verification_status")
    @Builder.Default
    private String verificationStatus = "PENDING";

    @Column(name = "verification_notes", columnDefinition = "text")
    private String verificationNotes;

    @Column(name = "verified_by")
    private UUID verifiedBy;

    @Column(name = "verified_at")
    private Instant verifiedAt;
}
