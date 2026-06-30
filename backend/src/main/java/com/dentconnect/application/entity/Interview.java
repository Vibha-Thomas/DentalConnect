package com.dentconnect.application.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "interviews")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Interview extends BaseEntity {

    @Column(name = "application_id", nullable = false)
    private UUID applicationId;

    @Column(name = "scheduled_at", nullable = false)
    private Instant scheduledAt;

    @Column(name = "duration_mins")
    private Integer durationMins;

    @Column(nullable = false)
    @Builder.Default
    private String type = "IN_PERSON"; // ONLINE | IN_PERSON | HYBRID

    private String location;

    @Column(name = "meeting_link", columnDefinition = "text")
    private String meetingLink;

    @Column(columnDefinition = "text")
    private String notes;

    @Column(nullable = false)
    @Builder.Default
    private String status = "SCHEDULED"; // SCHEDULED | COMPLETED | CANCELLED | RESCHEDULED
}
