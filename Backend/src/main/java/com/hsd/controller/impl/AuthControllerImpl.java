package com.hsd.controller.impl;

import com.hsd.dto.DtoAuthResponse;
import com.hsd.dto.DtoLoginRequest;
import com.hsd.dto.DtoRegisterRequest;
import com.hsd.services.IUserServices;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthControllerImpl {

    private final IUserServices userServices;

    @PostMapping("/register")
    public ResponseEntity<DtoAuthResponse> register(@RequestBody @Valid DtoRegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userServices.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<DtoAuthResponse> login(@RequestBody @Valid DtoLoginRequest request) {
        return ResponseEntity.ok(userServices.login(request));
    }
}
