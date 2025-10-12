package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.repository.CategoryRepository;
import vn.group3.marketplace.repository.ProductStorageRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.service.ProductService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/seller/products")
@RequiredArgsConstructor
public class SellerProductController {

    private final ProductService productService;
    private final CategoryRepository categoryRepo;
    private final ProductStorageRepository storageRepo;
    private final SellerStoreRepository storeRepo;

    private static final Long DEFAULT_STORE_ID = 1L; // TODO: lấy từ session của bạn

    private Long resolveStoreId(Long storeId) {
        return Optional.ofNullable(storeId).orElse(DEFAULT_STORE_ID);
    }

    // ============ LIST ============
    @GetMapping
    public String list(@RequestParam(value = "storeId", required = false) Long storeId,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) ProductStatus status,
            @RequestParam(required = false) Long parentCategoryId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String fromDate, // yyyy-MM-dd
            @RequestParam(required = false) String toDate, // yyyy-MM-dd
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        Long sid = resolveStoreId(storeId);

        // Parse khoảng ngày (from inclusive, to exclusive)
        LocalDateTime createdFrom = null;
        LocalDateTime createdToExclusive = null;
        try {
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                createdFrom = LocalDate.parse(fromDate).atStartOfDay();
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                createdToExclusive = LocalDate.parse(toDate).plusDays(1).atStartOfDay();
            }
        } catch (Exception ignored) {
        }

        // Gọi service với ĐẦY ĐỦ tham số (lọc trực tiếp ở DB)
        Page<Product> data = productService.search(
                sid, q, status, categoryId,
                parentCategoryId, createdFrom, createdToExclusive,
                PageRequest.of(page, size));

        // Chuẩn bị danh mục lớn / danh mục con cho UI filter
        List<Category> allCats = categoryRepo.findAll();
        List<Category> parentCategories = allCats.stream()
                .filter(c -> c.getParent() == null)
                .sorted((a, b) -> a.getName().compareToIgnoreCase(b.getName()))
                .collect(Collectors.toList());

        List<Category> subCategories = parentCategoryId == null
                ? Collections.emptyList()
                : allCats.stream()
                        .filter(c -> c.getParent() != null && Objects.equals(c.getParent().getId(), parentCategoryId))
                        .sorted((a, b) -> a.getName().compareToIgnoreCase(b.getName()))
                        .collect(Collectors.toList());

        // Model attributes cho view
        model.addAttribute("page", data);
        model.addAttribute("q", q);
        model.addAttribute("status", status);
        model.addAttribute("parentCategoryId", parentCategoryId);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("fromDate", fromDate);
        model.addAttribute("toDate", toDate);
        model.addAttribute("storeId", sid);
        model.addAttribute("parentCategories", parentCategories);
        model.addAttribute("subCategories", subCategories);
        model.addAttribute("ProductStatus", ProductStatus.values());
        model.addAttribute("storageStatusAvailable", ProductStorageStatus.AVAILABLE);

        return "seller/products";
    }

    // ============ NEW FORM ============
    @GetMapping("/new")
    public String createForm(@RequestParam(value = "storeId", required = false) Long storeId, Model model) {
        Long sid = resolveStoreId(storeId);

        Product form = new Product();
        SellerStore store = new SellerStore();
        store.setId(sid);
        form.setSellerStore(store);
        form.setStatus(ProductStatus.ACTIVE);

        model.addAttribute("form", form);
        model.addAttribute("storeId", sid);
        model.addAttribute("categories", categoryRepo.findAll());
        model.addAttribute("formMode", "CREATE");
        return "seller/product-form";
    }

    // ============ CREATE ============
    @PostMapping
    public String create(@ModelAttribute("form") Product form,
            @RequestParam(value = "storeId", required = false) Long storeId,
            RedirectAttributes ra) {
        Long sid = resolveStoreId(storeId);
        SellerStore store = new SellerStore();
        store.setId(sid);
        form.setSellerStore(store);

        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            ra.addFlashAttribute("error", "Giá phải lớn hơn 0.");
            return "redirect:/seller/products/new?storeId=" + sid;
        }

        productService.create(form);
        ra.addFlashAttribute("success", " Thêm sản phẩm mới thành công!");
        return "redirect:/seller/products?storeId=" + sid;
    }

    // ============ EDIT FORM ============
    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id,
            @RequestParam(value = "storeId", required = false) Long storeId,
            Model model) {
        Long sid = resolveStoreId(storeId);
        Product form = productService.getOwned(id, sid);

        model.addAttribute("form", form);
        model.addAttribute("storeId", sid);
        model.addAttribute("categories", categoryRepo.findAll());
        model.addAttribute("formMode", "UPDATE");
        return "seller/product-form";
    }

    // ============ UPDATE ============
    @PostMapping("/{id}")
    public String update(@PathVariable Long id,
            @ModelAttribute("form") Product form,
            @RequestParam(value = "storeId", required = false) Long storeId,
            RedirectAttributes ra) {
        Long sid = resolveStoreId(storeId);
        form.setId(id);
        productService.update(form, sid);
        ra.addFlashAttribute("success", " Sửa sản phẩm thành công!");
        return "redirect:/seller/products?storeId=" + sid;
    }

    // ============ TOGGLE STATUS ============
    @PostMapping("/{id}/toggle")
    public String toggle(@PathVariable Long id,
            @RequestParam ProductStatus to,
            @RequestParam(value = "storeId", required = false) Long storeId,
            RedirectAttributes ra) {
        Long sid = resolveStoreId(storeId);
        productService.toggle(id, sid, to);
        ra.addFlashAttribute("success", "Đã chuyển trạng thái sản phẩm #" + id + " sang " + to);
        return "redirect:/seller/products?storeId=" + sid;
    }

    // ============ SOFT DELETE ============
    @PostMapping("/{id}/delete")
    public String softDelete(@PathVariable Long id,
            @RequestParam(value = "storeId", required = false) Long storeId,
            RedirectAttributes ra) {
        Long sid = resolveStoreId(storeId);
        productService.softDelete(id, sid, 1L); // TODO: thay bằng userId thực tế
        ra.addFlashAttribute("success", "Đã xóa (ẩn) sản phẩm #" + id);
        return "redirect:/seller/products?storeId=" + sid;
    }
}
