package vn.group3.marketplace;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Simple test to verify Spring Boot test setup
 */
@SpringBootTest
public class SimpleTest {

    @Test
    public void contextLoads() {
        // Simple test to verify Spring context loads
        assertTrue(true, "Context should load successfully");
    }
}
