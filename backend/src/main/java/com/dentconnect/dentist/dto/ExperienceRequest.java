package com.dentconnect.dentist.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExperienceRequest {

    @NotBlank
    private String title;

    @NotBlank
    private String organization;

    private String location;

    @NotNull
    private String startDate;

    private String endDate;

    private boolean isCurrent;

    private String description;
}
