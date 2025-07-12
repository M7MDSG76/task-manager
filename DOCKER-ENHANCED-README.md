# Task Manager - Enhanced Docker Setup

A comprehensive Docker containerization setup for the Task Manager application with development, production, and management tools.

## 🏗️ Architecture

The application consists of four main services:
- **Frontend**: React application with Vite and TailwindCSS (Port 5174/80)
- **Backend**: Spring Boot REST API with OAuth2 (Port 8084)
- **Database**: PostgreSQL with Liquibase migrations (Port 5433)
- **Authentication**: Keycloak server (Port 8080/8443)

## 🚀 Quick Start

### Option 1: Using PowerShell Script (Windows)
```powershell
# Start development infrastructure
.\docker-setup.ps1 dev

# Start full environment
.\docker-setup.ps1 start

# Check status
.\docker-setup.ps1 status
```

### Option 2: Using Bash Script (Linux/Mac)
```bash
# Make script executable
chmod +x docker-setup.sh

# Start development infrastructure
./docker-setup.sh dev

# Start full environment
./docker-setup.sh start

# Check status
./docker-setup.sh status
```

### Option 3: Using Makefile
```bash
# Start development infrastructure
make dev

# Start full environment
make start

# Check status
make status
```

### Option 4: Direct Docker Compose
```bash
# Development environment
docker-compose -f docker-compose.dev.yml up -d

# Production environment
docker-compose up -d
```

## 📋 Prerequisites

- **Docker Desktop** 20.10+ with 4GB+ RAM allocated
- **Docker Compose** 2.0+
- **Available ports**: 5174, 5433, 8080, 8084
- **PowerShell** 5.1+ (Windows) or **Bash** (Linux/Mac)

## 🛠️ Setup Options

### 1. Development Setup (Recommended)

Start only infrastructure services and run backend/frontend locally:

```bash
# Using script
./docker-setup.sh dev

# Using Docker Compose
docker-compose -f docker-compose.dev.yml up -d postgres keycloak

# Run backend locally
cd taskmanager
./mvnw spring-boot:run -Dspring-boot.run.profiles=docker

# Run frontend locally
cd task-app
npm install && npm run dev
```

**Benefits:**
- Fast development with hot reloading
- Easy debugging and development
- Reduced resource usage

### 2. Full Containerized Development

Run everything in containers with development features:

```bash
# Using script
./docker-setup.sh dev-full

# Using Docker Compose
docker-compose -f docker-compose.dev.yml --profile dev-backend --profile dev-frontend up -d
```

**Features:**
- Hot reloading for frontend (volume mounted)
- Development profiles enabled
- Source code mounted for real-time changes

### 3. Production Environment

Optimized for production deployment:

```bash
# Copy and configure environment
cp .env.template .env
# Edit .env with production values

# Using script
./docker-setup.sh prod

# Using Docker Compose
docker-compose -f docker-compose.prod.yml up -d
```

**Features:**
- HTTPS support for Keycloak
- Resource limits and security hardening
- Production-optimized builds
- Health checks and monitoring

## 🔧 Management Commands

### Using Scripts

**PowerShell (Windows):**
```powershell
.\docker-setup.ps1 help                    # Show all commands
.\docker-setup.ps1 status                  # Service status
.\docker-setup.ps1 logs backend            # View backend logs
.\docker-setup.ps1 backup                  # Backup database
.\docker-setup.ps1 health                  # Health check
.\docker-setup.ps1 cleanup                 # Remove everything
```

**Bash (Linux/Mac):**
```bash
./docker-setup.sh help                     # Show all commands
./docker-setup.sh status                   # Service status
./docker-setup.sh logs backend             # View backend logs
./docker-setup.sh backup                   # Backup database
./docker-setup.sh health                   # Health check
./docker-setup.sh cleanup                  # Remove everything
```

### Using Makefile

```bash
make help                                   # Show all commands
make status                                 # Service status
make logs service=backend                   # View backend logs
make backup                                 # Backup database
make health                                 # Health check
make cleanup                                # Remove everything
```

## 🌐 Service URLs

### Development
- **Frontend**: http://localhost:5174 (development server)
- **Backend API**: http://localhost:8084/task-management/api/v1
- **Keycloak Admin**: http://localhost:8080/admin
- **Database**: localhost:5433

### Production
- **Frontend**: http://localhost (port 80) or https://localhost (port 443)
- **Backend API**: http://localhost:8084/task-management/api/v1
- **Keycloak Admin**: https://localhost:8443/admin
- **Database**: Internal network only

## 🔐 Default Credentials

| Service | Username | Password | Role |
|---------|----------|----------|------|
| Keycloak Admin | admin | admin123 | Administrator |
| Application User | admin | admin123 | Admin |
| Application User | user | user123 | User |
| Database | postgres | postgres | Database User |

**⚠️ Change these in production!**

## 📊 Monitoring & Health Checks

### Built-in Health Checks
All services include comprehensive health checks:
- **Backend**: `/actuator/health` endpoint
- **Database**: `pg_isready` command
- **Keycloak**: Realm endpoint check
- **Frontend**: HTTP response check

### Monitoring Commands
```bash
# Check all service health
./docker-setup.sh health

# View resource usage
docker stats

# Service status
./docker-setup.sh status

# View logs
./docker-setup.sh logs [service-name]
```

## 💾 Data Management

### Database Backup
```bash
# Create backup
./docker-setup.sh backup

# Restore from backup
./docker-setup.sh restore backup-20241212-120000.sql
```

### Volume Management
```bash
# List volumes
docker volume ls

# Backup volumes (manual)
docker run --rm -v task_manager_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .

# Restore volumes (manual)
docker run --rm -v task_manager_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres-backup.tar.gz -C /data
```

## 🔒 Security Configuration

### Environment Variables (.env file)
```bash
# Database Security
POSTGRES_USER=your_secure_user
POSTGRES_PASSWORD=your_secure_password_123!

# Keycloak Security
KEYCLOAK_ADMIN=your_admin_user
KEYCLOAK_ADMIN_PASSWORD=your_secure_admin_password_123!
KC_HOSTNAME=your.domain.com

# Application Settings
APP_ENV=production
```

### Production Security Checklist
- [ ] Change all default passwords
- [ ] Configure SSL certificates
- [ ] Set up firewall rules
- [ ] Configure reverse proxy (nginx)
- [ ] Enable HTTPS for all services
- [ ] Set up monitoring and logging
- [ ] Regular security updates
- [ ] Backup strategy implementation

## 🚨 Troubleshooting

### Common Issues

**1. Port Conflicts**
```bash
# Check port usage (Windows)
netstat -ano | findstr :8080

# Check port usage (Linux/Mac)
lsof -i :8080

# Solution: Stop conflicting services or change ports in docker-compose.yml
```

**2. Memory Issues**
```bash
# Check Docker memory usage
docker stats

# Solution: Increase Docker Desktop memory limit to 4GB+
```

**3. Database Connection Issues**
```bash
# Check database status
docker-compose exec postgres pg_isready -U postgres

# Check backend logs for connection errors
docker-compose logs backend | grep -i error

# Restart database service
docker-compose restart postgres
```

**4. Keycloak Import Issues**
```bash
# Check Keycloak logs
docker-compose logs keycloak

# Manual realm import
docker-compose exec keycloak /opt/keycloak/bin/kc.sh import --file /opt/keycloak/data/import/task-maneger-realm.json
```

**5. Frontend Build Issues**
```bash
# Clear npm cache
docker-compose exec frontend npm cache clean --force

# Rebuild frontend
docker-compose build --no-cache frontend
```

### Reset Everything
```bash
# Complete reset (⚠️ Data Loss)
./docker-setup.sh cleanup
docker system prune -a
```

## 📈 Performance Optimization

### Development
- Use infrastructure-only setup for fastest development
- Enable hot reloading with volume mounts
- Limit container resources appropriately

### Production
- Use multi-stage builds for smaller images
- Enable gzip compression in nginx
- Configure JVM memory settings
- Use production database configurations
- Implement caching strategies

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Deploy Task Manager
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: |
          cp .env.template .env
          # Configure production environment
          docker-compose -f docker-compose.prod.yml up -d --build
```

### Docker Build Commands
```bash
# Build all images
make build

# Build specific service
docker-compose build --no-cache backend

# Tag for registry
docker tag task-manager-backend:latest your-registry/task-manager-backend:v1.0.0
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Keycloak Docker Guide](https://www.keycloak.org/server/containers)
- [Spring Boot Docker Guide](https://spring.io/guides/topicals/spring-boot-docker/)
- [React Docker Best Practices](https://docs.docker.com/language/nodejs/build-images/)

## 🆘 Support

### Getting Help
1. **Check service logs**: `./docker-setup.sh logs [service]`
2. **Verify service health**: `./docker-setup.sh health`
3. **Check resource usage**: `./docker-setup.sh status`
4. **Review configuration**: Ensure .env file is properly configured
5. **Restart services**: `./docker-setup.sh restart`

### Common Commands Reference
```bash
# Quick status check
./docker-setup.sh status

# View all logs
./docker-setup.sh logs

# Health check
./docker-setup.sh health

# Backup data
./docker-setup.sh backup

# Reset everything
./docker-setup.sh cleanup
```
