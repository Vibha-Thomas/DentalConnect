package com.dentconnect.clinic.dto;

import com.dentconnect.clinic.entity.Clinic;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class ClinicResponse {
    private UUID id;
    private UUID ownerId;
    private String name;
    private String slug;
    private String description;
    private String logoUrl;
    private String address;
    private String city;
    private String state;
    private String country;
    private String pincode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String phone;
    private String email;
    private String website;
    private List<String> specialties;
    private String workingHours;
    private int chairsCount;
    private String verificationStatus;
    private UUID verifiedBy;
    private Instant verifiedAt;
    private UUID regionId;
    private Instant createdAt;

    public static ClinicResponse from(Clinic c) {
        return ClinicResponse.builder()
                .id(c.getId())
                .ownerId(c.getOwnerId())
                .name(c.getName())
                .slug(c.getSlug())
                .description(c.getDescription())
                .logoUrl(c.getLogoUrl())
                .address(c.getAddress())
                .city(c.getCity())
                .state(c.getState())
                .country(c.getCountry())
                .pincode(c.getPincode())
                .latitude(c.getLatitude())
                .longitude(c.getLongitude())
                .phone(c.getPhone())
                .email(c.getEmail())
                .website(c.getWebsite())
                .specialties(c.getSpecialties())
                .workingHours(c.getWorkingHours())
                .chairsCount(c.getChairsCount())
                .verificationStatus(c.getVerificationStatus())
                .verifiedBy(c.getVerifiedBy())
                .verifiedAt(c.getVerifiedAt())
                .regionId(c.getRegionId())
                .createdAt(c.getCreatedAt())
                .build();
    }
}
