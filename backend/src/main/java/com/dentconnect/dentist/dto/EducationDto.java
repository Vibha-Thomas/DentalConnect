package com.dentconnect.dentist.dto;

import com.dentconnect.dentist.entity.Education;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class EducationDto {
    private UUID id;
    private UUID dentistId;
    private String degree;
    private String institution;
    private Integer startYear;
    private Integer endYear;
    private String grade;

    public static EducationDto from(Education e) {
        return EducationDto.builder()
                .id(e.getId())
                .dentistId(e.getDentistId())
                .degree(e.getDegree())
                .institution(e.getInstitution())
                .startYear(e.getStartYear())
                .endYear(e.getEndYear())
                .grade(e.getGrade())
                .build();
    }
}
