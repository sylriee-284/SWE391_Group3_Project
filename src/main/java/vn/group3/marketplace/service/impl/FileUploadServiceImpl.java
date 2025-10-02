package vn.group3.marketplace.service.impl;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import vn.group3.marketplace.service.interfaces.FileUploadService;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.UUID;

@Slf4j
@Service
public class FileUploadServiceImpl implements FileUploadService {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.upload.max-file-size:2097152}") // 2MB default
    private long maxFileSize;

    @Value("${app.upload.allowed-extensions:jpg,jpeg,png,gif}")
    private String allowedExtensions;

    private static final String STORE_LOGO_DIR = "stores/logos";
    private static final String PRODUCT_IMAGE_DIR = "products/images";
    private static final String USER_AVATAR_DIR = "users/avatars";

    @Override
    public String uploadStoreLogo(Long storeId, MultipartFile logoFile) {
        log.info("Uploading logo for store {}", storeId);
        
        if (!isValidImageFile(logoFile)) {
            throw new IllegalArgumentException("Invalid image file");
        }

        String fileName = generateFileName(logoFile.getOriginalFilename());
        String relativePath = STORE_LOGO_DIR + "/" + storeId + "/" + fileName;
        
        try {
            String fullPath = saveFile(logoFile, relativePath);
            String fileUrl = "/uploads/" + relativePath;

            log.info("Successfully uploaded store logo: {}", fileUrl);
            return fileUrl;
            
        } catch (IOException e) {
            log.error("Failed to upload store logo for store {}: {}", storeId, e.getMessage());
            throw new RuntimeException("Failed to upload logo: " + e.getMessage(), e);
        }
    }

    @Override
    public String uploadProductImage(Long productId, MultipartFile imageFile) {
        log.info("Uploading image for product {}", productId);
        
        if (!isValidImageFile(imageFile)) {
            throw new IllegalArgumentException("Invalid image file");
        }

        String fileName = generateFileName(imageFile.getOriginalFilename());
        String relativePath = PRODUCT_IMAGE_DIR + "/" + productId + "/" + fileName;
        
        try {
            String fullPath = saveFile(imageFile, relativePath);
            String fileUrl = "/uploads/" + relativePath;

            log.info("Successfully uploaded product image: {}", fileUrl);
            return fileUrl;
            
        } catch (IOException e) {
            log.error("Failed to upload product image for product {}: {}", productId, e.getMessage());
            throw new RuntimeException("Failed to upload image: " + e.getMessage(), e);
        }
    }

    @Override
    public String uploadUserAvatar(Long userId, MultipartFile avatarFile) {
        log.info("Uploading avatar for user {}", userId);
        
        if (!isValidImageFile(avatarFile)) {
            throw new IllegalArgumentException("Invalid image file");
        }

        String fileName = generateFileName(avatarFile.getOriginalFilename());
        String relativePath = USER_AVATAR_DIR + "/" + userId + "/" + fileName;
        
        try {
            String fullPath = saveFile(avatarFile, relativePath);
            String fileUrl = "/uploads/" + relativePath;

            log.info("Successfully uploaded user avatar: {}", fileUrl);
            return fileUrl;
            
        } catch (IOException e) {
            log.error("Failed to upload user avatar for user {}: {}", userId, e.getMessage());
            throw new RuntimeException("Failed to upload avatar: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean deleteFile(String fileUrl) {
        if (fileUrl == null || fileUrl.isEmpty()) {
            return false;
        }

        try {
            // Handle both absolute URLs and relative paths
            String relativePath;
            if (fileUrl.startsWith("http://") || fileUrl.startsWith("https://")) {
                // Legacy absolute URL format: http://localhost:8080/uploads/...
                relativePath = fileUrl.replaceFirst("^https?://[^/]+/uploads/", "");
            } else if (fileUrl.startsWith("/uploads/")) {
                // New relative path format: /uploads/...
                relativePath = fileUrl.replace("/uploads/", "");
            } else {
                // Direct path: products/images/...
                relativePath = fileUrl;
            }

            Path filePath = Paths.get(uploadDir, relativePath);

            if (Files.exists(filePath)) {
                Files.delete(filePath);
                log.info("Successfully deleted file: {}", fileUrl);
                return true;
            }

        } catch (IOException e) {
            log.error("Failed to delete file {}: {}", fileUrl, e.getMessage());
        }

        return false;
    }

    @Override
    public boolean isValidImageFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return false;
        }

        // Check file size
        if (file.getSize() > maxFileSize) {
            log.warn("File size {} exceeds maximum allowed size {}", file.getSize(), maxFileSize);
            return false;
        }

        // Check file extension
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            return false;
        }

        String extension = getFileExtension(originalFilename).toLowerCase();
        String[] allowed = getAllowedExtensions();
        
        boolean isValidExtension = Arrays.asList(allowed).contains(extension);
        if (!isValidExtension) {
            log.warn("File extension {} is not allowed. Allowed: {}", extension, Arrays.toString(allowed));
            return false;
        }

        // Check content type
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            log.warn("Invalid content type: {}", contentType);
            return false;
        }

        return true;
    }

    @Override
    public long getMaxFileSize() {
        return maxFileSize;
    }

    @Override
    public String[] getAllowedExtensions() {
        return allowedExtensions.split(",");
    }

    private String saveFile(MultipartFile file, String relativePath) throws IOException {
        Path uploadPath = Paths.get(uploadDir, relativePath);
        
        // Create directories if they don't exist
        Files.createDirectories(uploadPath.getParent());
        
        // Save file
        Files.copy(file.getInputStream(), uploadPath, StandardCopyOption.REPLACE_EXISTING);
        
        return uploadPath.toString();
    }

    private String generateFileName(String originalFilename) {
        String extension = getFileExtension(originalFilename);
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        
        return timestamp + "_" + uuid + "." + extension;
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1);
    }
}
