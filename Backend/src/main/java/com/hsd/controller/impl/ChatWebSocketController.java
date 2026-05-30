package com.hsd.controller.impl;

import com.hsd.dto.DtoMessage;
import com.hsd.dto.DtoMessageRequest;
import com.hsd.entities.Message;
import com.hsd.services.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final IMessageService messageService;

    /**
     * Doğrudan mesaj: client → /app/chat.direct
     * Kaydedilir ve alıcıya /user/{receiverId}/queue/messages üzerinden iletilir.
     */
    @MessageMapping("/chat.direct")
    public void sendDirectMessage(@Payload DtoMessageRequest request, Principal principal) {
        DtoMessage saved = messageService.sendMessage(request, principal.getName());
        messagingTemplate.convertAndSendToUser(
                String.valueOf(saved.getReceiverId()),
                "/queue/messages",
                saved
        );
    }

    /**
     * Proje odası mesajı: client → /app/chat.project
     * Kaydedilir ve tüm proje üyelerine /topic/project/{projectId} üzerinden broadcast edilir.
     */
    @MessageMapping("/chat.project")
    public void sendProjectMessage(@Payload DtoMessageRequest request, Principal principal) {
        if (request.getMessageType() != Message.MessageType.PROJECT || request.getProjectId() == null) {
            return;
        }
        DtoMessage saved = messageService.sendMessage(request, principal.getName());
        messagingTemplate.convertAndSend(
                "/topic/project/" + saved.getProjectId(),
                saved
        );
    }
}
