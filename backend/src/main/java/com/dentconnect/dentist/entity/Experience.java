package com.dentconnect.dentist.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "experience")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Experience extends BaseEntity {

    @Column(name = "dentist_id", nullable = false)
    private UUID dentistId;

    private String title;

    private String organization;

    private String location;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "is_current")
    private boolean isCurrent;

    @Column(columnDefinition = "text")
    private String description;
}
