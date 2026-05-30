package com.hsd.controller;

import com.hsd.dto.*;

import java.util.List;

public interface IUserController {

    DtoUser getUserById(Long id);

    DtoUser updateUser(Long id, DtoUserUpdate request);

    List<DtoUser> getAllUsers();

    List<DtoUser> searchUsers(Long universityId, Long skillId, String name);

    void addSkill(Long userId, Long skillId);

    void removeSkill(Long userId, Long skillId);
}
