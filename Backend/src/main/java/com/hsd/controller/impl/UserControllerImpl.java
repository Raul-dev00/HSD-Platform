package com.hsd.controller.impl;

import com.hsd.controller.IUserController;
import com.hsd.dto.*;
import com.hsd.services.IUserServices;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserControllerImpl implements IUserController {

    private final IUserServices userServices;

    @Override
    @GetMapping("/{id}")
    public DtoUser getUserById(@PathVariable Long id) {
        return userServices.getUserById(id);
    }

    @Override
    @PutMapping("/{id}")
    public DtoUser updateUser(@PathVariable Long id, @RequestBody @Valid DtoUserUpdate request) {
        return userServices.updateUser(id, request);
    }

    @Override
    @GetMapping
    public List<DtoUser> getAllUsers() {
        return userServices.getAllUsers();
    }

    @Override
    @GetMapping("/search")
    public List<DtoUser> searchUsers(
            @RequestParam(required = false) Long universityId,
            @RequestParam(required = false) Long skillId,
            @RequestParam(required = false) String name) {
        return userServices.searchUsers(universityId, skillId, name);
    }

    @Override
    @PostMapping("/{userId}/skills/{skillId}")
    public void addSkill(@PathVariable Long userId, @PathVariable Long skillId) {
        userServices.addSkillToUser(userId, skillId);
    }

    @Override
    @DeleteMapping("/{userId}/skills/{skillId}")
    public void removeSkill(@PathVariable Long userId, @PathVariable Long skillId) {
        userServices.removeSkillFromUser(userId, skillId);
    }
}
