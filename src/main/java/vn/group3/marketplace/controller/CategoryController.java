package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageService;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/admin/categories")
@PreAuthorize("hasRole('ADMIN')")
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
     */
    // test
    @GetMapping("/category/{categoryName}")
    public String getCategoryByName(@PathVariable String categoryName) {
        // Simple redirect to homepage for now
        return "redirect:/homepage";
    }

    // ===================== DANH SÁCH CHA =====================
    @GetMapping
    public String listParentCategories(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        var p = categoryService.findParentCategories(page - 1, size); // service 0-based
        model.addAttribute("categories", p.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", p.getTotalPages());
        model.addAttribute("pageSize", size);

        model.addAttribute("parentCategory", null);
        model.addAttribute("pageTitle", "Quản lý danh mục (CHA)");
        return "admin/categories";
    }

    // ===================== FORM THÊM CHA =====================
    @GetMapping("/add")
    public String showAddParentCategory(Model model) {
        Category dto = new Category();
        // tùy ý: mặc định active
        dto.setIsActive(Boolean.TRUE);

        model.addAttribute("category", dto);
        model.addAttribute("parentCategory", null); // là CHA
        model.addAttribute("pageTitle", "Thêm danh mục CHA");
        model.addAttribute("formMode", "create-parent");
        return "admin/category_form"; // trỏ tới JSP form dùng chung
    }

    // ===================== DANH SÁCH CON (CÓ PHÂN TRANG) =====================
    @GetMapping("/{parentId}/subcategories")
    public String listSubcategories(
            @PathVariable Long parentId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        var parent = categoryService.getById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));

        var p = categoryService.findSubcategoriesByParentId(parentId, page - 1, size);
        model.addAttribute("parentCategory", parent);
        model.addAttribute("categories", p.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", p.getTotalPages());
        model.addAttribute("pageSize", size);

        model.addAttribute("pageTitle", "Danh mục con của: " + parent.getName());
        return "admin/categories";
    }

    // ===================== FORM THÊM CON =====================
    @GetMapping("/{parentId}/subcategories/add")
    public String showAddSubcategory(@PathVariable Long parentId, Model model) {
        // ✳️ ADDED: dùng lại category_form.jsp
        Category parent = categoryService.getById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));

        Category dto = new Category();
        dto.setParentId(parent.getId()); // ✳️ quan trọng

        model.addAttribute("category", dto);
        model.addAttribute("parentCategory", parent);
        model.addAttribute("pageTitle", "Thêm danh mục con cho: " + parent.getName());
        model.addAttribute("formMode", "create-child"); // gợi ý cho JSP
        return "admin/category_form";
    }

    // ===================== FORM SỬA (CHA hoặc CON) =====================
    @GetMapping("/edit/{id}")
    public String showEdit(@PathVariable Long id, Model model) {
        Category cat = categoryService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));

        Category parent = null;
        if (cat.getParentId() != null && cat.getParentId() != 0) {
            // đang sửa danh mục CON
            parent = categoryService.getById(cat.getParentId()).orElse(null);
        } else {
            // đang sửa danh mục CHA -> nạp children để hiển thị ở dưới form
            model.addAttribute("children", categoryService.findSubcategoriesByParentId(id));
        }

        model.addAttribute("category", cat);
        model.addAttribute("parentCategory", parent); // ✳️ nếu là con thì JSP biết để hiển thị tiêu đề
        model.addAttribute("pageTitle", (parent == null ? "Sửa danh mục CHA: " : "Sửa danh mục con: ") + cat.getName());
        model.addAttribute("formMode", "edit");
        return "admin/category_form";
    }

    // ===================== LƯU (THÊM / SỬA) =====================
    @PostMapping("/save")
    public String save(@ModelAttribute("category") Category cat, RedirectAttributes ra) {
        // ✳️ CHANGED: tôn trọng parentId từ form (hidden)
        boolean isNew = (cat.getId() == null);
        categoryService.save(cat);

        if (cat.getParentId() != null && cat.getParentId() != 0) {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục con.");
            return "redirect:/admin/categories/" + cat.getParentId() + "/subcategories";
        } else {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục cha.");
            return "redirect:/admin/categories";
        }
    }

    // ===================== XOÁ mềm =====================
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        Category cat = categoryService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));

        // Nếu là CHA
        if (cat.getParentId() == null || cat.getParentId() == 0) {
            if (categoryService.hasChildren(id)) {
                ra.addFlashAttribute("error", "Danh mục CHA đang có danh mục con, hãy xoá hết CON trước.");
                return "redirect:/admin/categories";
            }
            categoryService.softDelete(id); // xoá mềm CHA
            ra.addFlashAttribute("success", "Đã xoá (ẩn) danh mục CHA.");
            return "redirect:/admin/categories";
        }

        // Nếu là CON
        Long parentId = cat.getParentId();
        categoryService.softDelete(id);
        ra.addFlashAttribute("success", "Đã xoá (ẩn) danh mục con.");
        return "redirect:/admin/categories/" + parentId + "/subcategories";
    }

    // --------------------- TÁCH RIÊNG: TẠO CHA ---------------------
    // [FIX] (path): KHÔNG dùng /admin/categories/create nữa vì đã có prefix của
    // class
    @PostMapping("/create")
    public String create(@ModelAttribute("category") Category cat, RedirectAttributes ra) {
        boolean isNew = (cat.getId() == null);
        categoryService.save(cat);

        if (cat.getParentId() != null && cat.getParentId() != 0) {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục con.");
            return "redirect:/admin/categories/" + cat.getParentId() + "/subcategories";
        } else {
            ra.addFlashAttribute("success", (isNew ? "Đã thêm" : "Đã cập nhật") + " danh mục cha.");
            return "redirect:/admin/categories";
        }
    }

    // --------------------- TÁCH RIÊNG: TẠO CON ---------------------
    // [FIX] (path): KHÔNG dùng /admin/categories/{parentId}/subcategories/create
    // với prefix lặp
    @PostMapping("/{parentId}/subcategories/create")
    public String createChild(@PathVariable Long parentId,
            @ModelAttribute Category category,
            RedirectAttributes ra) {
        category.setParentId(parentId);
        categoryService.save(category);
        ra.addFlashAttribute("success", "Tạo danh mục con thành công!");
        return "redirect:/admin/categories/" + parentId + "/subcategories";
    }

    // --------------------- TÁCH RIÊNG: CẬP NHẬT ---------------------
    // (tuỳ bạn giữ /save hoặc tách riêng /update — cả hai đều OK)
    @PostMapping("/update/{id}")
    public String update(@PathVariable Long id,
            @ModelAttribute("category") Category cat,
            RedirectAttributes ra) {
        cat.setId(id); // đảm bảo cập nhật đúng record
        categoryService.save(cat);

        if (cat.getParentId() != null && cat.getParentId() != 0) {
            ra.addFlashAttribute("success", "Đã cập nhật danh mục con.");
            return "redirect:/admin/categories/" + cat.getParentId() + "/subcategories";
        } else {
            ra.addFlashAttribute("success", "Đã cập nhật danh mục cha.");
            return "redirect:/admin/categories";
        }
    }

    // --------------------- ĐỔI TRẠNG THÁI (POST) ---------------------
    // ĐỔI TRẠNG THÁI (ACTIVE/INACTIVE) – POST
    @PostMapping("/toggle/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String toggleCategory(@PathVariable Long id,
            @RequestHeader(value = "referer", required = false) String referer,
            RedirectAttributes ra) {
        Category updated = categoryService.toggleStatusAndReturn(id);
        ra.addFlashAttribute("successMessage", "Đã đổi trạng thái danh mục!");

        if (referer != null && referer.contains("/edit/")) {
            return (updated.getParentId() != null && updated.getParentId() != 0)
                    ? "redirect:/admin/categories/" + updated.getParentId() + "/subcategories"
                    : "redirect:/admin/categories";
        }
        return "redirect:" + (referer != null ? referer : "/admin/categories");
    }

}