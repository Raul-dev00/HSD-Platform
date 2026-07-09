package com.hsd.services.impl;

import com.hsd.dto.DtoMessage;
import com.hsd.dto.DtoMessageRequest;
import com.hsd.entities.Message;
import com.hsd.entities.Project;
import com.hsd.entities.User;
import com.hsd.exception.BaseException;
import com.hsd.exception.ErrorMessage;
import com.hsd.exception.MessageType;
import com.hsd.repository.MessageRepository;
import com.hsd.repository.ProjectRepository;
import com.hsd.repository.UserRepository;
import com.hsd.services.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements IMessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final ProjectRepository projectRepository;

    @Override
    @Transactional
    public DtoMessage sendMessage(DtoMessageRequest request, String senderEmail) {
        User sender = findUserByEmail(senderEmail);

        Message.MessageBuilder builder = Message.builder()
                .content(request.getContent())
                .messageType(request.getMessageType())
                .sender(sender);

        if (request.getMessageType() == Message.MessageType.DIRECT) {
            if (request.getReceiverId() == null) {
                throw new BaseException(new ErrorMessage(MessageType.INVALID_MESSAGE_TYPE, "DIRECT mesaj için receiverId gerekli"));
            }
            User receiver = userRepository.findById(request.getReceiverId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Alıcı kullanıcı")));
            builder.receiver(receiver);
        } else if (request.getMessageType() == Message.MessageType.PROJECT) {
            if (request.getProjectId() == null) {
                throw new BaseException(new ErrorMessage(MessageType.INVALID_MESSAGE_TYPE, "PROJECT mesaj için projectId gerekli"));
            }
            Project project = projectRepository.findById(request.getProjectId())
                    .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Proje")));
            builder.project(project);
        }

        return mapToDto(messageRepository.save(builder.build()));
    }

    @Override
    public List<DtoMessage> getDirectMessages(Long otherUserId, String currentUserEmail) {
        User currentUser = findUserByEmail(currentUserEmail);
        return messageRepository.findDirectMessages(currentUser.getId(), otherUserId).stream()
                .map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    public List<DtoMessage> getProjectMessages(Long projectId) {
        return messageRepository.findByProjectIdOrderBySentAtAsc(projectId).stream()
                .map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void clearProjectMessages(Long projectId, String requesterEmail) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Proje")));
        if (!project.getOwner().getEmail().equals(requesterEmail)) {
            throw new BaseException(new ErrorMessage(MessageType.UNAUTHORIZED, null));
        }
        messageRepository.deleteByProjectId(projectId);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, "Kullanıcı")));
    }

    private DtoMessage mapToDto(Message m) {
        return DtoMessage.builder()
                .id(m.getId())
                .content(m.getContent())
                .messageType(m.getMessageType())
                .sentAt(m.getSentAt())
                .senderId(m.getSender().getId())
                .senderName(m.getSender().getName())
                .receiverId(m.getReceiver() != null ? m.getReceiver().getId() : null)
                .projectId(m.getProject() != null ? m.getProject().getId() : null)
                .build();
    }
}
