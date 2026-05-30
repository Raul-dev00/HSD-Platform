package com.hsd.controller.impl;

import com.hsd.dto.DtoSkill;
import com.hsd.dto.DtoSkillIU;
import com.hsd.entities.Skill;
import com.hsd.services.ISkillService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/skills")
@RequiredArgsConstructor
public class SkillControllerImpl {

    private final ISkillService skillService;

    @PostMapping
    public ResponseEntity<DtoSkill> create(@RequestBody @Valid DtoSkillIU request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(skillService.createSkill(request));
    }

    @GetMapping
    public List<DtoSkill> getAll() {
        return skillService.getAllSkills();
    }

    @GetMapping("/category/{category}")
    public List<DtoSkill> getByCategory(@PathVariable Skill.SkillCategory category) {
        return skillService.getSkillsByCategory(category);
    }
}
