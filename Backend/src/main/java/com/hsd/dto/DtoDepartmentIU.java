package com.hsd.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoDepartmentIU {

    @NotBlank(message = "Bölüm adı boş olamaz")
    private String name;

    @NotNull(message = "Üniversite ID boş olamaz")
    private Long universityId;
}
