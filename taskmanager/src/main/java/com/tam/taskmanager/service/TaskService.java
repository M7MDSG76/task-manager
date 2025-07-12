package com.tam.taskmanager.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.scheduling.config.Task;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import com.tam.taskmanager.Specs.TaskSpecs;
import com.tam.taskmanager.dto.task.TaskDTO;
import com.tam.taskmanager.entity.TaskEntity;
import com.tam.taskmanager.entity.UserEntity;
import com.tam.taskmanager.enums.PriorityEnum;
import com.tam.taskmanager.enums.StatusEnum;
import com.tam.taskmanager.repository.TaskRepository;
import org.springframework.data.domain.Pageable;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class TaskService {

    // This service will contain methods to handle task operations like create,
    // update, delete, and fetch tasks.
    // For now, we can leave it empty or add some basic methods.
    @Autowired
    private TaskRepository taskRepository;

    // @Autowired
    // private UserService userService;

    public Long createTask(Long userId, String title, String description, String priority, String status) {
        PriorityEnum priorityEnum = null;
        StatusEnum statusEnum = null;
        try {
            priorityEnum = PriorityEnum.valueOf(priority.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid priority value: " + priority);
        }

        try {
            statusEnum = StatusEnum.valueOf(status.toUpperCase());

        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid status value: " + status);
        }

        TaskDTO task = new TaskDTO(null, title, description, priorityEnum, statusEnum);

        UserEntity user = new UserEntity();
        log.info("user ID: {}", userId);
        user.setId(userId);
        // save to DB
        TaskEntity savedTask = taskRepository.save(toEntity(user, task));

        return savedTask.getId();
    }

    private TaskEntity toEntity(UserEntity userId, TaskDTO taskDTO) {
        TaskEntity taskEntity = new TaskEntity();
        taskEntity.setTitle(taskDTO.getTitle());
        taskEntity.setDescription(taskDTO.getDescription());
        taskEntity.setPriority(taskDTO.getPriority().name());
        taskEntity.setStatus(taskDTO.getStatus().name());
        try {
            taskEntity.setAssignedUser(userId);
        } catch (Exception e) {
            log.error("Error assigning user to task: {}", e.getMessage());
        }
        return taskEntity;
    }

    private TaskDTO toDto(TaskEntity taskEntity) {
        return new TaskDTO(
                taskEntity.getId(),
                taskEntity.getTitle(),
                taskEntity.getDescription(),
                PriorityEnum.valueOf(taskEntity.getPriority()),
                StatusEnum.valueOf(taskEntity.getStatus()));
    }

    public TaskDTO updateTask(long userId, Long taskId, String title, String description, String priority,
            String status) {
        PriorityEnum priorityEnum = null;
        StatusEnum statusEnum = null;
        try {
            priorityEnum = PriorityEnum.valueOf(priority.toUpperCase());

        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid priority value: " + priority);
        }

        try {
            statusEnum = StatusEnum.valueOf(status.toUpperCase());

        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid status value: " + status);
        }

        log.info("Updating task with id: {}, title: {}, description: {}, priority: {}, status: {}",
                taskId, title, description, priorityEnum, statusEnum);
        // Update the task in the database using taskId
        TaskSpecs taskSpecs = new TaskSpecs();
        Optional<TaskEntity> taskEntityOptional = taskRepository
                .findOne(taskSpecs.getTaskByIdAndUserId(userId, taskId));
        TaskEntity taskEntity = taskEntityOptional
                .orElseThrow(() -> new IllegalArgumentException("Task not found with id: " + taskId));
        taskEntity = updateEntity(taskEntity, title, description, priorityEnum, statusEnum);
        taskRepository.save(taskEntity);
        log.info("Updated task with id: {}", taskId);
        return toDto(taskEntity);
    }

    private TaskEntity updateEntity(TaskEntity taskEntity, String title, String description, PriorityEnum priority,
            StatusEnum status) {
        taskEntity.setTitle(title);
        taskEntity.setDescription(description);
        taskEntity.setPriority(priority.name());
        taskEntity.setStatus(status.name());
        return taskEntity;
    }

    public boolean deleteTask(Long userId, Long taskId) {
        log.info("Deleting task with id: {}", taskId);
        TaskSpecs specs = new TaskSpecs();
        Optional<TaskEntity> task = taskRepository.findOne(specs.getTaskByIdAndUserId(userId, taskId));
        if (task.isPresent()) {
            log.info("Found task: {}", task.get().getId());
            try {
                taskRepository.delete(task.get());
                return true;
            } catch (OptimisticLockingFailureException e) {
                // TODO: handle exception
                log.error("Error deleting task with id {}: {}", taskId, e.getMessage());
                return false;
            }
        } else {
            log.error("Task not found or you don't have permission to delete it: userId={}, taskId={}", userId, taskId);
        }
        return false; // Return false if task not found or deletion failed
    }

    public List<TaskDTO> getAllTasks(String priority, String status, int pageSize, int pageNumber, Long userId) {
        TaskSpecs taskSpecs = new TaskSpecs();
        Pageable pageable = PageRequest.of(pageNumber, pageSize, Sort.unsorted());
        // Fetch all tasks from the database
        Page<TaskEntity> taskEntities = taskRepository
                .findAll(taskSpecs.getTasksByPriorityAndStatusandUserId(userId, priority, status), pageable);
        List<TaskDTO> taskDTOs = new ArrayList<>();
        if (taskEntities.hasContent()) {
            log.info("Found {} tasks with priority: {} and status: {}", taskEntities.getContent().size(), priority,
                    status);
            for (TaskEntity taskEntity : taskEntities.getContent()) {
                // Mapping to DTO is Necessary to avoid data leakage
                taskDTOs.add(toDto(taskEntity));
            }
            return taskDTOs;
        } else {
            log.info("No tasks found with priority: {} and status: {}", priority, status);
            return taskDTOs; // Return empty list if no tasks found
        }

    }

    public List<TaskDTO> searchTasks(String search, int pageSize, int pageNumber, Long userId) {
        TaskSpecs taskSpecs = new TaskSpecs();
        Pageable pageable = PageRequest.of(pageNumber, pageSize, Sort.unsorted());
        // Fetch all tasks from the database
        Page<TaskEntity> taskEntities = taskRepository
                .findAll(taskSpecs.getBySearchinput(userId, search), pageable);
        List<TaskDTO> taskDTOs = new ArrayList<>();
        if (taskEntities.hasContent()) {
            log.info("Found {} tasks with search input: {}", taskEntities.getContent().size(), search);
            for (TaskEntity taskEntity : taskEntities.getContent()) {
                // Mapping to DTO is Necessary to avoid data leakage
                taskDTOs.add(toDto(taskEntity));
            }
            return taskDTOs;
        } else {
            log.info("No tasks found with search input: {}", search);
            return taskDTOs; // Return empty list if no tasks found
        }
    }
}
