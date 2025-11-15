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

        // ===== VALIDATE PAGINATION PARAMETERS =====
        if (page < 0) {
            page = 0;
        }
        if (size <= 0 || size > 100) {
            size = 10; // Reset to default if invalid
        }

        User user = currentUser.getUser();
        Page<WalletTransaction> transactions;

        // Sanitize inputs
        String sanitizedType = (type != null) ? type.trim() : null;
        String sanitizedStatus = (status != null) ? status.trim() : null;

        // Filter theo type và status với logic ưu tiên
        boolean hasType = sanitizedType != null && !sanitizedType.isEmpty();
        boolean hasStatus = sanitizedStatus != null && !sanitizedStatus.isEmpty();

        // Track parsed enums validity to preserve filters on overflow redirect
        WalletTransactionType parsedType = null;
        WalletTransactionStatus parsedStatus = null;

        if (hasType && hasStatus) {
            // Cả hai filter - ưu tiên cao nhất
            try {
                parsedType = WalletTransactionType.valueOf(sanitizedType.toUpperCase());
                parsedStatus = WalletTransactionStatus.valueOf(sanitizedStatus.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndTypeAndStatus(user, parsedType,
                        parsedStatus, page, size);
                model.addAttribute("selectedType", sanitizedType);
                model.addAttribute("selectedStatus", sanitizedStatus);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
        } else if (hasType) {
            // Chỉ filter theo type
            try {
                parsedType = WalletTransactionType.valueOf(sanitizedType.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndType(user, parsedType, page, size);
                model.addAttribute("selectedType", sanitizedType);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
        } else if (hasStatus) {
            // Chỉ filter theo status
            try {
                parsedStatus = WalletTransactionStatus.valueOf(sanitizedStatus.toUpperCase());
                transactions = walletTransactionService.getTransactionsByUserAndStatus(user, parsedStatus, page,
                        size);
            } catch (IllegalArgumentException e) {
                transactions = walletTransactionService.getTransactionsByUser(user, page, size);
            }
            model.addAttribute("selectedStatus", sanitizedStatus);
        } else {
            // Không có filter - lấy tất cả
            transactions = walletTransactionService.getTransactionsByUser(user, page, size);
        }

        // ===== VALIDATE PAGE NUMBER AGAINST ACTUAL TOTAL PAGES =====
        if (page >= transactions.getTotalPages() && transactions.getTotalPages() > 0) {
            // Redirect to last page if current page is beyond available pages
            int lastPage = transactions.getTotalPages() - 1;
            // Dùng sanitized chuỗi nếu enum parse thành công, ngược lại bỏ filter đó
            String typeForRedirect = (parsedType != null) ? sanitizedType : null;
            String statusForRedirect = (parsedStatus != null) ? sanitizedStatus : null;
            return buildRedirectUrl(lastPage, size, typeForRedirect, statusForRedirect);
        }

        // Thống kê
        long totalTransactions = transactions.getTotalElements();

        // Add to model
        model.addAttribute("transactions", transactions);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", transactions.getTotalPages());
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

    // Helper method to build redirect URL with all filter parameters
    private String buildRedirectUrl(int page, int size, String type, String status) {
        StringBuilder url = new StringBuilder("redirect:/wallet/transactions?page=" + page + "&size=" + size);

        if (type != null && !type.trim().isEmpty()) {
            url.append("&type=").append(java.net.URLEncoder.encode(type, java.nio.charset.StandardCharsets.UTF_8));
        }
        if (status != null && !status.trim().isEmpty()) {
            url.append("&status=").append(java.net.URLEncoder.encode(status, java.nio.charset.StandardCharsets.UTF_8));
        }

        return url.toString();
    }
}