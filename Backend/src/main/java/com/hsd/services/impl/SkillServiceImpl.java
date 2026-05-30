package com.hsd.services.impl;

import com.hsd.dto.DtoSkill;
import com.hsd.dto.DtoSkillIU;
import com.hsd.entities.Skill;
import com.hsd.exception.BaseException;
import com.hsd.exception.ErrorMessage;
import com.hsd.exception.MessageType;
import com.hsd.repository.SkillRepository;
import com.hsd.services.ISkillService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SkillServiceImpl implements ISkillService {

    private final SkillRepository skillRepository;

    @Override
    public DtoSkill createSkill(DtoSkillIU request) {
        if (skillRepository.findByName(request.getName()).isPresent()) {
            throw new BaseException(new ErrorMessage(MessageType.ALREADY_EXISTS, request.getName()));
        }
        Skill skill = Skill.builder()
                .name(request.getName())
                .category(request.getCategory())
                .build();
        return mapToDto(skillRepository.save(skill));
    }

    @Override
    public List<DtoSkill> getAllSkills() {
        return skillRepository.findAll().stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public List<DtoSkill> getSkillsByCategory(Skill.SkillCategory category) {
        return skillRepository.findByCategory(category).stream().map(this::mapToDto).collect(Collectors.toList());
    }

    private DtoSkill mapToDto(Skill skill) {
        return DtoSkill.builder()
                .id(skill.getId())
                .name(skill.getName())
                .category(skill.getCategory())
                .build();
    }
}
