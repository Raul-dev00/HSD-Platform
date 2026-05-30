package com.hsd.controller.impl;

import com.hsd.dto.*;
import com.hsd.entities.Project;
import com.hsd.services.IProjectService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/projects")
@RequiredArgsConstructor
public class ProjectControllerImpl {

    private final IProjectService projectService;

    @PostMapping
    public ResponseEntity<DtoProject> createProject(@RequestBody @Valid DtoProjectIU request,
                                                     Authentication auth) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(projectService.createProject(request, auth.getName()));
    }

    @GetMapping
    public List<DtoProject> getAllProjects(@RequestParam(required = false) Project.ProjectStatus status) {
        if (status != null) {
            return projectService.getProjectsByStatus(status);
        }
        return projectService.getAllProjects();
    }

    @GetMapping("/mine")
    public List<DtoProject> getMyProjects(Authentication auth) {
        return projectService.getMyProjects(auth.getName());
    }

    @GetMapping("/{id}")
    public DtoProject getProjectById(@PathVariable Long id) {
        return projectService.getProjectById(id);
    }

    @PutMapping("/{id}")
    public DtoProject updateProject(@PathVariable Long id,
                                    @RequestBody @Valid DtoProjectIU request,
                                    Authentication auth) {
        return projectService.updateProject(id, request, auth.getName());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long id, Authentication auth) {
        projectService.deleteProject(id, auth.getName());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/apply")
    public ResponseEntity<DtoProjectMember> apply(@PathVariable Long id,
                                                   @RequestBody DtoApplyRequest request,
                                                   Authentication auth) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(projectService.applyToProject(id, request, auth.getName()));
    }

    @GetMapping("/{id}/applications")
    public List<DtoProjectMember> getApplications(@PathVariable Long id, Authentication auth) {
        return projectService.getApplications(id, auth.getName());
    }

    @PutMapping("/applications/{applicationId}/status")
    public DtoProjectMember updateApplicationStatus(@PathVariable Long applicationId,
                                                     @RequestBody @Valid DtoApplicationStatusRequest request,
                                                     Authentication auth) {
        return projectService.updateApplicationStatus(applicationId, request, auth.getName());
    }
}
