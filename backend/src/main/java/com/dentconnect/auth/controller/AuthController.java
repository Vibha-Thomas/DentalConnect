package com.dentconnect.auth.controller;

import com.dentconnect.auth.dto.AuthRequest;
import com.dentconnect.auth.dto.AuthResponse;
import com.dentconnect.auth.service.AuthService;
import com.dentconnect.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Firebase-backed authentication with JWT")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Login or register with Firebase token")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody AuthRequest request) {
        AuthResponse response = authService.loginWithFirebaseToken(request);
        return ResponseEntity.ok(ApiResponse.success(
                response.isNewUser() ? "Account created successfully" : "Login successful",
                response
        ));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@RequestBody Map<String, String> body) {
        String refreshToken = body.get("refreshToken");
        if (refreshToken == null || refreshToken.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("refreshToken is required"));
        }
        AuthResponse response = authService.refreshAccessToken(refreshToken);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout and revoke refresh token")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestBody Map<String, String> body) {
        String refreshToken = body.get("refreshToken");
        if (refreshToken != null) {
            authService.logout(refreshToken);
        }
        return ResponseEntity.ok(ApiResponse.success("Logged out successfully", null));
    }
}
