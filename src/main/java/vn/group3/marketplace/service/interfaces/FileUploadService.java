package vn.group3.marketplace.service.interfaces;

import org.springframework.web.multipart.MultipartFile;

/**
 * Service interface for file upload operations
 */
public interface FileUploadService {

    /**
     * Upload store logo
     * @param storeId Store ID
     * @param logoFile Logo file to upload
     * @return URL of uploaded logo
     */
    String uploadStoreLogo(Long storeId, MultipartFile logoFile);

    /**
     * Upload product image
     * @param productId Product ID
     * @param imageFile Image file to upload
     * @return URL of uploaded image
     */
    String uploadProductImage(Long productId, MultipartFile imageFile);

    /**
     * Upload user avatar
     * @param userId User ID
     * @param avatarFile Avatar file to upload
     * @return URL of uploaded avatar
     */
    String uploadUserAvatar(Long userId, MultipartFile avatarFile);

    /**
     * Delete file by URL
     * @param fileUrl File URL to delete
     * @return true if deleted successfully
     */
    boolean deleteFile(String fileUrl);

    /**
     * Validate image file
     * @param file File to validate
     * @return true if valid
     */
    boolean isValidImageFile(MultipartFile file);

    /**
     * Get file size limit in bytes
     * @return Maximum file size
     */
    long getMaxFileSize();

    /**
     * Get allowed file extensions
     * @return Array of allowed extensions
     */
    String[] getAllowedExtensions();
}
