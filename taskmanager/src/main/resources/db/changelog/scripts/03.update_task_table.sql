--failOnError=false
-- Add assigned_user_id column
ALTER TABLE task
ADD COLUMN "assigned_user_id" INTEGER;

-- Add foreign key constraint
ALTER TABLE task
ADD CONSTRAINT fk_task_user
FOREIGN KEY ("assigned_user_id")
REFERENCES task_user("id")
ON DELETE SET NULL;

-- Add index for performance on the foreign key
CREATE INDEX idx_task_assigned_user ON task("assigned_user_id");