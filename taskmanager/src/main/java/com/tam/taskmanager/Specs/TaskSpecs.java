package com.tam.taskmanager.Specs;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.tam.taskmanager.entity.TaskEntity;

import jakarta.persistence.criteria.Predicate;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class TaskSpecs {

    public Specification<TaskEntity> getTasksByPriorityAndStatusandUserId(Long userId, String priority, String status) {

        try {
            return (root, query, criteriaBuilder) -> {
                List<Predicate> predicates = new ArrayList<>();

                if (priority != null) {
                    predicates.add(criteriaBuilder.equal(root.get("priority"), priority));
                }
                if (status != null) {
                    predicates.add(criteriaBuilder.equal(root.get("status"), status));
                }
                if (userId != null) {
                    predicates.add(criteriaBuilder.equal(root.get("assignedUser").get("id"), userId));
                }
                return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
            };
        } catch (Exception e) {
            return (root, query, criteriaBuilder) -> {
                List<Predicate> predicates = new ArrayList<>();
                predicates.add(criteriaBuilder.equal(root.get("Priority"), "HIGH"));
                return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
            };
        }
    }

    public Specification<TaskEntity> getBySearchinput(Long userId, String searchInput) {
        log.info("Searching tasks with input: {}", searchInput);
        return (root, query, criteriaBuilder) -> {
            if (searchInput == null || searchInput.trim().isEmpty()) {
                return criteriaBuilder.conjunction(); // No search input, return all tasks
            }
            List<Predicate> predicates = new ArrayList<>();
            if (searchInput != null && !searchInput.trim().isEmpty()) {
                predicates.add(criteriaBuilder.or(
                        criteriaBuilder.like(root.get("title"), "%" + searchInput + "%"),
                        criteriaBuilder.like(root.get("description"), "%" + searchInput + "%")));
            }
            if (userId != null) {
                predicates.add(criteriaBuilder.equal(root.get("assignedUser").get("id"), userId));
            }
            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }

    public Specification<TaskEntity> getTaskByIdAndUserId(Long userId, Long taskId) {
        log.info("Fetching task with id: {} for user id: {}", taskId, userId);
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (userId != null) {
                predicates.add(criteriaBuilder.equal(root.get("assignedUser").get("id"), userId));
            }
            if (taskId != null) {
                predicates.add(criteriaBuilder.equal(root.get("id"), taskId));
            }
            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}
