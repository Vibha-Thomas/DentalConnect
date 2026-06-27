package com.dentconnect.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String userId;
    private String email;
    private String displayName;
    private String role;
    private String accessToken;
    private String refreshToken;
    private boolean newUser;
}
