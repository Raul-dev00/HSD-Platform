package com.hsd.dto;

import com.hsd.entities.Message;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoMessageRequest {

    @NotBlank(message = "Mesaj içeriği boş olamaz")
    private String content;

    @NotNull(message = "Mesaj tipi boş olamaz")
    private Message.MessageType messageType;

    /** receiverId: DIRECT mesajlar için */
    private Long receiverId;

    /** projectId: PROJECT mesajlar için */
    private Long projectId;
}
