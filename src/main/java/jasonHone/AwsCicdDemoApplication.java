package jasonHone;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"jasonHone"})
public class AwsCicdDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(AwsCicdDemoApplication.class, args);
    }
}
