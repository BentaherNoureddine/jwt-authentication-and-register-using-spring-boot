package com.noureddine.forest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class ForestApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(ForestApiApplication.class, args);
    }

}
