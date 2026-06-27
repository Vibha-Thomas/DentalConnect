package com.dentconnect.dentist.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "education")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Education extends BaseEntity {

    @Column(name = "dentist_id", nullable = false)
    private UUID dentistId;

    private String degree;

    private String institution;

    @Column(name = "start_year")
    private Integer startYear;

    @Column(name = "end_year")
    private Integer endYear;

    private String grade;
}
