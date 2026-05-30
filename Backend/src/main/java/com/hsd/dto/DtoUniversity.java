package com.hsd.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoUniversity {
    private Long id;
    private String name;
    private String city;
    private int memberCount;
}
