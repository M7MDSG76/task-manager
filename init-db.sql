-- Create additional database for Keycloak
SELECT 'CREATE DATABASE keycloak'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE task_manager TO postgres;
GRANT ALL PRIVILEGES ON DATABASE keycloak TO postgres;
