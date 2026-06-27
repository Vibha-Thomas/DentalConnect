package com.dentconnect.clinic.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ClinicRequest {

    @NotBlank
    private String name;

    private String address;

    @NotBlank
    private String city;

    private String state;

    private String country;

    private String pincode;

    private String phone;

    private String email;

    private String website;

    private String description;

    private List<String> specialties;

    private String workingHours;

    private int chairsCount;

    private BigDecimal latitude;

    private BigDecimal longitude;
}
