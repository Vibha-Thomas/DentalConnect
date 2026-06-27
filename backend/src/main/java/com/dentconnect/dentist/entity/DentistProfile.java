package com.dentconnect.dentist.entity;

import com.dentconnect.common.converter.StringListConverter;
import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "dentist_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DentistProfile extends BaseEntity {

    @Column(name = "user_id", unique = true, nullable = false)
    private UUID userId;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private String gender;

    @Column(columnDefinition = "text")
    private String bio;

    @Column(name = "reg_number")
    private String regNumber;

    @Column(name = "reg_council")
    private String regCouncil;

    @Column(name = "reg_verified", columnDefinition = "boolean default false")
    private boolean regVerified;

    @Column(name = "experience_years")
    private int experienceYears;

    @Column(name = "salary_min")
    private Integer salaryMin;

    @Column(name = "salary_max")
    private Integer salaryMax;

    private String availability;

    @Convert(converter = StringListConverter.class)
    @Column(name = "preferred_cities")
    private List<String> preferredCities;

    @Convert(converter = StringListConverter.class)
    @Column(name = "languages")
    private List<String> languages;

    @Column(name = "resume_url")
    private String resumeUrl;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "dentist_skills",
        joinColumns = @JoinColumn(name = "dentist_id"),
        inverseJoinColumns = @JoinColumn(name = "skill_id")
    )
    private Set<Skill> skills;
}
