package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.util.SecurityContextUtils;

import java.util.List;

@ControllerAdvice
@RequiredArgsConstructor
public class GlobalControllerAdvice {

    private final CategoryService categoryService;

    @ModelAttribute("parentCategories")
    public List<Category> addParentCategoriesToModel() {
        return categoryService.getParentCategories();
    }

    @ModelAttribute("categories")
    public List<Category> addCategoriesToModel() {
        return categoryService.getAllCategories();
    }

    @ModelAttribute("havingPendingStore")
    public boolean isHavingPendingStore() {
        try {
            // Check if user is authenticated
            var auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
                return false;
            }

            User user = SecurityContextUtils.getCurrentUserDetails().getUser();
            if (user == null) {
                return false;
            }
            return user.getSellerStore() != null && user.getSellerStore().getStatus() == StoreStatus.PENDING;
        } catch (Exception e) {
            // If any error getting user details, return false
            return false;
        }
    }

    @ModelAttribute("userStore")
    public SellerStore addUserStoreToModel() {
        try {
            // Check if user is authenticated
            var auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
                return null;
            }

            User user = SecurityContextUtils.getCurrentUserDetails().getUser();
            if (user == null) {
                return null;
            }
            return user.getSellerStore();
        } catch (Exception e) {
            // If any error getting user details, return null
            return null;
        }
    }

}