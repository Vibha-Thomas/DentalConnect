package com.dentconnect.dentist.controller;

import com.dentconnect.common.dto.ApiResponse;
import com.dentconnect.dentist.dto.DentistProfileRequest;
import com.dentconnect.dentist.dto.DentistProfileResponse;
import com.dentconnect.dentist.dto.EducationRequest;
import com.dentconnect.dentist.dto.ExperienceRequest;
import com.dentconnect.dentist.service.DentistService;
import com.dentconnect.user.entity.User;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/dentists")
@RequiredArgsConstructor
@Tag(name = "Dentist", description = "Dentist profile management")
public class DentistController {

    private final DentistService dentistService;

    private User currentUser() {
        return (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }

    @GetMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> getMyProfile() {
        return ResponseEntity.ok(ApiResponse.success(dentistService.getMyProfile(currentUser().getId())));
    }

    @PostMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> createProfile(
            @Valid @RequestBody DentistProfileRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(dentistService.createProfile(currentUser().getId(), req)));
    }

    @PutMapping("/me")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> updateProfile(
            @Valid @RequestBody DentistProfileRequest req) {
        return ResponseEntity.ok(ApiResponse.success(dentistService.updateProfile(currentUser().getId(), req)));
    }

    @PostMapping("/me/education")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> addEducation(
            @Valid @RequestBody EducationRequest req) {
        return ResponseEntity.ok(ApiResponse.success(dentistService.addEducation(currentUser().getId(), req)));
    }

    @DeleteMapping("/me/education/{id}")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<Void>> deleteEducation(@PathVariable UUID id) {
        dentistService.deleteEducation(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/me/experience")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> addExperience(
            @Valid @RequestBody ExperienceRequest req) {
        return ResponseEntity.ok(ApiResponse.success(dentistService.addExperience(currentUser().getId(), req)));
    }

    @DeleteMapping("/me/experience/{id}")
    @PreAuthorize("hasAuthority('DENTIST')")
    public ResponseEntity<ApiResponse<Void>> deleteExperience(@PathVariable UUID id) {
        dentistService.deleteExperience(currentUser().getId(), id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<DentistProfileResponse>> getProfileById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(dentistService.getProfileById(id)));
    }
}
