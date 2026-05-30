package com.hsd.services;

import com.hsd.dto.*;
import com.hsd.entities.Project;

import java.util.List;

public interface IProjectService {

    DtoProject createProject(DtoProjectIU request, String ownerEmail);

    List<DtoProject> getAllProjects();

    List<DtoProject> getProjectsByStatus(Project.ProjectStatus status);

    DtoProject getProjectById(Long id);

    DtoProject updateProject(Long id, DtoProjectIU request, String requesterEmail);

    void deleteProject(Long id, String requesterEmail);

    DtoProjectMember applyToProject(Long projectId, DtoApplyRequest request, String applicantEmail);

    List<DtoProjectMember> getApplications(Long projectId, String requesterEmail);

    DtoProjectMember updateApplicationStatus(Long applicationId, DtoApplicationStatusRequest request, String requesterEmail);

    List<DtoProject> getMyProjects(String email);
}
