package vn.group3.marketplace.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.UserRepository;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify DevUserConfig creates development user properly
 */
@SpringBootTest
@Transactional
public class DevUserConfigTest {

    @Autowired
    private UserRepository userRepository;

    @Test
    public void testDevUserExists() {
        // Check if development user was created
        Optional<User> devUser = userRepository.findByUsername("devuser");
        
        assertTrue(devUser.isPresent(), "Development user should exist");
        
        User user = devUser.get();
        assertNotNull(user.getId(), "Development user should have an ID");
        assertEquals("devuser", user.getUsername());
        assertEquals("dev@taphoammo.com", user.getEmail());
        assertEquals("Development User", user.getFullName());
        assertEquals("0123456789", user.getPhone());
        assertTrue(user.getEnabled());
        
        System.out.println("Development user found with ID: " + user.getId());
    }

    @Test
    public void testGetDevUserMethod() {
        // Test the static method used by controllers
        try {
            User devUser = DevUserConfig.getDevUser(userRepository);
            assertNotNull(devUser, "DevUserConfig.getDevUser should return a user");
            assertNotNull(devUser.getId(), "Development user should have an ID");
            assertEquals("devuser", devUser.getUsername());
            
            System.out.println("DevUserConfig.getDevUser() returned user with ID: " + devUser.getId());
        } catch (Exception e) {
            fail("DevUserConfig.getDevUser should not throw exception: " + e.getMessage());
        }
    }
}
