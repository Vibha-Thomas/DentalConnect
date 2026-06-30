package com.dentconnect.clinic.repository;

import com.dentconnect.clinic.entity.Clinic;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicRepository extends JpaRepository<Clinic, UUID> {

    Optional<Clinic> findByOwnerIdAndDeletedAtIsNull(UUID ownerId);

    Page<Clinic> findByVerificationStatusAndDeletedAtIsNull(String status, Pageable pageable);

    @Query("SELECT COUNT(c) FROM Clinic c WHERE c.verificationStatus = 'VERIFIED' AND c.deletedAt IS NULL")
    long countVerified();

    @Query("SELECT COUNT(c) FROM Clinic c WHERE c.deletedAt IS NULL")
    long countAll();

    long countByDeletedAtIsNull();
    long countByVerificationStatusAndDeletedAtIsNull(String status);
}
