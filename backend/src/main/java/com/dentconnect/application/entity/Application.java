package com.dentconnect.application.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Application extends BaseEntity {

    @Column(name = "job_id", nullable = false)
    private UUID jobId;

    @Column(name = "dentist_id", nullable = false)
    private UUID dentistId;

    @Column(nullable = false)
    @Builder.Default
    private String status = "APPLIED";
    // APPLIED | VIEWED | SHORTLISTED | INTERVIEW_SCHEDULED | INTERVIEW_COMPLETED | OFFER_MADE | ACCEPTED | REJECTED | WITHDRAWN

    @Column(name = "cover_letter", columnDefinition = "text")
    private String coverLetter;
}
