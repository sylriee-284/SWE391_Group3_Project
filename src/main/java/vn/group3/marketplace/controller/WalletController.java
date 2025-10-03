package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
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

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/wallet")
public class WalletController {

    private final WalletTransactionRepository walletTransactionRepository;
    private final WalletRepository walletRepository;
    private final WalletService walletService;
    private final VNPayService vnpayService;
    private final UserRepository userRepository;

    public WalletController(WalletService walletService, VNPayService vnpayService,
            WalletTransactionRepository walletTransactionRepository, WalletRepository walletRepository,
            UserRepository userRepository) {
        this.walletService = walletService;
        this.vnpayService = vnpayService;
        this.walletTransactionRepository = walletTransactionRepository;
        this.walletRepository = walletRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/deposit")
    public String showDepositForm(@AuthenticationPrincipal CustomUserDetails currentUser) {
        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }
        return "wallet/deposit";
    }

    @GetMapping
    public String getWallet(@AuthenticationPrincipal CustomUserDetails currentUser, Model model) {
        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }
        User user = currentUser.getUser();
        Wallet wallet = walletService.findByUserId(user.getId()).orElse(null);
        model.addAttribute("wallet", wallet);
        model.addAttribute("user", user);
        return "wallet/detail";
    }

    @GetMapping("/{userId}")
    public String getWalletById(@PathVariable Long userId, Model model) {
        Wallet wallet = walletService.findByUserId(userId).orElse(null);
        model.addAttribute("wallet", wallet);
        return "wallet/detail";
    }

    // User tự nạp tiền cho chính mình
    @PostMapping("/deposit")
    public String deposit(@RequestParam Double amount,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            HttpServletRequest request) {
        System.out.println("=== Wallet Controller Debug ===");
        System.out.println("User: " + (currentUser != null ? currentUser.getUsername() : "NULL"));
        System.out.println("User ID: " + (currentUser != null ? currentUser.getId() : "NULL"));
        System.out.println("User Email: " + (currentUser != null ? currentUser.getEmail() : "NULL"));
        System.out.println("Amount: " + amount);

        // Kiểm tra user có null không
        if (currentUser == null) {
            System.out.println("Current user is null, redirecting to login");
            return "redirect:/login?error=not_authenticated";
        }

        // Lấy User entity từ CustomUserDetails
        User user = currentUser.getUser();
        System.out.println("User from CustomUserDetails: " + (user != null ? user.getUsername() : "NULL"));

        // Validation số tiền
        if (amount == null || amount < 10000) {
            System.out.println("Invalid amount, redirecting with error");
            return "redirect:/wallet/deposit?error=invalid_amount";
        }

        String paymentRef = java.util.UUID.randomUUID().toString();
        String ip = vnpayService.getIpAddress(request);

        System.out.println("Payment Ref: " + paymentRef);
        System.out.println("IP Address: " + ip);

        // Tạo pending transaction cho user hiện tại
        try {
            walletService.createPendingDeposit(user, amount, paymentRef);
            System.out.println("Created pending deposit successfully");
        } catch (Exception e) {
            System.err.println("Error creating pending deposit: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/wallet/deposit?error=database";
        }

        try {
            String paymentUrl = vnpayService.generateVNPayURL(amount, paymentRef, ip);
            System.out.println("Generated VNPay URL: " + paymentUrl);
            System.out.println("Redirecting to VNPay...");
            System.out.println("=== End Wallet Controller Debug ===");
            return "redirect:" + paymentUrl;
        } catch (UnsupportedEncodingException e) {
            System.err.println("Encoding error: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/wallet/deposit?error=encoding";
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/wallet/deposit?error=vnpay";
        }
    }

    @GetMapping("/vnpay-callback")
    public String vnpayCallback(@RequestParam Map<String, String> params) {
        System.out.println("=== VNPay Callback Received ===");
        System.out.println("All params: " + params);

        // Lấy payment reference từ params
        String paymentRef = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String amount = params.get("vnp_Amount");
        String bankCode = params.get("vnp_BankCode");

        System.out.println("Payment Ref: " + paymentRef);
        System.out.println("Response Code: " + responseCode);
        System.out.println("Amount: " + amount);
        System.out.println("Bank Code: " + bankCode);

        // Kiểm tra thanh toán thành công (response code = 00)
        if ("00".equals(responseCode)) {
            System.out.println("Payment successful, processing deposit...");
            try {
                walletService.processSuccessfulDeposit(paymentRef);
                System.out.println("Deposit processed successfully");

                // REFRESH AUTHENTICATION để cập nhật số dư trong session
                refreshAuthenticationContext();

                return "wallet/success";
            } catch (Exception e) {
                System.err.println("Error processing deposit: " + e.getMessage());
                e.printStackTrace();
                return "wallet/failure";
            }
        } else {
            System.out.println("Payment failed with response code: " + responseCode);
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

                System.out.println("Refreshing authentication for user: " + username);

                // Fetch lại user mới từ database (với số dư đã cập nhật)
                User refreshedUser = userRepository.findByUsername(username).orElse(null);
                if (refreshedUser != null) {
                    // Tạo CustomUserDetails mới với thông tin đã cập nhật
                    CustomUserDetails newUserDetails = new CustomUserDetails(refreshedUser);

                    System.out.println(" Old balance in session: " + currentUserDetails.getBalance());
                    System.out.println(" New balance from DB: " + newUserDetails.getBalance());

                    // Tạo authentication object mới
                    UsernamePasswordAuthenticationToken newAuth = new UsernamePasswordAuthenticationToken(
                            newUserDetails,
                            currentAuth.getCredentials(),
                            newUserDetails.getAuthorities());

                    // Cập nhật SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(newAuth);
                    System.out.println(" Authentication context refreshed successfully!");
                }
            }
        } catch (Exception e) {
            System.err.println(" Error refreshing authentication context: " + e.getMessage());
            e.printStackTrace();
        }
    }

}
