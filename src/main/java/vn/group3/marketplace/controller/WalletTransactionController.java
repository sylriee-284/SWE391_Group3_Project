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

        // Sanitize inputs
        String sanitizedType = (type != null) ? type.trim() : null;
        String sanitizedStatus = (status != null) ? status.trim() : null;

        // Validate pagination params (page >= 0, size in [1, 100])
        if (page < 0) {
            return buildRedirectUrl(0, size, sanitizedType, sanitizedStatus);
        }
        if (size < 1 || size > 100) {
            int normalizedSize = 10; // default fallback
            return buildRedirectUrl(page, normalizedSize, sanitizedType, sanitizedStatus);
        }

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

        // Nếu page vượt quá tổng trang, redirect về trang cuối cùng, giữ lại filter hợp
        // lệ
        int totalPages = transactions.getTotalPages();
        if (totalPages > 0 && page >= totalPages) {
            int lastPage = totalPages - 1;
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

    private String buildRedirectUrl(int page, int size, String type, String status) {
        StringBuilder sb = new StringBuilder("redirect:/wallet/transactions?page=").append(page)
                .append("&size=").append(size);
        if (type != null && !type.isEmpty()) {
            sb.append("&type=").append(type);
        }
        if (status != null && !status.isEmpty()) {
            sb.append("&status=").append(status);
        }
        return sb.toString();
    }
}