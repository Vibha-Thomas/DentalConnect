package com.dentconnect.clinic.repository;

import com.dentconnect.clinic.entity.ClinicStaff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicStaffRepository extends JpaRepository<ClinicStaff, UUID> {

    List<ClinicStaff> findByClinicIdAndDeletedAtIsNull(UUID clinicId);

    Optional<ClinicStaff> findByClinicIdAndUserIdAndDeletedAtIsNull(UUID clinicId, UUID userId);

    List<ClinicStaff> findByUserIdAndDeletedAtIsNull(UUID userId);

    Optional<ClinicStaff> findFirstByUserIdAndDeletedAtIsNull(UUID userId);
}
