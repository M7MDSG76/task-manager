## Entity Relationship Diagram created using draw.io

![Task Management Database ERD](/task_manager_erd_img.png)

```
Image shows the complete entity relationship diagram with:
- task_user table (left) with primary key and Keycloak integration
- task table (right) with foreign key relationship
- Visual connection line showing 1:N cardinality
- All columns, data types, and constraints clearly labeled
```
## Table Specifications

### task_user Table
**Purpose**: Stores user information integrated with Keycloak authentication

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Auto-incrementing user identifier |
| `user_name` | VARCHAR(255) | NULLABLE | Display username (can be null) |
| `keycloak_user_id` | VARCHAR(400) | NOT NULL, UNIQUE | Keycloak UUID identifier |
| `created_at` | TIMESTAMP | DEFAULT NOW() | User registration timestamp |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last profile update timestamp |

### task Table
**Purpose**: Stores task information with user assignment

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Auto-incrementing task identifier |
| `title` | VARCHAR(155) | NOT NULL | Task title (required) |
| `description` | VARCHAR(255) | NULLABLE | Optional task description |
| `priority` | VARCHAR(10) | NOT NULL | Task priority: LOW, MEDIUM, HIGH |
| `status` | VARCHAR(10) | NOT NULL | Task status: PENDING, IN_PROGRESS, COMPLETED |
| `assigned_user_id` | INTEGER | FOREIGN KEY | Reference to task_user.id |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Task creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last task update timestamp |

## Relationships

### One-to-Many: task_user → task
- **Cardinality**: One user can have multiple tasks (1:N)
- **Foreign Key**: `task.assigned_user_id` → `task_user.id`
- **Referential Integrity**: ON DELETE SET NULL (tasks remain if user is deleted)

## Sample Data

### task_user
| id | user_name | keycloak_user_id | created_at | updated_at |
|----|-----------|------------------|------------|------------|
| 1 | admin | a1b2c3d4-e5f6-7890-ab12-cd34ef567890 | 2025-07-12 10:00:00 | 2025-07-12 10:00:00 |
| 2 | john_doe | b2c3d4e5-f6g7-8901-bc23-de45fg678901 | 2025-07-12 11:30:00 | 2025-07-12 11:30:00 |

### task
| id | title | description | priority | status | assigned_user_id | created_at | updated_at |
|----|-------|-------------|----------|--------|------------------|------------|------------|
| 1 | Setup project | Initialize the task management system | HIGH | COMPLETED | 1 | 2025-07-12 10:15:00 | 2025-07-12 14:30:00 |
| 2 | Add search feature | Implement task search functionality | MEDIUM | COMPLETED | 1 | 2025-07-12 12:00:00 | 2025-07-12 15:00:00 |

## Database Access

### Connection Details (Development Environment)
- **Host**: localhost
- **Port**: 5433 (external), 5432 (internal)
- **Database**: task_manager
- **Username**: postgres
- **Password**: postgres

### Docker Access
```bash
# Connect to database via Docker
docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d task_manager

# Useful queries
\dt                          # List all tables
SELECT * FROM public.task;   # View all tasks
SELECT * FROM public.task_user; # View all users

# Join query to see tasks with user info
SELECT t.id, t.title, t.priority, t.status, u.user_name 
FROM public.task t 
JOIN public.task_user u ON t.assigned_user_id = u.id;
```

---

**Database Schema Version**: 1.0  
**Last Updated**: July 12, 2025  
**Status**: Active and verified working

## ✅ Database Verification

- **Tables Created**: `task_user` and `task` tables successfully created
- **Relationships**: Foreign key constraint working properly
- **Data Access**: Database accessible via Docker and external clients
- **Indexes**: Primary keys and foreign keys properly indexed
- **Timestamps**: Automatic timestamp management working
- **Integration**: Spring Boot JPA integration fully functional

## Current Database Statistics

Execute these queries to check current data:
```sql
-- Count total users
SELECT COUNT(*) FROM public.task_user;

-- Count total tasks
SELECT COUNT(*) FROM public.task;

-- Tasks by status
SELECT status, COUNT(*) as count 
FROM public.task 
GROUP BY status;

-- Tasks by priority
SELECT priority, COUNT(*) as count 
FROM public.task 
GROUP BY priority;
```
| 2 | Create user interface | Develop React components for task management | MEDIUM | IN_PROGRESS | 1 | 2025-07-12 10:20:00 | 2025-07-12 13:45:00 |
| 3 | Write documentation | Complete API and user documentation | LOW | PENDING | 2 | 2025-07-12 11:45:00 | 2025-07-12 11:45:00 |
| 4 | Test authentication | Verify Keycloak integration works properly | HIGH | PENDING | 2 | 2025-07-12 12:00:00 | 2025-07-12 12:00:00 |

---

**Document Version**: 2.0  
**Last Updated**: July 12, 2025  
**Database**: PostgreSQL 16-alpine  
**Project**: Task Management Application  
**Environment**: Docker containerized development setup

