package com.dentconnect.user.repository;

import com.dentconnect.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByFirebaseUidAndDeletedAtIsNull(String firebaseUid);

    Optional<User> findByEmailAndDeletedAtIsNull(String email);

    Optional<User> findByPhoneAndDeletedAtIsNull(String phone);

    boolean existsByEmailAndDeletedAtIsNull(String email);

    boolean existsByPhoneAndDeletedAtIsNull(String phone);

    Page<User> findByDeletedAtIsNull(Pageable pageable);

    @Query("SELECT COUNT(u) FROM User u WHERE u.deletedAt IS NULL")
    long countActiveUsers();
}
