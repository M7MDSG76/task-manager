# Task Manager - Docker Setup

This repository contains a complete task management application with Docker containerization support.

## Architecture

The application consists of:
- **Frontend**: React 18 application with Vite development server (Port 5174)
- **Backend**: Spring Boot 3.5.3 REST API with OpenJDK 19 (Port 8084)
- **Database**: PostgreSQL 16-alpine (Port 5433 external, 5432 internal)
- **Authentication**: Keycloak 26.3.1 with auto-realm import (Port 8080)

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM available for Docker

## Quick Start

1. **Clone the repository and navigate to the project directory:**
   ```bash
   cd TAM
   ```

2. **Start all services using Docker Compose:**
   ```bash
   # For development environment (current working setup)
   docker-compose -f docker-compose.dev.yml up -d
   
   # Alternative: For production environment (if configured)
   docker-compose up -d
   ```

3. **Wait for all services to be healthy (approximately 2-3 minutes):**
   ```bash
   docker-compose -f docker-compose.dev.yml ps
   ```

4. **Access the applications:**
   - Frontend: http://localhost:5174
   - Backend API: http://localhost:8084/task-management/api/v1
   - Backend Health: http://localhost:8084/task-management/actuator/health
   - Keycloak Admin: http://localhost:8080/admin (admin/admin123)
   - Database: localhost:5433 (postgres/postgres, DB: task_manager)

## Authentication & User Management

### Keycloak Configuration
- **Realm**: `task-maneger-realm` (auto-imported)
- **Client**: `t-m-client` for frontend authentication
- **User Registration**: Enabled for new user signup
- **Default Group**: `default_group` with `manage_task` role
- **Auto Assignment**: All new users automatically added to default_group

### Default Credentials

**Keycloak Admin Console:**
- Username: `admin`
- Password: `admin123`
- URL: http://localhost:8080/admin

**Application Access:**
- Users can register directly through the application
- All registered users automatically get task management permissions
- No pre-configured test users - register as needed

## Services Overview

### Frontend (React + Vite)
- **Container**: `task-manager-frontend-dev`
- **Port**: 5174 (external) → 5173 (internal)
- **Technology**: React 18, Vite dev server, Tailwind CSS
- **Authentication**: Keycloak integration with keycloak-js
- **Features**: Hot reload, source maps, development optimization
- **Node.js**: 22.17.0-alpine

### Backend (Spring Boot)
- **Container**: `task-manager-backend-dev`
- **Port**: 8084
- **Technology**: Spring Boot 3.5.3, Spring Security OAuth2, HikariCP
- **Database**: PostgreSQL with JPA/Hibernate
- **Features**: DevTools enabled, JWT validation, connection pooling
- **Java**: OpenJDK 19-alpine

### Database (PostgreSQL) 
- **Container**: `task-manager-postgres-dev`
- **Port**: 5433 (external) → 5432 (internal)
- **Version**: PostgreSQL 16-alpine
- **Database**: `task_manager`
- **Credentials**: postgres/postgres
- **Features**: Health checks, volume persistence, init scripts

### Authentication (Keycloak)
- **Container**: `task-manager-keycloak-dev`
- **Port**: 8080
- **Version**: Keycloak 26.3.1 
- **Admin Console**: http://localhost:8080/admin
- **Realm**: `task-maneger-realm` (auto-imported)
- **Features**: User registration, default groups, role assignment

## Development Commands

### View logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f backend-dev
docker-compose -f docker-compose.dev.yml logs -f frontend-dev
docker-compose -f docker-compose.dev.yml logs -f postgres
docker-compose -f docker-compose.dev.yml logs -f keycloak
```

### Restart services
```bash
# Restart all
docker-compose -f docker-compose.dev.yml restart

# Restart specific service
docker-compose -f docker-compose.dev.yml restart backend-dev
```

### Rebuild and restart
```bash
# Rebuild all images
docker-compose -f docker-compose.dev.yml build --no-cache

# Rebuild and restart
docker-compose -f docker-compose.dev.yml up --build -d
```

### Stop services
```bash
# Stop all services
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (⚠️ This will delete all data)
docker-compose -f docker-compose.dev.yml down -v
```

## Health Checks

All services include health checks:

```bash
# Check service health
docker-compose -f docker-compose.dev.yml ps

# Backend health endpoint
curl http://localhost:8084/task-management/actuator/health

# Database connection test
docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U postgres
```

## Database Access

Connect to PostgreSQL:
```bash
# Using Docker
docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d task_manager

# Using external client
Host: localhost
Port: 5433
Database: task_manager
Username: postgres
Password: postgres
```

## Keycloak Configuration

### Admin Access
- URL: http://localhost:8080
- Username: admin
- Password: admin123

### Realm Configuration
- Realm: `task-maneger-realm`
- Client ID: `t-m-client`
- The realm is automatically imported with pre-configured users and settings

## API Documentation

### Task Management Endpoints
- **Base URL**: http://localhost:8084/task-management/api/v1
- **Authentication**: Required (JWT Bearer token from Keycloak)

Key endpoints:
- `GET /tasks` - List tasks with filtering and pagination
- `POST /tasks` - Create new task
- `PUT /tasks` - Update task
- `DELETE /tasks` - Delete task

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 5174, 8080, 8084, and 5433 are available
2. **Memory issues**: Increase Docker memory allocation to at least 4GB
3. **Startup timeout**: Services may take 2-3 minutes to fully initialize

### Reset everything
```bash
# Stop and remove all containers, networks, and volumes
docker-compose -f docker-compose.dev.yml down -v
docker system prune -f

# Restart
docker-compose -f docker-compose.dev.yml up -d
```

### Check service status
```bash
# View detailed service information
docker-compose -f docker-compose.dev.yml ps
docker-compose -f docker-compose.dev.yml top

# Check resource usage
docker stats
```

## Production Considerations

For production deployment, consider:

1. **Environment Variables**: Use Docker secrets or external config management
2. **SSL/TLS**: Configure HTTPS for all services
3. **Resource Limits**: Set appropriate CPU and memory limits
4. **Monitoring**: Add monitoring and logging solutions
5. **Backup**: Implement database backup strategies
6. **Security**: Review and harden security configurations

## File Structure

```
TAM/
├── docker-compose.dev.yml       # Development orchestration file (current working setup)
├── docker-compose.yml           # Production orchestration file
├── init-db.sql                  # Database initialization
├── keycloak-config/            # Keycloak realm configuration
│   └── task-maneger-realm-realm.json
├── task-app/                   # React frontend
│   ├── Dockerfile.dev          # Development Docker image
│   ├── .dockerignore
│   ├── nginx.conf
│   └── .env.docker
└── taskmanager/                # Spring Boot backend
    ├── Dockerfile
    ├── .dockerignore
    └── src/main/resources/
        └── application-docker.properties
```

## Support

For issues or questions:
1. Check the logs: `docker-compose -f docker-compose.dev.yml logs -f [service-name]`
2. Verify all services are healthy: `docker-compose -f docker-compose.dev.yml ps`
3. Check network connectivity between services
4. Review the configuration files for any environment-specific changes needed

---

**Document Status**: Updated for current working environment  
**Last Updated**: July 12, 2025  
**Current Setup**: Development environment (docker-compose.dev.yml)

## ✅ Verified Working Status

All services are currently operational and tested:
- **PostgreSQL**: Database accessible and healthy
- **Keycloak**: Realm imported, user registration working
- **Backend**: All APIs functional, JWT validation working
- **Frontend**: React app with search and CRUD operations
- **Integration**: End-to-end authentication and task management confirmed
