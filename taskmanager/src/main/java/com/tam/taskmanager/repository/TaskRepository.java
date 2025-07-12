package com.tam.taskmanager.repository;

import com.tam.taskmanager.entity.TaskEntity;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface TaskRepository extends JpaRepository<TaskEntity, Long>, JpaSpecificationExecutor<TaskEntity> {

    Page<TaskEntity> findAll(Specification<TaskEntity> specification, Pageable pageable);

    // void deleteById( Specification<TaskEntity> specification,Long id);

    // Optional<TaskEntity> findById(Specification<TaskEntity> specification,Long id);

}