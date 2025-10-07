package vn.group3.marketplace.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.repository.CategoryRepository;

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

    // --- CRUD: Start of Admin Category Management ---
    public List<Category> getAll() {
        return categoryRepository.findAll()
                .stream()
                .filter(c -> !Boolean.TRUE.equals(c.getIsDeleted()))
                .collect(Collectors.toList());
    }

    public Optional<Category> getById(Long id) {
        return categoryRepository.findById(id)
                .filter(c -> !Boolean.TRUE.equals(c.getIsDeleted()));
    }

    public Category create(Category category) {
        category.setId(null);
        category.setIsDeleted(false);
        // category.setCreatedAt(Timestamp.valueOf(LocalDateTime.now()));
        return categoryRepository.save(category);
    }

    public Category update(Long id, Category updated) {
        return categoryRepository.findById(id).map(existing -> {
            existing.setName(updated.getName());
            existing.setDescription(updated.getDescription());
            // existing.setUpdatedAt(Timestamp.valueOf(LocalDateTime.now()));
            return categoryRepository.save(existing);
        }).orElseThrow(() -> new RuntimeException("Category not found"));
    }

    public void softDelete(Long id, Long adminId) {
        categoryRepository.findById(id).ifPresent(c -> {
            c.setIsDeleted(true);
            c.setDeletedBy(adminId);
            categoryRepository.save(c);
        });
    }
    // --- CRUD: End of Admin Category Management ---
}
