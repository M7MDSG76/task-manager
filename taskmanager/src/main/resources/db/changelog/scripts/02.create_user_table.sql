
--failOnError=false
CREATE TABLE task_user(
    "id" SERIAL PRIMARY KEY,
    "user_name" VARCHAR(255) UNIQUE,
    "keycloak_user_id" VARCHAR(400) NOT NULL UNIQUE
);