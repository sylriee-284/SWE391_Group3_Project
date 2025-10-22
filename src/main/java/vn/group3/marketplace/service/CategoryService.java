package vn.group3.marketplace.service;

import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.repository.CategoryRepository;
import org.springframework.data.domain.Page;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.data.domain.Pageable;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findByIsDeletedFalse(); // Get only active categories
    }

    /**
     * Find all parent categories (categories with parent_id = null)
     * 
     * @return List of parent categories
     */
    public List<Category> getParentCategories() {
        return categoryRepository.findByParentIsNullAndIsDeletedFalse();
    }

    /**
     * Find child categories by parent id
     * 
     * @param parentId Parent category id
     * @return List of child categories
     */
    public List<Category> getChildCategories(Long parentId) {
        return categoryRepository.findByParentIdAndIsDeletedFalse(parentId);
    }

    /**
     * Find child categories by parent category
     * 
     * @param parent Parent category
     * @return List of child categories
     */
    public List<Category> getChildCategories(Category parent) {
        return categoryRepository.findByParentAndIsDeletedFalse(parent);
    }

    /**
     * Get category by id
     * 
     * @param id Category id
     * @return Category or null if not found
     */
    public Category getCategoryById(Long id) {
        return categoryRepository.findById(id).orElse(null);
    }

    /**
     * Get category by name
     *
     * @param name Category name
     * @return Category or null if not found
     */
    public Category getCategoryByName(String name) {
        return categoryRepository.findByNameAndIsDeletedFalse(name).orElse(null);
    }

    /**
     * Get parent category by name (case insensitive)
     * 
     * @param name Category name
     * @return Parent category or null if not found
     */
    public Category getParentCategoryByName(String name) {
        // First try exact match
        Category category = getCategoryByName(name);
        if (category != null && category.getParent() == null) {
            return category;
        }

        // If not found, try case insensitive search among parent categories
        return getParentCategories().stream()
                .filter(cat -> cat.getName().equalsIgnoreCase(name))
                .findFirst()
                .orElse(null);
    }

    // =========================Fix Below=========================
    // ========================= DANH MỤC CHA =========================

    @PersistenceContext
    private EntityManager em;

    public List<Category> findParentCategories() {
        String jpql = """
                SELECT c FROM Category c
                WHERE c.parent IS NULL
                  AND c.isDeleted = false
                ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class).getResultList();
    }

    public Page<Category> findParentCategories(int page, int size) {
        String base = """
                FROM Category c
                WHERE c.parent IS NULL
                  AND c.isDeleted = false
                """;

        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        List<Category> content = em.createQuery(select, Category.class)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
        Long total = em.createQuery(count, Long.class).getSingleResult();
        return new PageImpl<>(content, PageRequest.of(page, size), total);
    }

    // ========================= DANH MỤC CON =========================
    public List<Category> findSubcategoriesByParentId(Long parentId) {
        String jpql = """
                SELECT c FROM Category c
                WHERE c.parent.id = :pid
                  AND c.isDeleted = false
                ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class)
                .setParameter("pid", parentId)
                .getResultList();
    }

    public Page<Category> findSubcategoriesByParentId(Long parentId, int page, int size) {
        String base = """
                FROM Category c
                WHERE c.parent.id = :pid
                  AND c.isDeleted = false
                """;

        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        List<Category> content = em.createQuery(select, Category.class)
                .setParameter("pid", parentId)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
        Long total = em.createQuery(count, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();
        return new PageImpl<>(content, PageRequest.of(page, size), total);
    }

    // ========================= CRUD & TIỆN ÍCH =========================
    public Optional<Category> getById(Long id) {
        return categoryRepository.findByIdAndIsDeletedFalse(id);
    }

    @Transactional
    public Category save(Category c) {
        if (c.getParent() != null && c.getParent().getId() != null && c.getParent().getId() == 0) {
            c.setParent(null);
        }
        if (c.getId() == null) {
            c.setIsDeleted(false);
            em.persist(c);
            return c;
        } else {
            return em.merge(c);
        }
    }

    @Transactional
    public void softDelete(Long id) {
        Category c = categoryRepository.findByIdAndIsDeletedFalse(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy category id=" + id));
        c.setIsDeleted(true);
        // TODO: c.setDeletedBy(currentUserId);
        categoryRepository.save(c);
    }

    public boolean hasChildren(Long parentId) {
        String jpql = "SELECT COUNT(c) FROM Category c WHERE c.parent.id = :pid AND c.isDeleted = false";
        Long cnt = em.createQuery(jpql, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();
        return cnt != null && cnt > 0;
    }

    @Transactional
    public Category toggleStatusAndReturn(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));
        boolean cur = Boolean.TRUE.equals(c.getIsDeleted());
        c.setIsDeleted(!cur); // Đảo 2 chiều
        return categoryRepository.save(c);
    }

    /**
     * Lấy con trực tiếp theo parent + phân trang bằng Spring Data Repository
     * (chỉ những danh mục chưa xoá)
     * YÊU CẦU: trong CategoryRepository có method:
     * Page<Category> findByParent_IdAndIsDeletedFalse(Long parentId, Pageable p);
     */
    public Page<Category> findChildren(Long parentId, int page, int size) {
        return categoryRepository.findByParent_IdAndIsDeletedFalse(
                parentId, PageRequest.of(page, size));
    }

    // ========== LUÔN HIỂN THỊ TẤT CẢ (CHA) ==========
    public Page<Category> findParentCategoriesAll(int page, int size) {
        String jpql = "SELECT c FROM Category c WHERE c.parent IS NULL ORDER BY c.id DESC";
        String countJpql = "SELECT COUNT(c) FROM Category c WHERE c.parent IS NULL";

        var query = em.createQuery(jpql, Category.class)
                .setFirstResult(page * size)
                .setMaxResults(size);
        var items = query.getResultList();

        Long total = em.createQuery(countJpql, Long.class).getSingleResult();
        return new PageImpl<>(items, PageRequest.of(page, size), total);
    }

    // ========== LUÔN HIỂN THỊ TẤT CẢ (CON) ==========
    public Page<Category> findSubcategoriesAll(Long parentId, int page, int size) {
        String jpql = "SELECT c FROM Category c WHERE c.parent.id = :pid ORDER BY c.id DESC";
        String countJpql = "SELECT COUNT(c) FROM Category c WHERE c.parent.id = :pid";

        var query = em.createQuery(jpql, Category.class)
                .setParameter("pid", parentId)
                .setFirstResult(page * size)
                .setMaxResults(size);
        var items = query.getResultList();

        Long total = em.createQuery(countJpql, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();
        return new PageImpl<>(items, PageRequest.of(page, size), total);
    }

    // Lấy bất kỳ danh mục theo ID, kể cả INACTIVE (isDeleted=true)
    public Optional<Category> findAnyById(Long id) {
        return categoryRepository.findById(id); // KHÔNG thêm điều kiện active
    }

    // NEW: CHA có lọc theo q + active
    public Page<Category> findParentCategoriesFiltered(int page, int size, String q, Boolean active) {
        // Lấy tất cả rồi lọc (đủ dùng cho dữ liệu vừa/nhỏ)
        List<Category> all = categoryRepository.findAll(); // hoặc dùng hàm có sẵn
        List<Category> parents = all.stream()
                .filter(c -> c.getParent() == null || c.getParent().getId() == null || c.getParent().getId() == 0)
                .collect(Collectors.toList());

        List<Category> filtered = parents.stream()
                .filter(c -> {
                    boolean ok = true;
                    if (q != null && !q.trim().isEmpty()) {
                        String k = q.trim().toLowerCase();
                        ok &= (c.getName() != null && c.getName().toLowerCase().contains(k))
                                || (c.getDescription() != null && c.getDescription().toLowerCase().contains(k));
                    }
                    if (active != null) {
                        boolean isActive = Boolean.FALSE.equals(c.getIsDeleted()); // isDeleted=false => ACTIVE
                        ok &= (active ? isActive : !isActive);
                    }
                    return ok;
                })
                .collect(Collectors.toList());

        // phân trang thủ công
        Pageable pageable = PageRequest.of(page, size);
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        List<Category> content = start > end ? List.of() : filtered.subList(start, end);
        return new PageImpl<>(content, pageable, filtered.size());
    }

    // NEW: CON có lọc theo q + active
    public Page<Category> findSubcategoriesFiltered(Long parentId, int page, int size, String q, Boolean active) {
        List<Category> all = categoryRepository.findAll();
        List<Category> children = all.stream()
                .filter(c -> c.getParent() != null && parentId.equals(c.getParent().getId()))
                .collect(Collectors.toList());

        List<Category> filtered = children.stream()
                .filter(c -> {
                    boolean ok = true;
                    if (q != null && !q.trim().isEmpty()) {
                        String k = q.trim().toLowerCase();
                        ok &= (c.getName() != null && c.getName().toLowerCase().contains(k))
                                || (c.getDescription() != null && c.getDescription().toLowerCase().contains(k));
                    }
                    if (active != null) {
                        boolean isActive = Boolean.FALSE.equals(c.getIsDeleted());
                        ok &= (active ? isActive : !isActive);
                    }
                    return ok;
                })
                .collect(Collectors.toList());

        Pageable pageable = PageRequest.of(page, size);
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        List<Category> content = start > end ? List.of() : filtered.subList(start, end);
        return new PageImpl<>(content, pageable, filtered.size());
    }

    // Lấy Category theo ID, KHÔNG lọc theo isDeleted (dùng cho admin xem/sửa)
    public Optional<Category> getByIdAnyStatus(Long id) {
        return categoryRepository.findById(id); // dùng findById gốc của JPA
    }

}
