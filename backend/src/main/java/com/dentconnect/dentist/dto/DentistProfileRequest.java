package com.dentconnect.dentist.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class DentistProfileRequest {

    // ── Personal ─────────────────────────────────────────────────────────────

    @NotBlank(message = "Full name is required")
    @Size(max = 150)
    private String fullName;

    private String dateOfBirth;         // ISO-8601 date string: "YYYY-MM-DD"

    private String gender;              // MALE | FEMALE | OTHER

    @Size(max = 50)
    private String nationality;

    @Pattern(regexp = "^[+\\d\\s\\-()]{7,20}$", message = "Invalid phone number")
    private String phone;

    @Size(max = 500)
    private String bio;

    // ── Address ───────────────────────────────────────────────────────────────

    private String address;

    @Size(max = 100)
    private String city;

    @Size(max = 100)
    private String state;

    @Size(max = 100)
    private String country;

    @Size(max = 20)
    private String pinCode;

    @Size(max = 100)
    private String emergencyContactName;

    @Pattern(regexp = "^[+\\d\\s\\-()]{7,20}$", message = "Invalid emergency contact phone")
    private String emergencyContactPhone;

    // ── Professional ─────────────────────────────────────────────────────────

    @Size(max = 50)
    private String regNumber;

    @Size(max = 100)
    private String regCouncil;

    private String regValidUntil;       // ISO-8601 date string

    @Size(max = 100)
    private String degree;

    @Size(max = 200)
    private String university;

    private Integer graduationYear;

    @Size(max = 200)
    private String internshipHospital;

    private Integer experienceYears;

    private Integer expectedSalary;

    private Integer salaryMin;

    private Integer salaryMax;

    // ── Preferences ───────────────────────────────────────────────────────────

    private String availability;        // IMMEDIATE | 15_DAYS | 30_DAYS | 60_DAYS

    private String employmentPreference; // FULL_TIME | PART_TIME | LOCUM | CONSULTANT | INTERNSHIP

    private List<String> preferredCities;

    private List<String> languages;

    // ── Skills ────────────────────────────────────────────────────────────────

    private List<UUID> skillIds;

    // ── Onboarding step tracking ──────────────────────────────────────────────

    private Integer onboardingStep;
}
