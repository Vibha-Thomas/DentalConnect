package com.dentconnect.dentist.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EducationRequest {

    @NotBlank
    private String degree;

    @NotBlank
    private String institution;

    @NotNull
    private Integer startYear;

    private Integer endYear;

    private String grade;
}
