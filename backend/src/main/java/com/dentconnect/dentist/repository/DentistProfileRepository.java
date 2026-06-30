package com.dentconnect.dentist.repository;

import com.dentconnect.dentist.entity.DentistProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DentistProfileRepository extends JpaRepository<DentistProfile, UUID> {
    Optional<DentistProfile> findByUserIdAndDeletedAtIsNull(UUID userId);
    boolean existsByUserIdAndDeletedAtIsNull(UUID userId);

    long countByDeletedAtIsNull();
    long countByVerificationStatusAndDeletedAtIsNull(String status);
    long countByOnboardingCompletedTrueAndDeletedAtIsNull();
    long countByCreatedAtBetweenAndDeletedAtIsNull(java.time.Instant from, java.time.Instant to);

    @Query(value = """
        SELECT dp.city as city, COUNT(dp.id) as count
        FROM dentist_profiles dp
        WHERE dp.deleted_at IS NULL AND dp.city IS NOT NULL AND dp.city <> ''
        GROUP BY dp.city
        ORDER BY count DESC
        LIMIT :limit
        """, nativeQuery = true)
    List<java.util.Map<String, Object>> findTopCitiesByDentistCount(@org.springframework.data.repository.query.Param("limit") int limit);
}
