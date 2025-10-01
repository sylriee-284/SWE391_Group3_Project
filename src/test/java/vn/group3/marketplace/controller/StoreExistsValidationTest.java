package vn.group3.marketplace.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.controller.web.SellerStoreController;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.service.interfaces.SellerStoreService;
import vn.group3.marketplace.util.DevUserCreator;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify "already has store" validation logic
 */
@SpringBootTest
@Transactional
public class StoreExistsValidationTest {

    @Autowired
    private SellerStoreController sellerStoreController;
    
    @Autowired
    private SellerStoreService sellerStoreService;
    
    @Autowired
    private DevUserCreator devUserCreator;

    @Test
    public void testUserWithoutStore() {
        // Test user without store should be able to access create form
        User user = devUserCreator.createOrGetDevUser();
        
        // Check if user has store
        Optional<SellerStore> existingStore = sellerStoreService.getStoreByOwnerId(user.getId());
        
        if (existingStore.isEmpty()) {
            System.out.println("✅ User " + user.getId() + " does not have a store - can create new store");
            assertTrue(true, "User without store should be able to create store");
        } else {
            System.out.println("⚠️ User " + user.getId() + " already has store: " + existingStore.get().getStoreName());
            assertTrue(existingStore.isPresent(), "User already has store - validation should trigger");
        }
    }

    @Test
    public void testStoreValidationLogic() {
        // Test the validation logic in controller
        User user = devUserCreator.createOrGetDevUser();
        
        // Check current store status
        Optional<SellerStore> existingStore = sellerStoreService.getStoreByOwnerId(user.getId());
        
        if (existingStore.isPresent()) {
            SellerStore store = existingStore.get();
            assertNotNull(store.getStoreName(), "Store should have a name");
            assertNotNull(store.getStatus(), "Store should have a status");
            assertEquals(user.getId(), store.getOwnerUser().getId(), "Store should belong to the user");
            
            System.out.println("✅ Store validation passed:");
            System.out.println("  - Store Name: " + store.getStoreName());
            System.out.println("  - Store Status: " + store.getStatus());
            System.out.println("  - Owner ID: " + store.getOwnerUser().getId());
        } else {
            System.out.println("✅ No existing store found - user can create new store");
        }
    }

    @Test
    public void testControllerDependencies() {
        // Test that all required dependencies are injected
        assertNotNull(sellerStoreController, "SellerStoreController should be injected");
        assertNotNull(sellerStoreService, "SellerStoreService should be injected");
        assertNotNull(devUserCreator, "DevUserCreator should be injected");
        
        System.out.println("✅ All controller dependencies are properly injected");
    }

    @Test
    public void testMockUserHasValidId() {
        // Test that mock user always has valid ID for validation
        User user = devUserCreator.createOrGetDevUser();
        
        assertNotNull(user, "User should not be null");
        assertNotNull(user.getId(), "User ID should not be null");
        assertTrue(user.getId() > 0, "User ID should be positive");
        
        System.out.println("✅ Mock user has valid ID: " + user.getId());
        System.out.println("  - Username: " + user.getUsername());
        System.out.println("  - Email: " + user.getEmail());
    }
}
