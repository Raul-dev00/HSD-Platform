package com.hsd.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoDepartment {
    private Long id;
    private String name;
    private Long universityId;
    private String universityName;
}
