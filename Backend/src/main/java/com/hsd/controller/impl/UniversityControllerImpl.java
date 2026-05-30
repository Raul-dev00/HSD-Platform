package com.hsd.controller.impl;

import com.hsd.dto.*;
import com.hsd.services.IUniversityService;
import com.hsd.services.IUserServices;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/universities")
@RequiredArgsConstructor
public class UniversityControllerImpl {

    private final IUniversityService universityService;
    private final IUserServices userServices;

    @PostMapping
    public ResponseEntity<DtoUniversity> create(@RequestBody @Valid DtoUniversityIU request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(universityService.createUniversity(request));
    }

    @GetMapping
    public List<DtoUniversity> getAll() {
        return universityService.getAllUniversities();
    }

    @GetMapping("/{id}")
    public DtoUniversity getById(@PathVariable Long id) {
        return universityService.getUniversityById(id);
    }

    @GetMapping("/{id}/members")
    public List<DtoUser> getMembers(@PathVariable Long id) {
        return userServices.getUsersByUniversity(id);
    }

    @GetMapping("/{id}/departments")
    public List<DtoDepartment> getDepartments(@PathVariable Long id) {
        return universityService.getDepartmentsByUniversity(id);
    }

    @PostMapping("/departments")
    public ResponseEntity<DtoDepartment> createDepartment(@RequestBody @Valid DtoDepartmentIU request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(universityService.createDepartment(request));
    }
}
