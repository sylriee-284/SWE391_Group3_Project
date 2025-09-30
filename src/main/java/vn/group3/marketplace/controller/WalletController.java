package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.service.VNPayService;
import vn.group3.marketplace.service.WalletService;

import java.io.UnsupportedEncodingException;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import vn.group3.marketplace.domain.entity.User;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
    public String showDepositForm() {
        return "wallet/deposit"; // hoặc "deposit" nếu đặt ở gốc view
    }

    @GetMapping("/{userId}")
    public String getWallet(@PathVariable Long userId, Model model) {
        // model.addAttribute("wallet", walletService.findByUser(userId).orElseThrow());
        return "wallet/detail";
    }

    @PostMapping("/deposit")
    public String deposit(@RequestParam Double amount, HttpServletRequest request) {
        String paymentRef = java.util.UUID.randomUUID().toString();
        String ip = vnpayService.getIpAddress(request);

        // ĐỪNG tạo/safe WalletTransaction ở đây khi test
        try {
            String paymentUrl = vnpayService.generateVNPayURL(amount, paymentRef, ip);
            return "redirect:" + paymentUrl;
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return "redirect:/wallet?error=encoding";
        }
    }

    @GetMapping("/vnpay-callback") // KHÔNG phải "/wallet/vnpay-callback"
    public String vnpayCallback(@RequestParam Map<String, String> params) {
        // Khi test: chỉ cần validate chữ ký (nếu bạn đã viết) rồi trả view
        // TODO: boolean ok = vnpayService.verifyCallback(params);
        boolean ok = true; // tạm thời
        return ok ? "wallet/success" : "wallet/failure";
    }

}
