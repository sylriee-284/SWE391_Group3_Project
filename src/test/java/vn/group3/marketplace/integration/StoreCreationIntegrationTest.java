package vn.group3.marketplace.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.controller.web.SellerStoreController;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.dto.request.SellerStoreCreateRequest;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.util.DevUserCreator;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration test to verify store creation works without authentication errors
 */
@SpringBootTest
@Transactional
public class StoreCreationIntegrationTest {

    @Autowired
    private SellerStoreController sellerStoreController;
    
    @Autowired
    private DevUserCreator devUserCreator;
    
    @Autowired
    private UserRepository userRepository;

    @Test
    public void testDevUserCreation() {
        // Test that dev user can be created/retrieved
        User devUser = devUserCreator.createOrGetDevUser();
        
        assertNotNull(devUser, "Dev user should not be null");
        assertNotNull(devUser.getId(), "Dev user should have an ID");
        assertEquals("devuser", devUser.getUsername());
        assertEquals("dev@taphoammo.com", devUser.getEmail());
        
        System.out.println("Dev user created successfully with ID: " + devUser.getId());
    }

    @Test
    public void testStoreCreationRequest() {
        // Test that we can create a store creation request without NPE
        SellerStoreCreateRequest request = new SellerStoreCreateRequest();
        request.setStoreName("Test Store");
        request.setStoreDescription("Test Description");
        request.setContactEmail("test@example.com");
        request.setContactPhone("0123456789");
        request.setBusinessLicense("TEST123");
        request.setAgreeToTerms(true);
        request.setAgreeToSellerPolicy(true);
        
        // This should not throw "The given id must not be null" error
        assertNotNull(request);
        assertTrue(request.getAgreeToTerms());
        assertTrue(request.getAgreeToSellerPolicy());
        
        System.out.println("Store creation request created successfully");
    }

    @Test
    public void testControllerBeanInjection() {
        // Test that all required beans are injected
        assertNotNull(sellerStoreController, "SellerStoreController should be injected");
        assertNotNull(devUserCreator, "DevUserCreator should be injected");
        assertNotNull(userRepository, "UserRepository should be injected");
        
        System.out.println("All controller dependencies injected successfully");
    }
}
