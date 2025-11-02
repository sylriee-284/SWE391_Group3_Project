package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.repository.OrderRepository;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.domain.entity.Category;

import java.math.BigDecimal;
import java.util.List;
import java.util.Collections;

@Controller
@RequestMapping("/store")
@RequiredArgsConstructor
public class StoreController {

    private final SellerStoreRepository storeRepo;
    private final ProductRepository productRepo;
    private final OrderRepository orderRepository;
    private final ProductService productService;
    private final CategoryService categoryService;

    @GetMapping("/{id}")
    public String storeHome(@PathVariable Long id,
            // Main filters
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "parentCategoryId", required = false) Long parentCategoryId,
            @RequestParam(value = "categoryId", required = false) Long categoryId,
            @RequestParam(value = "priceMin", required = false) String priceMin,
            @RequestParam(value = "priceMax", required = false) String priceMax,
            @RequestParam(value = "inStock", required = false) Boolean inStock,
            @RequestParam(value = "ratingGte", required = false) String ratingGte,
            @RequestParam(value = "sort", required = false, defaultValue = "newest") String sort,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "24") int size,

            // Hot products from other stores filters
            @RequestParam(value = "hotPage", defaultValue = "0") int hotPage,
            @RequestParam(value = "hotSize", defaultValue = "12") int hotSize,
            @RequestParam(value = "hotQ", required = false) String hotQ,
            @RequestParam(value = "hotCategoryId", required = false) Long hotCategoryId,
            @RequestParam(value = "hotPriceMin", required = false) String hotPriceMin,
            @RequestParam(value = "hotPriceMax", required = false) String hotPriceMax,
            @RequestParam(value = "hotSort", required = false, defaultValue = "best_seller") String hotSort,
            Model model) {

        long startTime = System.currentTimeMillis();

        // ===== 1. VALIDATE STORE =====
        SellerStore store = storeRepo.findById(id).orElse(null);
        if (store == null) {
            model.addAttribute("errorMessage", "Cửa hàng không tồn tại");
            return "redirect:/";
        }

        // ===== 2. KPIs - ONLY ON FIRST PAGE (CACHE-FRIENDLY) =====
        long totalActiveProducts = 0;
        long totalSold = 0;
        BigDecimal storeRating = BigDecimal.ZERO;
        Long ratingCount = 0L;
        long totalAvailable = 0;
        List<?> categories = java.util.Collections.emptyList();
        BigDecimal minP = BigDecimal.ZERO;
        BigDecimal maxP = BigDecimal.ZERO;

        if (page == 0) {
            // Only calculate KPIs on first page load
            totalActiveProducts = productRepo.countBySellerStoreIdAndStatus(id, ProductStatus.ACTIVE);

            java.util.List<vn.group3.marketplace.domain.enums.OrderStatus> countedStatuses = java.util.List.of(
                    vn.group3.marketplace.domain.enums.OrderStatus.PAID,
                    vn.group3.marketplace.domain.enums.OrderStatus.CONFIRMED,
                    vn.group3.marketplace.domain.enums.OrderStatus.COMPLETED);
            Long totalSoldObj = orderRepository.sumQuantityByStoreAndStatuses(id, countedStatuses);
            totalSold = totalSoldObj == null ? 0L : totalSoldObj.longValue();

            storeRating = orderRepository.findStoreRating(id);
            ratingCount = orderRepository.countStoreRatings(id);

            if (storeRating == null)
                storeRating = BigDecimal.ZERO;
            if (ratingCount == null)
                ratingCount = 0L;

            totalAvailable = totalActiveProducts;
            categories = productRepo.findDistinctCategoriesByStore(id);
            minP = productRepo.findMinPriceByStore(id);
            maxP = productRepo.findMaxPriceByStore(id);

            System.out
                    .println("=== KPIs Loaded (page 0) - Time: " + (System.currentTimeMillis() - startTime) + "ms ===");
        }

        // ===== 2.5. LOAD PARENT CATEGORIES & SUBCATEGORIES FOR FILTER =====
        List<Category> parentCategories = categoryService.getParentCategories();
        List<Category> subCategories = Collections.emptyList();

        // Determine which parent to show subcategories for
        Long selectedParentId = parentCategoryId;

        if (categoryId != null) {
            Category selectedCategory = categoryService.getCategoryById(categoryId);
            if (selectedCategory != null && selectedCategory.getParent() != null) {
                // If selected is a child category, get its parent
                selectedParentId = selectedCategory.getParent().getId();
                subCategories = categoryService.getChildCategories(selectedCategory.getParent());
            }
        } else if (parentCategoryId != null) {
            // Load subcategories for the selected parent
            Category parentCat = categoryService.getCategoryById(parentCategoryId);
            if (parentCat != null) {
                subCategories = categoryService.getChildCategories(parentCat);
            }
        }

        // ===== 3. PARSE FILTER PARAMETERS =====
        java.math.BigDecimal minPriceDec = null, maxPriceDec = null;
        try {
            if (priceMin != null && !priceMin.isEmpty())
                minPriceDec = new java.math.BigDecimal(priceMin);
        } catch (Exception ignored) {
        }
        try {
            if (priceMax != null && !priceMax.isEmpty())
                maxPriceDec = new java.math.BigDecimal(priceMax);
        } catch (Exception ignored) {
        }

        // ===== 4. DETERMINE SORT =====
        org.springframework.data.domain.Sort sortObj;
        switch (sort) {
            case "price_asc":
                sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC,
                        "price");
                break;
            case "price_desc":
                sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                        "price");
                break;
            case "rating_desc":
                sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                        "rating");
                break;
            case "best_seller":
                sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                        "soldQuantity");
                break;
            case "newest":
            default:
                sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                        "createdAt");
                break;
        }

        // ===== 5. GET PRODUCTS WITH FILTERS (SINGLE QUERY) =====
        org.springframework.data.domain.PageRequest pr = org.springframework.data.domain.PageRequest.of(page, size,
                sortObj);
        org.springframework.data.domain.Page<Product> productsPage = productService.search(id, q, ProductStatus.ACTIVE,
                categoryId, null, null, null, minPriceDec, maxPriceDec, null, null, pr);

        System.out.println("=== Products Loaded - Time: " + (System.currentTimeMillis() - startTime) + "ms ===");

        // ===== 6. COLLECTIONS (ONLY ON FIRST PAGE) =====
        List<Product> newestProducts = java.util.Collections.emptyList();
        List<Product> bestSellers = java.util.Collections.emptyList();

        if (page == 0) {
            org.springframework.data.domain.PageRequest newestPr = org.springframework.data.domain.PageRequest.of(0, 8,
                    org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                            "createdAt"));
            newestProducts = productService.search(id, null, ProductStatus.ACTIVE,
                    null, null, null, null, null, null, null, null, newestPr).getContent();

            org.springframework.data.domain.PageRequest bestSellerPr = org.springframework.data.domain.PageRequest.of(0,
                    8,
                    org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                            "soldQuantity"));
            bestSellers = productService.search(id, null, ProductStatus.ACTIVE,
                    null, null, null, null, null, null, null, null, bestSellerPr).getContent();
        }

        // ===== 7. HOT PRODUCTS FROM OTHER STORES (OPTIMIZED - DATABASE QUERY) =====
        java.math.BigDecimal hotMinPriceDec = null, hotMaxPriceDec = null;
        try {
            if (hotPriceMin != null && !hotPriceMin.isEmpty())
                hotMinPriceDec = new java.math.BigDecimal(hotPriceMin);
        } catch (Exception ignored) {
        }
        try {
            if (hotPriceMax != null && !hotPriceMax.isEmpty())
                hotMaxPriceDec = new java.math.BigDecimal(hotPriceMax);
        } catch (Exception ignored) {
        }

        // Determine hot products sort
        org.springframework.data.domain.Sort hotSortObj;
        switch (hotSort) {
            case "newest":
                hotSortObj = org.springframework.data.domain.Sort
                        .by(org.springframework.data.domain.Sort.Direction.DESC, "createdAt");
                break;
            case "price_asc":
                hotSortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC,
                        "price");
                break;
            case "price_desc":
                hotSortObj = org.springframework.data.domain.Sort
                        .by(org.springframework.data.domain.Sort.Direction.DESC, "price");
                break;
            case "best_seller":
            default:
                hotSortObj = org.springframework.data.domain.Sort
                        .by(org.springframework.data.domain.Sort.Direction.DESC, "soldQuantity");
                break;
        }

        // Get hot products from OTHER stores - SINGLE DATABASE QUERY (FAST!)
        org.springframework.data.domain.PageRequest hotPr = org.springframework.data.domain.PageRequest.of(hotPage,
                hotSize, hotSortObj);

        // Use optimized query to exclude current store and apply all filters at
        // database level
        org.springframework.data.domain.Page<Product> hotProductsPage = productRepo.findHotProductsExcludingStore(
                id, // excludeStoreId
                ProductStatus.ACTIVE,
                hotQ,
                hotCategoryId,
                hotMinPriceDec,
                hotMaxPriceDec,
                hotPr);

        System.out.println("=== Hot Products Loaded - Time: " + (System.currentTimeMillis() - startTime) + "ms ===");

        // ===== 8. ADD TO MODEL =====
        model.addAttribute("store", store);
        model.addAttribute("storeRating", storeRating);
        model.addAttribute("ratingCount", ratingCount);
        model.addAttribute("totalActiveProducts", totalActiveProducts);
        model.addAttribute("totalSold", totalSold);
        model.addAttribute("totalAvailable", totalAvailable);
        model.addAttribute("categories", categories);
        model.addAttribute("parentCategories", parentCategories);
        model.addAttribute("subCategories", subCategories);
        model.addAttribute("minPrice", minP != null ? minP : BigDecimal.ZERO);
        model.addAttribute("maxPrice", maxP != null ? maxP : BigDecimal.ZERO);
        model.addAttribute("productsPage", productsPage);
        model.addAttribute("newestProducts", newestProducts);
        model.addAttribute("bestSellers", bestSellers);

        // Hot products
        model.addAttribute("hotProductsPage", hotProductsPage);
        model.addAttribute("hotQ", hotQ);
        model.addAttribute("hotCategoryId", hotCategoryId);
        model.addAttribute("hotPriceMin", hotPriceMin);
        model.addAttribute("hotPriceMax", hotPriceMax);
        model.addAttribute("hotSort", hotSort);

        // Filter states
        model.addAttribute("currentSort", sort);
        model.addAttribute("filterQ", q);
        model.addAttribute("filterParentCategoryId", selectedParentId);
        model.addAttribute("filterCategoryId", categoryId);
        model.addAttribute("filterPriceMin", priceMin);
        model.addAttribute("filterPriceMax", priceMax);
        model.addAttribute("filterInStock", inStock);
        model.addAttribute("filterRatingGte", ratingGte);

        long totalTime = System.currentTimeMillis() - startTime;
        System.out.println("=== TOTAL PAGE LOAD TIME: " + totalTime + "ms ===");

        return "store/info";
    }
}
