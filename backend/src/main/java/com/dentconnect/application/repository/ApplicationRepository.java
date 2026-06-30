package com.dentconnect.application.repository;

import com.dentconnect.application.entity.Application;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ApplicationRepository extends JpaRepository<Application, UUID>, JpaSpecificationExecutor<Application> {

    @Query("SELECT COUNT(a) FROM Application a WHERE a.deletedAt IS NULL")
    long countAll();

    long countByDeletedAtIsNull();

    Page<Application> findByStatusAndDeletedAtIsNull(String status, Pageable pageable);
}
