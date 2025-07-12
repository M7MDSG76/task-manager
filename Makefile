# Task Manager Docker Makefile
# Use this for easier command execution

.PHONY: help dev dev-full start prod stop restart cleanup logs status backup restore health build

# Default target
help: ## Show this help message
	@echo "Task Manager Docker Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make dev             # Start development infrastructure"
	@echo "  make logs service=backend  # Show backend logs"
	@echo "  make backup          # Create database backup"

# Environment setup
setup: ## Setup environment files
	@if [ ! -f .env ]; then cp .env.template .env; echo "Created .env file from template"; fi

# Development targets
dev: setup ## Start development infrastructure only (PostgreSQL + Keycloak)
	docker-compose -f docker-compose.dev.yml up -d postgres keycloak
	@echo "Development infrastructure started. Run backend/frontend locally."

dev-full: setup ## Start full development environment in containers
	docker-compose -f docker-compose.dev.yml --profile dev-backend --profile dev-frontend up -d

# Production targets
start: setup ## Start standard environment
	docker-compose up -d --build

prod: setup ## Start production environment
	@if [ ! -f .env ]; then echo "Please create .env file first"; exit 1; fi
	docker-compose -f docker-compose.prod.yml up -d --build

# Management targets
stop: ## Stop all services
	docker-compose down 2>/dev/null || true
	docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
	docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

restart: stop start ## Restart all services

cleanup: ## Remove all containers, networks, and volumes (⚠️  DATA LOSS)
	@echo "⚠️  This will delete all data! Press Ctrl+C to cancel..."
	@sleep 5
	docker-compose down -v 2>/dev/null || true
	docker-compose -f docker-compose.dev.yml down -v 2>/dev/null || true
	docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true
	docker system prune -f

# Monitoring targets
logs: ## Show logs for all services or specific service (use service=name)
ifdef service
	docker-compose logs -f $(service)
else
	docker-compose logs -f
endif

status: ## Show service status and resource usage
	@echo "=== Service Status ==="
	docker-compose ps 2>/dev/null || echo "No services running"
	@echo ""
	@echo "=== Resource Usage ==="
	docker stats --no-stream 2>/dev/null || echo "No containers running"

health: ## Check service health
	@echo "Checking service health..."
	@curl -f -s http://localhost:8084/task-management/actuator/health > /dev/null && echo "✅ Backend healthy" || echo "❌ Backend unhealthy"
	@curl -f -s http://localhost:5174 > /dev/null && echo "✅ Frontend healthy" || echo "❌ Frontend unhealthy"
	@curl -f -s http://localhost:8080/realms/master > /dev/null && echo "✅ Keycloak healthy" || echo "❌ Keycloak unhealthy"
	@docker-compose exec -T postgres pg_isready -U postgres > /dev/null && echo "✅ Database healthy" || echo "❌ Database unhealthy"

# Database targets
backup: ## Create database backup
	@backup_file="backup-$$(date +%Y%m%d-%H%M%S).sql"; \
	docker-compose exec -T postgres pg_dump -U postgres task_manager > "$$backup_file"; \
	echo "Database backup created: $$backup_file"

restore: ## Restore database from backup (use file=backup.sql)
ifndef file
	@echo "Please specify backup file: make restore file=backup.sql"
else
	@echo "⚠️  This will replace all data! Press Ctrl+C to cancel..."
	@sleep 5
	docker-compose exec -T postgres psql -U postgres task_manager < $(file)
	@echo "Database restored from $(file)"
endif

# Build targets
build: ## Build all Docker images
	docker-compose build --no-cache

build-backend: ## Build backend Docker image
	docker-compose build --no-cache backend

build-frontend: ## Build frontend Docker image
	docker-compose build --no-cache frontend

# Development helpers
shell-backend: ## Open shell in backend container
	docker-compose exec backend sh

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend sh

shell-db: ## Open PostgreSQL shell
	docker-compose exec postgres psql -U postgres task_manager

# URL shortcuts
urls: ## Show service URLs
	@echo "🌐 Frontend:        http://localhost:3000"
	@echo "🔧 Backend API:     http://localhost:8084/task-management/api/v1"
	@echo "🔐 Keycloak Admin:  http://localhost:8080/admin (admin/admin123)"
	@echo "🗄️  Database:       localhost:5432 (postgres/postgres)"

# Clean targets
clean-images: ## Remove task manager Docker images
	docker rmi $$(docker images -q "task-manager-*" 2>/dev/null) 2>/dev/null || true

clean-volumes: ## Remove all Docker volumes (⚠️  DATA LOSS)
	@echo "⚠️  This will delete all data! Press Ctrl+C to cancel..."
	@sleep 5
	docker volume prune -f

# Advanced targets
update: ## Pull latest images and restart
	docker-compose pull
	$(MAKE) restart

scale-backend: ## Scale backend service (use replicas=N)
ifndef replicas
	@echo "Please specify replicas: make scale-backend replicas=2"
else
	docker-compose up -d --scale backend=$(replicas)
endif
