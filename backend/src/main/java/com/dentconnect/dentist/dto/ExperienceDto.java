package com.dentconnect.dentist.dto;

import com.dentconnect.dentist.entity.Experience;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
public class ExperienceDto {
    private UUID id;
    private String title;
    private String organization;
    private String location;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean isCurrent;
    private String description;

    public static ExperienceDto from(Experience e) {
        return ExperienceDto.builder()
                .id(e.getId())
                .title(e.getTitle())
                .organization(e.getOrganization())
                .location(e.getLocation())
                .startDate(e.getStartDate())
                .endDate(e.getEndDate())
                .isCurrent(e.isCurrent())
                .description(e.getDescription())
                .build();
    }
}
