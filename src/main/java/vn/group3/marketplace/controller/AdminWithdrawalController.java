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
            Model model) {

        Page<WalletTransaction> withdrawals;
        String selectedStatus = "";

        // Get withdrawals with filters
        if ((status != null && !status.trim().isEmpty()) ||
                (fromDate != null && !fromDate.trim().isEmpty()) ||
                (toDate != null && !toDate.trim().isEmpty())) {

            WalletTransactionStatus statusEnum = null;
            if (status != null && !status.trim().isEmpty()) {
                try {
                    statusEnum = WalletTransactionStatus.valueOf(status.toUpperCase());
                    selectedStatus = status.toUpperCase();
                } catch (IllegalArgumentException e) {
                    // Invalid status, ignore
                }
            }

            withdrawals = withdrawalRequestService.getWithdrawalRequestsWithFilters(
                    statusEnum, fromDate, toDate, page, size);
        } else {
            withdrawals = withdrawalRequestService.getAllWithdrawalRequests(page, size);
        }

        model.addAttribute("withdrawals", withdrawals);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", withdrawals.getTotalPages());
        model.addAttribute("selectedStatus", selectedStatus);
        model.addAttribute("totalElements", withdrawals.getTotalElements());

        return "admin/withdrawals/list";
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
