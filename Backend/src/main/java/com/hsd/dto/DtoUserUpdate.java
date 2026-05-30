package com.hsd.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoUserUpdate {
    private String name;
    private Integer yearLevel;
    private String githubUrl;
    private String linkedinUrl;
    private String bio;
    private Long universityId;
    private Long departmentId;
    private List<Long> skillIds;
}
