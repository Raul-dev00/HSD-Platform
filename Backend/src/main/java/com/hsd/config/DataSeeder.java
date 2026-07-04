package com.hsd.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hsd.entities.Department;
import com.hsd.entities.Skill;
import com.hsd.entities.University;
import com.hsd.repository.DepartmentRepository;
import com.hsd.repository.SkillRepository;
import com.hsd.repository.UniversityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UniversityRepository universityRepository;
    private final DepartmentRepository departmentRepository;
    private final SkillRepository skillRepository;

    @Override
    @SuppressWarnings("unchecked")
    public void run(String... args) throws Exception {
        if (universityRepository.count() == 0) {
            ObjectMapper mapper = new ObjectMapper();
            TypeReference<Map<String, Object>> typeReference = new TypeReference<>() {};
            
            try {
                InputStream inputStream = new ClassPathResource("turkiye-universiteleri-ve-bolumleri.json").getInputStream();
                Map<String, Object> universitiesMap = mapper.readValue(inputStream, typeReference);
                
                List<University> universityEntities = new ArrayList<>();
                List<Department> departmentEntities = new ArrayList<>();

                for (Map.Entry<String, Object> entry : universitiesMap.entrySet()) {
                    Map<String, Object> uMap = (Map<String, Object>) entry.getValue();
                    String name = (String) uMap.get("name");
                    if (name != null) {
                        name = name.trim();
                    } else {
                        continue;
                    }
                    
                    // Şehir/Adres bilgisi
                    String city = "";
                    if (uMap.get("address") != null) {
                         String address = (String) uMap.get("address");
                         // Veritabanındaki 'city' alanına sığması için uzun adresi keselim (eğer çok uzunsa)
                         city = address.length() > 255 ? address.substring(0, 255) : address;
                    }
                    
                    University u = University.builder().name(name).city(city).build();
                    universityEntities.add(u);
                    
                    // Fakülteler ve Bölümleri işle
                    if (uMap.containsKey("faculties")) {
                        Map<String, Object> faculties = (Map<String, Object>) uMap.get("faculties");
                        for (Object facultyObj : faculties.values()) {
                            Map<String, Object> facultyMap = (Map<String, Object>) facultyObj;
                            if (facultyMap.containsKey("departments")) {
                                List<String> departments = (List<String>) facultyMap.get("departments");
                                for (String deptName : departments) {
                                    if (deptName != null && !deptName.trim().isEmpty()) {
                                        departmentEntities.add(Department.builder()
                                                .name(deptName.trim())
                                                .university(u) // FK ilişkisi
                                                .build());
                                    }
                                }
                            }
                        }
                    }
                }
                
                // İlk olarak üniversiteleri kaydedelim
                universityRepository.saveAll(universityEntities);
                System.out.println(universityEntities.size() + " üniversite kaydedildi.");
                
                // Ardından ilgili bölümleri kaydedelim
                departmentRepository.saveAll(departmentEntities);
                System.out.println(departmentEntities.size() + " bölüm kaydedildi.");
                
                System.out.println("JSON dosyasından üniversiteler ve bölümler başarıyla yüklendi!");
                
            } catch (Exception e) {
                System.out.println("JSON okunamadı: " + e.getMessage());
                e.printStackTrace();
            }
        }

        if (skillRepository.count() == 0) {
            List<Skill> skills = List.of(
                    Skill.builder().name("Flutter").category(Skill.SkillCategory.MOBILE).build(),
                    Skill.builder().name("Android (Kotlin/Java)").category(Skill.SkillCategory.MOBILE).build(),
                    Skill.builder().name("iOS (Swift)").category(Skill.SkillCategory.MOBILE).build(),
                    Skill.builder().name("React Native").category(Skill.SkillCategory.MOBILE).build(),
                    Skill.builder().name("Spring Boot").category(Skill.SkillCategory.BACKEND).build(),
                    Skill.builder().name("Node.js").category(Skill.SkillCategory.BACKEND).build(),
                    Skill.builder().name("Python (Django/FastAPI)").category(Skill.SkillCategory.BACKEND).build(),
                    Skill.builder().name("React").category(Skill.SkillCategory.WEB).build(),
                    Skill.builder().name("Vue.js").category(Skill.SkillCategory.WEB).build(),
                    Skill.builder().name("Angular").category(Skill.SkillCategory.WEB).build(),
                    Skill.builder().name("Machine Learning").category(Skill.SkillCategory.AI).build(),
                    Skill.builder().name("Deep Learning").category(Skill.SkillCategory.AI).build(),
                    Skill.builder().name("Data Analysis").category(Skill.SkillCategory.DATA).build(),
                    Skill.builder().name("SQL & Veritabanları").category(Skill.SkillCategory.DATA).build(),
                    Skill.builder().name("Embedded C / C++").category(Skill.SkillCategory.EMBEDDED).build(),
                    Skill.builder().name("Arduino / Raspberry Pi").category(Skill.SkillCategory.EMBEDDED).build(),
                    Skill.builder().name("UI/UX Tasarım").category(Skill.SkillCategory.OTHER).build(),
                    Skill.builder().name("Proje Yönetimi").category(Skill.SkillCategory.OTHER).build()
            );
            skillRepository.saveAll(skills);
            System.out.println(skills.size() + " yetenek (skill) veritabanına kaydedildi.");
        }
    }
}
