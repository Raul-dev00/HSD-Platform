package com.hsd.services;

import com.hsd.dto.DtoSkill;
import com.hsd.dto.DtoSkillIU;
import com.hsd.entities.Skill;

import java.util.List;

public interface ISkillService {

    DtoSkill createSkill(DtoSkillIU request);

    List<DtoSkill> getAllSkills();

    List<DtoSkill> getSkillsByCategory(Skill.SkillCategory category);
}
