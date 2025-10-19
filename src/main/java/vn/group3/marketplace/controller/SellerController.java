package vn.group3.marketplace.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.service.SellerStoreService;
import vn.group3.marketplace.service.UserService;

@Controller
@RequestMapping("/seller")
public class SellerController {

    private final UserService userService;
    private final SellerStoreService sellerStoreService;

    public SellerController(UserService userService, SellerStoreService sellerStoreService) {
        this.userService = userService;
        this.sellerStoreService = sellerStoreService;
    }

    /**
     * Display seller registration form
     */
    @GetMapping("/register")
    public String showSellerRegistration(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // Check if user already has a store
        if (sellerStoreService.hasExistingStore(currentUser)) {
            return "redirect:/seller/dashboard";
        }

        // Add current user and balance information to model
        model.addAttribute("user", currentUser);
        model.addAttribute("userBalance", currentUser.getBalance());

        // Add system settings to model
        model.addAttribute("minDepositAmount", sellerStoreService.getMinDepositAmount());
        model.addAttribute("maxListingPriceRate", sellerStoreService.getMaxListingPriceRate());
        model.addAttribute("platformFeeRate", sellerStoreService.getPlatformFeeRate());

        return "seller/seller-register";
    }

    /**
     * Process seller registration
     */
    @PostMapping("/register")
    public String processSellerRegistration(
            @RequestParam String storeName,
            @RequestParam(required = false) String storeDescription,
            @RequestParam String ownerName,
            @RequestParam String depositAmount,
            Model model,
            RedirectAttributes redirectAttributes) {

        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            // Parse and validate deposit amount
            BigDecimal deposit;
            try {
                // Remove commas and convert to BigDecimal
                deposit = new BigDecimal(depositAmount.replace(",", ""));
            } catch (NumberFormatException e) {
                model.addAttribute("error", "Số tiền ký quỹ không hợp lệ");
                return "seller/seller-register";
            }

            // Create new store in INACTIVE status
            SellerStore store = SellerStore.builder()
                    .owner(currentUser)
                    .storeName(storeName)
                    .description(storeDescription)
                    .depositAmount(deposit)
                    .status(StoreStatus.INACTIVE)
                    .build();

            // Process deposit and create store
            SellerStore createdStore = sellerStoreService.createStore(store);

            redirectAttributes.addFlashAttribute("success",
                    "Đăng ký cửa hàng thành công! Vui lòng chờ trong khi chúng tôi xử lý khoản tiền ký quỹ.");
            return "redirect:/seller/register-success?storeId=" + createdStore.getId();

        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "seller/seller-register";
        } catch (Exception e) {
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "seller/seller-register";
        }
    }

    /**
     * Show pending registration page while store deposit is being processed
     */
    @GetMapping("/pending-registration")
    public String showPendingRegistration(@RequestParam Long storeId, Model model) {
        SellerStore store = sellerStoreService.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));

        // If store is already active, redirect to dashboard
        if (store.getStatus() == StoreStatus.ACTIVE) {
            return "redirect:/seller/dashboard";
        }

        model.addAttribute("store", store);
        return "seller/pending-registration";
    }

    /**
     * Show registration success page with store details
     */
    @GetMapping("/register-success")
    public String showRegistrationSuccess(@RequestParam Long storeId, Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // Get store details
        SellerStore store = sellerStoreService.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));

        // Add data to model
        model.addAttribute("user", currentUser);
        model.addAttribute("store", store);

        return "seller/register-success";
    }

    /**
     * Check if store name exists (AJAX endpoint)
     */
    @GetMapping("/check-store-name")
    @ResponseBody
    public org.springframework.http.ResponseEntity<java.util.Map<String, Object>> checkStoreName(
            @RequestParam String storeName) {
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        boolean exists = sellerStoreService.isStoreNameExists(storeName);
        response.put("exists", exists);
        if (exists) {
            response.put("message", "Tên cửa hàng đã tồn tại. Vui lòng chọn tên khác.");
            // Return 409 Conflict when the name is already taken - this makes it easy for
            // frontend to
            // detect and show an inline error.
            return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.CONFLICT)
                    .body(response);
        }

        response.put("message", "Tên cửa hàng khả dụng.");
        return org.springframework.http.ResponseEntity.ok(response);
    }
}
