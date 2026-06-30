package com.dentconnect.application.repository;

import com.dentconnect.application.entity.Interview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface InterviewRepository extends JpaRepository<Interview, UUID> {
    long countByDeletedAtIsNull();
    long countByStatusAndDeletedAtIsNull(String status);
}
