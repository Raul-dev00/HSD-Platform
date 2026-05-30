package com.hsd.dto;

import com.hsd.entities.ProjectMember;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoApplicationStatusRequest {

    @NotNull(message = "Durum boş olamaz")
    private ProjectMember.MemberStatus status;
}
