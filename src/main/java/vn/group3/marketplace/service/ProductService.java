package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.repository.ProductRepository;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    /**
     * Get products by parent category with pagination
     * 
     * @param parentCategory The parent category
     * @param page           Page number (0-based)
     * @param size           Page size
     * @param sortBy         Sort field
     * @param sortDirection  Sort direction (asc/desc)
     * @return Page of products
     */
    public Page<Product> getProductsByParentCategory(Category parentCategory, int page, int size,
            String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return productRepository.findByParentCategoryId(
                parentCategory.getId(),
                ProductStatus.ACTIVE,
                pageable);
    }

    /**
     * Get products by parent category with search keyword and pagination
     * 
     * @param parentCategory The parent category
     * @param keyword        Search keyword
     * @param page           Page number (0-based)
     * @param size           Page size
     * @param sortBy         Sort field
     * @param sortDirection  Sort direction (asc/desc)
     * @return Page of products
     */
    public Page<Product> searchProductsByParentCategory(Category parentCategory, String keyword,
            int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        if (keyword == null || keyword.trim().isEmpty()) {
            return getProductsByParentCategory(parentCategory, page, size, sortBy, sortDirection);
        }

        return productRepository.findByParentCategoryIdAndKeyword(
                parentCategory.getId(),
                ProductStatus.ACTIVE,
                keyword.trim(),
                pageable);
    }

    /**
     * Get products by specific child category with pagination
     * 
     * @param category      The child category
     * @param page          Page number (0-based)
     * @param size          Page size
     * @param sortBy        Sort field
     * @param sortDirection Sort direction (asc/desc)
     * @return Page of products
     */
    public Page<Product> getProductsByCategory(Category category, int page, int size,
            String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return productRepository.findByCategoryId(
                category.getId(),
                ProductStatus.ACTIVE,
                pageable);
    }

    /**
     * Get products by specific child category with search keyword and pagination
     * 
     * @param category      The child category
     * @param keyword       Search keyword
     * @param page          Page number (0-based)
     * @param size          Page size
     * @param sortBy        Sort field
     * @param sortDirection Sort direction (asc/desc)
     * @return Page of products
     */
    public Page<Product> searchProductsByCategory(Category category, String keyword,
            int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        if (keyword == null || keyword.trim().isEmpty()) {
            return getProductsByCategory(category, page, size, sortBy, sortDirection);
        }

        return productRepository.findByCategoryIdAndKeyword(
                category.getId(),
                ProductStatus.ACTIVE,
                keyword.trim(),
                pageable);
    }

    /**
     * Count products by parent category
     * 
     * @param parentCategory The parent category
     * @return Number of products
     */
    public Long countProductsByParentCategory(Category parentCategory) {
        return productRepository.countByParentCategoryId(parentCategory.getId(), ProductStatus.ACTIVE);
    }
}