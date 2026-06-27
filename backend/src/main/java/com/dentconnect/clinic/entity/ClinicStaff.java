package com.dentconnect.clinic.entity;

import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "clinic_staff")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClinicStaff extends BaseEntity {

    @Column(name = "clinic_id", nullable = false)
    private UUID clinicId;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String role;
}
