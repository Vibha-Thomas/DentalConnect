package com.dentconnect.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "firebase_uid", unique = true)
    private String firebaseUid;

    @Column(unique = true)
    private String email;

    @Column(unique = true)
    private String phone;

    @Column(name = "display_name")
    private String displayName;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "role_id")
    private Integer roleId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", insertable = false, updatable = false)
    private Role role;

    @Builder.Default
    private String status = "ACTIVE";

    @Column(name = "last_login")
    private Instant lastLogin;

    @Column(name = "created_at", updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @Column(name = "deleted_at")
    private Instant deletedAt;

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }

    // ── UserDetails implementation ──

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (role != null && role.getName() != null) {
            return List.of(new SimpleGrantedAuthority(role.getName()));
        }
        return List.of();
    }

    @Override
    public String getPassword() {
        return null; // Firebase handles passwords
    }

    @Override
    public String getUsername() {
        return email != null ? email : firebaseUid;
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return !"SUSPENDED".equals(status); }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return !"DELETED".equals(status) && deletedAt == null; }
}
