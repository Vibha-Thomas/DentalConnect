package com.dentconnect.dentist.dto;

import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.dentist.entity.Education;
import com.dentconnect.dentist.entity.Experience;
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
    private String fullName;
    private LocalDate dateOfBirth;
    private String gender;
    private String bio;
    private String regNumber;
    private String regCouncil;
    private boolean regVerified;
    private int experienceYears;
    private Integer salaryMin;
    private Integer salaryMax;
    private String availability;
    private List<String> preferredCities;
    private List<String> languages;
    private String resumeUrl;
    private List<SkillDto> skills;
    private List<EducationDto> education;
    private List<ExperienceDto> experience;
    private Instant createdAt;

    public static DentistProfileResponse from(DentistProfile p, List<Education> edList, List<Experience> exList) {
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
                .education(edList.stream().map(EducationDto::from).toList())
                .experience(exList.stream().map(ExperienceDto::from).toList())
                .createdAt(p.getCreatedAt())
                .build();
    }
}
