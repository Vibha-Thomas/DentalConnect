package com.dentconnect.dentist.repository;

import com.dentconnect.dentist.entity.DentistProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DentistProfileRepository extends JpaRepository<DentistProfile, UUID> {
    Optional<DentistProfile> findByUserIdAndDeletedAtIsNull(UUID userId);
    boolean existsByUserIdAndDeletedAtIsNull(UUID userId);
}
