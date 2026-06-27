package com.dentconnect.auth.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class AuthRequest {

    @NotBlank(message = "Firebase token is required")
    private String firebaseToken;

    private String role;         // DENTIST, CLINIC_OWNER, etc.
    private String displayName;  // For registration
    private String phone;        // Optional phone number
}
