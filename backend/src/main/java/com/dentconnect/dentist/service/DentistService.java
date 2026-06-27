package com.dentconnect.dentist.service;

import com.dentconnect.common.exception.BadRequestException;
import com.dentconnect.common.exception.ResourceNotFoundException;
import com.dentconnect.common.exception.UnauthorizedException;
import com.dentconnect.dentist.dto.DentistProfileRequest;
import com.dentconnect.dentist.dto.DentistProfileResponse;
import com.dentconnect.dentist.dto.EducationDto;
import com.dentconnect.dentist.dto.EducationRequest;
import com.dentconnect.dentist.dto.ExperienceDto;
import com.dentconnect.dentist.dto.ExperienceRequest;
import com.dentconnect.dentist.dto.SkillDto;
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

    public DentistProfileResponse getMyProfile(UUID userId) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return buildResponse(profile);
    }

    public DentistProfileResponse createProfile(UUID userId, DentistProfileRequest req) {
        if (profileRepo.existsByUserIdAndDeletedAtIsNull(userId)) {
            throw new BadRequestException("Profile already exists");
        }
        DentistProfile profile = DentistProfile.builder()
                .userId(userId)
                .fullName(req.getFullName())
                .gender(req.getGender())
                .bio(req.getBio())
                .regNumber(req.getRegNumber())
                .regCouncil(req.getRegCouncil())
                .experienceYears(req.getExperienceYears() != null ? req.getExperienceYears() : 0)
                .salaryMin(req.getSalaryMin())
                .salaryMax(req.getSalaryMax())
                .availability(req.getAvailability())
                .preferredCities(req.getPreferredCities())
                .languages(req.getLanguages())
                .build();
        if (req.getDateOfBirth() != null && !req.getDateOfBirth().isBlank()) {
            profile.setDateOfBirth(LocalDate.parse(req.getDateOfBirth()));
        }
        if (req.getSkillIds() != null && !req.getSkillIds().isEmpty()) {
            profile.setSkills(new HashSet<>(skillRepo.findAllById(req.getSkillIds())));
        }
        profile = profileRepo.save(profile);
        return buildResponse(profile);
    }

    public DentistProfileResponse updateProfile(UUID userId, DentistProfileRequest req) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        profile.setFullName(req.getFullName());
        if (req.getGender() != null) profile.setGender(req.getGender());
        if (req.getBio() != null) profile.setBio(req.getBio());
        if (req.getRegNumber() != null) profile.setRegNumber(req.getRegNumber());
        if (req.getRegCouncil() != null) profile.setRegCouncil(req.getRegCouncil());
        if (req.getExperienceYears() != null) profile.setExperienceYears(req.getExperienceYears());
        if (req.getSalaryMin() != null) profile.setSalaryMin(req.getSalaryMin());
        if (req.getSalaryMax() != null) profile.setSalaryMax(req.getSalaryMax());
        if (req.getAvailability() != null) profile.setAvailability(req.getAvailability());
        if (req.getPreferredCities() != null) profile.setPreferredCities(req.getPreferredCities());
        if (req.getLanguages() != null) profile.setLanguages(req.getLanguages());
        if (req.getDateOfBirth() != null && !req.getDateOfBirth().isBlank()) {
            profile.setDateOfBirth(LocalDate.parse(req.getDateOfBirth()));
        }
        if (req.getSkillIds() != null) {
            profile.setSkills(new HashSet<>(skillRepo.findAllById(req.getSkillIds())));
        }
        profile = profileRepo.save(profile);
        return buildResponse(profile);
    }

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
        return buildResponse(profile);
    }

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

    public DentistProfileResponse getProfileById(UUID dentistId) {
        DentistProfile profile = profileRepo.findById(dentistId)
                .filter(p -> p.getDeletedAt() == null)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        return buildResponse(profile);
    }

    public void updateResumeUrl(UUID userId, String resumeUrl) {
        DentistProfile profile = profileRepo.findByUserIdAndDeletedAtIsNull(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Profile not found"));
        profile.setResumeUrl(resumeUrl);
        profileRepo.save(profile);
    }

    private DentistProfileResponse buildResponse(DentistProfile p) {
        List<Education> edu = educationRepo.findByDentistIdAndDeletedAtIsNull(p.getId());
        List<Experience> exp = experienceRepo.findByDentistIdAndDeletedAtIsNull(p.getId());
        return DentistProfileResponse.builder()
                .id(p.getId())
                .userId(p.getUserId())
                .fullName(p.getFullName())
                .dateOfBirth(p.getDateOfBirth())
                .gender(p.getGender())
                .bio(p.getBio())
                .regNumber(p.getRegNumber())
                .regCouncil(p.getRegCouncil())
                .regVerified(p.isRegVerified())
                .experienceYears(p.getExperienceYears())
                .salaryMin(p.getSalaryMin())
                .salaryMax(p.getSalaryMax())
                .availability(p.getAvailability())
                .preferredCities(p.getPreferredCities())
                .languages(p.getLanguages())
                .resumeUrl(p.getResumeUrl())
                .skills(p.getSkills() != null
                        ? p.getSkills().stream().map(SkillDto::from).toList()
                        : List.of())
                .education(edu.stream().map(EducationDto::from).toList())
                .experience(exp.stream().map(ExperienceDto::from).toList())
                .createdAt(p.getCreatedAt())
                .build();
    }
}
