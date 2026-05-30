package com.hsd.dto;

import com.hsd.entities.Message;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtoMessage {
    private Long id;
    private String content;
    private Message.MessageType messageType;
    private LocalDateTime sentAt;
    private Long senderId;
    private String senderName;
    private Long receiverId;
    private Long projectId;
}
