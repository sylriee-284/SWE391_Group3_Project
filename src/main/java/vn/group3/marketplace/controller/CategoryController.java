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

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/admin/categories")
@PreAuthorize("hasRole('ADMIN')")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /**
     * Display category by name
     */
    @GetMapping("/category/{categoryName}")
    public String getCategoryByName(@PathVariable String categoryName) {
        // Simple redirect to homepage for now
        return "redirect:/homepage";
    }

    // ===================== DANH SÁCH CHA =====================
    @GetMapping
    public String listParentCategories(Model model) {
        // ✳️ CHANGED: chỉ load danh mục CHA (parentId == null hoặc 0)
        List<Category> parents = categoryService.findParentCategories();
        model.addAttribute("categories", parents);
        model.addAttribute("parentCategory", null); // ✳️ để JSP biết đang ở chế độ CHA
        model.addAttribute("pageTitle", "Quản lý danh mục (CHA)");
        return "admin/categories";
    }

    // ===================== DANH SÁCH CON (CÓ PHÂN TRANG) =====================
    @GetMapping("/{parentId}/subcategories")
    public String listSubcategories(
            @PathVariable Long parentId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        var parent = categoryService.getById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục cha ID: " + parentId));

        var pageData = categoryService.findSubcategoriesByParentId(parentId, page, size);

        // để JSP hiện danh sách như cũ:
        model.addAttribute("categories", pageData.getContent());

        // truyền thêm info phân trang nếu bạn muốn vẽ nút Prev/Next:
        model.addAttribute("pageData", pageData);
        model.addAttribute("currentPage", page);
        model.addAttribute("pageSize", size);

        model.addAttribute("parentCategory", parent);
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
            parent = categoryService.getById(cat.getParentId()).orElse(null);
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

    // ===================== XOÁ mềm(CHỈ CHO PHÉP XOÁ CON) =====================
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        Category cat = categoryService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));

        if (cat.getParentId() == null || cat.getParentId() == 0) {
            ra.addFlashAttribute("error", "Không thể xoá danh mục CHA.");
            return "redirect:/admin/categories";
        }

        Long parentId = cat.getParentId();
        categoryService.softDelete(id); // 🔸 thay cho deleteById
        ra.addFlashAttribute("success", "Đã xoá (ẩn) danh mục con.");
        return "redirect:/admin/categories/" + parentId + "/subcategories";
    }

}
