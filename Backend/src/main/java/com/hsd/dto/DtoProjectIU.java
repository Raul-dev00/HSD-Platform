package com.hsd.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoProjectIU {

    @NotBlank(message = "Proje adı boş olamaz")
    private String name;

    private String description;
}
