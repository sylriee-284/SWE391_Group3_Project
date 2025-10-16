package vn.group3.marketplace.controller;

import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.VNPayService;
import vn.group3.marketplace.service.WalletService;

import java.io.UnsupportedEncodingException;
import java.util.Map;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.security.CustomUserDetails;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/wallet")
public class WalletController {

    private static final Logger logger = LoggerFactory.getLogger(WalletController.class);
    private static final String REDIRECT_NOT_AUTHENTICATED = "redirect:/login?error=not_authenticated";

    private final WalletService walletService;
    private final VNPayService vnpayService;
    private final UserRepository userRepository;
    private final vn.group3.marketplace.service.UserSerialTaskService depositQueueService;

    public WalletController(WalletService walletService, VNPayService vnpayService,
            UserRepository userRepository,
            vn.group3.marketplace.service.UserSerialTaskService depositQueueService) {
        this.walletService = walletService;
        this.vnpayService = vnpayService;
        this.userRepository = userRepository;
        this.depositQueueService = depositQueueService;
    }

    @GetMapping
    public String getWallet(@AuthenticationPrincipal CustomUserDetails currentUser, Model model) {
        if (currentUser == null) {
            return REDIRECT_NOT_AUTHENTICATED;
        }
        User user = currentUser.getUser();
        java.math.BigDecimal balance = walletService.findBalanceByUserId(user.getId())
                .orElse(java.math.BigDecimal.ZERO);
        model.addAttribute("wallet", java.util.Map.of("balance", balance));
        model.addAttribute("user", user);
        return "wallet/detail";
    }

    @GetMapping("/deposit")
    public String showDepositForm(@AuthenticationPrincipal CustomUserDetails currentUser) {
        if (currentUser == null) {
            return REDIRECT_NOT_AUTHENTICATED;
        }
        return "wallet/deposit";
    }

    // User tự nạp tiền cho chính mình
    @PostMapping("/deposit")
    public String deposit(@RequestParam java.math.BigDecimal amount,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            HttpServletRequest request) {
        logger.debug("=== Wallet Controller Debug ===");
        logger.debug("User: {}", (currentUser != null ? currentUser.getUsername() : "NULL"));
        logger.debug("User ID: {}", (currentUser != null ? currentUser.getId() : "NULL"));
        logger.debug("User Email: {}", (currentUser != null ? currentUser.getEmail() : "NULL"));
        logger.debug("Amount: {}", amount);

        // Kiểm tra user có null không
        if (currentUser == null) {
            logger.warn("Current user is null, redirecting to login");
            return REDIRECT_NOT_AUTHENTICATED;
        }

        // Lấy User entity từ CustomUserDetails
        User user = currentUser.getUser();
        logger.debug("User from CustomUserDetails: {}", (user != null ? user.getUsername() : "NULL"));

        // Validation số tiền
        if (amount == null || amount.compareTo(new java.math.BigDecimal(10000)) < 0) {
            logger.warn("Invalid amount: {}", amount);
            return "redirect:/wallet/deposit?error=invalid_amount";
        }

        String paymentRef = java.util.UUID.randomUUID().toString();
        String ip = vnpayService.getIpAddress(request);

        logger.debug("Payment Ref: {}", paymentRef);
        logger.debug("IP Address: {}", ip);

        // Tạo pending transaction cho user hiện tại
        try {
            walletService.createPendingDeposit(user, amount, paymentRef);
            if (user != null) {
                logger.info("Created pending deposit for userId={} amount={} ref={}", user.getId(), amount, paymentRef);
            } else {
                logger.info("Created pending deposit for unknown user amount={} ref={}", amount, paymentRef);
            }
        } catch (Exception e) {
            logger.error("Error creating pending deposit: {}", e.getMessage(), e);
            return "redirect:/wallet/deposit?error=database";
        }

        try {
            String paymentUrl = vnpayService.generateVNPayURL(amount.doubleValue(), paymentRef, ip);
            logger.debug("Generated VNPay URL: {}", paymentUrl);
            logger.debug("Redirecting to VNPay...");
            logger.debug("=== End Wallet Controller Debug ===");
            return "redirect:" + paymentUrl;
        } catch (UnsupportedEncodingException e) {
            logger.error("Encoding error: {}", e.getMessage(), e);
            return "redirect:/wallet/deposit?error=encoding";
        } catch (Exception e) {
            logger.error("Unexpected error while generating VNPay URL: {}", e.getMessage(), e);
            return "redirect:/wallet/deposit?error=vnpay";
        }
    }

    @GetMapping("/vnpay-callback")
    public String vnpayCallback(@RequestParam Map<String, String> params) {
        logger.debug("=== VNPay Callback Received ===");
        logger.debug("All params: {}", params);

        // Lấy payment reference từ params
        String paymentRef = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String amount = params.get("vnp_Amount");
        String bankCode = params.get("vnp_BankCode");

        logger.debug("Payment Ref: {}", paymentRef);
        logger.debug("Response Code: {}", responseCode);
        logger.debug("Amount: {}", amount);
        logger.debug("Bank Code: {}", bankCode);

        // Kiểm tra thanh toán thành công (response code = 00)
        if ("00".equals(responseCode)) {
            logger.info("Payment successful (ref={}), enqueueing deposit processing...", paymentRef);

            try {
                // Tìm userId từ paymentRef bằng API rõ ràng trên WalletService
                Long partitionUserId = walletService.findUserIdByPaymentRef(paymentRef).orElse(0L);

                var future = depositQueueService.enqueueDeposit(partitionUserId, paymentRef);

                // Chờ tối đa 10 giây để hoàn tất xử lý (để có thể refresh session ngay lập tức)
                try {
                    future.get(10, java.util.concurrent.TimeUnit.SECONDS);
                    logger.info("Deposit processed (via queue) for ref={}", paymentRef);
                } catch (java.util.concurrent.TimeoutException te) {
                    logger.warn(
                            "Deposit processing not finished within timeout for ref={}; returning success page and letting background worker finish",
                            paymentRef);
                }

                // REFRESH AUTHENTICATION để cập nhật số dư trong session
                refreshAuthenticationContext();

                return "wallet/success";
            } catch (Exception e) {
                logger.error("Error queueing/processing deposit: {}", e.getMessage(), e);
                return "wallet/failure";
            }
        } else {
            logger.warn("Payment failed with response code: {}", responseCode);
            return "wallet/failure";
        }
    }

    /**
     * Refresh authentication context để cập nhật thông tin user trong session
     * 
     * VẤN ĐỀ: Sau khi nạp tiền thành công, database đã cập nhật số dư mới,
     * nhưng CustomUserDetails trong session vẫn chứa số dư cũ.
     * 
     * GIẢI PHÁP: Fetch lại user từ database và cập nhật SecurityContext
     */
    private void refreshAuthenticationContext() {
        try {
            Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();
            if (currentAuth != null && currentAuth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails currentUserDetails = (CustomUserDetails) currentAuth.getPrincipal();
                String username = currentUserDetails.getUsername();

                logger.debug("Refreshing authentication for user: {}", username);

                // Fetch lại user mới từ database (với số dư đã cập nhật)
                User refreshedUser = userRepository.findByUsername(username).orElse(null);
                if (refreshedUser != null) {
                    // Tạo CustomUserDetails mới với thông tin đã cập nhật
                    CustomUserDetails newUserDetails = new CustomUserDetails(refreshedUser);

                    logger.debug(" Old balance in session: {}", currentUserDetails.getBalance());
                    logger.debug(" New balance from DB: {}", newUserDetails.getBalance());

                    // Tạo authentication object mới
                    UsernamePasswordAuthenticationToken newAuth = new UsernamePasswordAuthenticationToken(
                            newUserDetails,
                            currentAuth.getCredentials(),
                            newUserDetails.getAuthorities());

                    // Cập nhật SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(newAuth);
                    logger.info("Authentication context refreshed successfully for user={}", username);
                }
            }
        } catch (Exception e) {
            logger.error("Error refreshing authentication context: {}", e.getMessage(), e);
        }
    }

}
