package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageService;
import vn.group3.marketplace.repository.OrderRepository;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/store")
@RequiredArgsConstructor
public class StoreController {

    private final SellerStoreRepository storeRepo;
    private final ProductRepository productRepo;
    private final OrderRepository orderRepository;
    private final ProductService productService;
    private final ProductStorageService productStorageService;

    @GetMapping("/{id}")
    public String storeHome(@PathVariable Long id,
            @RequestParam(value = "categoryId", required = false) Long categoryId,
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "minPrice", required = false) String minPrice,
            @RequestParam(value = "maxPrice", required = false) String maxPrice,
            // suggestion filters
            @RequestParam(value = "suggest_q", required = false) String suggestQ,
            @RequestParam(value = "suggest_categoryId", required = false) Long suggestCategoryId,
            @RequestParam(value = "suggest_minPrice", required = false) String suggestMinPrice,
            @RequestParam(value = "suggest_maxPrice", required = false) String suggestMaxPrice,
            @RequestParam(value = "suggest_sort", required = false, defaultValue = "sold") String suggestSort,
            // suggestion from other shops
            @RequestParam(value = "suggestOther_q", required = false) String suggestOtherQ,
            @RequestParam(value = "suggestOther_categoryId", required = false) Long suggestOtherCategoryId,
            @RequestParam(value = "suggestOther_minPrice", required = false) String suggestOtherMinPrice,
            @RequestParam(value = "suggestOther_maxPrice", required = false) String suggestOtherMaxPrice,
            @RequestParam(value = "suggestOther_sort", required = false, defaultValue = "sold") String suggestOtherSort,
            @RequestParam(value = "suggestOtherPage", required = false, defaultValue = "0") int suggestOtherPage,
            @RequestParam(value = "suggestOtherSize", required = false, defaultValue = "8") int suggestOtherSize,
            @RequestParam(value = "sort", required = false, defaultValue = "newest") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            Model model) {

        SellerStore store = storeRepo.findById(id).orElse(null);
        if (store == null) {
            model.addAttribute("errorMessage", "Cửa hàng không tồn tại");
            return "redirect:/";
        }

        // KPIs
        long totalActiveProducts = productService.search(id, null, ProductStatus.ACTIVE, null, null, null, null, null,
                null, null, null, PageRequest.of(0, 1)).getTotalElements();

        // total sold - aggregate via OrderRepository for meaningful statuses
        java.util.List<vn.group3.marketplace.domain.enums.OrderStatus> countedStatuses = java.util.List.of(
                vn.group3.marketplace.domain.enums.OrderStatus.PAID,
                vn.group3.marketplace.domain.enums.OrderStatus.CONFIRMED,
                vn.group3.marketplace.domain.enums.OrderStatus.COMPLETED);

        Long totalSoldObj = orderRepository.sumQuantityByStoreAndStatuses(id, countedStatuses);
        long totalSold = totalSoldObj == null ? 0L : totalSoldObj.longValue();

        // total available storage items across products - sum dynamic stock
        List<Product> productsForCount = productService.search(id, null, ProductStatus.ACTIVE, null, null, null, null,
                null, null, null, null, PageRequest.of(0, 1000)).getContent();
        long totalAvailable = productsForCount.stream()
                .mapToLong(p -> productStorageService.getAvailableStock(p.getId())).sum();

        // distinct categories
        List<?> categories = productRepo.findDistinctCategoriesByStore(id);

        BigDecimal minP = productRepo.findMinPriceByStore(id);
        BigDecimal maxP = productRepo.findMaxPriceByStore(id);

        // Product list with filters
        java.math.BigDecimal minPriceDec = null, maxPriceDec = null;
        try {
            if (minPrice != null && !minPrice.isEmpty())
                minPriceDec = new java.math.BigDecimal(minPrice);
        } catch (Exception ignored) {
        }
        try {
            if (maxPrice != null && !maxPrice.isEmpty())
                maxPriceDec = new java.math.BigDecimal(maxPrice);
        } catch (Exception ignored) {
        }

        // Determine Sort
        org.springframework.data.domain.Sort sortObj = org.springframework.data.domain.Sort
                .by(org.springframework.data.domain.Sort.Direction.DESC, "updatedAt");
        if ("price_asc".equals(sort)) {
            sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC,
                    "price");
        } else if ("price_desc".equals(sort)) {
            sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                    "price");
        } else if ("newest".equals(sort)) {
            sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                    "createdAt");
        } else if ("sold".equals(sort)) {
            // Best effort: products with higher rating & updatedAt (fallback). For accurate
            // sold sorting, need OrderRepository aggregate.
            sortObj = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC,
                    "rating");
        }

        org.springframework.data.domain.PageRequest pr = org.springframework.data.domain.PageRequest.of(page, size,
                sortObj);

        org.springframework.data.domain.Page<Product> pageData = productService.search(id, q, ProductStatus.ACTIVE,
                categoryId, null, null, null, minPriceDec, maxPriceDec, null, null, pr);

        model.addAttribute("currentSort", sort);

        model.addAttribute("store", store);
        model.addAttribute("totalActiveProducts", totalActiveProducts);
        model.addAttribute("totalSold", totalSold);
        model.addAttribute("totalAvailable", totalAvailable);
        model.addAttribute("categories", categories);
        model.addAttribute("minPrice", minP);
        model.addAttribute("maxPrice", maxP);
        model.addAttribute("productsPage", pageData);

        // --- Suggested products (best-sellers) ---
        // We'll fetch top product IDs by sold quantity for this store (limit 12), then
        // filter in-memory
        java.util.List<Object[]> top = orderRepository.findTopSoldProductIdsByStore(id, null,
                org.springframework.data.domain.PageRequest.of(0, 12));
        java.util.List<Long> topIds = new java.util.ArrayList<>();
        for (Object[] row : top) {
            if (row != null && row.length > 0 && row[0] instanceof Number) {
                topIds.add(((Number) row[0]).longValue());
            }
        }

        java.util.List<Product> suggestedProducts = new java.util.ArrayList<>();
        if (!topIds.isEmpty()) {
            java.util.List<Product> prods = productRepo.findAllById(topIds);

            // Apply lightweight suggestion filters in-memory
            java.math.BigDecimal sMin = null, sMax = null;
            try {
                if (suggestMinPrice != null && !suggestMinPrice.isEmpty())
                    sMin = new java.math.BigDecimal(suggestMinPrice);
            } catch (Exception ignored) {
            }
            try {
                if (suggestMaxPrice != null && !suggestMaxPrice.isEmpty())
                    sMax = new java.math.BigDecimal(suggestMaxPrice);
            } catch (Exception ignored) {
            }

            for (Product p : prods) {
                if (p.getSellerStore() == null || !p.getSellerStore().getId().equals(id))
                    continue;
                if (suggestCategoryId != null
                        && (p.getCategory() == null || !p.getCategory().getId().equals(suggestCategoryId)))
                    continue;
                if (sMin != null && p.getPrice() != null && p.getPrice().compareTo(sMin) < 0)
                    continue;
                if (sMax != null && p.getPrice() != null && p.getPrice().compareTo(sMax) > 0)
                    continue;
                if (suggestQ != null && !suggestQ.trim().isEmpty()) {
                    String qq = suggestQ.trim().toLowerCase();
                    if ((p.getName() == null || !p.getName().toLowerCase().contains(qq))
                            && (p.getDescription() == null || !p.getDescription().toLowerCase().contains(qq))) {
                        continue;
                    }
                }
                suggestedProducts.add(p);
            }

            // sort suggestedProducts based on suggestSort
            // (sold/newest/price_asc/price_desc)
            if ("price_asc".equals(suggestSort)) {
                suggestedProducts.sort(java.util.Comparator
                        .comparing(p -> p.getPrice() == null ? java.math.BigDecimal.ZERO : p.getPrice()));
            } else if ("price_desc".equals(suggestSort)) {
                suggestedProducts.sort(java.util.Comparator
                        .comparing((Product p) -> p.getPrice() == null ? java.math.BigDecimal.ZERO : p.getPrice())
                        .reversed());
            } else if ("newest".equals(suggestSort)) {
                suggestedProducts.sort(java.util.Comparator.comparing(Product::getCreatedAt,
                        java.util.Comparator.nullsLast(java.util.Comparator.reverseOrder())));
            } else { // sold or default
                     // keep order roughly as in topIds
                java.util.Map<Long, Integer> index = new java.util.HashMap<>();
                int idx = 0;
                for (Long idd : topIds) {
                    index.put(idd, idx++);
                }
                suggestedProducts.sort((a, b) -> Integer.compare(index.getOrDefault(a.getId(), 9999),
                        index.getOrDefault(b.getId(), 9999)));
            }
        }

        model.addAttribute("suggestedProducts", suggestedProducts);
        model.addAttribute("suggest_q", suggestQ);
        model.addAttribute("suggest_categoryId", suggestCategoryId);
        model.addAttribute("suggest_minPrice", suggestMinPrice);
        model.addAttribute("suggest_maxPrice", suggestMaxPrice);
        model.addAttribute("suggest_sort", suggestSort);

        // --- Suggested products from other shops ---
        java.util.List<Object[]> topOther = orderRepository.findTopSoldProductIdsExcludingStore(id,
                org.springframework.data.domain.PageRequest.of(0, 12));
        java.util.List<Long> topOtherIds = new java.util.ArrayList<>();
        for (Object[] row : topOther) {
            if (row != null && row.length > 0 && row[0] instanceof Number) {
                topOtherIds.add(((Number) row[0]).longValue());
            }
        }

        java.util.List<Product> suggestedOtherProducts = new java.util.ArrayList<>();
        if (!topOtherIds.isEmpty()) {
            java.util.List<Product> prods = productRepo.findAllById(topOtherIds);

            // Apply lightweight suggestion-other filters in-memory
            java.math.BigDecimal sMinO = null, sMaxO = null;
            try {
                if (suggestOtherMinPrice != null && !suggestOtherMinPrice.isEmpty())
                    sMinO = new java.math.BigDecimal(suggestOtherMinPrice);
            } catch (Exception ignored) {
            }
            try {
                if (suggestOtherMaxPrice != null && !suggestOtherMaxPrice.isEmpty())
                    sMaxO = new java.math.BigDecimal(suggestOtherMaxPrice);
            } catch (Exception ignored) {
            }

            for (Product p : prods) {
                if (p.getSellerStore() == null || p.getSellerStore().getId().equals(id))
                    continue; // ensure other shops
                if (suggestOtherCategoryId != null
                        && (p.getCategory() == null || !p.getCategory().getId().equals(suggestOtherCategoryId)))
                    continue;
                if (sMinO != null && p.getPrice() != null && p.getPrice().compareTo(sMinO) < 0)
                    continue;
                if (sMaxO != null && p.getPrice() != null && p.getPrice().compareTo(sMaxO) > 0)
                    continue;
                if (suggestOtherQ != null && !suggestOtherQ.trim().isEmpty()) {
                    String qq = suggestOtherQ.trim().toLowerCase();
                    if ((p.getName() == null || !p.getName().toLowerCase().contains(qq))
                            && (p.getDescription() == null || !p.getDescription().toLowerCase().contains(qq))) {
                        continue;
                    }
                }
                suggestedOtherProducts.add(p);
            }

            // sort suggestedOtherProducts based on suggestOtherSort
            if ("price_asc".equals(suggestOtherSort)) {
                suggestedOtherProducts.sort(java.util.Comparator
                        .comparing(p -> p.getPrice() == null ? java.math.BigDecimal.ZERO : p.getPrice()));
            } else if ("price_desc".equals(suggestOtherSort)) {
                suggestedOtherProducts.sort(java.util.Comparator
                        .comparing((Product p) -> p.getPrice() == null ? java.math.BigDecimal.ZERO : p.getPrice())
                        .reversed());
            } else if ("newest".equals(suggestOtherSort)) {
                suggestedOtherProducts.sort(java.util.Comparator.comparing(Product::getCreatedAt,
                        java.util.Comparator.nullsLast(java.util.Comparator.reverseOrder())));
            } else { // sold or default
                java.util.Map<Long, Integer> index = new java.util.HashMap<>();
                int idx = 0;
                for (Long idd : topOtherIds) {
                    index.put(idd, idx++);
                }
                suggestedOtherProducts.sort((a, b) -> Integer.compare(index.getOrDefault(a.getId(), 9999),
                        index.getOrDefault(b.getId(), 9999)));
            }
        }

        // Create a Page for suggestedOtherProducts for pagination
        org.springframework.data.domain.Page<Product> suggestedOtherPageObj;
        if (suggestedOtherProducts.isEmpty()) {
            suggestedOtherPageObj = new org.springframework.data.domain.PageImpl<>(java.util.List.of(),
                    org.springframework.data.domain.PageRequest.of(suggestOtherPage, suggestOtherSize), 0);
        } else {
            int total = suggestedOtherProducts.size();
            int start = suggestOtherPage * suggestOtherSize;
            if (start > total)
                start = 0; // reset if out of range
            int end = Math.min(start + suggestOtherSize, total);
            java.util.List<Product> pageContent = suggestedOtherProducts.subList(start, end);
            suggestedOtherPageObj = new org.springframework.data.domain.PageImpl<>(pageContent,
                    org.springframework.data.domain.PageRequest.of(suggestOtherPage, suggestOtherSize), total);
        }

        model.addAttribute("suggestedOtherProductsPage", suggestedOtherPageObj);
        model.addAttribute("suggestOther_q", suggestOtherQ);
        model.addAttribute("suggestOther_categoryId", suggestOtherCategoryId);
        model.addAttribute("suggestOther_minPrice", suggestOtherMinPrice);
        model.addAttribute("suggestOther_maxPrice", suggestOtherMaxPrice);
        model.addAttribute("suggestOther_sort", suggestOtherSort);
        model.addAttribute("suggestOtherPage", suggestOtherPage);
        model.addAttribute("suggestOtherSize", suggestOtherSize);

        return "store/info";
    }
}
