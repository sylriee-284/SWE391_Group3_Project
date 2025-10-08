package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.domain.entity.Category;

import java.util.List;

@ControllerAdvice
@RequiredArgsConstructor
public class GlobalControllerAdvice {

    private final CategoryService categoryService;

    @ModelAttribute("parentCategories")
    public List<Category> addParentCategoriesToModel() {
        return categoryService.getParentCategories();
    }

}