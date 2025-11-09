package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.security.CustomUserDetails;

import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.repository.CategoryRepository;
// removed unused ProductStorageRepository import
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
    // product storage repository not needed here; use ProductStorageService if
    // required
    private final SellerStoreRepository storeRepo;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    // Trim đầu/cuối; chuỗi toàn khoảng trắng => null (kích hoạt @NotBlank)
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    // Get current seller's store ID from authenticated user
    private Long getCurrentSellerStoreId(CustomUserDetails currentUser) {
        if (currentUser == null || currentUser.getUser() == null) {
            return null;
        }
        SellerStore sellerStore = currentUser.getUser().getSellerStore();
        return sellerStore != null ? sellerStore.getId() : null;
    }

    // Resolve store ID: use provided storeId or get from current user
    private Long resolveStoreId(Long storeId, CustomUserDetails currentUser) {
        return storeId != null ? storeId : getCurrentSellerStoreId(currentUser);
    }

    // Lấy tối đa 4 danh mục cha để hiển thị nhanh
    private List<Category> top4Parents() {
        List<Category> parents = categoryRepo.findByParentIsNullAndIsDeletedFalseOrderByNameAsc();
        return parents.size() > 4 ? parents.subList(0, 4) : parents;
    }

    // Tiện ích lấy max price của store (có thể null)
    private BigDecimal getStoreMaxPrice(Long storeId) {
        return storeRepo.findById(storeId).map(SellerStore::getMaxListingPrice).orElse(null);
    }

    // Xóa file ảnh cũ từ thư mục static
    private void deleteOldImageFile(String imageUrl) {
        if (imageUrl == null || imageUrl.isEmpty())
            return;

        try {
            // Chuyển URL thành đường dẫn file
            String fileName = imageUrl;
            if (fileName.startsWith("/images/products/")) {
                fileName = fileName.substring("/images/products/".length());
            } else if (fileName.startsWith("/image/products/")) {
                fileName = fileName.substring("/image/products/".length());
            } else {
                // Nếu URL không theo format mong đợi, bỏ qua
                return;
            }

            Path staticProductsDir = Paths.get("src/main/resources/static/images/products");
            Path fileToDelete = staticProductsDir.resolve(fileName);

            if (Files.exists(fileToDelete)) {
                Files.delete(fileToDelete);
            }
        } catch (Exception e) {
            // Log error silently if needed
        }
    }

    // Tìm số thứ tự tiếp theo để đặt tên file ảnh (ví dụ: nếu có 1.png, 2.png thì
    // trả về 3)
    private int getNextImageNumber(Path directory) throws Exception {
        if (!Files.exists(directory)) {
            return 1;
        }

        int maxNumber = 0;
        try (var stream = Files.list(directory)) {
            var files = stream
                    .filter(Files::isRegularFile)
                    .map(p -> p.getFileName().toString())
                    .toList();

            for (String filename : files) {
                // Lấy tên file không có extension (ví dụ: "123.png" -> "123")
                String nameWithoutExt = filename;
                int dotIndex = filename.lastIndexOf('.');
                if (dotIndex > 0) {
                    nameWithoutExt = filename.substring(0, dotIndex);
                }

                // Thử parse thành số
                try {
                    int num = Integer.parseInt(nameWithoutExt);
                    if (num > maxNumber) {
                        maxNumber = num;
                    }
                } catch (NumberFormatException ignored) {
                    // Bỏ qua file không phải số
                }
            }
        }

        return maxNumber + 1;
    }

    // Lưu một file ảnh đơn vào thư mục static images của project và trả về đường
    // dẫn public
    private String saveSingleImageToStatic(MultipartFile file, Path targetDir, String filename) throws Exception {
        if (file == null || file.isEmpty())
            return null;

        long maxBytes = 10L * 1024 * 1024;
        if (file.getSize() > maxBytes) {
            throw new IllegalArgumentException("Ảnh vượt quá 10MB.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !(contentType.equals("image/jpeg") || contentType.equals("image/png"))) {
            throw new IllegalArgumentException("Chỉ hỗ trợ ảnh JPG hoặc PNG.");
        }

        Files.createDirectories(targetDir);

        String original = file.getOriginalFilename();
        String ext = ".png";
        if (original != null && original.lastIndexOf('.') >= 0) {
            ext = original.substring(original.lastIndexOf('.')).toLowerCase();
        }

        String safeName = filename + ext;
        Path dest = targetDir.resolve(safeName);
        Files.copy(file.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);

        return "/images/products/" + safeName;
    }

    // Lưu nhiều file (theo thứ tự số) vào thư mục static images/products
    private List<String> saveMultipleImagesToStatic(Long productId, MultipartFile[] files) throws Exception {
        if (files == null || files.length == 0) {
            return Collections.emptyList();
        }

        // Kiểm tra xem có file thực sự được upload không
        boolean hasValidFile = false;
        for (MultipartFile f : files) {
            if (f != null && !f.isEmpty() && f.getSize() > 0) {
                hasValidFile = true;
                break;
            }
        }

        if (!hasValidFile) {
            return Collections.emptyList();
        }

        // Target directory inside project static resources
        Path staticProductsDir = Paths.get("src/main/resources/static/images/products");

        // Tìm số thứ tự tiếp theo (chỉ dùng khi productId == null)
        int nextNumber = (productId == null) ? getNextImageNumber(staticProductsDir) : 0;

        List<String> saved = new ArrayList<>();
        for (MultipartFile f : files) {
            if (f == null || f.isEmpty() || f.getSize() == 0)
                continue;

            // Nếu đang update sản phẩm (có productId), dùng productId làm tên file
            // Nếu đang tạo mới (không có productId), dùng số thứ tự tiếp theo
            String filenameBase = (productId != null) ? String.valueOf(productId) : String.valueOf(nextNumber);
            String url = saveSingleImageToStatic(f, staticProductsDir, filenameBase);
            if (url != null) {
                saved.add(url);
                // Chỉ tăng số thứ tự khi đang tạo mới (không có productId)
                if (productId == null) {
                    nextNumber++;
                }
            }
        }

        return saved;
    }

    // ============ LIST ============
    @GetMapping
    public String list(@AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) ProductStatus status,
            @RequestParam(required = false) Long parentCategoryId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String fromDate, // yyyy-MM-dd
            @RequestParam(required = false) String toDate, // yyyy-MM-dd
            @RequestParam(required = false) String minPrice,
            @RequestParam(required = false) String maxPrice,
            @RequestParam(required = false) Long idFrom,
            @RequestParam(required = false) Long idTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        // Get current seller's store ID
        if (currentUser == null || currentUser.getUser() == null) {
            return "redirect:/login?error=not_authenticated";
        }

        SellerStore sellerStore = currentUser.getUser().getSellerStore();
        if (sellerStore == null) {
            model.addAttribute("errorMessage", "Bạn chưa có cửa hàng. Vui lòng liên hệ admin để tạo cửa hàng.");
            return "error";
        }

        Long sid = sellerStore.getId();

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

        java.math.BigDecimal minP = null, maxP = null;
        try {
            if (minPrice != null && !minPrice.trim().isEmpty())
                minP = new java.math.BigDecimal(minPrice);
        } catch (Exception ignored) {
        }
        try {
            if (maxPrice != null && !maxPrice.trim().isEmpty())
                maxP = new java.math.BigDecimal(maxPrice);
        } catch (Exception ignored) {
        }

        Page<Product> data = productService.search(
                sid, q, status, categoryId,
                parentCategoryId, createdFrom, createdToExclusive,
                minP, maxP, idFrom, idTo,
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
        model.addAttribute("minPrice", minPrice);
        model.addAttribute("maxPrice", maxPrice);
        model.addAttribute("idFrom", idFrom);
        model.addAttribute("idTo", idTo);
        model.addAttribute("ProductStatus", ProductStatus.values());
        model.addAttribute("storageStatusAvailable", ProductStorageStatus.AVAILABLE);

        // CUNG CẤP max price cho trang danh sách (để modal Sửa áp giới hạn)
        model.addAttribute("storeMaxListingPrice", getStoreMaxPrice(sid));

        // Truyền thông tin trạng thái cửa hàng để kiểm tra có cho phép thêm sản phẩm
        // không
        storeRepo.findById(sid).ifPresent(store -> {
            model.addAttribute("storeStatus", store.getStatus());
        });

        return "seller/products";
    }

    // ============ NEW FORM ============
    @GetMapping("/new")
    public String createForm(@AuthenticationPrincipal CustomUserDetails currentUser,
            Model model,
            RedirectAttributes redirectAttributes) {
        Long sid = getCurrentSellerStoreId(currentUser);
        if (sid == null) {
            return "redirect:/login?error=not_authenticated";
        }

        // Kiểm tra trạng thái cửa hàng
        Optional<SellerStore> storeOpt = storeRepo.findById(sid);
        if (storeOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Không tìm thấy cửa hàng");
            return "redirect:/seller/products?storeId=" + sid;
        }

        SellerStore sellerStore = storeOpt.get();
        if ("INACTIVE".equals(sellerStore.getStatus().name())) {
            redirectAttributes.addFlashAttribute("error", "Không thể thêm sản phẩm mới khi cửa hàng đã đóng");
            return "redirect:/seller/products?storeId=" + sid;
        }

        Product form = new Product();
        SellerStore store = new SellerStore();
        store.setId(sid);
        form.setSellerStore(store);
        // For new products created by seller, default status should be INACTIVE per
        // requirement
        form.setStatus(ProductStatus.INACTIVE);
        // Stock should be null for new product and not input by seller
        form.setStock(null);

        model.addAttribute("form", form);
        model.addAttribute("storeId", sid);
        // load store limit if available
        model.addAttribute("storeMaxListingPrice", getStoreMaxPrice(sid));
        model.addAttribute("formMode", "CREATE");
        model.addAttribute("parentCategories", top4Parents());
        model.addAttribute("subCategories", Collections.emptyList());

        return "seller/product-form";
    }

    // ============ CREATE ============
    @PostMapping
    public String create(@AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @ModelAttribute("form") Product form,
            BindingResult binding,
            @RequestParam(value = "storeId", required = false) Long storeId,
            @RequestParam(value = "imageFiles", required = false) MultipartFile[] imageFiles,
            Model model,
            RedirectAttributes ra) {

        Long sid = getCurrentSellerStoreId(currentUser);
        if (sid == null) {
            return "redirect:/login?error=not_authenticated";
        }
        SellerStore store = new SellerStore();
        store.setId(sid);
        form.setSellerStore(store);

        // Kiểm tra giá > 0
        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.valueOf(0.01)) < 0) {
            binding.rejectValue("price", "price.min", "Giá phải lớn hơn 0.");
        }

        // Kiểm tra trần giá theo store (nếu có)
        BigDecimal maxPrice = getStoreMaxPrice(sid);
        if (maxPrice != null && form.getPrice() != null && form.getPrice().compareTo(maxPrice) > 0) {
            binding.rejectValue("price", "price.max", "Giá vượt mức tối đa cho phép của cửa hàng.");
        }

        if (binding.hasErrors()) {
            // nạp lại dropdown khi có lỗi
            model.addAttribute("storeId", sid);
            model.addAttribute("storeMaxListingPrice", maxPrice);
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

        // // Tạo sản phẩm trước để có ID
        // Product createdProduct = productService.create(form);

        // // Sau đó upload ảnh với tên file dựa trên productId
        // try {
        // List<String> saved = saveMultipleImagesToStatic(createdProduct.getId(),
        // imageFiles);
        // if (!saved.isEmpty()) {
        // // Cập nhật lại product với URL ảnh
        // createdProduct.setProductUrl(saved.get(0));
        // productService.update(createdProduct, sid);
        // }
        // } catch (Exception e) {
        // // Nếu upload ảnh thất bại, sản phẩm vẫn được tạo nhưng không có ảnh
        // ra.addFlashAttribute("warningMessage", "Sản phẩm đã được tạo nhưng upload ảnh
        // thất bại: " + e.getMessage());
        // return "redirect:/seller/products";
        // }

        ra.addFlashAttribute("successMessage", "Thêm sản phẩm mới thành công!");
        return "redirect:/seller/products";
    }

    // ============ EDIT FORM ============
    @GetMapping("/{id}/edit")
    public String editForm(@AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            Model model) {
        Long sid = getCurrentSellerStoreId(currentUser);
        if (sid == null) {
            return "redirect:/login?error=not_authenticated";
        }
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
        // load store limit if available
        model.addAttribute("storeMaxListingPrice", getStoreMaxPrice(sid));

        return "seller/product-form";
    }

    // ============ UPDATE ============
    @PostMapping("/{id}")
    public String update(@AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @Valid @ModelAttribute("form") Product form,
            BindingResult binding,
            @RequestParam(value = "storeId", required = false) Long storeId,
            @RequestParam(value = "imageFiles", required = false) MultipartFile[] imageFiles,
            Model model,
            RedirectAttributes redirectAttributes) {

        Long sid = resolveStoreId(storeId, currentUser);
        if (sid == null) {
            return "redirect:/login?error=not_authenticated";
        }
        form.setId(id);

        Product existed = productService.getOwned(id, sid);

        // Lấy giá niêm yết tối đa của cửa hàng
        BigDecimal maxPrice = getStoreMaxPrice(sid);

        // Kiểm tra giá > 0
        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.valueOf(0.01)) < 0) {
            binding.rejectValue("price", "price.min", "Giá phải lớn hơn 0.");
        }

        // Kiểm tra trần giá theo store (nếu có)
        if (maxPrice != null && form.getPrice() != null && form.getPrice().compareTo(maxPrice) > 0) {
            binding.rejectValue("price", "price.max",
                    "Giá vượt mức tối đa cho phép của cửa hàng. Giá niêm yết tối đa là: " + maxPrice + " ₫");
        }

        // Ảnh: nếu upload mới thì XÓA ảnh cũ và lưu ảnh mới; nếu không, giữ ảnh cũ
        try {
            List<String> saved = saveMultipleImagesToStatic(id, imageFiles);
            if (!saved.isEmpty()) {
                // XÓA ảnh cũ trước khi cập nhật ảnh mới
                if (existed.getProductUrl() != null && !existed.getProductUrl().isEmpty()) {
                    deleteOldImageFile(existed.getProductUrl());
                }
                form.setProductUrl(saved.get(0));
            } else {
                // Không upload ảnh mới, giữ nguyên ảnh cũ
                form.setProductUrl(existed.getProductUrl());
            }
        } catch (Exception e) {
            binding.rejectValue("productUrl", "image.invalid", e.getMessage());
        }

        if (binding.hasErrors()) {
            model.addAttribute("storeId", sid);
            model.addAttribute("storeMaxListingPrice", maxPrice);
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

        try {
            productService.update(form, sid);
            redirectAttributes.addFlashAttribute("successMessage", "Sửa sản phẩm thành công!");
            return "redirect:/seller/products";
        } catch (IllegalArgumentException ex) {
            // Bind error to status field so it shows on the form
            binding.rejectValue("status", "status.invalid", ex.getMessage());

            model.addAttribute("storeId", sid);
            model.addAttribute("storeMaxListingPrice", maxPrice);
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
    }

    // ============ TOGGLE STATUS ============
    @PostMapping("/{id}/toggle")
    public String toggle(@AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @RequestParam ProductStatus to,
            RedirectAttributes ra) {
        Long sid = getCurrentSellerStoreId(currentUser);
        if (sid == null) {
            return "redirect:/login?error=not_authenticated";
        }
        try {
            productService.toggle(id, sid, to);
            ra.addFlashAttribute("successMessage", "Đã chuyển trạng thái sản phẩm #" + id + " sang " + to);
        } catch (IllegalArgumentException ex) {
            ra.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/seller/products";
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

    // ============ DETAIL (view-only) ============
    @GetMapping("/{id}")
    public String detail(@PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(value = "storeId", required = false) Long storeId,
            Model model,
            RedirectAttributes redirectAttributes) {
        Long sid = resolveStoreId(storeId, currentUser);

        try {
            // Use getOwned to ensure seller can only view their product in seller context
            Product product = productService.getOwned(id, sid);

            model.addAttribute("product", product);
            model.addAttribute("storeId", sid);

            return "seller/product-detail";
        } catch (IllegalArgumentException e) {
            // Product not found or doesn't belong to this store
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Không tìm thấy sản phẩm hoặc sản phẩm không thuộc cửa hàng của bạn.");
            return "redirect:/seller/products";
        }
    }

    // ============ AJAX: cập nhật nhanh (dùng cho modal) ============
    @PostMapping(value = "/{id}/ajax-update", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> ajaxUpdate(@AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @RequestBody Map<String, Object> payload) {
        Long sid = getCurrentSellerStoreId(currentUser);
        Map<String, Object> out = new HashMap<>();
        if (sid == null) {
            out.put("ok", false);
            out.put("message", "Not authenticated");
            return out;
        }
        try {
            Product existing = productService.getOwned(id, sid);

            // apply simple updates
            String name = (String) payload.get("name");
            String slug = (String) payload.get("slug");
            Object priceObj = payload.get("price");
            Object stockObj = payload.get("stock");
            String statusStr = (String) payload.get("status");

            if (name != null)
                existing.setName(name);
            if (slug != null)
                existing.setSlug(slug);
            if (priceObj != null) {
                // Try to coerce common formatted input into a clean numeric string.
                // Users may paste values with grouping (commas/dots) or currency symbols.
                String raw = String.valueOf(priceObj).trim();
                // Keep digits, dot, comma and minus for initial normalization
                String cleaned = raw.replaceAll("[^0-9,\\.\\-]", "");
                // Remove common thousand separators (commas)
                cleaned = cleaned.replaceAll(",", "");
                // If there are multiple dots (e.g. 1.000.000) assume dots are thousand
                // separators and remove them. If there's only one dot it may be a
                // decimal separator and should be kept.
                int dotCount = cleaned.length() - cleaned.replace(".", "").length();
                if (dotCount > 1) {
                    cleaned = cleaned.replaceAll("\\.", "");
                }

                if (cleaned.isEmpty() || cleaned.equals("-") || cleaned.equals(".")) {
                    out.put("ok", false);
                    out.put("message", "Giá không hợp lệ");
                    return out;
                }

                try {
                    existing.setPrice(new java.math.BigDecimal(cleaned));
                } catch (Exception pe) {
                    out.put("ok", false);
                    out.put("message", "Giá không hợp lệ");
                    return out;
                }
            }
            if (stockObj != null) {
                try {
                    existing.setStock(Integer.valueOf(String.valueOf(stockObj)));
                } catch (Exception ignored) {
                }
            }
            if (statusStr != null) {
                try {
                    existing.setStatus(ProductStatus.valueOf(statusStr));
                } catch (Exception ignored) {
                }
            }

            // optional fields: description and category
            String desc = (String) payload.get("description");
            Object catIdObj = payload.get("categoryId");
            if (desc != null)
                existing.setDescription(desc);
            if (catIdObj != null) {
                try {
                    Long cid = Long.valueOf(String.valueOf(catIdObj));
                    categoryRepo.findById(cid).ifPresent(existing::setCategory);
                } catch (Exception ignored) {
                }
            }

            // Kiểm tra trần giá theo store khi AJAX lưu nhanh
            BigDecimal maxPrice = getStoreMaxPrice(sid);
            if (maxPrice != null && existing.getPrice() != null && existing.getPrice().compareTo(maxPrice) > 0) {
                out.put("ok", false);
                out.put("message", "Giá vượt mức tối đa cho phép của cửa hàng.");
                return out;
            }
            // Kiểm tra giá tối thiểu khi AJAX
            if (existing.getPrice() == null || existing.getPrice().compareTo(BigDecimal.valueOf(0.01)) < 0) {
                out.put("ok", false);
                out.put("message", "Giá phải lớn hơn 0.");
                return out;
            }

            // Delegate to service.update for validation and persist
            productService.update(existing, sid);

            out.put("ok", true);
            out.put("message", "Cập nhật thành công");
            return out;
        } catch (IllegalArgumentException ex) {
            out.put("ok", false);
            out.put("message", ex.getMessage());
            return out;
        } catch (Exception ex) {
            out.put("ok", false);
            out.put("message", "Lỗi hệ thống");
            return out;
        }
    }

    // ============ AJAX: Upload ảnh sản phẩm ============
    @PostMapping(value = "/{id}/upload-image", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> uploadImage(@PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("imageFile") MultipartFile imageFile,
            @RequestParam(value = "storeId", required = false) Long storeId) {
        Long sid = resolveStoreId(storeId, currentUser);
        Map<String, Object> out = new HashMap<>();

        try {
            Product existing = productService.getOwned(id, sid);

            // Validate file
            if (imageFile == null || imageFile.isEmpty()) {
                out.put("ok", false);
                out.put("message", "Vui lòng chọn file ảnh");
                return out;
            }

            // Validate file type
            String contentType = imageFile.getContentType();
            if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png"))) {
                out.put("ok", false);
                out.put("message", "Chỉ chấp nhận file JPG hoặc PNG");
                return out;
            }

            // Validate file size (max 10MB)
            if (imageFile.getSize() > 10 * 1024 * 1024) {
                out.put("ok", false);
                out.put("message", "File ảnh không được vượt quá 10MB");
                return out;
            }

            // Delete old image first
            if (existing.getProductUrl() != null && !existing.getProductUrl().isEmpty()) {
                deleteOldImageFile(existing.getProductUrl());
            }

            // Save new image with same base filename as productId
            Path staticProductsDir = Paths.get("src/main/resources/static/images/products");
            Files.createDirectories(staticProductsDir);

            // Use productId as base filename (without extension)
            String filenameBase = String.valueOf(id);
            String imageUrl = saveSingleImageToStatic(imageFile, staticProductsDir, filenameBase);

            // Update product
            existing.setProductUrl(imageUrl);
            productService.update(existing, sid);

            out.put("ok", true);
            out.put("message", "Upload ảnh thành công");
            out.put("imageUrl", imageUrl);
            return out;

        } catch (IllegalArgumentException ex) {
            out.put("ok", false);
            out.put("message", ex.getMessage());
            return out;
        } catch (Exception ex) {
            out.put("ok", false);
            out.put("message", "Lỗi khi upload ảnh: " + ex.getMessage());
            return out;
        }
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
