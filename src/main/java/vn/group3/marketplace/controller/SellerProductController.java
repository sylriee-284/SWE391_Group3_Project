package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
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

import jakarta.validation.Valid;
import org.springframework.validation.BindingResult;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.nio.file.*;

@Controller
@RequestMapping("/seller/products")
@RequiredArgsConstructor
public class SellerProductController {

    private final ProductService productService;
    private final CategoryRepository categoryRepo;
    private final ProductStorageRepository storageRepo;
    private final SellerStoreRepository storeRepo;

    private static final Long DEFAULT_STORE_ID = 1L;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    // Trim đầu/cuối; chuỗi toàn khoảng trắng => null (kích hoạt @NotBlank)
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    private Long resolveStoreId(Long storeId) {
        return Optional.ofNullable(storeId).orElse(DEFAULT_STORE_ID);
    }

    // Lấy tối đa 4 danh mục cha để hiển thị nhanh
    private List<Category> top4Parents() {
        List<Category> parents = categoryRepo.findByParentIsNullAndIsDeletedFalseOrderByNameAsc();
        return parents.size() > 4 ? parents.subList(0, 4) : parents;
    }

    // Lưu ảnh vào thư mục uploads và trả về đường dẫn public
    private String saveImageToUploads(MultipartFile file) throws Exception {
        if (file == null || file.isEmpty())
            return null;

        // Kiểm tra MIME & size (<= 10MB)
        long maxBytes = 10L * 1024 * 1024;
        if (file.getSize() > maxBytes) {
            throw new IllegalArgumentException("Ảnh vượt quá 10MB.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !(contentType.equals("image/jpeg") || contentType.equals("image/png"))) {
            throw new IllegalArgumentException("Chỉ hỗ trợ ảnh JPG hoặc PNG.");
        }

        Path root = Paths.get(uploadDir);
        Files.createDirectories(root);

        String original = file.getOriginalFilename();
        String ext = ".jpg";
        if (original != null && original.lastIndexOf('.') >= 0) {
            ext = original.substring(original.lastIndexOf('.')).toLowerCase();
        }
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;
        Path dest = root.resolve(filename);
        Files.copy(file.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);

        return "/uploads/" + filename;
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

        Page<Product> data = productService.search(
                sid, q, status, categoryId,
                parentCategoryId, createdFrom, createdToExclusive,
                PageRequest.of(page, size));

        // Phục vụ filter ở trang danh sách
        List<Category> allCats = categoryRepo.findByIsDeletedFalse();
        List<Category> parentCategories = allCats.stream()
                .filter(c -> c.getParent() == null)
                .sorted(Comparator.comparing(Category::getName, String.CASE_INSENSITIVE_ORDER))
                .collect(Collectors.toList());

        List<Category> subCategories = parentCategoryId == null
                ? Collections.emptyList()
                : allCats.stream()
                        .filter(c -> c.getParent() != null && Objects.equals(c.getParent().getId(), parentCategoryId))
                        .sorted(Comparator.comparing(Category::getName, String.CASE_INSENSITIVE_ORDER))
                        .collect(Collectors.toList());

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
        model.addAttribute("formMode", "CREATE");
        model.addAttribute("parentCategories", top4Parents());
        model.addAttribute("subCategories", Collections.emptyList());

        return "seller/product-form";
    }

    // ============ CREATE ============
    @PostMapping
    public String create(@Valid @ModelAttribute("form") Product form,
            BindingResult binding,
            @RequestParam(value = "storeId", required = false) Long storeId,
            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
            Model model,
            RedirectAttributes ra) {

        Long sid = resolveStoreId(storeId);
        SellerStore store = new SellerStore();
        store.setId(sid);
        form.setSellerStore(store);

        // Upload ảnh (nếu có)
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imagePath = saveImageToUploads(imageFile);
                form.setProductUrl(imagePath);
            } catch (Exception e) {
                binding.rejectValue("productUrl", "image.invalid", e.getMessage());
            }
        }

        // Kiểm tra giá > 0 nếu entity chưa có constraint
        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.valueOf(0.01)) < 0) {
            binding.rejectValue("price", "price.min", "Giá phải lớn hơn 0.");
        }

        if (binding.hasErrors()) {
            // nạp lại dropdown khi có lỗi
            model.addAttribute("storeId", sid);
            model.addAttribute("formMode", "CREATE");
            model.addAttribute("parentCategories", top4Parents());

            List<Category> subCats = Collections.emptyList();
            if (form.getCategory() != null && form.getCategory().getId() != null) {
                Category current = categoryRepo.findById(form.getCategory().getId()).orElse(null);
                if (current != null && current.getParent() != null) {
                    subCats = categoryRepo.findByParentAndIsDeletedFalse(current.getParent());
                    model.addAttribute("selectedParentId", current.getParent().getId());
                    model.addAttribute("selectedChildId", current.getId());
                }
            }
            model.addAttribute("subCategories", subCats);
            return "seller/product-form";
        }

        productService.create(form);
        ra.addFlashAttribute("success", "Thêm sản phẩm mới thành công!");
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
        model.addAttribute("formMode", "UPDATE");

        List<Category> parents = top4Parents();
        model.addAttribute("parentCategories", parents);

        List<Category> subCats = Collections.emptyList();
        Long selectedParentId = null;
        Long selectedChildId = null;

        if (form.getCategory() != null) {
            Category current = form.getCategory();
            Category parent = (current.getParent() == null) ? current : current.getParent();
            selectedParentId = parent != null ? parent.getId() : null;
            selectedChildId = current.getId();
            if (parent != null) {
                subCats = categoryRepo.findByParentAndIsDeletedFalse(parent);
            }
        }

        model.addAttribute("selectedParentId", selectedParentId);
        model.addAttribute("selectedChildId", selectedChildId);
        model.addAttribute("subCategories", subCats);

        return "seller/product-form";
    }

    // ============ UPDATE ============
    @PostMapping("/{id}")
    public String update(@PathVariable Long id,
            @Valid @ModelAttribute("form") Product form,
            BindingResult binding,
            @RequestParam(value = "storeId", required = false) Long storeId,
            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
            Model model,
            RedirectAttributes ra) {

        Long sid = resolveStoreId(storeId);
        form.setId(id);

        Product existed = productService.getOwned(id, sid);

        // Ảnh: nếu upload mới thì validate; nếu không, giữ ảnh cũ
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imagePath = saveImageToUploads(imageFile);
                form.setProductUrl(imagePath);
            } catch (Exception e) {
                binding.rejectValue("productUrl", "image.invalid", e.getMessage());
            }
        } else {
            form.setProductUrl(existed.getProductUrl());
        }

        // Kiểm tra giá > 0 nếu entity chưa có constraint
        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.valueOf(0.01)) < 0) {
            binding.rejectValue("price", "price.min", "Giá phải lớn hơn 0.");
        }

        if (binding.hasErrors()) {
            model.addAttribute("storeId", sid);
            model.addAttribute("formMode", "UPDATE");

            List<Category> parents = top4Parents();
            model.addAttribute("parentCategories", parents);

            List<Category> subCats = Collections.emptyList();
            Long selectedParentId = null;
            Long selectedChildId = null;

            if (form.getCategory() != null) {
                Category current = form.getCategory();
                Category parent = (current.getParent() == null) ? current : current.getParent();
                selectedParentId = parent != null ? parent.getId() : null;
                selectedChildId = current.getId();
                if (parent != null)
                    subCats = categoryRepo.findByParentAndIsDeletedFalse(parent);
            }

            model.addAttribute("selectedParentId", selectedParentId);
            model.addAttribute("selectedChildId", selectedChildId);
            model.addAttribute("subCategories", subCats);
            return "seller/product-form";
        }

        productService.update(form, sid);
        ra.addFlashAttribute("success", "Sửa sản phẩm thành công!");
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

    // ============ API: trả danh mục con (JSON) ============
    @GetMapping(value = "/categories", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Option> childrenByParent(@RequestParam("parentId") Long parentId) {
        List<Category> children = categoryRepo.findByParent_IdAndIsDeletedFalseOrderByNameAsc(parentId);
        List<Option> out = new ArrayList<>();
        for (Category c : children) {
            out.add(new Option(c.getId(), c.getName()));
        }
        return out;
    }

    // DTO đơn giản cho JSON
    public static class Option {
        private final Long id;
        private final String name;

        public Option(Long id, String name) {
            this.id = id;
            this.name = name;
        }

        public Long getId() {
            return id;
        }

        public String getName() {
            return name;
        }
    }
}
