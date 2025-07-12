package com.tam.taskmanager.dto.task;

import lombok.Data;
import com.tam.taskmanager.enums.StatusEnum;
import com.tam.taskmanager.enums.PriorityEnum;

@Data
public class TaskDTO {
    private Long id;
    private String title;
    private String description;
    private PriorityEnum priority;
    private StatusEnum status;

    public TaskDTO(Long id, String title, String description, PriorityEnum priority, StatusEnum status) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = status;
    }
}
