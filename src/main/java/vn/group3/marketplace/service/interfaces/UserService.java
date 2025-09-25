package vn.group3.marketplace.service.interfaces;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.group3.marketplace.domain.entity.User;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service interface for User management
 * Defines business operations for user-related functionality
 */
public interface UserService {

    /**
     * Register a new user
     * @param user User entity to register
     * @param rawPassword Plain text password
     * @return Registered user with encrypted password
     */
    User registerUser(User user, String rawPassword);

    /**
     * Find user by ID
     * @param id User ID
     * @return Optional containing user if found
     */
    Optional<User> findById(Long id);

    /**
     * Find user by username
     * @param username Username to search for
     * @return Optional containing user if found
     */
    Optional<User> findByUsername(String username);

    /**
     * Find user by email
     * @param email Email to search for
     * @return Optional containing user if found
     */
    Optional<User> findByEmail(String email);

    /**
     * Find user by username or email
     * @param usernameOrEmail Username or email to search for
     * @return Optional containing user if found
     */
    Optional<User> findByUsernameOrEmail(String usernameOrEmail);

    /**
     * Update user profile
     * @param user User entity with updated information
     * @return Updated user
     */
    User updateUser(User user);

    /**
     * Change user password
     * @param userId User ID
     * @param oldPassword Current password
     * @param newPassword New password
     * @return true if password changed successfully
     */
    boolean changePassword(Long userId, String oldPassword, String newPassword);

    /**
     * Update user status
     * @param userId User ID
     * @param status New status
     * @return Updated user
     */
    User updateUserStatus(Long userId, String status);

    /**
     * Enable or disable user account
     * @param userId User ID
     * @param enabled Enable/disable flag
     * @return Updated user
     */
    User setUserEnabled(Long userId, boolean enabled);

    /**
     * Lock or unlock user account
     * @param userId User ID
     * @param locked Lock/unlock flag
     * @return Updated user
     */
    User setUserLocked(Long userId, boolean locked);

    /**
     * Soft delete user
     * @param userId User ID to delete
     * @param deletedBy ID of user performing deletion
     */
    void deleteUser(Long userId, Long deletedBy);

    /**
     * Restore soft deleted user
     * @param userId User ID to restore
     */
    void restoreUser(Long userId);

    /**
     * Assign role to user
     * @param userId User ID
     * @param roleCode Role code to assign
     * @return Updated user
     */
    User assignRole(Long userId, String roleCode);

    /**
     * Remove role from user
     * @param userId User ID
     * @param roleCode Role code to remove
     * @return Updated user
     */
    User removeRole(Long userId, String roleCode);

    /**
     * Check if username is available
     * @param username Username to check
     * @return true if username is available
     */
    boolean isUsernameAvailable(String username);

    /**
     * Check if email is available
     * @param email Email to check
     * @return true if email is available
     */
    boolean isEmailAvailable(String email);

    /**
     * Get all users with pagination
     * @param pageable Pagination information
     * @return Page of users
     */
    Page<User> getAllUsers(Pageable pageable);

    /**
     * Search users by term
     * @param searchTerm Search term
     * @param pageable Pagination information
     * @return Page of matching users
     */
    Page<User> searchUsers(String searchTerm, Pageable pageable);

    /**
     * Get users by status
     * @param status User status
     * @param pageable Pagination information
     * @return Page of users with specified status
     */
    Page<User> getUsersByStatus(String status, Pageable pageable);

    /**
     * Get users by role
     * @param roleCode Role code
     * @param pageable Pagination information
     * @return Page of users with specified role
     */
    Page<User> getUsersByRole(String roleCode, Pageable pageable);

    /**
     * Get users with seller stores
     * @param pageable Pagination information
     * @return Page of users who have seller stores
     */
    Page<User> getUsersWithSellerStores(Pageable pageable);

    /**
     * Get users with minimum wallet balance
     * @param minBalance Minimum balance threshold
     * @param pageable Pagination information
     * @return Page of users with sufficient balance
     */
    Page<User> getUsersWithMinBalance(BigDecimal minBalance, Pageable pageable);

    /**
     * Get user statistics
     * @return Map containing user statistics
     */
    java.util.Map<String, Long> getUserStatistics();

    /**
     * Validate user for seller store creation
     * @param userId User ID
     * @param depositAmount Required deposit amount
     * @return true if user can create seller store
     */
    boolean canCreateSellerStore(Long userId, BigDecimal depositAmount);
}
