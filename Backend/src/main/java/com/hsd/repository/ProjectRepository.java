package com.hsd.repository;

import com.hsd.entities.Project;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {

    List<Project> findByOwnerId(Long ownerId);

    List<Project> findByStatus(Project.ProjectStatus status);

    List<Project> findByNameContainingIgnoreCase(String name);

    @Query("SELECT DISTINCT p FROM Project p JOIN p.members pm WHERE pm.user.id = :userId AND pm.memberStatus = 'ACCEPTED'")
    List<Project> findProjectsByMemberId(@Param("userId") Long userId);
}
