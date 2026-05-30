package com.hsd.controller.impl;

import com.hsd.dto.DtoMessage;
import com.hsd.dto.DtoMessageRequest;
import com.hsd.services.IMessageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/messages")
@RequiredArgsConstructor
public class MessageControllerImpl {

    private final IMessageService messageService;

    @PostMapping
    public ResponseEntity<DtoMessage> send(@RequestBody @Valid DtoMessageRequest request,
                                           Authentication auth) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(messageService.sendMessage(request, auth.getName()));
    }

    @GetMapping("/direct/{userId}")
    public List<DtoMessage> getDirectMessages(@PathVariable Long userId, Authentication auth) {
        return messageService.getDirectMessages(userId, auth.getName());
    }

    @GetMapping("/project/{projectId}")
    public List<DtoMessage> getProjectMessages(@PathVariable Long projectId) {
        return messageService.getProjectMessages(projectId);
    }
}
