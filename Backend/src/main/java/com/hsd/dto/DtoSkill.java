package com.hsd.dto;

import com.hsd.entities.Skill;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoSkill {
    private Long id;
    private String name;
    private Skill.SkillCategory category;
}
