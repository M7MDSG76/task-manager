# Task Management Application - System Design Document

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Database Design](#database-design)
4. [API Design](#4. **React Frontend** (Nginx + React build)
   - Port: 5174
   - Production optimized build-design)
5. [Authentication & Security](#authentication--security)
6. [Technology Stack](#technology-stack)
7. [Deployment](#deployment)

## Overview

The Task Management Application (TAM) is a simple web-based system that allows users to manage tasks with secure authentication. Users can create, edit, delete, and view tasks with filtering capabilities.

### Core Features
- **User Authentication**: Keycloak-based secure login with user registration
- **Task Management**: Create, read, update, delete tasks with search functionality  
- **Task Properties**: Title, description, priority (Low/Medium/High), status (Pending/In-Progress/Completed)
- **Advanced Features**: Filter by priority/status, text search, pagination, auto-timestamps
- **User Management**: Auto-group assignment, role-based access via Keycloak
- **Modern UI**: React-based frontend with Tailwind CSS and responsive design

### Project Scope
This is a focused implementation covering the essential features for task management with proper authentication, following standard web application patterns.

## System Architecture

### Architecture Pattern
The application follows a simple **3-Layer Architecture**:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │    Database     │
│                 │◄──►│                 │◄──►│                 │
│ React + Vite    │    │ Spring Boot API │    │  PostgreSQL     │
│ (Port 5174)     │    │ (Port 8084)     │    │  (Port 5433)    │
│                 │    │                 │    │                 │
│ - Task Forms    │    │ - REST APIs     │    │ - task_user     │
│ - Auth Pages    │    │ - JWT Security  │    │ - task          │
│ - Search & List │    │ - Search Logic  │    │ - Indexes       │
│ - Filters       │    │ - Pagination    │    │ - Timestamps    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │
          └───────────────────────┼───────── Authentication via JWT
                                  │
                        ┌─────────────────┐
                        │   Keycloak      │
                        │ Auth Server     │
                        │ (Port 8080)     │
                        │                 │
                        │ - Realm Import  │
                        │ - User Reg      │
                        │ - Auto Groups   │
                        │ - Role Mgmt     │
                        └─────────────────┘
```
                        └─────────────────┘


### Components
1. **React Frontend**: User interface for task management
2. **Spring Boot Backend**: REST API with business logic
3. **PostgreSQL Database**: Data persistence
4. **Keycloak**: Authentication and user management
5. **Docker**: Containerization for easy deployment

## Database Design

### Entity Relationship Diagram

```
┌─────────────────────┐         ┌─────────────────────┐
│     task_user       │         │        task         │
├─────────────────────┤         ├─────────────────────┤
│ id (PK)            │◄────────┤ id (PK)            │
│ user_name          │   1:N   │ title              │
│ keycloak_user_id   │         │ description        │
└─────────────────────┘         │ priority           │
                                │ status             │
                                │ assigned_user_id(FK)│
                                └─────────────────────┘
```

### Database Schema

#### Users Table (`task_user`)
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | User identifier |
| user_name | VARCHAR(255) | UNIQUE | Username |
| keycloak_user_id | VARCHAR(400) | NOT NULL, UNIQUE | Keycloak ID |

#### Tasks Table (`task`)
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Task identifier |
| title | VARCHAR(155) | NOT NULL | Task title |
| description | VARCHAR(255) | NULL | Task description |
| priority | VARCHAR(10) | NOT NULL | LOW, MEDIUM, HIGH |
| status | VARCHAR(10) | NOT NULL | PENDING, IN_PROGRESS, COMPLETED |
| assigned_user_id | INTEGER | FOREIGN KEY | User assignment |

#### Relationships
- One user can have multiple tasks (1:N)
- Foreign key constraint: `task.assigned_user_id` → `task_user.id`

## API Design

### RESTful Endpoints

**Base URL**: `http://localhost:8084/task-management/api/v1`

| Method | Endpoint | Description | Parameters |
|--------|----------|-------------|------------|
| GET | `/tasks` | Get filtered tasks | `priority`, `status`, `pageSize`, `pageNumber` |
| GET | `/tasks/search` | Search tasks by text | `search`, `pageSize`, `pageNumber` |
| POST | `/tasks` | Create new task | Form data: `title`, `description`, `priority`, `status` |
| PUT | `/tasks` | Update task | Form data: `taskId`, `title`, `description`, `priority`, `status` |
| DELETE | `/tasks` | Delete task | Query param: `taskId` |

### Request/Response Examples

**Get Tasks with Filter**
```
GET /api/v1/tasks?priority=HIGH&status=PENDING&pageSize=10&pageNumber=0

Response: 200 OK
[
  {
    "id": 1,
    "title": "Complete documentation",
    "description": "Write system documentation",
    "priority": "HIGH",
    "status": "PENDING"
  }
]
```

**Create Task**
```
POST /api/v1/tasks
Content-Type: application/x-www-form-urlencoded

title=New Task&description=Task description&priority=MEDIUM&status=PENDING

Response: 200 OK
{
  "taskId": 15
}
```

## Authentication & Security

### JWT Authentication Flow
1. User logs in through Keycloak
2. Keycloak issues JWT token
3. Frontend includes token in API requests
4. Backend validates token and processes request

### Security Features
- **JWT Tokens**: Stateless authentication
- **OAuth2 Resource Server**: Spring Security integration
- **CORS Configuration**: Cross-origin request handling
- **Method Security**: Endpoint protection with annotations

### Token Structure
```
Authorization: Bearer <JWT_TOKEN>
```

The JWT contains user information and roles for authorization.

## Technology Stack

### Frontend
- **Framework**: React 18 with Vite
- **Styling**: Tailwind CSS
- **Authentication**: Keycloak JS adapter
- **HTTP Client**: Fetch API
- **Build Tool**: Vite

### Backend
- **Framework**: Spring Boot 3.x
- **Language**: Java 19
- **Security**: Spring Security with OAuth2
- **Database**: Spring Data JPA
- **Build Tool**: Maven

### Database
- **RDBMS**: PostgreSQL 16
- **Migrations**: Liquibase

### Authentication
- **Identity Provider**: Keycloak 26.3.1
- **Protocol**: OAuth2 / OIDC
- **Tokens**: JWT

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Web Server**: Nginx (for React app)

## Deployment

### Docker Setup

The application runs in 4 Docker containers:

1. **PostgreSQL** (`postgres:16-alpine`)
   - Port: 5433 (external), 5432 (internal)
   - Volume: Database persistence
   - Database: `task_manager`

2. **Keycloak** (`quay.io/keycloak/keycloak:26.3.1`)
   - Port: 8080
   - Realm: Auto-imported on startup with user registration
   - Default groups and roles configured

3. **Backend** (Custom Spring Boot image)
   - Port: 8084
   - JWT validation with Keycloak
   - HikariCP connection pool optimization

4. **Frontend** (React + Vite dev server)
   - Port: 5174 (external), 5173 (internal)
   - Development optimized with hot reload

### Startup Sequence
```
postgres → keycloak → backend-dev → frontend-dev
```

### Environment Setup
```bash
# Start all services (development environment)
docker-compose -f docker-compose.dev.yml up -d

# Access points
Frontend: http://localhost:5174
Backend API: http://localhost:8084/task-management/api/v1
Keycloak: http://localhost:8080
Database: localhost:5433 (postgres/postgres, DB: task_manager)
```

### Development vs Production
- **Development**: Uses `docker-compose.dev.yml` with hot reload (current working setup)
- **Production**: Uses `docker-compose.yml` with optimized builds (requires configuration)

---

**Document Version**: 1.1  
**Last Updated**: July 12, 2025  
**Project**: Task Management Application  
**Current Status**: All services operational in development environment

## Current Implementation Status

✅ **Completed Features:**
- Full authentication system with Keycloak integration
- Task CRUD operations with REST API endpoints
- Search functionality with dedicated `/tasks/search` endpoint
- User registration with automatic group assignment
- PostgreSQL database with proper schema and relationships
- Docker containerization with development environment
- Frontend React application with modern UI components
- Backend Spring Boot with security and database optimization

✅ **Architecture Validated:**
- 4-container Docker setup working successfully
- JWT authentication flow functional
- Database connections and queries verified
- Cross-origin requests properly configured
- Service dependencies and startup sequence established

🔄 **Current Environment**: Development mode with docker-compose.dev.yml
