# Task Management 

A modern, full-stack task management system built with React, Spring Boot, PostgreSQL, and Keycloak authentication.

![Project Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![Frontend](**postgres** - PostgreSQL database
   - Port: 5433 (external), 5432 (internal)
   - Volume: `postgres_dev_data`
   - Database: `task_manager`
   - Health check: `pg_isready`

2. **keycloak** - Authentication server  
   - Port: 8080
   - Volume: `keycloak_dev_data`
   - Realm: Auto-imported with user registration enabled
   - Default groups: `default_group` with `manage_task` role

3. **backend-dev** - Spring Boot API
   - Port: 8084
   - Dependencies: postgres, keycloak
   - Features: JWT validation, HikariCP connection pool, DevTools

4. **frontend-dev** - React application
   - Port: 5174 (external), 5173 (internal) 
   - Dependencies: backend-dev
   - Features: Vite dev server, hot reload, Tailwind CSSbadge/Frontend-React%2018-blue)
![Backend](https://img.shields.io/badge/Backend-Spring%20Boot%203.5-green)
![Database](https://img.shields.io/badge/Database-PostgreSQL%2016-blue)
![Authentication](https://img.shields.io/badge/Auth-Keycloak%2026.3.1-red)

## 🚀 Features

### ✅ Implemented Features 

#### **User Authentication**
- ✅ Secure user registration and login via Keycloak
- ✅ JWT token-based authentication
- ✅ OAuth2/OIDC integration

#### **Task Management**
- ✅ Create, edit, delete, and view tasks
- ✅ Task properties: title, description, priority (Low/Medium/High), status (Pending/In-Progress/Completed)
- ✅ Advanced filtering by priority and status
- ✅ **Bonus**: Pagination and sorting

#### **API Design**
- ✅ RESTful APIs for all operations
- ✅ Comprehensive task CRUD operations

#### **Technical Requirements**
- ✅ Java with Spring Boot framework
- ✅ Clean, modular, and well-documented code
- ✅ React frontend with modern UI
- ✅ Forms for authentication and task management

#### **Database**
- ✅ PostgreSQL relational database
- ✅ Proper schema for user and task data

#### **DevOps**
- ✅ Docker containerization
- ✅ Docker Compose environment setup

#### **Documentation**
- ✅ System Design Document
- ✅ Database ERD

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │    Database     │
│                 │◄──►│                 │◄──►│                 │
│ React App       │    │ Spring Boot API │    │  PostgreSQL     │
│ (Port 5174)     │    │ (Port 8084)     │    │  (Port 5432)    │
│                 │    │                 │    │                 │
│ - Task Forms    │    │ - REST APIs     │    │ - User Table    │
│ - Auth Pages    │    │ - JWT Security  │    │ - Task Table    │
│ - Task List     │    │ - Business Logic│    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │
          └───────────────────────┼───────── Authentication via JWT
                                  │
                        ┌─────────────────┐
                        │   Keycloak      │
                        │ Auth Server     │
                        │ (Port 8080)     │
                        └─────────────────┘
```

## 🛠️ Technology Stack

### Frontend
- **Framework**: React 18 with Vite
- **Styling**: Tailwind CSS
- **Authentication**: Keycloak JS adapter
- **HTTP Client**: Axios
- **UI Components**: Radix UI
- **Icons**: Lucide React

### Backend
- **Framework**: Spring Boot 3.5.3
- **Language**: Java 19
- **Security**: Spring Security with OAuth2
- **Database**: Spring Data JPA with Hibernate
- **Migration**: Liquibase
- **Build Tool**: Maven

### Database
- **RDBMS**: PostgreSQL 16
- **Schema Management**: Liquibase migrations

### Authentication
- **Identity Provider**: Keycloak 26.3.1
- **Protocol**: OAuth2 / OIDC
- **Tokens**: JWT

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Web Server**: Nginx (for React app)
- **Networking**: Docker networks with service discovery

## 📋 Prerequisites

Before running this project, make sure you have the following installed:

- **Docker** (version 20.0 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Git** (for cloning the repository)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd task-manager
```

### 2. Start the Application

```bash
# Start all services (development environment)
docker-compose -f docker-compose.dev.yml up -d

# Check service status
docker-compose -f docker-compose.dev.yml ps
```

### 3. Access the Application
Use postman collection (![POSTMAN]([https://img.shields.io/badge/Backend-Spring%20Boot%203.5-green](https://www.postman.com/alghanmimo/task-manager-ws/collection/75xnrcn/taskmanager))) collection as all listed backend and authorization requests are prepared for testing.

Once all containers are running:
- **Frontend**: http://localhost:5174
- **Backend API**: http://localhost:8084/task-management/api/v1
- **Backend Health**: http://localhost:8084/task-management/actuator/health
- **Keycloak Admin**: http://localhost:8080/admin (admin/admin123)
- **Database**: localhost:5433 (postgres/postgres, database: task_manager)

### 4. Login Credentials

**Keycloak Admin:**
- Username: `admin`
- Password: `admin123`

**Application Users** (auto-created via Keycloak registration):
- Users register directly through the application
- All new users automatically assigned to `default_group` with `manage_task` role
- User registration is enabled in Keycloak

## 📖 API Documentation

### Base URL
```
http://localhost:8084/task-management/api/v1
```

### Endpoints

| Method | Endpoint | Description | Parameters |
|--------|----------|-------------|------------|
| GET | `/tasks` | Get all tasks with filtering | `priority`, `status`, `pageSize`, `pageNumber` |
| GET | `/tasks/search` | Search tasks by text | `search`, `pageSize`, `pageNumber` |
| POST | `/tasks` | Create new task | Form data: `title`, `description`, `priority`, `status` |
| PUT | `/tasks` | Update task | Form data: `taskId`, `title`, `description`, `priority`, `status` |
| DELETE | `/tasks` | Delete task | Query param: `taskId` |

### Database Access

**Connect to PostgreSQL via Docker:**
```bash
# Connect to the database container
docker exec -it task-manager-postgres-dev psql -U postgres -d task_manager

# View all tables
\dt

# View tasks
SELECT * FROM public.task;

# View users
SELECT * FROM public.task_user;

# View tasks with user info
SELECT t.id, t.title, t.priority, t.status, u.user_name 
FROM public.task t 
JOIN public.task_user u ON t.assigned_user_id = u.id;
```

**Database Connection Info:**
- Host: localhost
- Port: 5433
- Database: task_manager
- Username: postgres
- Password: postgres

**Create a new task:**
```bash
curl -X POST \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "title=New Task&description=Task description&priority=MEDIUM&status=PENDING" \
  "http://localhost:8084/task-management/api/v1/tasks"
```

## 🗄️ Database Schema

### Tables

#### task_user
| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL PRIMARY KEY | User identifier |
| user_name | VARCHAR(255) | Username |
| keycloak_user_id | VARCHAR(400) | Keycloak ID |

#### task
| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL PRIMARY KEY | Task identifier |
| title | VARCHAR(155) | Task title |
| description | VARCHAR(255) | Task description |
| priority | VARCHAR(10) | LOW, MEDIUM, HIGH |
| status | VARCHAR(10) | PENDING, IN_PROGRESS, COMPLETED |
| assigned_user_id | INTEGER | FOREIGN KEY | User assignment (FK to task_user.id) |
| created_at | TIMESTAMP | DEFAULT NOW() | Task creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Task last update timestamp |

### Relationships
- One user can have multiple tasks (1:N)
- Foreign key: `task.assigned_user_id` → `task_user.id`

## 🔧 Development Setup

### Development Environment

For development with hot reloading:

```bash
# Use development docker-compose (current working setup)
docker-compose -f docker-compose.dev.yml up -d

# Development service ports:
# - Frontend: http://localhost:5174
# - Backend: http://localhost:8084  
# - Keycloak: http://localhost:8080
# - PostgreSQL: localhost:5433
```

### Key Development Features

- **Frontend Hot Reload**: Changes in `task-app/src` automatically reload
- **Backend Hot Reload**: Spring Boot DevTools enabled for class reloading
- **Volume Mounts**: Source code mounted for live development
- **Separate Databases**: Development and production use isolated data
- **Debug Ports**: JVM debug port available for backend debugging

### Building Individual Services

**Backend:**
```bash
cd taskmanager
./mvnw clean package
docker build -t taskmanager:latest .
```

**Frontend:**
```bash
cd task-app
npm install
npm run build
docker build -t task-app:latest .
```

### Environment Variables

**Backend (Spring Boot):**
```properties
# Database (Development - Port 5433)
spring.datasource.url=jdbc:postgresql://postgres:5432/task_manager
spring.datasource.username=postgres
spring.datasource.password=postgres

# Keycloak Integration
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8080/realms/task-maneger-realm
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=http://keycloak:8080/realms/task-maneger-realm/protocol/openid-connect/certs

# HikariCP Connection Pool
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000
```

**Frontend (React/Vite):**
```javascript
// Environment variables
VITE_KC_URL=http://localhost:8080
VITE_KC_REALM=task-maneger-realm  
VITE_KC_CLIENT=t-m-client
VITE_API_BASE_URL=http://localhost:8084/task-management/api/v1
```

## 🐳 Docker Services

### Service Overview (Development Environment)

1. **postgres** - PostgreSQL database
   - Port: 5433 (external), 5432 (internal)
   - Volume: `postgres_dev_data`
   - Database: `task_manager`
   - Health check: `pg_isready`

2. **keycloak** - Authentication server  
   - Port: 8080
   - Volume: `keycloak_dev_data`
   - Realm: Auto-imported with user registration enabled
   - Default groups: `default_group` with `manage_task` role

3. **backend-dev** - Spring Boot API
   - Port: 8084
   - Dependencies: postgres, keycloak
   - Features: JWT validation, HikariCP connection pool, DevTools

4. **frontend-dev** - React application
   - Port: 5174 (external), 5173 (internal) 
   - Dependencies: backend-dev
   - Features: Vite dev server, hot reload, Tailwind CSS

### Health Checks

All services include health checks:
- **Database**: `pg_isready`
- **Keycloak**: TCP connection test
- **Backend**: Spring Actuator `/health`
- **Frontend**: HTTP response check

## 🔍 Monitoring & Logs

### View Service Logs

```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f backend-dev
docker-compose -f docker-compose.dev.yml logs -f frontend-dev
docker-compose -f docker-compose.dev.yml logs -f keycloak
docker-compose -f docker-compose.dev.yml logs -f postgres
```

### Health Check Status

```bash
# Check container health
docker-compose -f docker-compose.dev.yml ps

# Backend health endpoint
curl http://localhost:8084/task-management/actuator/health
```

## 🧪 Testing

### Backend Tests

```bash
cd taskmanager
./mvnw test
```

### API Testing

Use the provided Postman collection or test with curl:

```bash
# Health check
curl http://localhost:8084/actuator/health

# Get tasks (requires authentication)
curl -H "Authorization: Bearer <TOKEN>" \
  http://localhost:8084/task-management/api/v1/tasks
```

## 📁 Project Structure

```
task-manager/
├── task-app/                 # React Frontend
│   ├── src/
│   │   ├── components/       # UI Components
│   │   ├── features/         # Feature modules
│   │   ├── auth/            # Authentication
│   │   └── services/        # API services
│   ├── Dockerfile
│   └── package.json
├── taskmanager/             # Spring Boot Backend
│   ├── src/main/java/       # Java source code
│   ├── src/main/resources/  # Configuration & migrations
│   ├── Dockerfile
│   └── pom.xml
├── keycloak-config/         # Keycloak realm configuration
│   └── task-maneger-realm-realm.json
├── docker-compose.yml       # Production environment
├── docker-compose.dev.yml   # Development environment
├── init-db.sql             # Database initialization
├── System-Design-Document.md
├── Database-ERD.md
└── README.md
```

## 🚨 Troubleshooting

### Common Issues

**1. Containers fail to start**
```bash
# Check Docker daemon
docker --version

# Check port conflicts
netstat -tulpn | grep :8080
netstat -tulpn | grep :8084
netstat -tulpn | grep :5174
```

**2. Keycloak startup issues**
```bash
# Check Keycloak logs
docker-compose logs keycloak

# Restart Keycloak
docker-compose restart keycloak
```

**3. Database connection errors**
```bash
# Check PostgreSQL status
docker-compose exec postgres pg_isready -U postgres

# Reset database
docker-compose down -v
docker-compose up -d
```

**4. Authentication issues**
```bash
# Verify Keycloak realm import
docker-compose exec keycloak bash
# Check if realm is imported correctly
```

### Reset Everything

```bash
# Stop all services and remove volumes
docker-compose -f docker-compose.dev.yml down -v

# Remove all images (optional)
docker-compose -f docker-compose.dev.yml down --rmi all

# Start fresh
docker-compose -f docker-compose.dev.yml up -d
```

## 📈 Performance Considerations

- Database indexing on foreign keys and filter columns
- JWT stateless authentication for scalability
- Nginx for efficient static file serving
- Docker multi-stage builds for optimized images
- Connection pooling with HikariCP

## 🔒 Security Features

- OAuth2/OIDC authentication with Keycloak
- JWT token validation on all API endpoints
- CORS configuration for cross-origin requests
- SQL injection prevention with parameterized queries
- Environment-based configuration management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or issues:
1. Check the [troubleshooting section](#-troubleshooting)
2. Review the logs using `docker-compose logs`
3. Open an issue in the repository

---

**Project Status**: Production Ready ✅  
**Last Updated**: July 12, 2025  
**Version**: 1.0.0  
**Current Environment**: Development (docker-compose.dev.yml)

## 📋 Current Application Status

✅ **All Services Running Successfully:**
- PostgreSQL 16-alpine on port 5433 (healthy)
- Keycloak 26.3.1 on port 8080 with realm auto-import
- Spring Boot backend on port 8084 (healthy with JWT validation)
- React frontend on port 5174 with Vite dev server

✅ **Features Implemented:**
- User authentication via Keycloak with auto-registration
- Task CRUD operations with search functionality
- Advanced filtering (priority, status) and pagination
- Separate search endpoint (`/tasks/search`) for text search
- Auto-group assignment for new users (`default_group` with `manage_task` role)
- HikariCP connection pool optimization
- Docker containerization with development hot-reload

✅ **Database:**
- PostgreSQL with `task_user` and `task` tables
- Foreign key relationships established
- Timestamps for audit trail
- Database accessible via `docker exec` or external client

## 🎯 Next Steps for Production

1. **Production Environment**: Configure `docker-compose.yml` for production deployment
2. **SSL/HTTPS**: Add SSL certificates for secure communication
3. **Environment Variables**: Externalize secrets and configuration
4. **Monitoring**: Add logging and monitoring solutions
5. **Backup Strategy**: Implement database backup procedures
