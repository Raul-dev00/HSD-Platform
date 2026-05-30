package com.hsd.services;

import com.hsd.dto.DtoDepartment;
import com.hsd.dto.DtoDepartmentIU;
import com.hsd.dto.DtoUniversity;
import com.hsd.dto.DtoUniversityIU;

import java.util.List;

public interface IUniversityService {

    DtoUniversity createUniversity(DtoUniversityIU request);

    List<DtoUniversity> getAllUniversities();

    DtoUniversity getUniversityById(Long id);

    DtoDepartment createDepartment(DtoDepartmentIU request);

    List<DtoDepartment> getDepartmentsByUniversity(Long universityId);
}
