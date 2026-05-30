package com.hsd.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "skill", schema = "hsd")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Skill {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private SkillCategory category;

    public enum SkillCategory {
        AI, EMBEDDED, MOBILE, WEB, BACKEND, DATA, OTHER
    }
}
