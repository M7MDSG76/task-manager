# Task Manager Docker Setup Script for Windows
# PowerShell script to help manage the Task Manager application

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$Service = "",
    
    [Parameter(Position=2)]
    [string]$BackupFile = ""
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check Docker
    try {
        docker --version | Out-Null
    }
    catch {
        Write-Error "Docker is not installed or not in PATH. Please install Docker Desktop."
        exit 1
    }
    
    # Check Docker Compose
    try {
        docker-compose --version | Out-Null
    }
    catch {
        try {
            docker compose version | Out-Null
        }
        catch {
            Write-Error "Docker Compose is not available. Please ensure Docker Desktop is properly installed."
            exit 1
        }
    }
    
    # Check available ports
    $ports = @(5174, 5432, 8080, 8084)
    foreach ($port in $ports) {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            Write-Warning "Port $port is already in use. This may cause conflicts."
        }
    }
    
    Write-Success "Prerequisites check completed"
}

# Function to setup environment
function Initialize-Environment {
    Write-Status "Setting up environment..."
    
    if (-not (Test-Path ".env")) {
        Write-Status "Creating .env file from template..."
        Copy-Item ".env.template" ".env"
        Write-Warning "Please edit .env file with your configuration before running in production"
    }
    else {
        Write-Success ".env file already exists"
    }
}

# Function to start development environment
function Start-DevEnvironment {
    Write-Status "Starting development environment..."
    Test-Prerequisites
    Initialize-Environment
    
    Write-Status "Starting infrastructure services (PostgreSQL and Keycloak)..."
    docker-compose -f docker-compose.dev.yml up -d postgres keycloak
    
    Write-Status "Waiting for services to be healthy..."
    Start-Sleep -Seconds 30
    
    Write-Success "Development infrastructure is ready!"
    Write-Status "You can now run the backend and frontend locally:"
    Write-Host "  Backend: cd taskmanager; .\mvnw.cmd spring-boot:run `"-Dspring-boot.run.profiles=docker`""
    Write-Host "  Frontend: cd task-app; npm install; npm run dev"
}

# Function to start full development environment
function Start-DevFullEnvironment {
    Write-Status "Starting full development environment with containers..."
    Test-Prerequisites
    Initialize-Environment
    
    docker-compose -f docker-compose.dev.yml --profile dev-backend --profile dev-frontend up -d
    
    Write-Status "Waiting for services to be healthy..."
    Start-Sleep -Seconds 60
    
    Write-Success "Full development environment is ready!"
    Show-ServiceUrls
}

# Function to start production environment
function Start-ProdEnvironment {
    Write-Status "Starting production environment..."
    Test-Prerequisites
    Initialize-Environment
    
    if (-not (Test-Path ".env")) {
        Write-Error "Please create and configure .env file before running production environment"
        exit 1
    }
    
    Write-Status "Building and starting production services..."
    docker-compose -f docker-compose.prod.yml up -d --build
    
    Write-Status "Waiting for services to be healthy..."
    Start-Sleep -Seconds 90
    
    Write-Success "Production environment is ready!"
    Show-ProductionUrls
}

# Function to start standard environment
function Start-StandardEnvironment {
    Write-Status "Starting standard environment..."
    Test-Prerequisites
    Initialize-Environment
    
    docker-compose up -d --build
    
    Write-Status "Waiting for services to be healthy..."
    Start-Sleep -Seconds 60
    
    Write-Success "Standard environment is ready!"
    Show-ServiceUrls
}

# Function to show service URLs
function Show-ServiceUrls {
    Write-Host ""
    Write-Success "Services are available at:"
    Write-Host "  🌐 Frontend:        http://localhost:3000"
    Write-Host "  🔧 Backend API:     http://localhost:8084/task-management/api/v1"
    Write-Host "  🔐 Keycloak Admin:  http://localhost:8080/admin (admin/admin123)"
    Write-Host "  🗄️  Database:       localhost:5432 (postgres/postgres)"
    Write-Host ""
}

# Function to show production URLs
function Show-ProductionUrls {
    Write-Host ""
    Write-Success "Production services are available at:"
    Write-Host "  🌐 Frontend:        http://localhost (port 80)"
    Write-Host "  🔧 Backend API:     http://localhost:8084/task-management/api/v1"
    Write-Host "  🔐 Keycloak Admin:  https://localhost:8443/admin"
    Write-Host "  🗄️  Database:       Internal network only"
    Write-Host ""
}

# Function to stop services
function Stop-Services {
    Write-Status "Stopping services..."
    
    # Stop all possible compose files
    try { docker-compose down 2>$null } catch { }
    try { docker-compose -f docker-compose.dev.yml down 2>$null } catch { }
    try { docker-compose -f docker-compose.prod.yml down 2>$null } catch { }
    
    Write-Success "Services stopped"
}

# Function to clean up everything
function Remove-AllServices {
    Write-Warning "This will remove all containers, networks, and volumes. Data will be lost!"
    $response = Read-Host "Are you sure? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Status "Cleaning up..."
        
        Stop-Services
        try { docker-compose down -v 2>$null } catch { }
        try { docker-compose -f docker-compose.dev.yml down -v 2>$null } catch { }
        try { docker-compose -f docker-compose.prod.yml down -v 2>$null } catch { }
        
        # Remove images
        try {
            $images = docker images -q "task-manager-*" 2>$null
            if ($images) {
                docker rmi $images 2>$null
            }
        } catch { }
        
        Write-Success "Cleanup completed"
    }
    else {
        Write-Status "Cleanup cancelled"
    }
}

# Function to show logs
function Show-ServiceLogs {
    param([string]$ServiceName)
    
    if ([string]::IsNullOrEmpty($ServiceName)) {
        docker-compose logs -f
    }
    else {
        docker-compose logs -f $ServiceName
    }
}

# Function to show status
function Show-ServiceStatus {
    Write-Status "Service status:"
    try {
        docker-compose ps 2>$null
    }
    catch {
        try {
            docker-compose -f docker-compose.dev.yml ps 2>$null
        }
        catch {
            try {
                docker-compose -f docker-compose.prod.yml ps 2>$null
            }
            catch {
                Write-Host "No running services found"
            }
        }
    }
    
    Write-Host ""
    Write-Status "Resource usage:"
    try {
        docker stats --no-stream 2>$null
    }
    catch {
        Write-Host "No running containers"
    }
}

# Function to backup database
function Backup-Database {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = "backup-$timestamp.sql"
    Write-Status "Creating database backup: $backupFile"
    
    docker-compose exec -T postgres pg_dump -U postgres task_manager > $backupFile
    Write-Success "Database backup created: $backupFile"
}

# Function to restore database
function Restore-Database {
    param([string]$BackupFilePath)
    
    if ([string]::IsNullOrEmpty($BackupFilePath)) {
        Write-Error "Please provide backup file path"
        exit 1
    }
    
    if (-not (Test-Path $BackupFilePath)) {
        Write-Error "Backup file not found: $BackupFilePath"
        exit 1
    }
    
    Write-Warning "This will replace all data in the database!"
    $response = Read-Host "Are you sure? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Status "Restoring database from: $BackupFilePath"
        Get-Content $BackupFilePath | docker-compose exec -T postgres psql -U postgres task_manager
        Write-Success "Database restored"
    }
    else {
        Write-Status "Restore cancelled"
    }
}

# Function to check health
function Test-ServiceHealth {
    Write-Status "Checking service health..."
    
    # Check if services are running
    $runningServices = docker-compose ps | Select-String "Up"
    if (-not $runningServices) {
        Write-Error "No services are running"
        return
    }
    
    # Check backend health
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8084/task-management/actuator/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Backend is healthy"
        }
    }
    catch {
        Write-Error "Backend health check failed"
    }
    
    # Check frontend
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Frontend is healthy"
        }
    }
    catch {
        Write-Error "Frontend health check failed"
    }
    
    # Check Keycloak
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/realms/master" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Keycloak is healthy"
        }
    }
    catch {
        Write-Error "Keycloak health check failed"
    }
    
    # Check database
    try {
        $result = docker-compose exec -T postgres pg_isready -U postgres
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Database is healthy"
        }
    }
    catch {
        Write-Error "Database health check failed"
    }
}

# Function to show help
function Show-Help {
    Write-Host "Task Manager Docker Management Script (PowerShell)"
    Write-Host ""
    Write-Host "Usage: .\docker-setup.ps1 [command] [parameters]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  dev                 Start development infrastructure only (recommended for development)"
    Write-Host "  dev-full           Start full development environment in containers"
    Write-Host "  start              Start standard environment"
    Write-Host "  prod               Start production environment"
    Write-Host "  stop               Stop all services"
    Write-Host "  restart            Restart all services"
    Write-Host "  cleanup            Remove all containers, networks, and volumes"
    Write-Host "  logs [service]     Show logs for all services or specific service"
    Write-Host "  status             Show service status and resource usage"
    Write-Host "  backup             Create database backup"
    Write-Host "  restore <file>     Restore database from backup file"
    Write-Host "  health             Check service health"
    Write-Host "  help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\docker-setup.ps1 dev             # Start development infrastructure"
    Write-Host "  .\docker-setup.ps1 logs backend    # Show backend logs"
    Write-Host "  .\docker-setup.ps1 backup          # Create database backup"
    Write-Host "  .\docker-setup.ps1 restore backup-20241212-120000.sql"
    Write-Host ""
}

# Main script logic
switch ($Command.ToLower()) {
    "dev" {
        Start-DevEnvironment
    }
    "dev-full" {
        Start-DevFullEnvironment
    }
    "start" {
        Start-StandardEnvironment
    }
    "prod" {
        Start-ProdEnvironment
    }
    "stop" {
        Stop-Services
    }
    "restart" {
        Stop-Services
        Start-Sleep -Seconds 5
        Start-StandardEnvironment
    }
    "cleanup" {
        Remove-AllServices
    }
    "logs" {
        Show-ServiceLogs -ServiceName $Service
    }
    "status" {
        Show-ServiceStatus
    }
    "backup" {
        Backup-Database
    }
    "restore" {
        Restore-Database -BackupFilePath $Service
    }
    "health" {
        Test-ServiceHealth
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
