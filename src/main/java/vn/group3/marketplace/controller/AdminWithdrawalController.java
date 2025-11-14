package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.WithdrawalRequestService;
import vn.group3.marketplace.service.AuthenticationRefreshService;

import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

@Controller
@RequestMapping("/admin/withdrawals")
public class AdminWithdrawalController {

    private final WithdrawalRequestService withdrawalRequestService;
    private final AuthenticationRefreshService authenticationRefreshService;

    public AdminWithdrawalController(
            WithdrawalRequestService withdrawalRequestService,
            AuthenticationRefreshService authenticationRefreshService) {
        this.withdrawalRequestService = withdrawalRequestService;
        this.authenticationRefreshService = authenticationRefreshService;
    }

    @GetMapping
    public String listWithdrawals(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(required = false) String keyword,
            Model model) {

        // Validate pagination parameters
        if (page < 0) {
            page = 0; // Default to first page if negative
        }

        if (size <= 0 || size > 100) {
            size = 10; // Default to 10 if invalid (too small or too large)
        }

        Page<WalletTransaction> withdrawals;
        String selectedStatus = "";

        // Process status parameter
        WalletTransactionStatus statusEnum = null;
        if (status != null && !status.trim().isEmpty()) {
            try {
                statusEnum = WalletTransactionStatus.valueOf(status.toUpperCase());
                selectedStatus = status.toUpperCase();
            } catch (IllegalArgumentException e) {
                // Invalid status, ignore
            }
        }

        // Process date and keyword parameters
        String processedFromDate = (fromDate != null && !fromDate.trim().isEmpty()) ? fromDate : null;
        String processedToDate = (toDate != null && !toDate.trim().isEmpty()) ? toDate : null;
        String processedKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;

        // Check if any filters are applied
        boolean hasFilters = statusEnum != null || processedFromDate != null ||
                processedToDate != null || processedKeyword != null;

        // Get withdrawals with combined filters or all withdrawals
        if (hasFilters) {
            withdrawals = withdrawalRequestService.getWithdrawalRequestsWithFilters(
                    statusEnum, processedFromDate, processedToDate, processedKeyword, page, size);
        } else {
            withdrawals = withdrawalRequestService.getAllWithdrawalRequests(page, size);
        }

        // Validate page number against actual total pages
        if (page >= withdrawals.getTotalPages() && withdrawals.getTotalPages() > 0) {
            // Redirect to last page if current page is beyond available pages
            int lastPage = withdrawals.getTotalPages() - 1;
            String redirectUrl = buildRedirectUrl(lastPage, size, status, processedFromDate, processedToDate,
                    processedKeyword);
            return "redirect:/admin/withdrawals" + redirectUrl;
        }

        model.addAttribute("withdrawals", withdrawals);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", withdrawals.getTotalPages());
        model.addAttribute("selectedStatus", selectedStatus);
        model.addAttribute("totalElements", withdrawals.getTotalElements());

        return "admin/withdrawals/list";
    }

    /**
     * Helper method to build redirect URL with current filters
     */
    private String buildRedirectUrl(int page, int size, String status, String fromDate, String toDate, String keyword) {
        StringBuilder url = new StringBuilder("?page=" + page);

        if (size != 10) { // Only add size if different from default
            url.append("&size=").append(size);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            url.append("&keyword=")
                    .append(java.net.URLEncoder.encode(keyword, java.nio.charset.StandardCharsets.UTF_8));
        }

        if (status != null && !status.trim().isEmpty()) {
            url.append("&status=").append(status);
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            url.append("&fromDate=").append(fromDate);
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            url.append("&toDate=").append(toDate);
        }

        return url.toString();
    }

    @GetMapping("/{id}")
    public String viewWithdrawal(
            @PathVariable Long id,
            Model model,
            RedirectAttributes redirectAttributes) {

        WalletTransaction withdrawal = withdrawalRequestService.getWithdrawalById(id)
                .orElse(null);

        if (withdrawal == null || withdrawal.getType() != WalletTransactionType.WITHDRAWAL) {
            redirectAttributes.addFlashAttribute("error", "Không tìm thấy yêu cầu rút tiền");
            return "redirect:/admin/withdrawals";
        }

        model.addAttribute("withdrawal", withdrawal);
        return "admin/withdrawals/detail";
    }

    @PostMapping("/{id}/approve")
    public String approveWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            RedirectAttributes redirectAttributes) {

        try {
            User admin = currentUser.getUser();
            Future<WalletTransaction> future = withdrawalRequestService.approveWithdrawalAsync(id, admin);
            WalletTransaction withdrawal = future.get(10, TimeUnit.SECONDS);

            redirectAttributes.addFlashAttribute("success",
                    String.format("Đã duyệt yêu cầu rút tiền #%d thành công!", withdrawal.getId()));
            return "redirect:/admin/withdrawals";

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/withdrawals";

        } catch (IllegalStateException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/withdrawals/" + id;

        } catch (java.util.concurrent.TimeoutException e) {
            redirectAttributes.addFlashAttribute("warning",
                    "Yêu cầu duyệt đang được xử lý, vui lòng kiểm tra lại sau");
            return "redirect:/admin/withdrawals";

        } catch (java.util.concurrent.RejectedExecutionException e) {
            redirectAttributes.addFlashAttribute("error",
                    "Hệ thống đang bận, vui lòng thử lại sau");
            return "redirect:/admin/withdrawals/" + id;

        } catch (java.util.concurrent.ExecutionException e) {
            Throwable cause = e.getCause();
            String message = (cause instanceof IllegalArgumentException || cause instanceof IllegalStateException)
                    ? cause.getMessage()
                    : "Có lỗi xảy ra khi duyệt yêu cầu";
            redirectAttributes.addFlashAttribute("error", message);
            return "redirect:/admin/withdrawals/" + id;

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Có lỗi không mong muốn: " + e.getMessage());
            return "redirect:/admin/withdrawals/" + id;
        }
    }

    @PostMapping("/{id}/reject")
    public String rejectWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @RequestParam String reason,
            RedirectAttributes redirectAttributes) {

        try {
            if (reason == null || reason.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "Vui lòng nhập lý do từ chối");
                return "redirect:/admin/withdrawals/" + id;
            }

            User admin = currentUser.getUser();
            Future<WalletTransaction> future = withdrawalRequestService.rejectWithdrawalAsync(id, reason.trim(), admin);
            WalletTransaction withdrawal = future.get(10, TimeUnit.SECONDS);

            authenticationRefreshService.refreshAuthenticationContextForUser(withdrawal.getUser().getId());

            redirectAttributes.addFlashAttribute("success",
                    String.format("Đã từ chối yêu cầu rút tiền #%d và hoàn tiền thành công!", withdrawal.getId()));
            return "redirect:/admin/withdrawals";

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/withdrawals";

        } catch (IllegalStateException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/withdrawals/" + id;

        } catch (java.util.concurrent.TimeoutException e) {
            redirectAttributes.addFlashAttribute("warning",
                    "Yêu cầu từ chối đang được xử lý, vui lòng kiểm tra lại sau");
            return "redirect:/admin/withdrawals";

        } catch (java.util.concurrent.RejectedExecutionException e) {
            redirectAttributes.addFlashAttribute("error",
                    "Hệ thống đang bận, vui lòng thử lại sau");
            return "redirect:/admin/withdrawals/" + id;

        } catch (java.util.concurrent.ExecutionException e) {
            Throwable cause = e.getCause();
            String message = (cause instanceof IllegalArgumentException || cause instanceof IllegalStateException)
                    ? cause.getMessage()
                    : "Có lỗi xảy ra khi từ chối yêu cầu";
            redirectAttributes.addFlashAttribute("error", message);
            return "redirect:/admin/withdrawals/" + id;

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Có lỗi không mong muốn: " + e.getMessage());
            return "redirect:/admin/withdrawals/" + id;
        }
    }
}
