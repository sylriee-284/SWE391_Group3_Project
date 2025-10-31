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

    /**
     * Display seller registration form
     */
    @GetMapping("/register")
    public String showSellerRegistration(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // If user has an active store, redirect to dashboard
        if (sellerStoreService.hasActiveStore(currentUser)) {
            return "redirect:/seller/dashboard";
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

    // Add fee settings from SystemSetting (percentage fee and fixed fee for small orders)
    Double percentageFee = systemSettingService.getDoubleValue("fee.percentage_fee", 3.0);
    Integer fixedFee = systemSettingService.getIntValue("fee.fixed_fee", 5000);
    model.addAttribute("percentageFee", percentageFee);
    model.addAttribute("fixedFee", fixedFee);

    // Add refund rate settings from SystemSetting
    Integer maxRefundRateMinDuration = systemSettingService.getIntValue("store.max_refund_rate_min_duration_months", 12);
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
            Integer maxRefundRateMinDuration = systemSettingService.getIntValue("store.max_refund_rate_min_duration_months", 12);
            Double percentageMaxRefundRate = systemSettingService.getDoubleValue("store.percentage_max_refund_rate", 100.0);
            Double percentageMinRefundRate = systemSettingService.getDoubleValue("store.percentage_min_refund_rate", 70.0);
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
    public String showRegistrationSuccess(@RequestParam Long storeId, Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.getFreshUserByUsername(auth.getName());

        // Get store details
        SellerStore store = sellerStoreService.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));
        
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
    Integer maxRefundRateMinDuration = systemSettingService.getIntValue("store.max_refund_rate_min_duration_months", 12);
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
                paymentRef
            );

            redirectAttributes.addFlashAttribute("success", 
                "Yêu cầu thanh toán đã được gửi. Vui lòng chờ trong khi chúng tôi xử lý khoản tiền ký quỹ.");
            return "redirect:/seller/register-success?storeId=" + storeId;

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "redirect:/seller/register-success?storeId=" + storeId;
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
    public org.springframework.http.ResponseEntity<java.util.Map<String, Object>> getStoreStatus(@PathVariable Long storeId) {
        java.util.Map<String, Object> resp = new java.util.HashMap<>();
        try {
            SellerStore store = sellerStoreService.findById(storeId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng"));

            resp.put("status", store.getStatus().name());

            return org.springframework.http.ResponseEntity.ok(resp);
        } catch (Exception e) {
            resp.put("error", e.getMessage());
            return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body(resp);
        }
    }
}
