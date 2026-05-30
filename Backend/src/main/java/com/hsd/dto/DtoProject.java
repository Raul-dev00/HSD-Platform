package com.hsd.dto;

import com.hsd.entities.Project;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoProject {
    private Long id;
    private String name;
    private String description;
    private Project.ProjectStatus status;
    private LocalDateTime createdAt;
    private Long ownerId;
    private String ownerName;
    private int memberCount;
}
