package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Role;

import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Repository interface for Role entity
 * Provides data access methods for role management
 */
@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {

    /**
     * Find role by code
     * @param code Role code to search for
     * @return Optional containing role if found
     */
    Optional<Role> findByCode(String code);

    /**
     * Find role by name
     * @param name Role name to search for
     * @return Optional containing role if found
     */
    Optional<Role> findByName(String name);

    /**
     * Check if role code exists
     * @param code Role code to check
     * @return true if role code exists
     */
    boolean existsByCode(String code);

    /**
     * Check if role name exists
     * @param name Role name to check
     * @return true if role name exists
     */
    boolean existsByName(String name);

    /**
     * Find roles by codes
     * @param codes Set of role codes to search for
     * @return List of roles with specified codes
     */
    @Query("SELECT r FROM Role r WHERE r.code IN :codes AND r.isDeleted = false")
    List<Role> findByCodes(@Param("codes") Set<String> codes);

    /**
     * Find roles with specific permission
     * @param permissionCode Permission code to filter by
     * @return List of roles that have the specified permission
     */
    @Query("SELECT r FROM Role r JOIN r.permissions p WHERE p.code = :permissionCode AND r.isDeleted = false")
    List<Role> findByPermissionCode(@Param("permissionCode") String permissionCode);

    /**
     * Find all non-deleted roles
     * @return List of all active roles
     */
    @Query("SELECT r FROM Role r WHERE r.isDeleted = false ORDER BY r.name")
    List<Role> findAllActive();

    /**
     * Find default roles for new users
     * @return List of default roles (typically BUYER role)
     */
    @Query("SELECT r FROM Role r WHERE r.code IN ('BUYER') AND r.isDeleted = false")
    List<Role> findDefaultRoles();

    /**
     * Count users with specific role
     * @param roleCode Role code to count users for
     * @return Number of users with specified role
     */
    @Query("SELECT COUNT(u) FROM User u JOIN u.roles r WHERE r.code = :roleCode AND u.isDeleted = false")
    long countUsersByRoleCode(@Param("roleCode") String roleCode);
}
