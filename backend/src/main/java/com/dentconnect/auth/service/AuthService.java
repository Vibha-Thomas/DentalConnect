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
        String firebaseUid;
        String email;
        String displayName = request.getDisplayName();
        String phone = request.getPhone();

        // 1. Verify Firebase token
        if (request.getFirebaseToken().startsWith("mock-")) {
            log.info("Using mock development authentication for token: {}", request.getFirebaseToken());
            String tokenVal = request.getFirebaseToken();
            if (tokenVal.contains(":")) {
                String[] parts = tokenVal.split(":", 2);
                firebaseUid = parts[0];
                email = parts[1];
            } else {
                firebaseUid = tokenVal;
                email = tokenVal.contains("@") ? tokenVal : tokenVal + "@example.com";
            }
            if (displayName == null) displayName = "Mock User";
        } else {
            try {
                FirebaseToken firebaseToken = FirebaseAuth.getInstance().verifyIdToken(request.getFirebaseToken());
                firebaseUid = firebaseToken.getUid();
                email = firebaseToken.getEmail();
                if (displayName == null) displayName = firebaseToken.getName();
                if (phone == null) phone = (String) firebaseToken.getClaims().get("phone_number");
            } catch (IllegalStateException e) {
                log.warn("Firebase not initialized. Using development fallback authentication.");
                firebaseUid = "mock-" + request.getFirebaseToken();
                email = request.getFirebaseToken().contains("@")
                        ? request.getFirebaseToken()
                        : request.getFirebaseToken() + "@example.com";
                if (displayName == null) displayName = "Mock User";
            } catch (FirebaseAuthException e) {
                log.warn("Firebase token verification failed: {}", e.getMessage());
                throw new UnauthorizedException("Invalid Firebase token: " + e.getMessage());
            }
        }

        // 2. Find or create user
        User user = userRepository.findByFirebaseUidAndDeletedAtIsNull(firebaseUid)
                .orElse(null);

        boolean isNewUser = (user == null);

        if (isNewUser) {
            // Check if a user with the same email already exists
            User existingEmailUser = email != null ? userRepository.findByEmailAndDeletedAtIsNull(email).orElse(null) : null;
            if (existingEmailUser != null) {
                if (existingEmailUser.getFirebaseUid() != null && !existingEmailUser.getFirebaseUid().equals(firebaseUid)) {
                    throw new BadRequestException("Email already in use");
                }
                if (existingEmailUser.getFirebaseUid() == null) {
                    user = existingEmailUser;
                    user.setFirebaseUid(firebaseUid);
                    isNewUser = false;
                }
            }

            // Check if a user with the same phone already exists
            User existingPhoneUser = phone != null ? userRepository.findByPhoneAndDeletedAtIsNull(phone).orElse(null) : null;
            if (existingPhoneUser != null) {
                if (existingPhoneUser.getFirebaseUid() != null && !existingPhoneUser.getFirebaseUid().equals(firebaseUid)) {
                    throw new BadRequestException("Phone number already in use");
                }
                if (existingPhoneUser.getFirebaseUid() == null) {
                    if (user != null && !user.getId().equals(existingPhoneUser.getId())) {
                        throw new BadRequestException("Conflict: Email and phone belong to different accounts");
                    }
                    if (user == null) {
                        user = existingPhoneUser;
                        user.setFirebaseUid(firebaseUid);
                        isNewUser = false;
                    }
                }
            }

            if (isNewUser) {
                String roleName = request.getRole() != null ? request.getRole() : "DENTIST";
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new BadRequestException("Invalid role: " + roleName));

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
            } else {
                user.setLastLogin(Instant.now());
                if (displayName != null && (user.getDisplayName() == null || user.getDisplayName().isBlank())) {
                    user.setDisplayName(displayName);
                }
                if (email != null && user.getEmail() == null) {
                    user.setEmail(email);
                }
                if (phone != null && user.getPhone() == null) {
                    user.setPhone(phone);
                }
                user = userRepository.save(user);
            }
        } else {
            // User exists by Firebase UID — enforce email/phone uniqueness check if request is updating them
            if (email != null && !email.equalsIgnoreCase(user.getEmail())) {
                if (userRepository.existsByEmailAndDeletedAtIsNull(email)) {
                    throw new BadRequestException("Email already in use");
                }
                user.setEmail(email);
            }
            if (phone != null && !phone.equals(user.getPhone())) {
                if (userRepository.existsByPhoneAndDeletedAtIsNull(phone)) {
                    throw new BadRequestException("Phone number already in use");
                }
                user.setPhone(phone);
            }

            user.setLastLogin(Instant.now());
            if (displayName != null && !displayName.isBlank()) {
                user.setDisplayName(displayName);
            }
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
