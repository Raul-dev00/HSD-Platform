package com.hsd.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoUser {
    private Long id;
    private String name;
    private String email;
    private Integer yearLevel;
    private String githubUrl;
    private String linkedinUrl;
    private String bio;
    private LocalDateTime createdAt;
    private Long universityId;
    private String universityName;
    private Long departmentId;
    private String departmentName;
    private List<DtoSkill> skills;
}
