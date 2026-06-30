package com.dentconnect.dentist.service;

import com.dentconnect.common.exception.BadRequestException;
import com.dentconnect.common.exception.ResourceNotFoundException;
import com.dentconnect.common.exception.UnauthorizedException;
import com.dentconnect.common.repository.DocumentRepository;
import com.dentconnect.common.service.ActivityTimelineService;
import com.dentconnect.dentist.dto.*;
import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.dentist.entity.Education;
import com.dentconnect.dentist.entity.Experience;
import com.dentconnect.dentist.repository.DentistProfileRepository;
import com.dentconnect.dentist.repository.EducationRepository;
import com.dentconnect.dentist.repository.ExperienceRepository;
import com.dentconnect.dentist.repository.SkillRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class DentistService {

    private final DentistProfileRepository profileRepo;
    private final EducationRepository educationRepo;
    private final ExperienceRepository experienceRepo;
    private final SkillRepository skillRepo;
    private final DocumentRepository documentRepo;
    private final ProfileCompletionService completionService;
    private final ActivityTimelineService activityTimeline;

    // ── Profile existence check (for splash screen redirect) ─────────────────

    @Transactional(readOnly = true)
    public boolean profileExists(UUID userId) {
        return profileRepo.existsByUserIdAndDeletedAtIsNull(userId);
    }

    // ── Get ───────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public DentistProfileResponse getMyProfile(UUID userId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return buildResponse(profile);
    }

    @Transactional(readOnly = true)
    public DentistProfileResponse getProfileById(UUID dentistId) {
        DentistProfile profile = profileRepo.findById(dentistId)
                .filter(p -> p.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return buildResponse(profile);
    }

    @Transactional(readOnly = true)
    public ProfileCompletionService.CompletionBreakdown getCompletion(UUID userId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return completionService.breakdown(profile);
    }

    // ── Create ────────────────────────────────────────────────────────────────

    public DentistProfileResponse createProfile(UUID userId, DentistProfileRequest req) {
        if (profileRepo.existsByUserIdAndDeletedAtIsNull(userId)) {
            throw new BadRequestException("Profile already exists");
        }

        DentistProfile profile = buildProfileFromRequest(
                DentistProfile.builder().userId(userId).build(), req);

        completionService.recalculateAndCache(profile);
        profile = profileRepo.save(profile);

        activityTimeline.record(userId, "DENTIST", profile.getId(),
                ActivityTimelineService.REGISTERED,
                "Dentist profile created");

        return buildResponse(profile);
    }

    // ── Update ────────────────────────────────────────────────────────────────

    public DentistProfileResponse updateProfile(UUID userId, DentistProfileRequest req) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));

        buildProfileFromRequest(profile, req);

        // Update onboarding step if provided
        if (req.getOnboardingStep() != null && req.getOnboardingStep() > profile.getOnboardingStep()) {
            profile.setOnboardingStep(req.getOnboardingStep());
            if (req.getOnboardingStep() >= 6) {
                profile.setOnboardingCompleted(true);
                activityTimeline.record(userId, "DENTIST", profile.getId(),
                        ActivityTimelineService.ONBOARDING_COMPLETED,
                        "Onboarding wizard completed");
            }
        }

        completionService.recalculateAndCache(profile);
        profile = profileRepo.save(profile);

        activityTimeline.record(userId, "DENTIST", profile.getId(),
                ActivityTimelineService.PROFILE_UPDATED,
                "Profile information updated");

        return buildResponse(profile);
    }

    // ── Photo ─────────────────────────────────────────────────────────────────

    public DentistProfileResponse updatePhotoUrl(UUID userId, String photoUrl) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        profile.setPhotoUrl(photoUrl);
        completionService.recalculateAndCache(profile);
        profile = profileRepo.save(profile);

        activityTimeline.record(userId, "DENTIST", profile.getId(),
                ActivityTimelineService.PHOTO_UPLOADED, "Profile photo updated");

        return buildResponse(profile);
    }

    // ── Onboarding step (autosave) ────────────────────────────────────────────

    public void updateOnboardingStep(UUID userId, int step) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        if (step > profile.getOnboardingStep()) {
            profile.setOnboardingStep(step);
            if (step >= 6) profile.setOnboardingCompleted(true);
            profileRepo.save(profile);
        }
    }

    // ── Education ────────────────────────────────────────────────────────────

    public DentistProfileResponse addEducation(UUID userId, EducationRequest req) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        Education edu = Education.builder()
                .dentistId(profile.getId())
                .degree(req.getDegree())
                .institution(req.getInstitution())
                .startYear(req.getStartYear())
                .endYear(req.getEndYear())
                .grade(req.getGrade())
                .build();
        educationRepo.save(edu);
        completionService.recalculateAndCache(profile);
        profileRepo.save(profile);
        return buildResponse(profile);
    }

    public void deleteEducation(UUID userId, UUID educationId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        Education edu = educationRepo.findById(educationId)
                .orElseThrow(() -> new ResourceNotFoundException("Education not found"));
        if (!edu.getDentistId().equals(profile.getId())) {
            throw new UnauthorizedException("Not authorized");
        }
        edu.softDelete();
        educationRepo.save(edu);
    }

    // ── Experience ────────────────────────────────────────────────────────────

    public DentistProfileResponse addExperience(UUID userId, ExperienceRequest req) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        Experience exp = Experience.builder()
                .dentistId(profile.getId())
                .title(req.getTitle())
                .organization(req.getOrganization())
                .location(req.getLocation())
                .startDate(req.getStartDate() != null ? LocalDate.parse(req.getStartDate()) : null)
                .endDate(req.getEndDate() != null && !req.getEndDate().isBlank()
                        ? LocalDate.parse(req.getEndDate()) : null)
                .isCurrent(req.isCurrent())
                .description(req.getDescription())
                .build();
        experienceRepo.save(exp);
        return buildResponse(profile);
    }

    public void deleteExperience(UUID userId, UUID experienceId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        Experience exp = experienceRepo.findById(experienceId)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found"));
        if (!exp.getDentistId().equals(profile.getId())) {
            throw new UnauthorizedException("Not authorized");
        }
        exp.softDelete();
        experienceRepo.save(exp);
    }

    // ── Delete ────────────────────────────────────────────────────────────────

    public void deleteProfile(UUID userId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        profile.softDelete();
        profileRepo.save(profile);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private DentistProfile buildProfileFromRequest(DentistProfile profile, DentistProfileRequest req) {
        if (req.getFullName()            != null) profile.setFullName(req.getFullName());
        if (req.getGender()              != null) profile.setGender(req.getGender());
        if (req.getNationality()         != null) profile.setNationality(req.getNationality());
        if (req.getPhone()               != null) profile.setPhone(req.getPhone());
        if (req.getBio()                 != null) profile.setBio(req.getBio());
        if (req.getAddress()             != null) profile.setAddress(req.getAddress());
        if (req.getCity()                != null) profile.setCity(req.getCity());
        if (req.getState()               != null) profile.setState(req.getState());
        if (req.getCountry()             != null) profile.setCountry(req.getCountry());
        if (req.getPinCode()             != null) profile.setPinCode(req.getPinCode());
        if (req.getEmergencyContactName() != null) profile.setEmergencyContactName(req.getEmergencyContactName());
        if (req.getEmergencyContactPhone()!= null) profile.setEmergencyContactPhone(req.getEmergencyContactPhone());
        if (req.getRegNumber()           != null) profile.setRegNumber(req.getRegNumber());
        if (req.getRegCouncil()          != null) profile.setRegCouncil(req.getRegCouncil());
        if (req.getDegree()              != null) profile.setDegree(req.getDegree());
        if (req.getUniversity()          != null) profile.setUniversity(req.getUniversity());
        if (req.getGraduationYear()      != null) profile.setGraduationYear(req.getGraduationYear());
        if (req.getInternshipHospital()  != null) profile.setInternshipHospital(req.getInternshipHospital());
        if (req.getExperienceYears()     != null) profile.setExperienceYears(req.getExperienceYears());
        if (req.getExpectedSalary()      != null) profile.setExpectedSalary(req.getExpectedSalary());
        if (req.getSalaryMin()           != null) profile.setSalaryMin(req.getSalaryMin());
        if (req.getSalaryMax()           != null) profile.setSalaryMax(req.getSalaryMax());
        if (req.getAvailability()        != null) profile.setAvailability(req.getAvailability());
        if (req.getEmploymentPreference()!= null) profile.setEmploymentPreference(req.getEmploymentPreference());
        if (req.getPreferredCities()     != null) profile.setPreferredCities(req.getPreferredCities());
        if (req.getLanguages()           != null) profile.setLanguages(req.getLanguages());
        if (req.getDateOfBirth()         != null && !req.getDateOfBirth().isBlank()) {
            profile.setDateOfBirth(LocalDate.parse(req.getDateOfBirth()));
        }
        if (req.getRegValidUntil()       != null && !req.getRegValidUntil().isBlank()) {
            profile.setRegValidUntil(LocalDate.parse(req.getRegValidUntil()));
        }
        if (req.getSkillIds()            != null) {
            profile.setSkills(new HashSet<>(skillRepo.findAllById(req.getSkillIds())));
        }
        return profile;
    }

    private DentistProfileResponse buildResponse(DentistProfile p) {
        List<Education> edu = educationRepo.findByDentistIdAndDeletedAtIsNull(p.getId());
        List<Experience> exp = experienceRepo.findByDentistIdAndDeletedAtIsNull(p.getId());

        // Documents — current versions only, no signed URLs
        List<DentistProfileResponse.DocumentSummaryDto> docs = p.getId() == null ? List.of() :
                documentRepo.findByEntityTypeAndEntityIdAndCurrentVersionTrueAndDeletedAtIsNull(
                        "DENTIST", p.getId())
                .stream()
                .map(d -> DentistProfileResponse.DocumentSummaryDto.builder()
                        .id(d.getId())
                        .type(d.getType())
                        .name(d.getName())
                        .mimeType(d.getMimeType())
                        .sizeBytes(d.getSizeBytes())
                        .versionNumber(d.getVersionNumber())
                        .currentVersion(d.isCurrentVersion())
                        .approvedVersion(d.isApprovedVersion())
                        .verificationStatus(d.getVerificationStatus())
                        .uploadedAt(d.getCreatedAt())
                        .build())
                .toList();

        return DentistProfileResponse.builder()
                .id(p.getId())
                .userId(p.getUserId())
                .fullName(p.getFullName())
                .dateOfBirth(p.getDateOfBirth())
                .gender(p.getGender())
                .nationality(p.getNationality())
                .phone(p.getPhone())
                .photoUrl(p.getPhotoUrl())
                .bio(p.getBio())
                .address(p.getAddress())
                .city(p.getCity())
                .state(p.getState())
                .country(p.getCountry())
                .pinCode(p.getPinCode())
                .emergencyContactName(p.getEmergencyContactName())
                .emergencyContactPhone(p.getEmergencyContactPhone())
                .regNumber(p.getRegNumber())
                .regCouncil(p.getRegCouncil())
                .regValidUntil(p.getRegValidUntil())
                .regVerified(p.isRegVerified())
                .degree(p.getDegree())
                .university(p.getUniversity())
                .graduationYear(p.getGraduationYear())
                .internshipHospital(p.getInternshipHospital())
                .experienceYears(p.getExperienceYears())
                .expectedSalary(p.getExpectedSalary())
                .salaryMin(p.getSalaryMin())
                .salaryMax(p.getSalaryMax())
                .availability(p.getAvailability())
                .employmentPreference(p.getEmploymentPreference())
                .preferredCities(p.getPreferredCities())
                .languages(p.getLanguages())
                .skills(p.getSkills() != null
                        ? p.getSkills().stream().map(SkillDto::from).toList()
                        : List.of())
                .education(edu.stream().map(EducationDto::from).toList())
                .experience(exp.stream().map(ExperienceDto::from).toList())
                .documents(docs)
                .profileCompletionScore(p.getProfileCompletionScore())
                .minimumCompletionForApplication(completionService.getMinimumForApplication())
                .canApplyToJobs(p.getProfileCompletionScore() >= completionService.getMinimumForApplication())
                .onboardingStep(p.getOnboardingStep())
                .onboardingCompleted(p.isOnboardingCompleted())
                .verificationStatus(p.getVerificationStatus())
                .createdAt(p.getCreatedAt())
                .updatedAt(p.getUpdatedAt())
                .build();
    }
}
