package vn.group3.marketplace.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import vn.group3.marketplace.service.interfaces.FileUploadService;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify FileUploadService bean injection
 */
@SpringBootTest
public class FileUploadServiceTest {

    @Autowired
    private FileUploadService fileUploadService;

    @Test
    public void testFileUploadServiceBeanExists() {
        // Verify that FileUploadService bean is properly injected
        assertNotNull(fileUploadService, "FileUploadService should be injected");
        
        // Verify basic functionality
        assertTrue(fileUploadService.getMaxFileSize() > 0, "Max file size should be configured");
        assertNotNull(fileUploadService.getAllowedExtensions(), "Allowed extensions should be configured");
        assertTrue(fileUploadService.getAllowedExtensions().length > 0, "Should have allowed extensions");
    }

    @Test
    public void testFileValidation() {
        // Test that validation methods work
        assertFalse(fileUploadService.isValidImageFile(null), "Null file should be invalid");
    }
}
