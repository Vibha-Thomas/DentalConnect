package com.dentconnect.clinic.entity;

import com.dentconnect.common.converter.StringListConverter;
import com.dentconnect.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "clinics")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Clinic extends BaseEntity {

    @Column(name = "owner_id")
    private UUID ownerId;

    @Column(nullable = false)
    private String name;

    private String slug;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "logo_url")
    private String logoUrl;

    private String address;

    private String city;

    private String state;

    private String country;

    private String pincode;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    private String phone;

    private String email;

    private String website;

    @Convert(converter = StringListConverter.class)
    @Column(name = "specialties")
    private List<String> specialties;

    @Column(name = "working_hours")
    private String workingHours;

    @Column(name = "chairs_count")
    private int chairsCount;

    @Column(name = "verification_status")
    @Builder.Default
    private String verificationStatus = "PENDING";

    @Column(name = "verified_by")
    private UUID verifiedBy;

    @Column(name = "verified_at")
    private Instant verifiedAt;

    @Column(name = "region_id")
    private UUID regionId;
}
