package com.hsd.services.impl;

import com.hsd.dto.*;
import com.hsd.entities.*;
import com.hsd.exception.BaseException;
import com.hsd.exception.ErrorMessage;
import com.hsd.exception.MessageType;
import com.hsd.repository.*;
import com.hsd.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServicesImpl implements com.hsd.services.IUserServices {

    private final UserRepository userRepository;
    private final UniversityRepository universityRepository;
    private final DepartmentRepository departmentRepository;
    private final SkillRepository skillRepository;
    private final UserSkillRepository userSkillRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    @Override
    @Transactional
    public DtoAuthResponse register(DtoRegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BaseException(new ErrorMessage(MessageType.EMAIL_ALREADY_IN_USE, request.getEmail()));
        }

        User.UserBuilder builder = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .yearLevel(request.getYearLevel());

        if (request.getUniversityId() != null) {
            University university = universityRepository.findById(request.getUniversityId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Üniversite")));
            builder.university(university);
        }

        if (request.getDepartmentId() != null) {
            Department department = departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Bölüm")));
            builder.department(department);
        }

        User saved = userRepository.save(builder.build());
        UserDetails userDetails = userDetailsService.loadUserByUsername(saved.getEmail());
        String token = jwtUtil.generateToken(userDetails);

        return DtoAuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .user(mapToDto(saved))
                .build();
    }

    @Override
    public DtoAuthResponse login(DtoLoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        String token = jwtUtil.generateToken(userDetails);

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.INVALID_CREDENTIALS, null)));

        return DtoAuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .user(mapToDto(user))
                .build();
    }

    @Override
    public DtoUser getUserById(Long id) {
        User user = findUserById(id);
        return mapToDto(user);
    }

    @Override
    @Transactional
    public DtoUser updateUser(Long id, DtoUserUpdate request) {
        User user = findUserById(id);

        if (request.getName() != null) user.setName(request.getName());
        if (request.getYearLevel() != null) user.setYearLevel(request.getYearLevel());
        if (request.getGithubUrl() != null) user.setGithubUrl(request.getGithubUrl());
        if (request.getLinkedinUrl() != null) user.setLinkedinUrl(request.getLinkedinUrl());
        if (request.getBio() != null) user.setBio(request.getBio());

        if (request.getUniversityId() != null) {
            University university = universityRepository.findById(request.getUniversityId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Üniversite")));
            user.setUniversity(university);
        }

        if (request.getDepartmentId() != null) {
            Department department = departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Bölüm")));
            user.setDepartment(department);
        }

        if (request.getSkillIds() != null) {
            userSkillRepository.deleteAll(userSkillRepository.findByUserId(id));
            List<UserSkill> newSkills = request.getSkillIds().stream()
                    .map(skillId -> {
                        Skill skill = skillRepository.findById(skillId)
                                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Yetenek")));
                        return UserSkill.builder().user(user).skill(skill).build();
                    }).collect(Collectors.toList());
            userSkillRepository.saveAll(newSkills);
        }

        return mapToDto(userRepository.save(user));
    }

    @Override
    public List<DtoUser> getAllUsers() {
        return userRepository.findAll().stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public List<DtoUser> searchUsers(Long universityId, Long skillId, String name) {
        if (name != null && !name.isBlank()) {
            return userRepository.findByNameContainingIgnoreCase(name).stream()
                    .map(this::mapToDto).collect(Collectors.toList());
        }
        if (universityId != null || skillId != null) {
            return userRepository.searchUsers(universityId, skillId).stream()
                    .map(this::mapToDto).collect(Collectors.toList());
        }
        return getAllUsers();
    }

    @Override
    public List<DtoUser> getUsersByUniversity(Long universityId) {
        return userRepository.findByUniversityId(universityId).stream()
                .map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void addSkillToUser(Long userId, Long skillId) {
        User user = findUserById(userId);
        Skill skill = skillRepository.findById(skillId)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Yetenek")));

        if (userSkillRepository.findByUserIdAndSkillId(userId, skillId).isPresent()) {
            throw new BaseException(new ErrorMessage(MessageType.ALREADY_EXISTS, "Bu yetenek zaten ekli"));
        }

        userSkillRepository.save(UserSkill.builder().user(user).skill(skill).build());
    }

    @Override
    @Transactional
    public void removeSkillFromUser(Long userId, Long skillId) {
        userSkillRepository.findByUserIdAndSkillId(userId, skillId)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Yetenek")));
        userSkillRepository.deleteByUserIdAndSkillId(userId, skillId);
    }

    private User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Kullanıcı")));
    }

    private DtoUser mapToDto(User user) {
        List<DtoSkill> skills = user.getUserSkills() == null ? List.of() :
                user.getUserSkills().stream()
                        .map(us -> DtoSkill.builder()
                                .id(us.getSkill().getId())
                                .name(us.getSkill().getName())
                                .category(us.getSkill().getCategory())
                                .build())
                        .collect(Collectors.toList());

        return DtoUser.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .yearLevel(user.getYearLevel())
                .githubUrl(user.getGithubUrl())
                .linkedinUrl(user.getLinkedinUrl())
                .bio(user.getBio())
                .createdAt(user.getCreatedAt())
                .universityId(user.getUniversity() != null ? user.getUniversity().getId() : null)
                .universityName(user.getUniversity() != null ? user.getUniversity().getName() : null)
                .departmentId(user.getDepartment() != null ? user.getDepartment().getId() : null)
                .departmentName(user.getDepartment() != null ? user.getDepartment().getName() : null)
                .skills(skills)
                .build();
    }
}
