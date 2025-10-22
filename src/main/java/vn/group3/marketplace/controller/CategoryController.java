package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.stream.Collectors;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageService;

import java.util.List;

@Controller
public class CategoryController {

    private final CategoryService categoryService;
    private final ProductService productService;
    private final ProductStorageService productStorageService;

    public CategoryController(CategoryService categoryService, ProductService productService,
            ProductStorageService productStorageService) {
        this.categoryService = categoryService;
        this.productService = productService;
        this.productStorageService = productStorageService;
    }

    /**
     * Display category products with filtering and pagination
     * Public endpoint - không có prefix /admin/categories
     */
    @GetMapping("/category/{categoryName}")
    public String getCategoryByName(
            @PathVariable String categoryName,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "12") int size,
            @RequestParam(value = "sort", defaultValue = "name") String sortBy,
            @RequestParam(value = "direction", defaultValue = "asc") String sortDirection,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "childCategory", required = false) Long childCategoryId,
            Model model) {

        // Find parent category by name (case insensitive)
        Category parentCategory = categoryService.getParentCategoryByName(categoryName);

        if (parentCategory == null) {
            // Handle category not found - redirect to home with error
            model.addAttribute("errorMessage", "Không tìm thấy danh mục: " + categoryName);
            return "redirect:/";
        }

        Page<Product> products;

        // If child category is selected, filter by child category
        if (childCategoryId != null) {
            Category childCategory = categoryService.getCategoryById(childCategoryId);
            if (childCategory != null && childCategory.getParent().getId().equals(parentCategory.getId())) {
                if (keyword != null && !keyword.trim().isEmpty()) {
                    products = productService.searchProductsByCategory(childCategory, keyword, page, size, sortBy,
                            sortDirection);
                } else {
                    products = productService.getProductsByCategory(childCategory, page, size, sortBy, sortDirection);
                }
            } else {
                // Invalid child category, fall back to parent category
                if (keyword != null && !keyword.trim().isEmpty()) {
                    products = productService.searchProductsByParentCategory(parentCategory, keyword, page, size,
                            sortBy, sortDirection);
                } else {
                    products = productService.getProductsByParentCategory(parentCategory, page, size, sortBy,
                            sortDirection);
                }
            }
        } else {
            // Show all products from parent category
            if (keyword != null && !keyword.trim().isEmpty()) {
                products = productService.searchProductsByParentCategory(parentCategory, keyword, page, size, sortBy,
                        sortDirection);
            } else {
                products = productService.getProductsByParentCategory(parentCategory, page, size, sortBy,
                        sortDirection);
            }
        }

        // Get child categories for filter
        List<Category> childCategories = categoryService.getChildCategories(parentCategory.getId());

        // Calculate dynamic stock for each product
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            // Store dynamic stock in a custom attribute for JSP access
            product.setStock((int) dynamicStock); // Convert long to int for existing stock field
        });

        // Add attributes to model
        model.addAttribute("parentCategory", parentCategory);
        model.addAttribute("childCategories", childCategories);
        model.addAttribute("products", products);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDirection", sortDirection);
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedChildCategory", childCategoryId);

        // Pagination info
        model.addAttribute("hasPrevious", products.hasPrevious());
        model.addAttribute("hasNext", products.hasNext());
        model.addAttribute("previousPage", page > 0 ? page - 1 : 0);
        model.addAttribute("nextPage", page + 1);

        return "category/category-products";
    }

    // ========================= ADMIN ENDPOINTS =========================
    // Tất cả các endpoint admin sử dụng prefix /admin/categories

    // ===================== DANH SÁCH CHA =====================
    @GetMapping("/admin/categories")
    public String listParentCategories(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(value = "q", required = false) String q, // NEW
            @RequestParam(value = "active", required = false) Boolean active, // NEW
            Model model) {

        var p = categoryService.findParentCategoriesFiltered(page - 1, size, q, active); // NEW
        model.addAttribute("categories", p.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", p.getTotalPages());
        model.addAttribute("pageSize", size);

        // giữ lại giá trị filter để UI hiển thị đúng
        model.addAttribute("parentCategory", null);
        model.addAttribute("pageTitle", "Quản lý danh mục (CHA)");
        model.addAttribute("q", q); // NEW
        model.addAttribute("active", active); // NEW
        return "admin/categories";
    }

    // ===================== FORM THÊM CHA =====================
    @GetMapping("/admin/categories/add")
    public String showAddParentCategory(Model model) {
        Category dto = new Category();
        // tùy ý: mặc định active (không cần set isActive nữa, mặc định isDeleted=false)

        model.addAttribute("category", dto);
        model.addAttribute("parentCategory", null); // là CHA
        model.addAttribute("pageTitle", "Thêm danh mục CHA");
        model.addAttribute("formMode", "create-parent");
        return "admin/category_form"; // trỏ tới JSP form dùng chung
    }

    // ===================== DANH SÁCH CON (CÓ PHÂN TRANG) =====================
    @GetMapping("/admin/categories/{parentId}/subcategories")
    public String listSubcategories(
            @PathVariable Long parentId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(value = "q", required = false) String q, // NEW
            @RequestParam(value = "active", required = false) Boolean active, // NEW
            Model model) {

        var parent = categoryService.getByIdAnyStatus(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));

        var p = categoryService.findSubcategoriesFiltered(parentId, page - 1, size, q, active); // NEW

        model.addAttribute("parentCategory", parent);
        model.addAttribute("categories", p.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", p.getTotalPages());
        model.addAttribute("pageSize", size);

        // giữ lại giá trị filter để UI hiển thị đúng
        model.addAttribute("pageTitle", "Danh mục con của: " + parent.getName());
        model.addAttribute("q", q); // NEW
        model.addAttribute("active", active); // NEW
        return "admin/categories";
    }

    // ===================== FORM THÊM CON =====================
    @GetMapping("/admin/categories/{parentId}/subcategories/add")
    public String showAddSubcategory(@PathVariable Long parentId, Model model) {
        // ✳️ ADDED: dùng lại category_form.jsp
        Category parent = categoryService.getByIdAnyStatus(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));

        Category dto = new Category();
        dto.setParent(parent); // Set the parent object directly

        model.addAttribute("category", dto);
        model.addAttribute("parentCategory", parent);
        model.addAttribute("pageTitle", "Thêm danh mục con cho: " + parent.getName());
        model.addAttribute("formMode", "create-child"); // gợi ý cho JSP
        return "admin/category_form";
    }

    // ===================== FORM SỬA (CHA hoặc CON) =====================
    @GetMapping("/admin/categories/edit/{id}")
    public String showEdit(@PathVariable Long id, Model model) {
        Category cat = categoryService.getByIdAnyStatus(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));

        Category parent = null;
        if (cat.getParent() != null && cat.getParent().getId() != null && cat.getParent().getId() != 0) {
            parent = categoryService.findAnyById(cat.getParent().getId()).orElse(null);
        } else {
            // nếu cần nạp children thì dùng hàm ALL (không lọc)
            model.addAttribute("children", categoryService.findSubcategoriesAll(id, 0, Integer.MAX_VALUE).getContent());
        }

        model.addAttribute("category", cat);
        model.addAttribute("parentCategory", parent);
        model.addAttribute("pageTitle", (parent == null ? "Sửa danh mục CHA: " : "Sửa danh mục con: ") + cat.getName());
        model.addAttribute("formMode", "edit");
        return "admin/category_form";
    }

    // ===================== LƯU (THÊM / SỬA) =====================
    @PostMapping("/admin/categories/save")
    public String save(@ModelAttribute("category") Category cat, RedirectAttributes ra) {
        boolean isNew = (cat.getId() == null);
        // Đảm bảo isDeleted được set là false khi tạo mới hoặc cập nhật
        if (isNew) {
            cat.setIsDeleted(false);
        }
        categoryService.save(cat);

        if (cat.getParent() != null && cat.getParent().getId() != null && cat.getParent().getId() != 0) {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục con.");
            return "redirect:/admin/categories/" + cat.getParent().getId() + "/subcategories";
        } else {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục cha.");
            return "redirect:/admin/categories";
        }
    }

    // ===================== XOÁ mềm =====================
    @PostMapping("/admin/categories/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        Category cat = categoryService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));

        // Nếu là CHA
        if (cat.getParent() == null || cat.getParent().getId() == null || cat.getParent().getId() == 0) {
            if (categoryService.hasChildren(id)) {
                ra.addFlashAttribute("error", "Danh mục CHA đang có danh mục con, hãy xoá hết CON trước.");
                return "redirect:/admin/categories";
            }
            categoryService.softDelete(id); // xoá mềm CHA
            ra.addFlashAttribute("success", "Đã xoá (ẩn) danh mục CHA.");
            return "redirect:/admin/categories";
        }

        // Nếu là CON
        Long parentId = cat.getParent().getId();
        categoryService.softDelete(id);
        ra.addFlashAttribute("success", "Đã xoá (ẩn) danh mục con.");
        return "redirect:/admin/categories/" + parentId + "/subcategories";
    }

    // --------------------- TÁCH RIÊNG: TẠO CON ---------------------
    @PostMapping("/admin/categories/{parentId}/subcategories/create")
    public String createChild(@PathVariable Long parentId,
            @ModelAttribute Category category,
            RedirectAttributes ra) {
        // category.setParentId(parentId); // Đã set parent object ở showAddSubcategory
        Category parent = categoryService.getById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));
        category.setParent(parent); // Set parent object directly
        categoryService.save(category);
        ra.addFlashAttribute("success", "Tạo danh mục con thành công!");
        return "redirect:/admin/categories/" + parentId + "/subcategories";
    }

    // --------------------- ĐỔI TRẠNG THÁI (POST) ---------------------
    // ĐỔI TRẠNG THÁI (ACTIVE/INACTIVE) – POST
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/admin/categories/toggle/{id}")
    public String toggleCategory(@PathVariable Long id,
            @RequestHeader(value = "referer", required = false) String referer,
            RedirectAttributes ra) {

        Category updated = categoryService.toggleStatusAndReturn(id);
        ra.addFlashAttribute("successMessage", "Đã đổi trạng thái danh mục!");

        if (referer != null && !referer.isBlank()) {
            // 1) Từ trang EDIT -> về list tương ứng, KHÔNG gắn query nào
            if (referer.contains("/admin/categories/") && referer.contains("/edit/")) {
                if (updated.getParent() != null && updated.getParent().getId() != null
                        && updated.getParent().getId() != 0) {
                    return "redirect:/admin/categories/" + updated.getParent().getId() + "/subcategories";
                } else {
                    return "redirect:/admin/categories";
                }
            }
            // 2) Đang ở trang danh sách CHA/CON -> quay lại URL hiện tại nhưng BỎ param
            // active
            if (referer.contains("/admin/categories/")) {
                return "redirect:" + removeQueryParam(referer, "active");
            }
            // 3) Khác -> quay lại nguyên referer
            return "redirect:" + referer;
        }
        // Fallback
        return "redirect:/admin/categories";
    }

    /** Thêm param status=... nếu URL chưa có. */
    private String ensureStatusParam(String url, String statusValue) {
        try {
            if (url.contains("status="))
                return url;
            return url + (url.contains("?") ? "&" : "?") + "status=" + statusValue;
        } catch (Exception e) {
            return url;
        }
    }

    @GetMapping("/{id}/children.json")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    public java.util.Map<String, Object> getChildrenJson(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {

        // DÙNG method ĐÃ CÓ trong CategoryService (trả về Page<Category>)
        var p = categoryService.findSubcategoriesByParentId(id, page - 1, size);

        // map về List<Map<...>> để tránh vòng lặp JSON
        java.util.List<java.util.Map<String, Object>> items = p.getContent().stream().map(c -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", c.getId());
            m.put("name", c.getName());
            m.put("description", c.getDescription());
            m.put("isDeleted", java.lang.Boolean.TRUE.equals(c.getIsDeleted()));
            m.put("parentId", c.getParent() != null ? c.getParent().getId() : null);
            return m;
        }).toList(); // nếu máy bạn không hỗ trợ toList(), dùng Collectors.toList()

        java.util.Map<String, Object> res = new java.util.HashMap<>();
        res.put("items", items);
        res.put("page", page);
        res.put("totalPages", p.getTotalPages());
        res.put("pageSize", size);
        return res;
    }

    // Ghi đè/thiết lập tham số query trong URL (vd: status=ALL)
    private String setOrReplaceQueryParam(String url, String key, String value) {
        try {
            int q = url.indexOf('?');
            String base = (q >= 0) ? url.substring(0, q) : url;
            String query = (q >= 0) ? url.substring(q + 1) : "";
            java.util.LinkedHashMap<String, String> params = new java.util.LinkedHashMap<>();
            if (!query.isEmpty()) {
                for (String p : query.split("&")) {
                    if (p.isEmpty())
                        continue;
                    String[] kv = p.split("=", 2);
                    String k = kv[0];
                    String v = (kv.length > 1) ? kv[1] : "";
                    params.put(k, v);
                }
            }
            // luôn ghi đè khóa cần set
            params.put(key, value);

            StringBuilder sb = new StringBuilder(base).append('?');
            boolean first = true;
            for (var e : params.entrySet()) {
                if (!first)
                    sb.append('&');
                sb.append(e.getKey()).append('=').append(e.getValue());
                first = false;
            }
            return sb.toString();
        } catch (Exception e) {
            // fallback an toàn
            return url + (url.contains("?") ? "&" : "?") + key + "=" + value;
        }
    }

    // Loại bỏ 1 query param khỏi URL (vd: active)
    private String removeQueryParam(String url, String key) {
        try {
            int q = url.indexOf('?');
            if (q < 0)
                return url;
            String base = url.substring(0, q);
            String query = url.substring(q + 1);
            java.util.LinkedHashMap<String, String> params = new java.util.LinkedHashMap<>();
            if (!query.isEmpty()) {
                for (String p : query.split("&")) {
                    if (p.isEmpty())
                        continue;
                    String[] kv = p.split("=", 2);
                    String k = kv[0];
                    if (!k.equals(key)) {
                        String v = (kv.length > 1) ? kv[1] : "";
                        params.put(k, v);
                    }
                }
            }
            if (params.isEmpty())
                return base;
            StringBuilder sb = new StringBuilder(base).append('?');
            boolean first = true;
            for (var e : params.entrySet()) {
                if (!first)
                    sb.append('&');
                sb.append(e.getKey()).append('=').append(e.getValue());
                first = false;
            }
            return sb.toString();
        } catch (Exception e) {
            return url; // an toàn
        }
    }

}