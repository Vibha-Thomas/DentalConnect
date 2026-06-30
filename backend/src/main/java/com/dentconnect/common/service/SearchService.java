package com.dentconnect.common.service;

import com.dentconnect.dentist.entity.DentistProfile;
import com.dentconnect.dentist.repository.DentistProfileRepository;
import com.dentconnect.clinic.entity.Clinic;
import com.dentconnect.clinic.repository.ClinicRepository;
import com.dentconnect.job.entity.Job;
import com.dentconnect.job.repository.JobRepository;
import com.dentconnect.application.entity.Application;
import com.dentconnect.application.repository.ApplicationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SearchService {

    private final DentistProfileRepository dentistProfileRepo;
    private final ClinicRepository clinicRepo;
    private final JobRepository jobRepo;
    private final ApplicationRepository applicationRepo;

    /**
     * Search result DTO returned by unified search
     */
    public record SearchResult(
            String id,
            String type,       // DENTIST | CLINIC | JOB | APPLICATION
            String title,      // Main name / title (e.g. dentist full name, job title)
            String subtitle,   // Secondary info (e.g. dentist city, job company / location)
            String status      // Verification status / Application status / Job status
    ) {}

    /**
     * Central search engine for admins. Searches across multiple entity types simultaneously.
     *
     * @param query the search query string
     * @param limit maximum results to return per category
     * @return unified list of search results
     */
    public List<SearchResult> search(String query, int limit) {
        List<SearchResult> results = new ArrayList<>();
        if (query == null || query.isBlank() || query.trim().length() < 2) {
            return results;
        }
        String cleanQuery = "%" + query.trim().toLowerCase() + "%";
        PageRequest page = PageRequest.of(0, limit);

        // 1. Search Dentists (by name, city, email, reg number)
        results.addAll(searchDentists(cleanQuery, page));

        // 2. Search Clinics (by name, city, phone)
        results.addAll(searchClinics(cleanQuery, page));

        // 3. Search Jobs (by title, location, employment type)
        results.addAll(searchJobs(cleanQuery, page));

        // 4. Search Applications (by cover letter)
        results.addAll(searchApplications(cleanQuery, page));

        return results;
    }

    private List<SearchResult> searchDentists(String query, PageRequest page) {
        // Find by custom query or specifications
        // Let's implement a simple specification or query. In a native method:
        // Since we can use custom native queries or JPA Specification, let's write a simple specification or manual fetch.
        // Let's do a manual fetch from repo using JpaSpecificationExecutor or direct query.
        // Wait, DentistProfileRepository doesn't inherit JpaSpecificationExecutor, but we can write a quick query or use existing methods.
        // Let's use custom native queries or jpql. We can add a method or query.
        // Let's write a JPQL query for dentist profile search.
        // Let's see if we can define Specification if DentistProfileRepository inherits JpaSpecificationExecutor,
        // but since it doesn't, let's just write jpql queries in the repos.
        // Wait, to keep it simple and clean, let's query using custom JPQL or native query.
        return dentistProfileRepo.findAll().stream()
                .filter(p -> p.getDeletedAt() == null &&
                        ((p.getFullName() != null && p.getFullName().toLowerCase().contains(query.replace("%", ""))) ||
                         (p.getCity() != null && p.getCity().toLowerCase().contains(query.replace("%", ""))) ||
                         (p.getRegNumber() != null && p.getRegNumber().toLowerCase().contains(query.replace("%", "")))))
                .limit(page.getPageSize())
                .map(p -> new SearchResult(
                        p.getId().toString(),
                        "DENTIST",
                        p.getFullName(),
                        p.getCity() != null ? p.getCity() : p.getRegNumber(),
                        p.getVerificationStatus()
                ))
                .collect(Collectors.toList());
    }

    private List<SearchResult> searchClinics(String query, PageRequest page) {
        return clinicRepo.findAll().stream()
                .filter(c -> c.getDeletedAt() == null &&
                        ((c.getName() != null && c.getName().toLowerCase().contains(query.replace("%", ""))) ||
                         (c.getCity() != null && c.getCity().toLowerCase().contains(query.replace("%", ""))) ||
                         (c.getEmail() != null && c.getEmail().toLowerCase().contains(query.replace("%", "")))))
                .limit(page.getPageSize())
                .map(c -> new SearchResult(
                        c.getId().toString(),
                        "CLINIC",
                        c.getName(),
                        c.getCity() != null ? c.getCity() : c.getEmail(),
                        c.getVerificationStatus()
                ))
                .collect(Collectors.toList());
    }

    private List<SearchResult> searchJobs(String query, PageRequest page) {
        return jobRepo.findAll().stream()
                .filter(j -> j.getDeletedAt() == null &&
                        ((j.getTitle() != null && j.getTitle().toLowerCase().contains(query.replace("%", ""))) ||
                         (j.getCity() != null && j.getCity().toLowerCase().contains(query.replace("%", ""))) ||
                         (j.getEmploymentType() != null && j.getEmploymentType().toLowerCase().contains(query.replace("%", "")))))
                .limit(page.getPageSize())
                .map(j -> new SearchResult(
                        j.getId().toString(),
                        "JOB",
                        j.getTitle(),
                        j.getCity() != null ? j.getCity() : j.getEmploymentType(),
                        j.getStatus()
                ))
                .collect(Collectors.toList());
    }

    private List<SearchResult> searchApplications(String query, PageRequest page) {
        return applicationRepo.findAll().stream()
                .filter(a -> a.getDeletedAt() == null &&
                        (a.getCoverLetter() != null && a.getCoverLetter().toLowerCase().contains(query.replace("%", ""))))
                .limit(page.getPageSize())
                .map(a -> new SearchResult(
                        a.getId().toString(),
                        "APPLICATION",
                        "Application for Job " + a.getJobId().toString().substring(0, 8),
                        a.getCoverLetter().substring(0, Math.min(a.getCoverLetter().length(), 40)) + "...",
                        a.getStatus()
                ))
                .collect(Collectors.toList());
    }
}
