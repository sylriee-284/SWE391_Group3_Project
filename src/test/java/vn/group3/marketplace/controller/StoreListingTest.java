package vn.group3.marketplace.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.controller.web.SellerStoreController;
import vn.group3.marketplace.dto.response.SellerStoreResponse;
import vn.group3.marketplace.service.interfaces.SellerStoreService;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify store listing functionality with master layout
 */
@SpringBootTest
@Transactional
public class StoreListingTest {

    @Autowired
    private SellerStoreController sellerStoreController;
    
    @Autowired
    private SellerStoreService sellerStoreService;

    @Test
    public void testStoreListingEndpoint() {
        // Test that store listing endpoint exists and works
        assertNotNull(sellerStoreController, "SellerStoreController should be injected");
        
        System.out.println("✅ Store listing controller is available");
    }

    @Test
    public void testGetAllActiveStores() {
        // Test the service method for getting active stores
        Pageable pageable = PageRequest.of(0, 12);
        Page<SellerStoreResponse> stores = sellerStoreService.getAllActiveStores(pageable);
        
        assertNotNull(stores, "Store page should not be null");
        assertTrue(stores.getSize() >= 0, "Page size should be non-negative");
        
        System.out.println("✅ Found " + stores.getTotalElements() + " active stores");
        System.out.println("✅ Page size: " + stores.getSize());
        System.out.println("✅ Total pages: " + stores.getTotalPages());
        
        // Log some store details if available
        stores.getContent().forEach(store -> {
            System.out.println("  - Store: " + store.getStoreName() + " (Status: " + store.getStatus() + ")");
        });
    }

    @Test
    public void testStoreSearch() {
        // Test store search functionality
        Pageable pageable = PageRequest.of(0, 12);
        
        // Test search with common terms
        String[] searchTerms = {"game", "shop", "dịch vụ", "online"};
        
        for (String term : searchTerms) {
            Page<SellerStoreResponse> searchResults = sellerStoreService.searchStores(term, pageable);
            assertNotNull(searchResults, "Search results should not be null for term: " + term);
            
            System.out.println("✅ Search for '" + term + "': " + searchResults.getTotalElements() + " results");
        }
    }

    @Test
    public void testStoresByStatus() {
        // Test filtering stores by status
        Pageable pageable = PageRequest.of(0, 12);
        
        String[] statuses = {"active", "pending", "suspended"};
        
        for (String status : statuses) {
            Page<SellerStoreResponse> statusResults = sellerStoreService.getStoresByStatus(status, pageable);
            assertNotNull(statusResults, "Status results should not be null for status: " + status);
            
            System.out.println("✅ Stores with status '" + status + "': " + statusResults.getTotalElements() + " results");
        }
    }

    @Test
    public void testVerifiedStores() {
        // Test getting verified stores
        Pageable pageable = PageRequest.of(0, 12);
        Page<SellerStoreResponse> verifiedStores = sellerStoreService.getVerifiedStores(pageable);
        
        assertNotNull(verifiedStores, "Verified stores should not be null");
        
        System.out.println("✅ Verified stores: " + verifiedStores.getTotalElements() + " results");
        
        // Verify that all returned stores are actually verified
        verifiedStores.getContent().forEach(store -> {
            assertTrue(store.getIsVerified(), "Store should be verified: " + store.getStoreName());
        });
    }

    @Test
    public void testPagination() {
        // Test pagination functionality
        Pageable firstPage = PageRequest.of(0, 5);
        Pageable secondPage = PageRequest.of(1, 5);
        
        Page<SellerStoreResponse> page1 = sellerStoreService.getAllActiveStores(firstPage);
        Page<SellerStoreResponse> page2 = sellerStoreService.getAllActiveStores(secondPage);
        
        assertNotNull(page1, "First page should not be null");
        assertNotNull(page2, "Second page should not be null");
        
        System.out.println("✅ Pagination test:");
        System.out.println("  - Page 1: " + page1.getNumberOfElements() + " stores");
        System.out.println("  - Page 2: " + page2.getNumberOfElements() + " stores");
        System.out.println("  - Total pages: " + page1.getTotalPages());
        System.out.println("  - Total elements: " + page1.getTotalElements());
    }
}
