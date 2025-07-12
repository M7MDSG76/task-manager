package com.tam.taskmanager.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;
import com.tam.taskmanager.dto.task.TaskDTO;
import com.tam.taskmanager.service.SecurityService;
import com.tam.taskmanager.service.TaskService;
import com.tam.taskmanager.service.UserService;

import jakarta.annotation.security.RolesAllowed;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/v1")
@Slf4j
@PreAuthorize("@securityService.hasAccessToTasks(authentication)")
public class TaskManagerController {

    @Autowired
    private TaskService taskService;

    @Autowired
    private UserService userService;

    /**
     * This endpoint creates a new task in the task manager.
     * 
     * @param authentication the authentication object containing user details
     * @param title          the title of the task
     * @param description    the description of the task
     * @param priority       the priority of the task
     * @param status         the status of the task
     * @return ResponseEntity with created task
     * request example:
     * http://localhost:8084/task-management/api/v1/tasks?title=test task9&description=desc&priority=LOW&status=PENDING
     */
    @PostMapping("/tasks")
    public ResponseEntity<Long> createTask(@RequestParam String title, @RequestParam String description,
            @RequestParam String priority, @RequestParam String status, Authentication authentication) {
        try {
            log.info("Creating task with title: {}", title);
            final Long userId = userService.getUserId(authentication);
            log.info("user ID1: {}", userId);
            Long taskId = taskService.createTask(userId, title, description, priority, status);
            return ResponseEntity.ok(taskId);
        } catch (Exception e) {
            log.error("Error creating task: {}", e.getMessage());
            return ResponseEntity.status(500).body(null);
        }
    }

    /**
     * This endpoint retrieves all tasks from the task manager.
     * 
     * @return ResponseEntity with list of tasks
     *         request example: http://localhost:8084/task-management/api/v1/tasks
     */
    @GetMapping("/tasks")
    public ResponseEntity<List<TaskDTO>> getAllTasks(
            @RequestParam(required = false) String priority,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(defaultValue = "0") int pageNumber,
            Authentication authentication) {
        try {
            log.info("Fetching all tasks");
            List<TaskDTO> tasks = taskService.getAllTasks(priority, status, pageSize, pageNumber,
                    userService.getUserId(authentication)); // Default page size
            // is 10
            return ResponseEntity.ok(tasks);
        } catch (Exception e) {
            log.error("Error fetching tasks: {}", e.getMessage());
            return ResponseEntity.status(500).body(null);
        }

    }

        /**
     * This endpoint retrieves all tasks from the task manager.
     * 
     * @return ResponseEntity with list of tasks
     *         request example: http://localhost:8084/task-management/api/v1/tasks
     */
    @GetMapping("/tasks/search")
    public ResponseEntity<List<TaskDTO>> searchTasks(
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(defaultValue = "0") int pageNumber,
            Authentication authentication) {
        try {
            log.info("Fetching all tasks");
            List<TaskDTO> tasks = taskService.searchTasks(search, pageSize, pageNumber,
                    userService.getUserId(authentication)); // Default page size
            // is 10
            return ResponseEntity.ok(tasks);
        } catch (Exception e) {
            log.error("Error fetching tasks: {}", e.getMessage());
            return ResponseEntity.status(500).body(null);
        }

    }

    /**
     * This endpoint updates a task by its ID.
     * 
     * @param taskId      the ID of the task to update
     * @param title       the new title of the task
     * @param description the new description of the task
     * @param priority    the new priority of the task
     * @param status      the new status of the task
     * @return ResponseEntity with updated task
     *         request example:
     *         http://localhost:8084/task-management/api/v1/tasks?taskId=1&title=New%20Title&description=New%20Description&priority=HIGH&status=IN_PROGRESS
     */
    @PutMapping("/tasks")
    public ResponseEntity<TaskDTO> updateTask(@RequestParam Long taskId,
            @RequestParam String title,
            @RequestParam String description,
            @RequestParam String priority,
            @RequestParam String status,
            Authentication authentication) {
        try {
            final Long userId = userService.getUserId(authentication);
            log.info("Updating task with id: {}", taskId);
            TaskDTO updatedTask = taskService.updateTask(userId,taskId, title, description, priority, status);
            return ResponseEntity.ok(updatedTask);
        } catch (Exception e) {
            log.error("Error updating task: {}", e.getMessage());
            return ResponseEntity.status(500).body(null);
        }
    }


    /**
     * This endpoint deletes a task by its ID.
     * 
     * @param taskId the ID of the task to delete
     * @return ResponseEntity with deletion status
     *         request example: http://localhost:8084/task-management/api/v1/tasks?taskId=?taskId
     */
    @DeleteMapping("/tasks")
    public ResponseEntity<String> deleteTask(@RequestParam Long taskId, Authentication authentication) {
        final long userId = userService.getUserId(authentication);
        try {
            log.info("Deleting task with id: {}", taskId);
            boolean isDeleted = taskService.deleteTask(userId, taskId);
            if (isDeleted) {
                return ResponseEntity.status(200).body("Task deleted successfully");
            } else {
                return ResponseEntity.status(404).body("Task not found or you don't have permission to delete it");
            }
        } catch (Exception e) {
            log.error("Error deleting task: {}", e.getMessage());
            return ResponseEntity.status(500)
                    .body("Error deleting taskId: " + taskId + ", \nwith error message:\n" + e.getMessage());
        }
    }

}
