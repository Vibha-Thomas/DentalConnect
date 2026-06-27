package com.dentconnect.auth.service;

import com.dentconnect.auth.dto.AuthRequest;
import com.dentconnect.auth.dto.AuthResponse;
import com.dentconnect.auth.entity.RefreshToken;
import com.dentconnect.auth.repository.RefreshTokenRepository;
import com.dentconnect.auth.security.JwtTokenProvider;
import com.dentconnect.common.exception.BadRequestException;
import com.dentconnect.common.exception.UnauthorizedException;
import com.dentconnect.user.entity.Role;
import com.dentconnect.user.entity.User;
import com.dentconnect.user.repository.RoleRepository;
import com.dentconnect.user.repository.UserRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${app.jwt.refresh-expiration-ms:604800000}")
    private long refreshExpirationMs;

    public AuthResponse loginWithFirebaseToken(AuthRequest request) {
        // 1. Verify Firebase token
        FirebaseToken firebaseToken;
        try {
            firebaseToken = FirebaseAuth.getInstance().verifyIdToken(request.getFirebaseToken());
        } catch (FirebaseAuthException e) {
            log.warn("Firebase token verification failed: {}", e.getMessage());
            throw new UnauthorizedException("Invalid Firebase token: " + e.getMessage());
        } catch (IllegalStateException e) {
            // Firebase not initialized — for development without Firebase config
            log.warn("Firebase not initialized. Using development mode authentication.");
            throw new UnauthorizedException("Firebase not configured. Please set up firebase-service-account.json");
        }

        String firebaseUid = firebaseToken.getUid();
        String email = firebaseToken.getEmail();
        String displayName = request.getDisplayName() != null
                ? request.getDisplayName()
                : firebaseToken.getName();
        String phone = request.getPhone() != null
                ? request.getPhone()
                : (String) firebaseToken.getClaims().get("phone_number");

        // 2. Find or create user
        User user = userRepository.findByFirebaseUidAndDeletedAtIsNull(firebaseUid)
                .orElse(null);

        boolean isNewUser = (user == null);

        if (isNewUser) {
            // Determine role
            String roleName = request.getRole() != null ? request.getRole() : "DENTIST";
            Role role = roleRepository.findByName(roleName)
                    .orElseThrow(() -> new BadRequestException("Invalid role: " + roleName));

            // Check email uniqueness
            if (email != null && userRepository.existsByEmailAndDeletedAtIsNull(email)) {
                // User might exist with same email but different firebase UID (e.g. phone auth)
                user = userRepository.findByEmailAndDeletedAtIsNull(email).orElse(null);
                if (user != null) {
                    // Link firebase UID to existing account
                    user.setFirebaseUid(firebaseUid);
                    user.setLastLogin(Instant.now());
                    user = userRepository.save(user);
                    isNewUser = false;
                }
            }

            if (isNewUser) {
                user = User.builder()
                        .firebaseUid(firebaseUid)
                        .email(email)
                        .phone(phone)
                        .displayName(displayName)
                        .roleId(role.getId())
                        .status("ACTIVE")
                        .lastLogin(Instant.now())
                        .build();
                user = userRepository.save(user);
                // Reload to get the role eager-loaded
                user = userRepository.findById(user.getId()).orElseThrow();
            }
        } else {
            // Update last login and display name
            user.setLastLogin(Instant.now());
            if (displayName != null && !displayName.isBlank()) user.setDisplayName(displayName);
            if (phone != null && user.getPhone() == null) user.setPhone(phone);
            user = userRepository.save(user);
        }

        // 3. Generate JWT tokens
        String accessToken = jwtTokenProvider.generateToken(user);
        String refreshTokenValue = UUID.randomUUID().toString();

        // 4. Save refresh token
        refreshTokenRepository.deleteByUserId(user.getId()); // revoke old tokens
        RefreshToken refreshToken = RefreshToken.builder()
                .userId(user.getId())
                .token(refreshTokenValue)
                .expiresAt(Instant.now().plusMillis(refreshExpirationMs))
                .build();
        refreshTokenRepository.save(refreshToken);

        String roleName = user.getRole() != null ? user.getRole().getName() : "DENTIST";

        return AuthResponse.builder()
                .userId(user.getId().toString())
                .email(user.getEmail())
                .displayName(user.getDisplayName())
                .role(roleName)
                .accessToken(accessToken)
                .refreshToken(refreshTokenValue)
                .newUser(isNewUser)
                .build();
    }

    public AuthResponse refreshAccessToken(String refreshTokenValue) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(refreshTokenValue)
                .orElseThrow(() -> new UnauthorizedException("Invalid refresh token"));

        if (refreshToken.getExpiresAt().isBefore(Instant.now())) {
            refreshTokenRepository.delete(refreshToken);
            throw new UnauthorizedException("Refresh token expired. Please log in again.");
        }

        User user = userRepository.findById(refreshToken.getUserId())
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        String accessToken = jwtTokenProvider.generateToken(user);
        String newRefreshTokenValue = UUID.randomUUID().toString();

        refreshToken.setToken(newRefreshTokenValue);
        refreshToken.setExpiresAt(Instant.now().plusMillis(refreshExpirationMs));
        refreshTokenRepository.save(refreshToken);

        String roleName = user.getRole() != null ? user.getRole().getName() : "DENTIST";

        return AuthResponse.builder()
                .userId(user.getId().toString())
                .email(user.getEmail())
                .displayName(user.getDisplayName())
                .role(roleName)
                .accessToken(accessToken)
                .refreshToken(newRefreshTokenValue)
                .newUser(false)
                .build();
    }

    public void logout(String refreshTokenValue) {
        refreshTokenRepository.findByToken(refreshTokenValue)
                .ifPresent(refreshTokenRepository::delete);
    }
}
