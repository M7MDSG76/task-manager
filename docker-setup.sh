#!/bin/bash

# Task Manager Docker Setup Script
# This script helps you set up and manage the Task Manager application

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check available ports
    PORTS=(5174 5432 8080 8084)
    for port in "${PORTS[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
            print_warning "Port $port is already in use. This may cause conflicts."
        fi
    done
    
    print_success "Prerequisites check completed"
}

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    if [ ! -f .env ]; then
        print_status "Creating .env file from template..."
        cp .env.template .env
        print_warning "Please edit .env file with your configuration before running in production"
    else
        print_success ".env file already exists"
    fi
}

# Function to start development environment
start_dev() {
    print_status "Starting development environment..."
    check_prerequisites
    setup_environment
    
    print_status "Starting infrastructure services (PostgreSQL and Keycloak)..."
    docker-compose -f docker-compose.dev.yml up -d postgres keycloak
    
    print_status "Waiting for services to be healthy..."
    sleep 30
    
    print_success "Development infrastructure is ready!"
    print_status "You can now run the backend and frontend locally:"
    echo "  Backend: cd taskmanager && ./mvnw spring-boot:run -Dspring-boot.run.profiles=docker"
    echo "  Frontend: cd task-app && npm install && npm run dev"
}

# Function to start full development environment
start_dev_full() {
    print_status "Starting full development environment with containers..."
    check_prerequisites
    setup_environment
    
    docker-compose -f docker-compose.dev.yml --profile dev-backend --profile dev-frontend up -d
    
    print_status "Waiting for services to be healthy..."
    sleep 60
    
    print_success "Full development environment is ready!"
    show_urls
}

# Function to start production environment
start_prod() {
    print_status "Starting production environment..."
    check_prerequisites
    setup_environment
    
    if [ ! -f .env ]; then
        print_error "Please create and configure .env file before running production environment"
        exit 1
    fi
    
    print_status "Building and starting production services..."
    docker-compose -f docker-compose.prod.yml up -d --build
    
    print_status "Waiting for services to be healthy..."
    sleep 90
    
    print_success "Production environment is ready!"
    show_urls_prod
}

# Function to start standard environment
start_standard() {
    print_status "Starting standard environment..."
    check_prerequisites
    setup_environment
    
    docker-compose up -d --build
    
    print_status "Waiting for services to be healthy..."
    sleep 60
    
    print_success "Standard environment is ready!"
    show_urls
}

# Function to show service URLs
show_urls() {
    echo ""
    print_success "Services are available at:"
    echo "  🌐 Frontend:        http://localhost:3000"
    echo "  🔧 Backend API:     http://localhost:8084/task-management/api/v1"
    echo "  🔐 Keycloak Admin:  http://localhost:8080/admin (admin/admin123)"
    echo "  🗄️  Database:       localhost:5432 (postgres/postgres)"
    echo ""
}

# Function to show production URLs
show_urls_prod() {
    echo ""
    print_success "Production services are available at:"
    echo "  🌐 Frontend:        http://localhost (port 80)"
    echo "  🔧 Backend API:     http://localhost:8084/task-management/api/v1"
    echo "  🔐 Keycloak Admin:  https://localhost:8443/admin"
    echo "  🗄️  Database:       Internal network only"
    echo ""
}

# Function to stop services
stop_services() {
    print_status "Stopping services..."
    
    # Stop all possible compose files
    docker-compose down 2>/dev/null || true
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    print_success "Services stopped"
}

# Function to clean up everything
cleanup() {
    print_warning "This will remove all containers, networks, and volumes. Data will be lost!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        
        stop_services
        docker-compose down -v 2>/dev/null || true
        docker-compose -f docker-compose.dev.yml down -v 2>/dev/null || true
        docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true
        
        # Remove images
        docker rmi $(docker images -q task-manager-* 2>/dev/null) 2>/dev/null || true
        
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$service"
    fi
}

# Function to show status
show_status() {
    print_status "Service status:"
    docker-compose ps 2>/dev/null || docker-compose -f docker-compose.dev.yml ps 2>/dev/null || docker-compose -f docker-compose.prod.yml ps 2>/dev/null || echo "No running services found"
    
    echo ""
    print_status "Resource usage:"
    docker stats --no-stream 2>/dev/null || echo "No running containers"
}

# Function to backup database
backup_db() {
    local backup_file="backup-$(date +%Y%m%d-%H%M%S).sql"
    print_status "Creating database backup: $backup_file"
    
    docker-compose exec -T postgres pg_dump -U postgres task_manager > "$backup_file"
    print_success "Database backup created: $backup_file"
}

# Function to restore database
restore_db() {
    local backup_file=$1
    if [ -z "$backup_file" ]; then
        print_error "Please provide backup file path"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_warning "This will replace all data in the database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring database from: $backup_file"
        docker-compose exec -T postgres psql -U postgres task_manager < "$backup_file"
        print_success "Database restored"
    else
        print_status "Restore cancelled"
    fi
}

# Function to show help
show_help() {
    echo "Task Manager Docker Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  dev                 Start development infrastructure only (recommended for development)"
    echo "  dev-full           Start full development environment in containers"
    echo "  start              Start standard environment"
    echo "  prod               Start production environment"
    echo "  stop               Stop all services"
    echo "  restart            Restart all services"
    echo "  cleanup            Remove all containers, networks, and volumes"
    echo "  logs [service]     Show logs for all services or specific service"
    echo "  status             Show service status and resource usage"
    echo "  backup             Create database backup"
    echo "  restore <file>     Restore database from backup file"
    echo "  health             Check service health"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev             # Start development infrastructure"
    echo "  $0 logs backend    # Show backend logs"
    echo "  $0 backup          # Create database backup"
    echo "  $0 restore backup-20241212-120000.sql"
    echo ""
}

# Function to check health
check_health() {
    print_status "Checking service health..."
    
    # Check if services are running
    if ! docker-compose ps | grep -q "Up"; then
        print_error "No services are running"
        return 1
    fi
    
    # Check backend health
    if curl -f -s http://localhost:8084/task-management/actuator/health > /dev/null; then
        print_success "Backend is healthy"
    else
        print_error "Backend health check failed"
    fi
    
    # Check frontend
    if curl -f -s http://localhost:3000 > /dev/null; then
        print_success "Frontend is healthy"
    else
        print_error "Frontend health check failed"
    fi
    
    # Check Keycloak
    if curl -f -s http://localhost:8080/realms/master > /dev/null; then
        print_success "Keycloak is healthy"
    else
        print_error "Keycloak health check failed"
    fi
    
    # Check database
    if docker-compose exec -T postgres pg_isready -U postgres > /dev/null; then
        print_success "Database is healthy"
    else
        print_error "Database health check failed"
    fi
}

# Main script logic
case "${1:-help}" in
    dev)
        start_dev
        ;;
    dev-full)
        start_dev_full
        ;;
    start)
        start_standard
        ;;
    prod)
        start_prod
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        sleep 5
        start_standard
        ;;
    cleanup)
        cleanup
        ;;
    logs)
        show_logs "$2"
        ;;
    status)
        show_status
        ;;
    backup)
        backup_db
        ;;
    restore)
        restore_db "$2"
        ;;
    health)
        check_health
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
