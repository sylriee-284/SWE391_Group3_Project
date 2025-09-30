package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
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

    public WalletController(WalletService walletService, VNPayService vnpayService,
            WalletTransactionRepository walletTransactionRepository, WalletRepository walletRepository) {
        this.walletService = walletService;
        this.vnpayService = vnpayService;
        this.walletTransactionRepository = walletTransactionRepository;
        this.walletRepository = walletRepository;
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
    public String deposit(@RequestParam Double amount, @AuthenticationPrincipal User user, HttpServletRequest request) {
        String paymentRef = UUID.randomUUID().toString();
        String ip = vnpayService.getIpAddress(request);

        // Tạo giao dịch tạm thời
        WalletTransaction tx = new WalletTransaction();
        tx.setUser(user);
        tx.setPaymentRef(paymentRef);
        tx.setAmount(amount);
        tx.setType(WalletTransactionType.DEPOSIT); // hoặc "DEPOSIT"
        tx.setPaymentStatus("pending");
        tx.setPaymentMethod("VNPAY");
        walletTransactionRepository.save(tx);

        try {
            String paymentUrl = vnpayService.generateVNPayURL(amount, paymentRef, ip);
            return "redirect:" + paymentUrl;
        } catch (UnsupportedEncodingException e) {
            // Xử lý lỗi encoding
            e.printStackTrace();
            return "redirect:/wallet/" + user.getId() + "?error=encoding";
        }
    }

    @GetMapping("/wallet/vnpay-callback")
    public String vnpayCallback(@RequestParam Map<String, String> params) {
        String paymentRef = params.get("vnp_TxnRef");
        WalletTransaction tx = walletTransactionRepository.findByPaymentRef(paymentRef).orElse(null);

        // TODO: Implement verifyCallback method in VNPayService
        boolean ok = true; // Tạm thời set true, cần implement verification logic
        // boolean ok = vnpayService.verifyCallback(params);

        if (tx != null && ok && "pending".equals(tx.getPaymentStatus())) {
            tx.setPaymentStatus("success");
            walletTransactionRepository.save(tx);

            // Tìm và cập nhật wallet
            Optional<Wallet> walletOpt = walletRepository.findByUserId(tx.getUser().getId());
            if (walletOpt.isPresent()) {
                Wallet wallet = walletOpt.get();
                wallet.setBalance(wallet.getBalance() + tx.getAmount());
                walletRepository.save(wallet);
            }

            return "wallet/success";
        }
        return "wallet/failure";
    }

}
