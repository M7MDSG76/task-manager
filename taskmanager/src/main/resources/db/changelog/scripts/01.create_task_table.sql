-- Create the task table
--failOnError=false
CREATE TABLE task (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(155) NOT NULL,
    "description" VARCHAR(255),
    "priority" VARCHAR(10) NOT NULL,
    "status" VARCHAR(10) NOT NULL
    -- "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
