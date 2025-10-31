package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.WalletTransactionService;

@Controller
@RequestMapping("/wallet/transactions")
public class WalletTransactionController {

    private final WalletTransactionService walletTransactionService;

    public WalletTransactionController(WalletTransactionService walletTransactionService) {
        this.walletTransactionService = walletTransactionService;
    }

    /**
     * Hiển thị danh sách lịch sử giao dịch của user
     */
    @GetMapping
    public String listTransactions(@AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String status,
            Model model) {

        // Kiểm tra authentication
        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }

        User user = currentUser.getUser();
        Page<WalletTransaction> transactions;

        // Filter theo type và status với logic ưu tiên
        boolean hasType = type != null && !type.isEmpty();
        boolean hasStatus = status != null && !status.isEmpty();

        if (hasType && hasStatus) {
            // Cả hai filter - ưu tiên cao nhất
            try {
                WalletTransactionType transactionType = WalletTransactionType.valueOf(type.toUpperCase());
                WalletTransactionStatus transactionStatus = WalletTransactionStatus.valueOf(status.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndTypeAndStatus(user, transactionType,
                        transactionStatus, page, size);
                model.addAttribute("selectedType", type);
                model.addAttribute("selectedStatus", status);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
        } else if (hasType) {
            // Chỉ filter theo type
            try {
                WalletTransactionType transactionType = WalletTransactionType.valueOf(type.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndType(user, transactionType, page, size);
                model.addAttribute("selectedType", type);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
        } else if (hasStatus) {
            // Chỉ filter theo status
            try {
                WalletTransactionStatus transactionStatus = WalletTransactionStatus.valueOf(status.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndStatus(user, transactionStatus, page,
                        size);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
            model.addAttribute("selectedStatus", status);
        } else {
            // Không có filter - lấy tất cả
            transactions = walletTransactionService.getTransactionsByUser(user, page, size);
        }

        // Thống kê
        long totalTransactions = transactions.getTotalElements();
        int totalPages = transactions.getTotalPages();

        // Add to model
        model.addAttribute("transactions", transactions);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalTransactions", totalTransactions);
        model.addAttribute("user", user);

        // 📝 Dropdown options
        model.addAttribute("transactionTypes", WalletTransactionType.values());
        model.addAttribute("paymentStatuses", WalletTransactionStatus.values());

        return "wallet/transactions";

    }

    /**
     * Xem chi tiết 1 giao dịch
     */
    @GetMapping("/{id}")
    public String transactionDetail(@AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            Model model) {

        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }

        User user = currentUser.getUser();

        // Tìm transaction và kiểm tra quyền sở hữu
        WalletTransaction transaction = walletTransactionService.findById(id)
                .filter(t -> walletTransactionService.canUserAccessTransaction(t, user)) // Chỉ user owner mới xem được
                .orElse(null);

        if (transaction == null) {
            return "redirect:/wallet/transactions?error=transaction_not_found";
        }

        model.addAttribute("transaction", transaction);
        model.addAttribute("user", user);
        model.addAttribute("transactionTypes", WalletTransactionType.values());

        return "wallet/transaction-detail";
    }

}