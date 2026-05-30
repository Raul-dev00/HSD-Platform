package com.hsd.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoUniversityIU {

    @NotBlank(message = "Üniversite adı boş olamaz")
    private String name;

    private String city;
}
