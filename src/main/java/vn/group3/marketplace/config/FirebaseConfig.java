// package vn.group3.marketplace.config;

// import com.google.auth.oauth2.GoogleCredentials;
// import com.google.cloud.firestore.Firestore;
// import com.google.firebase.FirebaseApp;
// import com.google.firebase.FirebaseOptions;
// import com.google.firebase.cloud.FirestoreClient;
// import com.google.firebase.database.FirebaseDatabase;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;
// import org.springframework.beans.factory.annotation.Value;
// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import org.springframework.core.io.ClassPathResource;

// import jakarta.annotation.PostConstruct;
// import java.io.IOException;
// import java.io.InputStream;

// @Configuration
// public class FirebaseConfig {

// private static final Logger logger =
// LoggerFactory.getLogger(FirebaseConfig.class);

// @Value("${firebase.config.path}")
// private String firebaseConfigPath;

// @Value("${firebase.database.url}")
// private String firebaseDatabaseUrl;

// @PostConstruct
// public void initialize() {
// try {
// // Check if Firebase has already been initialized
// if (FirebaseApp.getApps().isEmpty()) {
// InputStream serviceAccount = new
// ClassPathResource(firebaseConfigPath).getInputStream();

// FirebaseOptions options = FirebaseOptions.builder()
// .setCredentials(GoogleCredentials.fromStream(serviceAccount))
// .setDatabaseUrl(firebaseDatabaseUrl)
// .build();

// FirebaseApp.initializeApp(options);
// logger.info("Firebase has been initialized successfully with database URL:
// {}", firebaseDatabaseUrl);
// } else {
// logger.info("Firebase is already initialized");
// }
// } catch (IOException e) {
// logger.error(
// "Failed to initialize Firebase due to IO error. Check if the Firebase
// credentials file exists and is readable: {}",
// e.getMessage(), e);
// throw new IllegalStateException(
// "Unable to initialize Firebase application. Please check Firebase credentials
// configuration.", e);
// } catch (Exception e) {
// logger.error("Unexpected error occurred while initializing Firebase: {}",
// e.getMessage(), e);
// throw new IllegalStateException("Failed to initialize Firebase application
// due to unexpected error.", e);
// }
// }

// @Bean
// public FirebaseApp firebaseApp() {
// return FirebaseApp.getInstance();
// }

// @Bean
// public FirebaseDatabase firebaseDatabase() {
// return FirebaseDatabase.getInstance(firebaseApp());
// }

// @Bean
// public Firestore firestore() {
// return FirestoreClient.getFirestore();
// }
// }
