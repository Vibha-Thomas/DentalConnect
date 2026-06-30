package com.dentconnect.admin.service;

import com.dentconnect.dentist.repository.DentistProfileRepository;
import com.dentconnect.clinic.repository.ClinicRepository;
import com.dentconnect.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Dashboard KPI statistics service with Caffeine in-memory caching.
 *
 * KPIs are expensive queries on large tables. They are cached for
 * {@code app.admin.dashboard-cache-seconds} seconds (default: 30).
 *
 * Cache is also evicted automatically every 30 seconds via @Scheduled.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardStatisticsService {

    private final DentistProfileRepository dentistProfileRepo;
    private final ClinicRepository clinicRepo;
    private final UserRepository userRepo;
    private final com.dentconnect.job.repository.JobRepository jobRepo;
    private final com.dentconnect.application.repository.ApplicationRepository applicationRepo;
    private final com.dentconnect.application.repository.InterviewRepository interviewRepo;

    @Value("${app.admin.dashboard-cache-seconds:30}")
    private int cacheTtlSeconds;

    /**
     * Returns all dashboard KPIs.
     * Result is cached for {@code dashboard-cache-seconds} seconds.
     */
    @Cacheable("dashboardKpis")
    public DashboardKpis getKpis() {
        log.debug("Computing dashboard KPIs (cache miss)");

        long totalDentists = dentistProfileRepo.countByDeletedAtIsNull();
        long totalClinics  = clinicRepo.countByDeletedAtIsNull();
        long verifiedClinics = clinicRepo.countByVerificationStatusAndDeletedAtIsNull("VERIFIED");
        long pendingVerification = dentistProfileRepo.countByVerificationStatusAndDeletedAtIsNull("PENDING");
        long onboardingCompleted = dentistProfileRepo.countByOnboardingCompletedTrueAndDeletedAtIsNull();
        long totalJobs = jobRepo.countByDeletedAtIsNull();
        long totalApplications = applicationRepo.countByDeletedAtIsNull();
        long interviewsScheduled = interviewRepo.countByStatusAndDeletedAtIsNull("SCHEDULED");

        // Calculate growth trends (this month vs last month)
        java.time.Instant nowInstant = java.time.Instant.now();
        java.time.Instant thirtyDaysAgo = nowInstant.minus(java.time.Duration.ofDays(30));
        java.time.Instant sixtyDaysAgo = nowInstant.minus(java.time.Duration.ofDays(60));

        long dentistsThisMonth = dentistProfileRepo.countByCreatedAtBetweenAndDeletedAtIsNull(thirtyDaysAgo, nowInstant);
        long dentistsLastMonth = dentistProfileRepo.countByCreatedAtBetweenAndDeletedAtIsNull(sixtyDaysAgo, thirtyDaysAgo);
        double dentistGrowth = dentistsLastMonth == 0 ? (dentistsThisMonth > 0 ? 100.0 : 0.0) : 
                ((double)(dentistsThisMonth - dentistsLastMonth) / dentistsLastMonth) * 100.0;

        return new DashboardKpis(
                totalDentists,
                totalClinics,
                verifiedClinics,
                pendingVerification,
                onboardingCompleted,
                totalJobs,
                totalApplications,
                interviewsScheduled,
                dentistGrowth
        );
    }

    /**
     * Monthly registration data for charts (last N months).
     */
    @Cacheable("monthlyRegistrations")
    public List<MonthlyDataPoint> getMonthlyDentistRegistrations(int months) {
        List<MonthlyDataPoint> result = new ArrayList<>();
        YearMonth now = YearMonth.now();
        for (int i = months - 1; i >= 0; i--) {
            YearMonth month = now.minusMonths(i);
            Instant from = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
            Instant to   = month.atEndOfMonth().atTime(23, 59, 59).toInstant(ZoneOffset.UTC);
            long count = dentistProfileRepo.countByCreatedAtBetweenAndDeletedAtIsNull(from, to);
            result.add(new MonthlyDataPoint(month.toString(), count));
        }
        return result;
    }

    /**
     * Top cities by dentist count.
     */
    @Cacheable("topCities")
    public List<Map<String, Object>> getTopCitiesByDentistCount(int limit) {
        return dentistProfileRepo.findTopCitiesByDentistCount(limit);
    }

    /**
     * Evict all caches every N seconds (matches cache TTL).
     */
    @Scheduled(fixedDelayString = "${app.admin.dashboard-cache-seconds:30}000")
    @CacheEvict(value = {"dashboardKpis", "monthlyRegistrations", "topCities"}, allEntries = true)
    public void evictCaches() {
        log.debug("Dashboard statistics caches evicted");
    }

    // ── Result types ──────────────────────────────────────────────────────────

    public record DashboardKpis(
            long totalDentists,
            long totalClinics,
            long verifiedClinics,
            long pendingVerification,
            long onboardingCompleted,
            long totalJobs,
            long totalApplications,
            long interviewsScheduled,
            double dentistGrowth
    ) {}

    public record MonthlyDataPoint(String month, long count) {}
}
