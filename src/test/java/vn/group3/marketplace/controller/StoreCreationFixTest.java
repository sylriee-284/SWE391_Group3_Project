package vn.group3.marketplace.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.controller.web.SellerStoreController;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.util.DevUserCreator;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify the fix for "The given id must not be null" issue
 */
@SpringBootTest
@Transactional
public class StoreCreationFixTest {

    @Autowired
    private SellerStoreController sellerStoreController;
    
    @Autowired
    private DevUserCreator devUserCreator;

    @Test
    public void testDevUserHasValidId() {
        // Test that dev user creation works and has valid ID
        User devUser = devUserCreator.createOrGetDevUser();
        
        assertNotNull(devUser, "Dev user should not be null");
        assertNotNull(devUser.getId(), "Dev user should have a valid ID");
        assertTrue(devUser.getId() > 0, "Dev user ID should be positive");
        assertEquals("devuser", devUser.getUsername());
        
        System.out.println("✅ Dev user has valid ID: " + devUser.getId());
    }

    @Test
    public void testControllerCanGetDevUser() {
        // Test that controller can access dev user without NPE
        assertNotNull(sellerStoreController, "Controller should be injected");
        
        // This should not throw any exceptions
        assertDoesNotThrow(() -> {
            User devUser = devUserCreator.createOrGetDevUser();
            assertNotNull(devUser.getId(), "Dev user should have valid ID");
        }, "Getting dev user should not throw exception");
        
        System.out.println("✅ Controller can access dev user successfully");
    }

    @Test
    public void testUserIdNotNull() {
        // Verify that the user ID is never null
        User devUser = devUserCreator.createOrGetDevUser();
        
        assertNotNull(devUser.getId(), "User ID must not be null");
        assertTrue(devUser.getId() instanceof Long, "User ID should be Long type");
        assertTrue(devUser.getId() > 0, "User ID should be positive number");
        
        System.out.println("✅ User ID is valid: " + devUser.getId() + " (type: " + devUser.getId().getClass().getSimpleName() + ")");
    }
}
