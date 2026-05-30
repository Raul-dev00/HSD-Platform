package com.hsd.dto;

import com.hsd.entities.Skill;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoSkillIU {

    @NotBlank(message = "Yetenek adı boş olamaz")
    private String name;

    @NotNull(message = "Kategori boş olamaz")
    private Skill.SkillCategory category;
}
