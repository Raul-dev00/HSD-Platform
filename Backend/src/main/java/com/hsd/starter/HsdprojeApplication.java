package com.hsd.starter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@ComponentScan(basePackages = "com.hsd")
@EnableJpaRepositories(basePackages = "com.hsd")
@EntityScan(basePackages = "com.hsd.entities") // BU SATIRI EKLEDİK
public class HsdprojeApplication {

	public static void main(String[] args) {
		SpringApplication.run(HsdprojeApplication.class, args);
	}

}
