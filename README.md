# DentConnect

> Dental recruitment platform connecting dentists with clinics across India.

## Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter Mobile   │────▶│  Spring Boot API  │────▶│   PostgreSQL    │
│  (Riverpod)       │     │  (Java 21)        │     │   (Flyway)      │
└──────────────────┘     └──────────────────┘     └─────────────────┘
         │                        │
         ▼                        ▼
┌──────────────────┐     ┌──────────────────┐
│  Firebase          │     │  React Admin      │
│  Auth/Storage/FCM  │     │  Dashboard        │
└──────────────────┘     └──────────────────┘
```

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Java JDK | 21+ | [adoptium.net](https://adoptium.net) |
| Maven | 3.9+ | Bundled with `./mvnw` wrapper |
| Docker Desktop | Latest | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) — **must be running** |
| Flutter SDK | ≥3.19 | [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install/windows) |
| Node.js | 20+ | [nodejs.org](https://nodejs.org) |
| Python | 3.10+ | Optional, for dev scripts |

> ⚠️ **Docker Desktop must be open and running** before `docker-compose up`.
> ⚠️ **Flutter** must be added to your PATH. See [Flutter Windows install](https://docs.flutter.dev/get-started/install/windows).

---

## Quick Start

### 1. Start the database and backend

```powershell
# Ensure Docker Desktop is running first, then:
docker-compose up -d postgres

# Verify postgres is healthy
docker-compose ps
```

### 2. Run Spring Boot backend

```powershell
cd backend
./mvnw spring-boot:run
```

API available at: http://localhost:8080  
Swagger UI: http://localhost:8080/swagger-ui

### 3. Run the admin dashboard

```powershell
cd admin-dashboard
npm install
npm run dev
```

Admin UI: http://localhost:5173

### 4. Run Flutter app

> First, [install Flutter](https://docs.flutter.dev/get-started/install/windows) and add `C:\flutter\bin` to your PATH.

```powershell
cd dentconnect_app
flutter pub get
flutter run
```

### 5. (Optional) Python dev tools

```powershell
# From project root (activate venv first)
venv\Scripts\activate
pip install -r requirements.txt
```

### Run everything with Docker

```powershell
# All services (requires Docker Desktop running)
docker-compose up -d

# With pgAdmin for DB browsing
docker-compose --profile dev-tools up -d
```

### Run Admin Dashboard

```bash
cd admin-dashboard
npm install
npm run dev
```

Admin UI: http://localhost:5173

## Project Structure

```
DentalConnect/
├── backend/                  # Spring Boot API (Java 21)
│   ├── src/main/java/com/dentconnect/
│   │   ├── auth/             # Firebase Auth + JWT
│   │   ├── user/             # User management
│   │   ├── dentist/          # Dentist profiles
│   │   ├── clinic/           # Clinic management
│   │   ├── job/              # Job postings + search
│   │   ├── application/      # Job applications
│   │   ├── interview/        # Interview scheduling
│   │   ├── notification/     # Push notifications (FCM)
│   │   ├── admin/            # Admin dashboards
│   │   ├── whatsapp/         # Deep link generation
│   │   └── common/           # Shared: entities, DTOs, exceptions
│   └── src/main/resources/
│       └── db/migration/     # Flyway SQL migrations
├── dentconnect_app/          # Flutter mobile app
├── admin-dashboard/          # React admin portal
├── docker-compose.yml
└── README.md
```

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter, Riverpod, GoRouter, Material 3 |
| Backend | Spring Boot 3.3, Java 21, Spring Security |
| Database | PostgreSQL 16, Flyway migrations |
| Auth | Firebase Auth → JWT + Refresh Tokens |
| Storage | Firebase Storage |
| Push | Firebase Cloud Messaging |
| Analytics | Firebase Analytics + Crashlytics |
| Admin | React, Vite, Material UI |
| Deploy | Docker Compose |

## API Documentation

After starting the backend, visit:
- Swagger UI: http://localhost:8080/swagger-ui
- OpenAPI JSON: http://localhost:8080/api-docs

## Database

25 normalized tables (3NF) with:
- UUID primary keys
- Soft deletes (deleted_at) on all entities
- PostgreSQL Full Text Search for jobs
- Flyway-managed migrations
- Audit logging

## Security

- Firebase Authentication (Google, Phone OTP, Email)
- JWT access tokens (15 min) + refresh tokens (7 days)
- Role-Based Access Control (7 roles)
- Rate limiting
- Input validation
- Audit logging
- CORS configuration
- Secure file uploads


## License

Proprietary — DentConnect Team
