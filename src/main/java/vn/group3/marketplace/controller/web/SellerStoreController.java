package vn.group3.marketplace.controller.web;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.dto.request.SellerStoreCreateRequest;
import vn.group3.marketplace.dto.request.SellerStoreUpdateRequest;
import vn.group3.marketplace.dto.response.SellerStoreResponse;
import vn.group3.marketplace.dto.response.StoreDashboardResponse;
import vn.group3.marketplace.service.interfaces.SellerStoreService;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.math.BigDecimal;
import java.util.Optional;

/**
 * Controller for seller store management
 * Handles web requests for store operations
 */
@Slf4j
@Controller
@RequestMapping("/stores")
@RequiredArgsConstructor
public class SellerStoreController {

    private final SellerStoreService sellerStoreService;
    private final WalletService walletService;

    /**
     * Show all active stores (public view)
     */
    @GetMapping
    public String listStores(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            Model model) {

        Sort.Direction sortDirection = "desc".equalsIgnoreCase(direction) ? 
                Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));

        Page<SellerStoreResponse> stores;
        
        if (search != null && !search.trim().isEmpty()) {
            String sanitizedSearch = sanitizeSearchInput(search.trim());
            stores = sellerStoreService.searchStores(sanitizedSearch, pageable);
            model.addAttribute("search", sanitizedSearch);
        } else if (status != null && !status.trim().isEmpty()) {
            String sanitizedStatus = sanitizeStatusInput(status.trim());
            stores = sellerStoreService.getStoresByStatus(sanitizedStatus, pageable);
            model.addAttribute("status", sanitizedStatus);
        } else {
            stores = sellerStoreService.getAllActiveStores(pageable);
        }

        model.addAttribute("stores", stores);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", stores.getTotalPages());
        model.addAttribute("totalElements", stores.getTotalElements());
        model.addAttribute("sort", sort);
        model.addAttribute("direction", direction);

        return "store/list";
    }

    /**
     * Show store details (public view)
     */
    @GetMapping("/{storeId}")
    public String viewStore(@PathVariable Long storeId, Model model) {
        Optional<SellerStore> storeOpt = sellerStoreService.getStoreById(storeId);
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores?error=store_not_found";
        }

        SellerStore store = storeOpt.get();
        SellerStoreResponse storeResponse = SellerStoreResponse.fromEntity(store);

        model.addAttribute("store", storeResponse);
        // TODO: Add products, reviews, and other store data

        return "store/detail";
    }

    /**
     * Show create store form
     */
    @GetMapping("/create")
    // @PreAuthorize("hasRole('USER')") // TEMPORARILY DISABLED for testing
    public String showCreateForm(@AuthenticationPrincipal User currentUser, Model model) {
        // TEMPORARILY FAKE USER ID = 2 for testing (no authentication)
        Long userId = (currentUser != null) ? currentUser.getId() : 2L;

        // if (currentUser == null) {
        //     return "redirect:/auth/login?error=authentication_required";
        // }

        // Check if user already has a store
        Optional<SellerStore> existingStore = sellerStoreService.getStoreByOwnerId(userId);
        if (existingStore.isPresent()) {
            return "redirect:/stores/my-store?error=already_has_store";
        }

        model.addAttribute("createRequest", new SellerStoreCreateRequest());
        model.addAttribute("minimumDeposit", sellerStoreService.getMinimumDepositAmount());

        // Get user's wallet balance
        addWalletBalanceToModel(userId, model);

        return "store/create";
    }

    /**
     * Process store creation
     */
    @PostMapping("/create")
    // @PreAuthorize("hasRole('USER')") // TEMPORARILY DISABLED for testing
    public String createStore(
            @Valid @ModelAttribute("createRequest") SellerStoreCreateRequest request,
            BindingResult bindingResult,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes,
            Model model) {

        // TEMPORARILY FAKE USER ID = 2 for testing (no authentication)
        Long userId = (currentUser != null) ? currentUser.getId() : 2L;

        // if (currentUser == null) {
        //     return "redirect:/auth/login?error=authentication_required";
        // }

        if (bindingResult.hasErrors()) {
            model.addAttribute("minimumDeposit", sellerStoreService.getMinimumDepositAmount());
            addWalletBalanceToModel(userId, model);
            return "store/create";
        }

        try {
            SellerStore store = sellerStoreService.createStore(userId, request);
            redirectAttributes.addFlashAttribute("success",
                "Cửa hàng đã được tạo thành công! ID: " + store.getId());
            return "redirect:/stores/my-store";
        } catch (Exception e) {
            log.error("Failed to create store for user {}: {}", userId, e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể tạo cửa hàng: " + e.getMessage());
            return "redirect:/stores/create";
        }
    }

    /**
     * Show user's own store dashboard
     */
    @GetMapping("/my-store")
    @PreAuthorize("hasRole('SELLER')")
    public String myStoreDashboard(@AuthenticationPrincipal User currentUser, Model model) {
        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();
        StoreDashboardResponse dashboard = sellerStoreService.getStoreDashboard(store.getId());

        model.addAttribute("store", store);
        model.addAttribute("dashboard", dashboard);

        return "store/dashboard";
    }

    /**
     * Show store settings form
     */
    @GetMapping("/my-store/settings")
    @PreAuthorize("hasRole('SELLER')")
    public String showStoreSettings(@AuthenticationPrincipal User currentUser, Model model) {
        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();
        
        // Create update request from current store data
        SellerStoreUpdateRequest updateRequest = SellerStoreUpdateRequest.builder()
                .storeName(store.getStoreName())
                .storeDescription(store.getStoreDescription())
                .contactEmail(store.getContactEmail())
                .contactPhone(store.getContactPhone())
                .businessLicense(store.getBusinessLicense())
                .storeLogoUrl(store.getStoreLogoUrl())
                .build();

        model.addAttribute("store", store);
        model.addAttribute("updateRequest", updateRequest);

        return "store/settings";
    }

    /**
     * Process store settings update
     */
    @PostMapping("/my-store/settings")
    @PreAuthorize("hasRole('SELLER')")
    public String updateStoreSettings(
            @Valid @ModelAttribute("updateRequest") SellerStoreUpdateRequest request,
            BindingResult bindingResult,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes,
            Model model) {

        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();

        if (bindingResult.hasErrors()) {
            model.addAttribute("store", store);
            return "store/settings";
        }

        try {
            sellerStoreService.updateStore(store.getId(), request);
            redirectAttributes.addFlashAttribute("success", "Thông tin cửa hàng đã được cập nhật!");
            return "redirect:/stores/my-store/settings";
        } catch (Exception e) {
            log.error("Failed to update store {} for user {}: {}", store.getId(), currentUser.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể cập nhật thông tin: " + e.getMessage());
            return "redirect:/stores/my-store/settings";
        }
    }

    /**
     * Upload store logo
     */
    @PostMapping("/my-store/upload-logo")
    @PreAuthorize("hasRole('SELLER')")
    public String uploadLogo(
            @RequestParam("logoFile") MultipartFile logoFile,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();

        if (logoFile.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Vui lòng chọn file logo!");
            return "redirect:/stores/my-store/settings";
        }

        try {
            sellerStoreService.uploadStoreLogo(store.getId(), logoFile);
            redirectAttributes.addFlashAttribute("success", "Logo đã được cập nhật!");
        } catch (Exception e) {
            log.error("Failed to upload logo for store {}: {}", store.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể tải lên logo: " + e.getMessage());
        }

        return "redirect:/stores/my-store/settings";
    }

    /**
     * Remove store logo
     */
    @PostMapping("/my-store/remove-logo")
    @PreAuthorize("hasRole('SELLER')")
    public String removeLogo(
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();

        try {
            sellerStoreService.removeStoreLogo(store.getId());
            redirectAttributes.addFlashAttribute("success", "Logo đã được xóa!");
        } catch (Exception e) {
            log.error("Failed to remove logo for store {}: {}", store.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể xóa logo: " + e.getMessage());
        }

        return "redirect:/stores/my-store/settings";
    }

    /**
     * Deactivate store
     */
    @PostMapping("/my-store/deactivate")
    @PreAuthorize("hasRole('SELLER')")
    public String deactivateStore(
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();

        try {
            sellerStoreService.deactivateStore(store.getId(), currentUser.getId());
            redirectAttributes.addFlashAttribute("success", "Cửa hàng đã được tạm ngưng hoạt động!");
        } catch (Exception e) {
            log.error("Failed to deactivate store {}: {}", store.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể tạm ngưng cửa hàng: " + e.getMessage());
        }

        return "redirect:/stores/my-store";
    }

    /**
     * Activate store
     */
    @PostMapping("/my-store/activate")
    @PreAuthorize("hasRole('SELLER')")
    public String activateStore(
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        Optional<SellerStore> storeOpt = sellerStoreService.getStoreByOwnerId(currentUser.getId());
        
        if (storeOpt.isEmpty()) {
            return "redirect:/stores/create?info=no_store";
        }

        SellerStore store = storeOpt.get();

        try {
            sellerStoreService.activateStore(store.getId(), currentUser.getId());
            redirectAttributes.addFlashAttribute("success", "Cửa hàng đã được kích hoạt!");
        } catch (Exception e) {
            log.error("Failed to activate store {}: {}", store.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể kích hoạt cửa hàng: " + e.getMessage());
        }

        return "redirect:/stores/my-store";
    }

    /**
     * Check store name availability (AJAX)
     */
    @GetMapping("/check-name")
    @ResponseBody
    public boolean checkStoreNameAvailability(
            @RequestParam String storeName,
            @RequestParam(required = false) Long excludeId) {
        return sellerStoreService.isStoreNameAvailable(storeName, excludeId);
    }

    /**
     * Calculate max listing price (AJAX)
     */
    @GetMapping("/calculate-max-price")
    @ResponseBody
    public BigDecimal calculateMaxListingPrice(@RequestParam BigDecimal depositAmount) {
        return sellerStoreService.calculateMaxListingPrice(depositAmount);
    }

    /**
     * Helper method to add wallet balance to model
     * Reduces code duplication
     */
    private void addWalletBalanceToModel(Long userId, Model model) {
        try {
            BigDecimal walletBalance = walletService.getBalance(userId);
            model.addAttribute("walletBalance", walletBalance);
            model.addAttribute("formattedBalance", String.format("%,.0f VND", walletBalance));
        } catch (Exception e) {
            log.warn("Could not get wallet balance for user {}: {}", userId, e.getMessage());
            model.addAttribute("walletBalance", BigDecimal.ZERO);
            model.addAttribute("formattedBalance", "0 VND");
        }
    }

    /**
     * Sanitize search input to prevent injection attacks
     */
    private String sanitizeSearchInput(String search) {
        if (search == null) return "";

        // Remove potentially dangerous characters
        String sanitized = search.replaceAll("[<>\"'%;()&+]", "");

        // Limit length
        if (sanitized.length() > 100) {
            sanitized = sanitized.substring(0, 100);
        }

        return sanitized.trim();
    }

    /**
     * Sanitize status input to only allow valid status values
     */
    private String sanitizeStatusInput(String status) {
        if (status == null) return "";

        // Only allow alphanumeric and underscore
        String sanitized = status.replaceAll("[^a-zA-Z0-9_]", "");

        // Limit to reasonable length
        if (sanitized.length() > 20) {
            sanitized = sanitized.substring(0, 20);
        }

        return sanitized.toLowerCase();
    }
}
