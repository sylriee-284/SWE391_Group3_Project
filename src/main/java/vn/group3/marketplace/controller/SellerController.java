package vn.group3.marketplace.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.service.WalletTransactionQueueService;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.StoreStatus;

import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.domain.enums.SellerStoresType;
import vn.group3.marketplace.service.SellerStoreService;
import vn.group3.marketplace.service.UserService;
import vn.group3.marketplace.service.SystemSettingService;
import vn.group3.marketplace.repository.SellerStoreRepository;

@Controller
@RequestMapping("/seller")
@RequiredArgsConstructor
public class SellerController {

    private final UserService userService;
    private final SellerStoreService sellerStoreService;
    private final WalletTransactionQueueService walletTransactionQueueService;
    private final vn.group3.marketplace.service.WalletService walletService;
    private final SystemSettingService systemSettingService;
    private final SellerStoreRepository sellerStoreRepository;
    private final vn.group3.marketplace.service.CloseStoreService closeStoreService;

    /**
     * Display seller registration form
     */
    @GetMapping("/register")
    public String showSellerRegistration(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // If user has an active store, redirect to products page
        if (sellerStoreService.hasActiveStore(currentUser)) {
            return "redirect:/seller/products";
        }

        // Find any existing non-active store (PENDING or INACTIVE)
        SellerStore nonActiveStore = sellerStoreService.findNonActiveStoreByOwner(currentUser);

        // Add non-active store if exists (could be PENDING or INACTIVE)
        if (nonActiveStore != null) {
            model.addAttribute("inactiveStore", nonActiveStore);
        }

        // Add current user and balance information to model
        model.addAttribute("user", currentUser);
        model.addAttribute("userBalance", currentUser.getBalance());

        // Add system settings to model
        model.addAttribute("minDepositAmount", sellerStoreService.getMinDepositAmount());
        model.addAttribute("maxListingPriceRate", sellerStoreService.getMaxListingPriceRate());

        // Add fee settings from SystemSetting (percentage fee and fixed fee for small
        // orders)
        Double percentageFee = systemSettingService.getDoubleValue("fee.percentage_fee", 3.0);
        Integer fixedFee = systemSettingService.getIntValue("fee.fixed_fee", 5000);
        model.addAttribute("percentageFee", percentageFee);
        model.addAttribute("fixedFee", fixedFee);

        // Add refund rate settings from SystemSetting
        Integer maxRefundRateMinDuration = systemSettingService.getIntValue("store.max_refund_rate_min_duration_months",
                12);
        Double percentageMaxRefundRate = systemSettingService.getDoubleValue("store.percentage_max_refund_rate", 100.0);
        Double percentageMinRefundRate = systemSettingService.getDoubleValue("store.percentage_min_refund_rate", 70.0);
        Double noFeeRefundRate = systemSettingService.getDoubleValue("store.no_fee_refund_rate", 50.0);

        model.addAttribute("maxRefundRateMinDuration", maxRefundRateMinDuration);
        model.addAttribute("percentageMaxRefundRate", percentageMaxRefundRate);
        model.addAttribute("percentageMinRefundRate", percentageMinRefundRate);
        model.addAttribute("noFeeRefundRate", noFeeRefundRate);

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
            @RequestParam(required = false, defaultValue = "PERCENTAGE") String feeModel,
            Model model,
            RedirectAttributes redirectAttributes) {

        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            // Always add user data and settings to model for error cases
            model.addAttribute("user", currentUser);
            model.addAttribute("userBalance", currentUser.getBalance());
            model.addAttribute("minDepositAmount", sellerStoreService.getMinDepositAmount());
            model.addAttribute("maxListingPriceRate", sellerStoreService.getMaxListingPriceRate());
            // add fee settings so view can show them on validation errors
            Double percentageFee = systemSettingService.getDoubleValue("fee.percentage_fee", 3.0);
            Integer fixedFee = systemSettingService.getIntValue("fee.fixed_fee", 5000);
            model.addAttribute("percentageFee", percentageFee);
            model.addAttribute("fixedFee", fixedFee);

            // Add refund rate settings for validation errors
            Integer maxRefundRateMinDuration = systemSettingService
                    .getIntValue("store.max_refund_rate_min_duration_months", 12);
            Double percentageMaxRefundRate = systemSettingService.getDoubleValue("store.percentage_max_refund_rate",
                    100.0);
            Double percentageMinRefundRate = systemSettingService.getDoubleValue("store.percentage_min_refund_rate",
                    70.0);
            Double noFeeRefundRate = systemSettingService.getDoubleValue("store.no_fee_refund_rate", 50.0);

            model.addAttribute("maxRefundRateMinDuration", maxRefundRateMinDuration);
            model.addAttribute("percentageMaxRefundRate", percentageMaxRefundRate);
            model.addAttribute("percentageMinRefundRate", percentageMinRefundRate);
            model.addAttribute("noFeeRefundRate", noFeeRefundRate);

            // Parse and validate deposit amount
            BigDecimal deposit;
            try {
                // Remove commas and convert to BigDecimal
                String cleanAmount = depositAmount.trim().replace(",", "");
                deposit = new BigDecimal(cleanAmount);

                // Validate positive amount
                if (deposit.compareTo(BigDecimal.ZERO) <= 0) {
                    model.addAttribute("error", "Số tiền ký quỹ phải lớn hơn 0");
                    model.addAttribute("storeName", storeName);
                    model.addAttribute("storeDescription", storeDescription);
                    model.addAttribute("feeModel", feeModel);
                    return "seller/seller-register";
                }
            } catch (NumberFormatException e) {
                model.addAttribute("error", "Số tiền ký quỹ không hợp lệ. Vui lòng nhập chỉ các chữ số (VD: 1000000)");
                model.addAttribute("storeName", storeName);
                model.addAttribute("storeDescription", storeDescription);
                model.addAttribute("feeModel", feeModel);
                return "seller/seller-register";
            }

            // Check minimum deposit amount
            BigDecimal minDeposit = sellerStoreService.getMinDepositAmount();
            if (deposit.compareTo(minDeposit) < 0) {
                model.addAttribute("error",
                        "Số tiền ký quỹ phải từ " + String.format("%,.0f", minDeposit) + " VNĐ trở lên");
                model.addAttribute("storeName", storeName);
                model.addAttribute("storeDescription", storeDescription);
                model.addAttribute("feeModel", feeModel);
                return "seller/seller-register";
            }

            // Check if deposit amount is divisible by 100,000
            if (deposit.remainder(new BigDecimal(100000)).compareTo(BigDecimal.ZERO) != 0) {
                model.addAttribute("error", "Số tiền ký quỹ phải chia hết cho 100.000 VNĐ");
                model.addAttribute("storeName", storeName);
                model.addAttribute("storeDescription", storeDescription);
                model.addAttribute("feeModel", feeModel);
                return "seller/seller-register";
            }

            // Parse feeModel enum
            SellerStoresType feeModelEnum;
            try {
                feeModelEnum = SellerStoresType.valueOf(feeModel);
            } catch (IllegalArgumentException e) {
                model.addAttribute("error", "Mô hình phí không hợp lệ");
                model.addAttribute("storeName", storeName);
                model.addAttribute("storeDescription", storeDescription);
                return "seller/seller-register";
            }

            // CHECK IF STORE NAME ALREADY EXISTS
            if (sellerStoreService.isStoreNameExists(storeName)) {
                model.addAttribute("error", "Tên cửa hàng đã tồn tại. Vui lòng chọn tên khác.");
                model.addAttribute("storeName", storeName);
                model.addAttribute("storeDescription", storeDescription);
                model.addAttribute("feeModel", feeModel);
                return "seller/seller-register";
            }

            // Get fee percentage rate from system setting if fee model is PERCENTAGE
            BigDecimal feePercentageRate = null;
            if (feeModelEnum == SellerStoresType.PERCENTAGE) {
                Double percentageFeeFromSettings = systemSettingService.getDoubleValue("fee.percentage_fee", 3.0);
                feePercentageRate = BigDecimal.valueOf(percentageFeeFromSettings);
            }

            // Create new store in PENDING status (no immediate payment)
            SellerStore store = SellerStore.builder()
                    .owner(currentUser)
                    .storeName(storeName)
                    .description(storeDescription)
                    .depositAmount(deposit)
                    .feeModel(feeModelEnum)
                    .feePercentageRate(feePercentageRate)
                    .status(StoreStatus.PENDING)
                    .build();

            // Create store without payment - user will activate manually
            SellerStore createdStore = sellerStoreService.createStore(store);

            redirectAttributes.addFlashAttribute("success",
                    "Đăng ký cửa hàng thành công! Vui lòng bấm nút 'Kích hoạt cửa hàng' để thanh toán ký quỹ.");
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
     * Show registration success page with store details
     */
    @GetMapping("/register-success")
    public String showRegistrationSuccess(@RequestParam Long storeId, Model model,
            RedirectAttributes redirectAttributes) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // Get store details
        SellerStore store = sellerStoreService.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));

        // Verify ownership - only store owner can view this page
        if (!store.getOwner().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bạn không có quyền xem thông tin cửa hàng này");
            return "redirect:/";
        }

        // For PENDING stores, show activation prompt
        if (store.getStatus() == StoreStatus.PENDING) {
            model.addAttribute("pendingActivation", true);
        }

        // Add data to model
        model.addAttribute("user", currentUser);
        model.addAttribute("store", store);
        // Add fee settings so the success page can show contract values
        Double percentageFee = systemSettingService.getDoubleValue("fee.percentage_fee", 3.0);
        Integer fixedFee = systemSettingService.getIntValue("fee.fixed_fee", 5000);
        model.addAttribute("percentageFee", percentageFee);
        model.addAttribute("fixedFee", fixedFee);

        // Add refund rate settings so the success page can show refund policy
        Integer maxRefundRateMinDuration = systemSettingService.getIntValue("store.max_refund_rate_min_duration_months",
                12);
        Double percentageMaxRefundRate = systemSettingService.getDoubleValue("store.percentage_max_refund_rate", 100.0);
        Double percentageMinRefundRate = systemSettingService.getDoubleValue("store.percentage_min_refund_rate", 70.0);
        Double noFeeRefundRate = systemSettingService.getDoubleValue("store.no_fee_refund_rate", 50.0);

        model.addAttribute("maxRefundRateMinDuration", maxRefundRateMinDuration);
        model.addAttribute("percentageMaxRefundRate", percentageMaxRefundRate);
        model.addAttribute("percentageMinRefundRate", percentageMinRefundRate);
        model.addAttribute("noFeeRefundRate", noFeeRefundRate);

        return "seller/register-success";
    }

    /**
     * Retry store deposit payment
     */
    @PostMapping("/retry-deposit/{storeId}")
    public String retryStoreDeposit(@PathVariable Long storeId, RedirectAttributes redirectAttributes) {
        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            // Get store information
            SellerStore store = sellerStoreService.findById(storeId)
                    .orElseThrow(() -> new IllegalStateException("Shop không tồn tại"));

            // Verify ownership
            if (!store.getOwner().getId().equals(currentUser.getId())) {
                redirectAttributes.addFlashAttribute("error", "Bạn không có quyền truy cập shop này");
                return "redirect:/seller/register-success?storeId=" + storeId;
            }

            // Verify store status
            if (store.getStatus() == StoreStatus.ACTIVE) {
                redirectAttributes.addFlashAttribute("info", "Shop đã được kích hoạt thành công");
                return "redirect:/seller/register-success?storeId=" + storeId;
            }

            // Check balance before attempting payment
            if (currentUser.getBalance().compareTo(store.getDepositAmount()) < 0) {
                BigDecimal needed = store.getDepositAmount().subtract(currentUser.getBalance());
                redirectAttributes.addFlashAttribute("paymentError",
                        "Số dư không đủ để kích hoạt cửa hàng. Bạn cần nạp thêm " +
                                String.format("%,.0f", needed) + " VNĐ");
                return "redirect:/seller/register-success?storeId=" + storeId;
            }

            // Enqueue payment with same ref
            String paymentRef = "createdShop" + storeId;
            walletTransactionQueueService.enqueuePurchasePayment(
                    currentUser.getId(),
                    store.getDepositAmount(),
                    paymentRef);

            redirectAttributes.addFlashAttribute("success",
                    "Yêu cầu thanh toán đã được gửi. Vui lòng chờ trong khi chúng tôi xử lý khoản tiền ký quỹ.");
            return "redirect:/seller/register-success?storeId=" + storeId;

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "redirect:/seller/register-success?storeId=" + storeId;
        }
    }

    /**
     * Update pending store information
     */
    @PostMapping("/update-pending-store/{storeId}")
    public String updatePendingStore(
            @PathVariable Long storeId,
            @RequestParam String storeName,
            @RequestParam(required = false) String storeDescription,
            @RequestParam String depositAmount,
            @RequestParam(required = false, defaultValue = "PERCENTAGE") String feeModel,
            RedirectAttributes redirectAttributes) {

        System.out.println("=== UPDATE PENDING STORE ===");
        System.out.println("StoreId: " + storeId);
        System.out.println("StoreName: " + storeName);
        System.out.println("Description: " + storeDescription);
        System.out.println("Deposit: " + depositAmount);
        System.out.println("FeeModel: " + feeModel);

        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            // Get store and verify ownership
            SellerStore store = sellerStoreService.findById(storeId)
                    .orElseThrow(() -> new IllegalStateException("Không tìm thấy cửa hàng"));

            System.out.println("Current store name: " + store.getStoreName());
            System.out.println("Current deposit: " + store.getDepositAmount());

            if (!store.getOwner().getId().equals(currentUser.getId())) {
                redirectAttributes.addFlashAttribute("error", "Bạn không có quyền chỉnh sửa cửa hàng này");
                return "redirect:/seller/register";
            }

            // Verify store is PENDING
            if (store.getStatus() != StoreStatus.PENDING) {
                redirectAttributes.addFlashAttribute("error", "Chỉ có thể chỉnh sửa cửa hàng đang chờ kích hoạt");
                return "redirect:/seller/register";
            }

            // Parse and validate deposit amount
            BigDecimal deposit;
            try {
                String cleanAmount = depositAmount.trim().replace(",", "").replace(".", "");
                deposit = new BigDecimal(cleanAmount);

                if (deposit.compareTo(BigDecimal.ZERO) <= 0) {
                    redirectAttributes.addFlashAttribute("error", "Số tiền ký quỹ phải lớn hơn 0");
                    return "redirect:/seller/register";
                }

                // Validate minimum deposit
                BigDecimal minDeposit = sellerStoreService.getMinDepositAmount();
                if (deposit.compareTo(minDeposit) < 0) {
                    redirectAttributes.addFlashAttribute("error",
                            "Số tiền ký quỹ tối thiểu là " + String.format("%,.0f", minDeposit) + " VNĐ");
                    return "redirect:/seller/register";
                }
            } catch (NumberFormatException e) {
                redirectAttributes.addFlashAttribute("error", "Số tiền ký quỹ không hợp lệ");
                return "redirect:/seller/register";
            }

            // Check if store name changed and if new name exists
            if (!storeName.equals(store.getStoreName()) && sellerStoreService.isStoreNameExists(storeName)) {
                System.out.println("Store name exists: " + storeName);
                redirectAttributes.addFlashAttribute("error", "Tên cửa hàng đã tồn tại. Vui lòng chọn tên khác.");
                return "redirect:/seller/register";
            }

            System.out.println("Updating store...");

            // Update store information
            store.setStoreName(storeName);
            store.setDescription(storeDescription);
            store.setDepositAmount(deposit);

            // Update fee model
            SellerStoresType feeModelEnum;
            try {
                feeModelEnum = SellerStoresType.valueOf(feeModel);
            } catch (IllegalArgumentException e) {
                feeModelEnum = SellerStoresType.PERCENTAGE;
            }
            store.setFeeModel(feeModelEnum);

            // Calculate new max listing price based on new deposit
            Double maxListingPriceRateDouble = sellerStoreService.getMaxListingPriceRate();
            BigDecimal maxListingPriceRate = BigDecimal.valueOf(maxListingPriceRateDouble);
            BigDecimal maxListingPrice = deposit.multiply(maxListingPriceRate);
            store.setMaxListingPrice(maxListingPrice);

            // Save updated store
            sellerStoreRepository.save(store);

            System.out.println("Store updated successfully!");

            redirectAttributes.addFlashAttribute("success", "Cập nhật thông tin cửa hàng thành công!");
            return "redirect:/seller/register";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "redirect:/seller/register";
        }
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

    /**
     * JSON endpoint for polling store status without reloading the page.
     */
    @GetMapping("/status/{storeId}")
    @ResponseBody
    public org.springframework.http.ResponseEntity<java.util.Map<String, Object>> getStoreStatus(
            @PathVariable Long storeId) {
        java.util.Map<String, Object> resp = new java.util.HashMap<>();
        try {
            SellerStore store = sellerStoreService.findById(storeId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));

            resp.put("status", store.getStatus().name());

            return org.springframework.http.ResponseEntity.ok(resp);
        } catch (Exception e) {
            resp.put("error", e.getMessage());
            return org.springframework.http.ResponseEntity
                    .status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }

    /**
     * Display seller profile page
     */
    @GetMapping("/profile")
    public String showSellerProfile(Model model, RedirectAttributes redirectAttributes) {
        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getName())) {
                redirectAttributes.addFlashAttribute("error", "Vui lòng đăng nhập để truy cập trang này");
                return "redirect:/auth/login";
            }

            User currentUser = userService.getFreshUserByUsername(auth.getName());
            if (currentUser == null) {
                redirectAttributes.addFlashAttribute("error", "Không tìm thấy thông tin người dùng");
                return "redirect:/auth/login";
            }

            // Check if user has an active store
            if (!sellerStoreService.hasActiveStore(currentUser)) {
                redirectAttributes.addFlashAttribute("error",
                        "Bạn chưa có cửa hàng hoạt động. Vui lòng đăng ký trước.");
                return "redirect:/seller/register";
            }

            // Get the active store
            SellerStore activeStore = currentUser.getSellerStore();

            // Add data to model
            model.addAttribute("user", currentUser);
            model.addAttribute("store", activeStore);
            model.addAttribute("pageTitle", "Thông tin Seller");

            return "seller/profile";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "redirect:/";
    // ==================== CLOSE STORE ENDPOINTS ====================

    /**
     * GET /seller/store/settings
     * Show store settings page (including close store option)
     */
    @GetMapping("/store/settings")
    public String showStoreSettings(Model model) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            SellerStore store = currentUser.getSellerStore();
            if (store == null) {
                model.addAttribute("error", "You don't have a store yet");
                return "redirect:/seller/register";
            }

            model.addAttribute("store", store);
            model.addAttribute("currentUser", currentUser);

            return "seller/store-settings";
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            e.printStackTrace();
            return "error";
        }
    }

    /**
     * Update seller profile information
     */
    @PostMapping("/profile/update")
    public String updateSellerProfile(
            @RequestParam String fullName,
            @RequestParam(required = false) String phone,
            RedirectAttributes redirectAttributes) {

        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            // Update user information
            currentUser.setFullName(fullName);
            if (phone != null && !phone.trim().isEmpty()) {
                currentUser.setPhone(phone.trim());
            }

            // Save updated user
            userService.updateUser(currentUser);

            redirectAttributes.addFlashAttribute("successMessage", "Cập nhật thông tin thành công!");
            return "redirect:/seller/profile";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật: " + e.getMessage());
            return "redirect:/seller/profile";
        }
    }

    /**
     * GET /seller/store/{storeId}/close/preview
     * Get preview data before closing store
     */
    @GetMapping("/store/{storeId}/close/preview")
    @ResponseBody
    public org.springframework.http.ResponseEntity<?> getClosePreview(@PathVariable Long storeId) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            vn.group3.marketplace.dto.CloseStorePreviewDTO preview = closeStoreService.getClosePreview(storeId,
                    currentUser);

            return org.springframework.http.ResponseEntity.ok(preview);
        } catch (Exception e) {
            java.util.Map<String, String> error = new java.util.HashMap<>();
            error.put("error", e.getMessage());
            return org.springframework.http.ResponseEntity
                    .status(org.springframework.http.HttpStatus.BAD_REQUEST)
                    .body(error);
        }
    }

    /**
     * POST /seller/store/{storeId}/close/validate
     * Validate if store can be closed
     */
    @PostMapping("/store/{storeId}/close/validate")
    @ResponseBody
    public org.springframework.http.ResponseEntity<vn.group3.marketplace.dto.CloseStoreValidationDTO> validateClose(
            @PathVariable Long storeId,
            @RequestBody(required = false) java.util.Map<String, Object> body) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            vn.group3.marketplace.dto.CloseStoreValidationDTO validation = closeStoreService.validateClose(storeId,
                    currentUser);

            if (!validation.isOk()) {
                return org.springframework.http.ResponseEntity
                        .status(org.springframework.http.HttpStatus.BAD_REQUEST)
                        .body(validation);
            }

            return org.springframework.http.ResponseEntity.ok(validation);
        } catch (Exception e) {
            vn.group3.marketplace.dto.CloseStoreValidationDTO errorDto = vn.group3.marketplace.dto.CloseStoreValidationDTO
                    .builder()
                    .ok(false)
                    .errors(java.util.Collections.singletonList(
                            vn.group3.marketplace.dto.CloseStoreValidationDTO.ValidationError.builder()
                                    .code("INTERNAL_ERROR")
                                    .message(e.getMessage())
                                    .link("/seller/dashboard")
                                    .build()))
                    .build();
            return org.springframework.http.ResponseEntity
                    .status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(errorDto);
        }
    }

    /**
     * POST /seller/store/{storeId}/close/confirm
     * Confirm and close the store
     */
    @PostMapping("/store/{storeId}/close/confirm")
    @ResponseBody
    public org.springframework.http.ResponseEntity<vn.group3.marketplace.dto.CloseStoreResultDTO> confirmClose(
            @PathVariable Long storeId,
            @RequestBody vn.group3.marketplace.dto.CloseStoreConfirmRequestDTO request) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            vn.group3.marketplace.dto.CloseStoreResultDTO result = closeStoreService.confirmClose(storeId, currentUser,
                    request);

            return org.springframework.http.ResponseEntity.ok(result);
        } catch (Exception e) {
            vn.group3.marketplace.dto.CloseStoreResultDTO errorDto = vn.group3.marketplace.dto.CloseStoreResultDTO
                    .builder()
                    .ok(false)
                    .status("ERROR")
                    .depositRefund(BigDecimal.ZERO)
                    .walletBalanceAfter(BigDecimal.ZERO)
                    .build();
            return org.springframework.http.ResponseEntity
                    .status(org.springframework.http.HttpStatus.BAD_REQUEST)
                    .body(errorDto);
        }
    }

    /**
     * GET /seller/store/{storeId}/close/result
     * Show close result page
     */
    @GetMapping("/store/{storeId}/close/result")
    public String showCloseResult(@PathVariable Long storeId, Model model) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.getFreshUserByUsername(auth.getName());

            vn.group3.marketplace.dto.CloseStoreResultDTO result = closeStoreService.getCloseResult(storeId,
                    currentUser);

            SellerStore store = sellerStoreService.findById(storeId)
                    .orElseThrow(() -> new RuntimeException("Store not found"));

            // Tính toán thời gian hoạt động
            if (store.getCreatedAt() != null && store.getUpdatedAt() != null) {
                long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(
                        store.getCreatedAt(), store.getUpdatedAt());
                long monthsBetween = java.time.temporal.ChronoUnit.MONTHS.between(
                        store.getCreatedAt(), store.getUpdatedAt());

                model.addAttribute("operatingDays", daysBetween);
                model.addAttribute("operatingMonths", monthsBetween);

                // Format dates cho JSP
                java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter
                        .ofPattern("dd/MM/yyyy HH:mm");
                model.addAttribute("createdAtFormatted", store.getCreatedAt().format(formatter));
                model.addAttribute("updatedAtFormatted", store.getUpdatedAt().format(formatter));
            }

            model.addAttribute("store", store);
            model.addAttribute("result", result);
            model.addAttribute("currentUser", currentUser);

            // Tính toán số tiền hoàn cuối cùng (áp dụng refundPercentageRate nếu có)
            try {
                java.math.BigDecimal finalRefund = null;
                if (store.getRefundPercentageRate() != null
                        && store.getRefundPercentageRate().compareTo(java.math.BigDecimal.ZERO) > 0) {
                    // refundPercentageRate được lưu là phần trăm của tiền cọc (ví dụ 50 = 50%)
                    finalRefund = store.getDepositAmount()
                            .multiply(store.getRefundPercentageRate())
                            .divide(new java.math.BigDecimal("100"));
                } else {
                    finalRefund = result.getDepositRefund();
                }
                model.addAttribute("finalRefund", finalRefund);
            } catch (Exception ex) {
                // Nếu có lỗi tính toán, fallback về giá trị trả về bởi service
                model.addAttribute("finalRefund", result.getDepositRefund());
            }

            return "seller/close-store-result";
        } catch (Exception e) {
            e.printStackTrace(); // Log để debug
            model.addAttribute("error", e.getMessage());
            return "error";
        }
    }
}
