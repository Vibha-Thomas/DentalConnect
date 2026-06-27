package com.dentconnect.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Slf4j
@Configuration
public class FirebaseConfig {

    @Value("${app.firebase.config-path:firebase-service-account.json}")
    private String configPath;

    @PostConstruct
    public void initFirebase() {
        if (!FirebaseApp.getApps().isEmpty()) {
            log.info("Firebase already initialized");
            return;
        }

        // Try loading from classpath first, then file system
        InputStream serviceAccountStream = null;

        try {
            // Try classpath
            serviceAccountStream = getClass().getClassLoader()
                    .getResourceAsStream(configPath);

            // Try file system
            if (serviceAccountStream == null) {
                try {
                    serviceAccountStream = new FileInputStream(configPath);
                } catch (IOException e) {
                    log.warn("Firebase service account file not found at: {}. " +
                             "Firebase features will be disabled. " +
                             "Place firebase-service-account.json in the resources directory or set FIREBASE_CONFIG_PATH.",
                             configPath);
                    return;
                }
            }

            GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccountStream);
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(credentials)
                    .build();
            FirebaseApp.initializeApp(options);
            log.info("Firebase initialized successfully");

        } catch (IOException e) {
            log.error("Failed to initialize Firebase: {}", e.getMessage());
        } finally {
            if (serviceAccountStream != null) {
                try { serviceAccountStream.close(); } catch (IOException ignored) {}
            }
        }
    }
}
