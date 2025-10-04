package vn.group3.marketplace.service;

import java.util.List;

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
}
