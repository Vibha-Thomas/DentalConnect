package com.dentconnect.common.repository;

import com.dentconnect.common.entity.ProfileActivityLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProfileActivityLogRepository extends JpaRepository<ProfileActivityLog, UUID> {

    List<ProfileActivityLog> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<ProfileActivityLog> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(String entityType, UUID entityId);

    Page<ProfileActivityLog> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(
            String entityType, UUID entityId, Pageable pageable);
}
