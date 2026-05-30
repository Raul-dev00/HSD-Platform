package com.hsd.repository;

import com.hsd.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    List<User> findByUniversityId(Long universityId);

    List<User> findByDepartmentId(Long departmentId);

    @Query("SELECT DISTINCT u FROM User u JOIN u.userSkills us WHERE us.skill.id = :skillId")
    List<User> findBySkillId(@Param("skillId") Long skillId);

    @Query("SELECT DISTINCT u FROM User u JOIN u.userSkills us WHERE us.skill.name LIKE %:skillName%")
    List<User> findBySkillName(@Param("skillName") String skillName);

    @Query("SELECT u FROM User u WHERE u.university.id = :universityId AND (:skillId IS NULL OR EXISTS " +
           "(SELECT us FROM UserSkill us WHERE us.user = u AND us.skill.id = :skillId))")
    List<User> searchUsers(@Param("universityId") Long universityId, @Param("skillId") Long skillId);

    List<User> findByNameContainingIgnoreCase(String name);
}
