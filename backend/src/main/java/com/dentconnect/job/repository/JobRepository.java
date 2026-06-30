package com.dentconnect.job.repository;

import com.dentconnect.job.entity.Job;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface JobRepository extends JpaRepository<Job, UUID>, JpaSpecificationExecutor<Job> {

    @Query("SELECT COUNT(j) FROM Job j WHERE j.deletedAt IS NULL")
    long countAll();

    long countByDeletedAtIsNull();

    Page<Job> findByStatusAndDeletedAtIsNull(String status, Pageable pageable);
}
