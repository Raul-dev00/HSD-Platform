package com.hsd.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoAuthResponse {
    private String token;
    private String tokenType = "Bearer";
    private DtoUser user;
}
