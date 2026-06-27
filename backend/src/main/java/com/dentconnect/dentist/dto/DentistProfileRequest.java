package com.dentconnect.dentist.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class DentistProfileRequest {

    @NotBlank
    private String fullName;

    private String dateOfBirth;

    private String gender;

    private String bio;

    private String regNumber;

    private String regCouncil;

    private Integer experienceYears;

    private Integer salaryMin;

    private Integer salaryMax;

    private String availability;

    private List<String> preferredCities;

    private List<String> languages;

    private List<UUID> skillIds;
}
