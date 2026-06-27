# DentConnect - Slice 2: Production MVP (No Placeholders)

The infrastructure phase is now complete.

Verified working:

* Spring Boot starts successfully
* PostgreSQL is running
* Docker Compose is healthy
* Flyway has successfully applied all migrations
* Hibernate initializes correctly
* JWT Security configuration loads
* Database schema exists
* Maven build passes

Do NOT regenerate infrastructure.

Do NOT modify Docker unless required.

Do NOT regenerate Flyway migrations unless schema changes are absolutely necessary.

The focus of Slice 2 is implementing the actual business logic.

---

# Development Rules

This slice must produce a working MVP.

Do NOT generate:

* TODO comments
* mocked repositories
* fake dashboard data
* placeholder JSON
* hardcoded users
* hardcoded JWTs
* sample responses

Every screen must communicate with the backend.

Every backend endpoint must communicate with PostgreSQL.

Every feature must work end-to-end.

Flutter
↓

REST API

↓

Spring Boot

↓

JPA

↓

PostgreSQL

↓

Response

↓

Flutter UI

---

# Feature 1 — Authentication

Implement complete authentication.

Dentist Registration

Clinic Registration

Login

Logout

Refresh Token

JWT generation

JWT validation

Role-based authorization

Password hashing

Email uniqueness

Phone uniqueness

Validation

Persist users into PostgreSQL.

---

# Feature 2 — Dentist Profile

Create profile

Edit profile

Upload profile photo

Upload resume

Upload certificates

Dental Council Registration Number

Experience

Specializations

Preferred locations

Expected salary

Availability

CRUD APIs.

Persist everything.

---

# Feature 3 — Clinic Profile

Create clinic

Edit clinic

Upload logo

Clinic address

Google Maps coordinates

License upload

GST/Business registration (if applicable)

Clinic description

Services

Specialties

Verification status

Persist everything.

---

# Feature 4 — Job Posting

Verified clinics only.

Create job

Edit job

Delete job

Archive

Publish

Draft

Close

Fields

Title

Description

Salary

Employment type

Experience

Location

Required skills

Specialization

Vacancies

Store in PostgreSQL.

---

# Feature 5 — Job Search

Flutter search screen.

Backend search API.

Support

Pagination

Sorting

Filters

Keyword search

Location

Salary

Specialization

Experience

Verified clinics only

Recent jobs

---

# Feature 6 — Applications

Dentist applies.

Prevent duplicate applications.

Save application.

Status workflow

Applied

Reviewed

Shortlisted

Interview Scheduled

Rejected

Accepted

Application timeline

Notes

Store timestamps.

---

# Feature 7 — WhatsApp Integration

Generate WhatsApp deep links.

Allow clinic to message applicants.

Allow dentist to contact clinic.

Generate proper templates.

Do not require Meta Business API.

Use Click-to-Chat.

---

# Feature 8 — Notifications

Database notifications.

Unread count.

Read status.

Push notification hooks.

Firebase integration should remain optional until service account is configured.

---

# Feature 9 — Admin

Approve clinic

Reject clinic

Suspend user

View analytics

Approve jobs

Reject jobs

Audit logs

---

# Flutter Requirements

Replace every placeholder screen.

Every screen must consume live REST APIs.

No fake cards.

No hardcoded data.

Material 3.

Proper loading states.

Empty states.

Error states.

Pagination.

Search.

---

# Backend Requirements

Every endpoint must have

DTO

Validation

Service

Repository

Swagger documentation

Unit tests

Integration tests

Proper exception handling

Audit logging

---

# Database Requirements

All CRUD operations must use PostgreSQL.

No in-memory lists.

No mocked repositories.

No fake services.

---

# API Documentation

Update Swagger for every endpoint.

Include

Example request

Example response

Validation errors

Authentication requirements

---

# Testing

After every feature implementation

Run

./mvnw clean verify

Run

Docker Compose

Verify

Backend starts

Database connects

Flyway succeeds

Swagger loads

Authentication works

Feature works end-to-end

Do not continue to the next feature until the previous feature passes verification.

---

# Deliverables

At the end of Slice 2 provide:

1. List of implemented REST APIs

2. Flutter screens completed

3. Database tables used

4. Test coverage summary

5. Swagger endpoints

6. Features still pending for Slice 3

7. Manual testing checklist

The project should be usable by two real users:

A clinic can register, create a profile, post a job, review applicants, and contact them through WhatsApp.

A dentist can register, complete a profile, search jobs, apply, track application status, and receive notifications.

Everything must be production-grade and fully connected end-to-end.
