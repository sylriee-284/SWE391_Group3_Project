package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.User;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for User entity
 * Provides data access methods for user management
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

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
     * @param username Username to search for
     * @param email Email to search for
     * @return Optional containing user if found
     */
    Optional<User> findByUsernameOrEmail(String username, String email);

    /**
     * Check if username exists
     * @param username Username to check
     * @return true if username exists
     */
    boolean existsByUsername(String username);

    /**
     * Check if email exists
     * @param email Email to check
     * @return true if email exists
     */
    boolean existsByEmail(String email);

    /**
     * Find users by status with roles loaded
     * @param status User status to filter by
     * @param pageable Pagination information
     * @return Page of users with specified status and roles
     */
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.roles WHERE u.status = :status AND u.isDeleted = false")
    Page<User> findByStatus(@Param("status") String status, Pageable pageable);

    /**
     * Find users by enabled status
     * @param enabled Enabled status to filter by
     * @param pageable Pagination information
     * @return Page of users with specified enabled status
     */
    Page<User> findByEnabled(Boolean enabled, Pageable pageable);

    /**
     * Find users by role code with roles loaded
     * @param roleCode Role code to filter by
     * @param pageable Pagination information
     * @return Page of users with specified role and all roles loaded
     */
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.roles r WHERE r.code = :roleCode AND u.isDeleted = false")
    Page<User> findByRoleCode(@Param("roleCode") String roleCode, Pageable pageable);

    /**
     * Find users with seller stores
     * @param pageable Pagination information
     * @return Page of users who have seller stores
     */
    @Query("SELECT u FROM User u WHERE u.sellerStore IS NOT NULL AND u.isDeleted = false")
    Page<User> findUsersWithSellerStores(Pageable pageable);

    /**
     * Search users by username, email, or full name with roles loaded
     * @param searchTerm Search term to match against
     * @param pageable Pagination information
     * @return Page of matching users with roles
     */
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.roles WHERE " +
           "(LOWER(u.username) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND " +
           "u.isDeleted = false")
    Page<User> searchUsers(@Param("searchTerm") String searchTerm, Pageable pageable);

    /**
     * Find users created by specific user
     * @param createdBy ID of user who created these users
     * @param pageable Pagination information
     * @return Page of users created by specified user
     */
    Page<User> findByCreatedBy(Long createdBy, Pageable pageable);

    /**
     * Count users by status
     * @param status User status to count
     * @return Number of users with specified status
     */
    long countByStatus(String status);

    /**
     * Count enabled users
     * @param enabled Enabled status to count
     * @return Number of users with specified enabled status
     */
    long countByEnabled(Boolean enabled);

    /**
     * Find user by ID with roles loaded
     * @param id User ID
     * @return Optional containing user with roles if found
     */
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.roles WHERE u.id = :id")
    Optional<User> findByIdWithRoles(@Param("id") Long id);

    /**
     * Find user by username with roles loaded
     * @param username Username to search for
     * @return Optional containing user with roles if found
     */
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.roles WHERE u.username = :username")
    Optional<User> findByUsernameWithRoles(@Param("username") String username);

    /**
     * Find users with wallet balance greater than specified amount
     * @param minBalance Minimum wallet balance
     * @param pageable Pagination information
     * @return Page of users with sufficient wallet balance
     */
    @Query("SELECT u FROM User u JOIN u.wallet w WHERE w.balance >= :minBalance AND u.isDeleted = false")
    Page<User> findUsersWithMinBalance(@Param("minBalance") java.math.BigDecimal minBalance, Pageable pageable);

    /**
     * Find all non-deleted users (override default behavior)
     * @return List of all non-deleted users
     */
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.roles WHERE u.isDeleted = false")
    List<User> findAllActive();

    /**
     * Find all non-deleted users with pagination and roles loaded
     * @param pageable Pagination information
     * @return Page of all non-deleted users with roles
     */
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.roles WHERE u.isDeleted = false")
    Page<User> findAllActive(Pageable pageable);
}
