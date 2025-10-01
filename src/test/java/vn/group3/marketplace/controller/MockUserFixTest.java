package vn.group3.marketplace.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.controller.web.SellerStoreController;
import vn.group3.marketplace.domain.entity.User;

import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify the mock user fix for "The given id must not be null" issue
 */
@SpringBootTest
@Transactional
public class MockUserFixTest {

    @Autowired
    private SellerStoreController sellerStoreController;

    @Test
    public void testMockUserCreation() throws Exception {
        // Use reflection to access private createMockUser method
        Method createMockUserMethod = SellerStoreController.class.getDeclaredMethod("createMockUser");
        createMockUserMethod.setAccessible(true);
        
        User mockUser = (User) createMockUserMethod.invoke(sellerStoreController);
        
        assertNotNull(mockUser, "Mock user should not be null");
        assertNotNull(mockUser.getId(), "Mock user should have an ID");
        assertEquals(4L, mockUser.getId(), "Mock user should have ID = 4");
        assertEquals("mockuser4", mockUser.getUsername());
        assertEquals("mock4@taphoammo.com", mockUser.getEmail());
        assertEquals("Mock User (ID=4)", mockUser.getFullName());
        assertTrue(mockUser.getEnabled());
        
        System.out.println("✅ Mock user created successfully with ID: " + mockUser.getId());
    }

    @Test
    public void testUserIdIsNotNull() throws Exception {
        // Test that the mock user ID is never null
        Method createMockUserMethod = SellerStoreController.class.getDeclaredMethod("createMockUser");
        createMockUserMethod.setAccessible(true);
        
        User mockUser = (User) createMockUserMethod.invoke(sellerStoreController);
        
        assertNotNull(mockUser.getId(), "User ID must not be null");
        assertTrue(mockUser.getId() instanceof Long, "User ID should be Long type");
        assertEquals(4L, mockUser.getId(), "User ID should be exactly 4");
        
        System.out.println("✅ User ID is valid: " + mockUser.getId() + " (type: " + mockUser.getId().getClass().getSimpleName() + ")");
    }

    @Test
    public void testControllerExists() {
        // Basic test to ensure controller is properly injected
        assertNotNull(sellerStoreController, "SellerStoreController should be injected");
        System.out.println("✅ SellerStoreController is properly injected");
    }
}
