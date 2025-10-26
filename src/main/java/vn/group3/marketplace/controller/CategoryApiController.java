package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.dto.CategoryDTO;
import vn.group3.marketplace.service.CategoryService;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryApiController {

    private final CategoryService categoryService;

    /**
     * Get child categories by parent category ID
     * 
     * @param parentId Parent category ID
     * @return List of child categories
     */
    @GetMapping("/{parentId}/children")
    public ResponseEntity<List<CategoryDTO>> getChildCategories(@PathVariable Long parentId) {
        try {
            if (parentId == null || parentId <= 0) {
                return ResponseEntity.badRequest().build();
            }

            List<Category> childCategories = categoryService.getChildCategories(parentId);

            // Convert to DTO to avoid circular reference
            List<CategoryDTO> categoryDTOs = childCategories.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(categoryDTOs);
        } catch (Exception e) {
            // Log error for debugging
            System.err.println("Error loading child categories for parent " + parentId + ": " + e.getMessage());
            return ResponseEntity.ok(java.util.Collections.emptyList()); // Return empty list instead of error
        }
    }

    /**
     * Convert Category entity to CategoryDTO
     */
    private CategoryDTO convertToDTO(Category category) {
        return CategoryDTO.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .build();
    }
}