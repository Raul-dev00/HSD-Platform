package com.hsd.services.impl;

import com.hsd.dto.*;
import com.hsd.entities.*;
import com.hsd.exception.BaseException;
import com.hsd.exception.ErrorMessage;
import com.hsd.exception.MessageType;
import com.hsd.repository.ProjectMemberRepository;
import com.hsd.repository.ProjectRepository;
import com.hsd.repository.UserRepository;
import com.hsd.services.IProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProjectServiceImpl implements IProjectService {

    private final ProjectRepository projectRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public DtoProject createProject(DtoProjectIU request, String ownerEmail) {
        User owner = findUserByEmail(ownerEmail);
        Project project = Project.builder()
                .name(request.getName())
                .description(request.getDescription())
                .owner(owner)
                .status(Project.ProjectStatus.OPEN)
                .build();
        return mapToDto(projectRepository.save(project));
    }

    @Override
    public List<DtoProject> getAllProjects() {
        return projectRepository.findAll().stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public List<DtoProject> getProjectsByStatus(Project.ProjectStatus status) {
        return projectRepository.findByStatus(status).stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public DtoProject getProjectById(Long id) {
        return mapToDto(findProjectById(id));
    }

    @Override
    @Transactional
    public DtoProject updateProject(Long id, DtoProjectIU request, String requesterEmail) {
        Project project = findProjectById(id);
        ensureOwner(project, requesterEmail);

        if (request.getName() != null) project.setName(request.getName());
        if (request.getDescription() != null) project.setDescription(request.getDescription());
        if (request.getStatus() != null) project.setStatus(request.getStatus());

        return mapToDto(projectRepository.save(project));
    }

    @Override
    @Transactional
    public void deleteProject(Long id, String requesterEmail) {
        Project project = findProjectById(id);
        ensureOwner(project, requesterEmail);
        projectRepository.delete(project);
    }

    @Override
    @Transactional
    public DtoProjectMember applyToProject(Long projectId, DtoApplyRequest request, String applicantEmail) {
        Project project = findProjectById(projectId);
        User applicant = findUserByEmail(applicantEmail);

        if (project.getOwner().getEmail().equals(applicantEmail)) {
            throw new BaseException(new ErrorMessage(MessageType.CANNOT_APPLY_OWN_PROJECT, null));
        }

        if (projectMemberRepository.existsByProjectIdAndUserId(projectId, applicant.getId())) {
            throw new BaseException(new ErrorMessage(MessageType.PROJECT_APPLICATION_EXISTS, null));
        }

        ProjectMember member = ProjectMember.builder()
                .project(project)
                .user(applicant)
                .role(request.getRole())
                .memberStatus(ProjectMember.MemberStatus.PENDING)
                .build();

        return mapMemberToDto(projectMemberRepository.save(member));
    }

    @Override
    public List<DtoProjectMember> getApplications(Long projectId, String requesterEmail) {
        Project project = findProjectById(projectId);
        boolean isOwner = project.getOwner().getEmail().equals(requesterEmail);
        return projectMemberRepository.findByProjectId(projectId).stream()
                .filter(m -> isOwner || m.getMemberStatus() == ProjectMember.MemberStatus.ACCEPTED)
                .map(this::mapMemberToDto).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public DtoProjectMember updateApplicationStatus(Long applicationId, DtoApplicationStatusRequest request, String requesterEmail) {
        ProjectMember member = projectMemberRepository.findById(applicationId)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Başvuru")));

        ensureOwner(member.getProject(), requesterEmail);

        member.setMemberStatus(request.getStatus());
        member.setRespondedAt(LocalDateTime.now());

        return mapMemberToDto(projectMemberRepository.save(member));
    }

    @Override
    public List<DtoProject> getMyProjects(String email) {
        User user = findUserByEmail(email);
        List<Project> owned = projectRepository.findByOwnerId(user.getId());
        List<Project> joined = projectRepository.findProjectsByMemberId(user.getId());
        
        List<Project> allMyProjects = new java.util.ArrayList<>(owned);
        allMyProjects.addAll(joined);
        
        return allMyProjects.stream().distinct().map(this::mapToDto).collect(Collectors.toList());
    }

    private Project findProjectById(Long id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Proje")));
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Kullanıcı")));
    }

    private void ensureOwner(Project project, String email) {
        if (!project.getOwner().getEmail().equals(email)) {
            throw new BaseException(new ErrorMessage(MessageType.UNAUTHORIZED, null));
        }
    }

    private DtoProject mapToDto(Project p) {
        return DtoProject.builder()
                .id(p.getId())
                .name(p.getName())
                .description(p.getDescription())
                .status(p.getStatus())
                .createdAt(p.getCreatedAt())
                .ownerId(p.getOwner().getId())
                .ownerName(p.getOwner().getName())
                .memberCount(p.getMembers() == null ? 0 :
                        (int) p.getMembers().stream()
                                .filter(m -> m.getMemberStatus() == ProjectMember.MemberStatus.ACCEPTED)
                                .count())
                .build();
    }

    private DtoProjectMember mapMemberToDto(ProjectMember m) {
        return DtoProjectMember.builder()
                .id(m.getId())
                .projectId(m.getProject().getId())
                .projectName(m.getProject().getName())
                .userId(m.getUser().getId())
                .userName(m.getUser().getName())
                .userEmail(m.getUser().getEmail())
                .role(m.getRole())
                .memberStatus(m.getMemberStatus())
                .appliedAt(m.getAppliedAt())
                .respondedAt(m.getRespondedAt())
                .build();
    }
}
