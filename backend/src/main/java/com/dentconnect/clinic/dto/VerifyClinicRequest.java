package com.dentconnect.clinic.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VerifyClinicRequest {

    @NotBlank
    private String status;

    private String notes;
}
