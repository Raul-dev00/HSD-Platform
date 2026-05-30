package com.hsd.dto;

import com.hsd.entities.ProjectMember;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoProjectMember {
    private Long id;
    private Long projectId;
    private String projectName;
    private Long userId;
    private String userName;
    private String userEmail;
    private String role;
    private ProjectMember.MemberStatus memberStatus;
    private LocalDateTime appliedAt;
    private LocalDateTime respondedAt;
}
