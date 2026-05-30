package com.hsd.services;

import com.hsd.dto.DtoMessage;
import com.hsd.dto.DtoMessageRequest;

import java.util.List;

public interface IMessageService {

    DtoMessage sendMessage(DtoMessageRequest request, String senderEmail);

    List<DtoMessage> getDirectMessages(Long otherUserId, String currentUserEmail);

    List<DtoMessage> getProjectMessages(Long projectId);
}
