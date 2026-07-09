package com.hsd.repository;

import com.hsd.entities.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("SELECT m FROM Message m WHERE m.messageType = 'DIRECT' AND " +
           "((m.sender.id = :userId1 AND m.receiver.id = :userId2) OR " +
           "(m.sender.id = :userId2 AND m.receiver.id = :userId1)) " +
           "ORDER BY m.sentAt ASC")
    List<Message> findDirectMessages(@Param("userId1") Long userId1, @Param("userId2") Long userId2);

    List<Message> findByProjectIdOrderBySentAtAsc(Long projectId);

    @org.springframework.transaction.annotation.Transactional
    void deleteByProjectId(Long projectId);
}
