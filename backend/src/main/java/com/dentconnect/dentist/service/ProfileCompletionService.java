package com.dentconnect.dentist.service;

import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.common.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;

/**
 * Calculates and caches the dentist profile completion score.
 *
 * Score is computed on WRITE (every profile save), stored in the DB column
 * profile_completion_score, and READ cheaply as a single integer.
 *
 * The minimum threshold for job applications is configurable via:
 *   app.profile.minimum-completion-for-application (default: 80)
 *
 * Weights:
 *   Personal info  25%
 *   Professional   25%
 *   Skills         20%
 *   Documents      20%
 *   Preferences    10%
 */
@Service
@RequiredArgsConstructor
public class ProfileCompletionService {

    private final DocumentRepository documentRepository;

    @Value("${app.profile.minimum-completion-for-application:80}")
    private int minimumCompletionForApplication;

    /**
     * Calculate and persist the completion score into the profile entity.
     * Call this after every profile update, then save the profile.
     *
     * @param profile the profile entity (will be mutated in-place)
     */
    public void recalculateAndCache(DentistProfile profile) {
        int score = calculate(profile);
        profile.setProfileCompletionScore(score);
        profile.setProfileCompletionUpdatedAt(Instant.now());
    }

    /**
     * Compute the completion score without persisting.
     */
    public int calculate(DentistProfile profile) {
        int personal     = scorePersonal(profile);
        int professional = scoreProfessional(profile);
        int skills       = scoreSkills(profile);
        int documents    = scoreDocuments(profile);
        int preferences  = scorePreferences(profile);

        // Weighted total (out of 100)
        return (int) Math.round(
                personal     * 0.25 +
                professional * 0.25 +
                skills       * 0.20 +
                documents    * 0.20 +
                preferences  * 0.10
        );
    }

    /**
     * Build a per-section breakdown for the profile completion response.
     */
    public CompletionBreakdown breakdown(DentistProfile profile) {
        return new CompletionBreakdown(
                scorePersonal(profile),
                scoreProfessional(profile),
                scoreSkills(profile),
                scoreDocuments(profile),
                scorePreferences(profile),
                profile.getProfileCompletionScore(),
                minimumCompletionForApplication,
                profile.getProfileCompletionScore() >= minimumCompletionForApplication
        );
    }

    public int getMinimumForApplication() {
        return minimumCompletionForApplication;
    }

    // ── Section scorers (each returns 0–100) ─────────────────────────────────

    private int scorePersonal(DentistProfile p) {
        int fields = 0;
        int total  = 6;
        if (isSet(p.getFullName()))    fields++;
        if (p.getDateOfBirth() != null) fields++;
        if (isSet(p.getGender()))      fields++;
        if (isSet(p.getPhone()))       fields++;
        if (isSet(p.getPhotoUrl()))    fields++;
        if (isSet(p.getAddress()) || isSet(p.getCity())) fields++;
        return (int) Math.round(fields * 100.0 / total);
    }

    private int scoreProfessional(DentistProfile p) {
        int fields = 0;
        int total  = 5;
        if (isSet(p.getRegNumber()))   fields++;
        if (isSet(p.getDegree()))      fields++;
        if (isSet(p.getUniversity())) fields++;
        if (p.getExperienceYears() > 0) fields++;
        if (isSet(p.getEmploymentPreference())) fields++;
        return (int) Math.round(fields * 100.0 / total);
    }

    private int scoreSkills(DentistProfile p) {
        if (p.getSkills() == null || p.getSkills().isEmpty()) return 0;
        // Full score at 3+ skills, partial below
        int count = p.getSkills().size();
        return Math.min(100, count * 34);
    }

    private int scoreDocuments(DentistProfile p) {
        if (p.getId() == null) return 0;
        // Required: LICENSE + DEGREE_CERT (20 pts each) + RESUME (20 pts) + GOVT_ID (20 pts) = bonus 20
        int score = 0;
        if (documentRepository.existsByEntityTypeAndEntityIdAndTypeAndCurrentVersionTrueAndDeletedAtIsNull(
                "DENTIST", p.getId(), "LICENSE")) score += 30;
        if (documentRepository.existsByEntityTypeAndEntityIdAndTypeAndCurrentVersionTrueAndDeletedAtIsNull(
                "DENTIST", p.getId(), "DEGREE_CERT")) score += 30;
        if (documentRepository.existsByEntityTypeAndEntityIdAndTypeAndCurrentVersionTrueAndDeletedAtIsNull(
                "DENTIST", p.getId(), "RESUME")) score += 25;
        if (documentRepository.existsByEntityTypeAndEntityIdAndTypeAndCurrentVersionTrueAndDeletedAtIsNull(
                "DENTIST", p.getId(), "GOVT_ID")) score += 15;
        return Math.min(100, score);
    }

    private int scorePreferences(DentistProfile p) {
        int fields = 0;
        int total  = 2;
        if (p.getPreferredCities() != null && !p.getPreferredCities().isEmpty()) fields++;
        if (isSet(p.getAvailability())) fields++;
        return (int) Math.round(fields * 100.0 / total);
    }

    private static boolean isSet(String s) {
        return s != null && !s.isBlank();
    }

    // ── Result types ──────────────────────────────────────────────────────────

    public record CompletionBreakdown(
            int personal,
            int professional,
            int skills,
            int documents,
            int preferences,
            int total,
            int minimumRequired,
            boolean canApplyToJobs
    ) {}
}
