package com.hsd.services.impl;

import com.hsd.dto.DtoDepartment;
import com.hsd.dto.DtoDepartmentIU;
import com.hsd.dto.DtoUniversity;
import com.hsd.dto.DtoUniversityIU;
import com.hsd.entities.Department;
import com.hsd.entities.University;
import com.hsd.exception.BaseException;
import com.hsd.exception.ErrorMessage;
import com.hsd.exception.MessageType;
import com.hsd.repository.DepartmentRepository;
import com.hsd.repository.UniversityRepository;
import com.hsd.services.IUniversityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UniversityServiceImpl implements IUniversityService {

    private final UniversityRepository universityRepository;
    private final DepartmentRepository departmentRepository;

    @Override
    public DtoUniversity createUniversity(DtoUniversityIU request) {
        if (universityRepository.findByName(request.getName()).isPresent()) {
            throw new BaseException(new ErrorMessage(MessageType.ALREADY_EXISTS, request.getName()));
        }
        University university = University.builder()
                .name(request.getName())
                .city(request.getCity())
                .build();
        return mapToDto(universityRepository.save(university));
    }

    @Override
    public List<DtoUniversity> getAllUniversities() {
        return universityRepository.findAll().stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public DtoUniversity getUniversityById(Long id) {
        University university = universityRepository.findById(id)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Üniversite")));
        return mapToDto(university);
    }

    @Override
    public DtoDepartment createDepartment(DtoDepartmentIU request) {
        University university = universityRepository.findById(request.getUniversityId())
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Üniversite")));
        Department department = Department.builder()
                .name(request.getName())
                .university(university)
                .build();
        return mapDepartmentToDto(departmentRepository.save(department));
    }

    @Override
    public List<DtoDepartment> getDepartmentsByUniversity(Long universityId) {
        return departmentRepository.findByUniversityId(universityId).stream()
                .map(this::mapDepartmentToDto).collect(Collectors.toList());
    }

    private DtoUniversity mapToDto(University u) {
        return DtoUniversity.builder()
                .id(u.getId())
                .name(u.getName())
                .city(u.getCity())
                .memberCount(u.getUsers() == null ? 0 : u.getUsers().size())
                .build();
    }

    private DtoDepartment mapDepartmentToDto(Department d) {
        return DtoDepartment.builder()
                .id(d.getId())
                .name(d.getName())
                .universityId(d.getUniversity().getId())
                .universityName(d.getUniversity().getName())
                .build();
    }
}
