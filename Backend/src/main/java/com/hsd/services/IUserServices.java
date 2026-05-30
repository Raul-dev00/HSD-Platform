package com.hsd.services;

import com.hsd.dto.*;

import java.util.List;

public interface IUserServices {

    DtoAuthResponse register(DtoRegisterRequest request);

    DtoAuthResponse login(DtoLoginRequest request);

    DtoUser getUserById(Long id);

    DtoUser updateUser(Long id, DtoUserUpdate request);

    List<DtoUser> getAllUsers();

    List<DtoUser> searchUsers(Long universityId, Long skillId, String name);

    List<DtoUser> getUsersByUniversity(Long universityId);

    void addSkillToUser(Long userId, Long skillId);

    void removeSkillFromUser(Long userId, Long skillId);
}
