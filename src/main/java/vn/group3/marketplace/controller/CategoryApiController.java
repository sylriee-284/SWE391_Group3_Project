package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.repository.CategoryRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * REST API Controller for Category operations
 */
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryApiController {

    private final CategoryRepository categoryRepository;

    /**
     * Get child categories by parent ID
     * GET /api/categories/{parentId}/children
     */
    @GetMapping("/{parentId}/children")
    public ResponseEntity<List<Map<String, Object>>> getChildCategories(@PathVariable Long parentId) {
        List<Category> children = categoryRepository.findByParentIdAndIsDeletedFalse(parentId);
        
        // Convert to simple DTO for JSON response
        List<Map<String, Object>> response = children.stream()
            .map(category -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", category.getId());
                map.put("name", category.getName());
                return map;
            })
            .collect(Collectors.toList());
        
        return ResponseEntity.ok(response);
    }
}
