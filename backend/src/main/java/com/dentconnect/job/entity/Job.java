package com.dentconnect.job.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "jobs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Job extends BaseEntity {

    @Column(name = "clinic_id", nullable = false)
    private UUID clinicId;

    @Column(nullable = false)
    private String title;

    private String slug;

    @Column(name = "employment_type", nullable = false)
    private String employmentType; // INTERNSHIP | LOCUM | PART_TIME | FULL_TIME

    @Column(name = "experience_min")
    private Integer experienceMin;

    @Column(name = "experience_max")
    private Integer experienceMax;

    @Column(name = "salary_min")
    private Integer salaryMin;

    @Column(name = "salary_max")
    private Integer salaryMax;

    @Column(name = "salary_negotiable")
    private Boolean salaryNegotiable;

    @Column(columnDefinition = "text")
    private String benefits;

    @Column(columnDefinition = "text", nullable = false)
    private String description;

    private String location;

    private String city;

    private String state;

    @Column(name = "interview_type")
    private String interviewType; // ONLINE | IN_PERSON | HYBRID

    private LocalDate deadline;

    private Integer openings;

    @Column(nullable = false)
    @Builder.Default
    private String status = "DRAFT"; // DRAFT | PENDING_APPROVAL | PUBLISHED | CLOSED | ARCHIVED

    @Column(name = "approved_by")
    private UUID approvedBy;

    @Column(name = "approved_at")
    private Instant approvedAt;

    @Column(name = "region_id")
    private UUID regionId;

    @Column(name = "views_count")
    @Builder.Default
    private int viewsCount = 0;

    @Column(name = "applications_count")
    @Builder.Default
    private int applicationsCount = 0;
}
