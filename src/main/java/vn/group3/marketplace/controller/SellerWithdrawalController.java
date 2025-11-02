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
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.WithdrawalRequestService;

import java.math.BigDecimal;

@Controller
@RequestMapping("/seller/withdrawals")
public class SellerWithdrawalController {

    private final WithdrawalRequestService withdrawalRequestService;

    public SellerWithdrawalController(WithdrawalRequestService withdrawalRequestService) {
        this.withdrawalRequestService = withdrawalRequestService;
    }

    /**
     * Hiển thị danh sách yêu cầu rút tiền của seller
     */
    @GetMapping
    public String listWithdrawals(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        User user = currentUser.getUser();
        Page<WalletTransaction> withdrawals = withdrawalRequestService.getWithdrawalRequestsByUser(user, page, size);

        model.addAttribute("withdrawals", withdrawals);
        model.addAttribute("currentUser", user);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", withdrawals.getTotalPages());
        model.addAttribute("hasPendingWithdrawal", withdrawalRequestService.hasPendingWithdrawal(user));

        return "seller/withdrawals/list";
    }

    /**
     * Hiển thị form tạo yêu cầu rút tiền
     */
    @GetMapping("/create")
    public String showCreateForm(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            Model model,
            RedirectAttributes redirectAttributes) {

        User user = currentUser.getUser();
        
        // Kiểm tra xem đã có yêu cầu PENDING chưa
        if (withdrawalRequestService.hasPendingWithdrawal(user)) {
            redirectAttributes.addFlashAttribute("error", 
                    "Bạn đã có yêu cầu rút tiền đang chờ duyệt. Vui lòng chờ admin xử lý trước khi tạo yêu cầu mới.");
            return "redirect:/seller/withdrawals";
        }
        
        model.addAttribute("currentUser", user);

        return "seller/withdrawals/create";
    }

    /**
     * Xử lý tạo yêu cầu rút tiền
     */
    @PostMapping("/create")
    public String createWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam BigDecimal amount,
            @RequestParam String bankName,
            @RequestParam String bankAccountNumber,
            @RequestParam String bankAccountName,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            
            // Kiểm tra lại trước khi tạo
            if (withdrawalRequestService.hasPendingWithdrawal(user)) {
                redirectAttributes.addFlashAttribute("error", 
                        "Bạn đã có yêu cầu rút tiền đang chờ duyệt. Vui lòng chờ admin xử lý trước khi tạo yêu cầu mới.");
                return "redirect:/seller/withdrawals";
            }
            
            WalletTransaction withdrawal = withdrawalRequestService.createWithdrawalRequest(
                    user, amount, bankName, bankAccountNumber, bankAccountName);

            redirectAttributes.addFlashAttribute("success", 
                    "Tạo yêu cầu rút tiền thành công! Mã yêu cầu: #" + withdrawal.getId());
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException | IllegalStateException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/seller/withdrawals/create";
        }
    }

    /**
     * Hiển thị form sửa yêu cầu rút tiền
     */
    @GetMapping("/{id}/edit")
    public String showEditForm(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            Model model,
            RedirectAttributes redirectAttributes) {

        User user = currentUser.getUser();
        WalletTransaction withdrawal = withdrawalRequestService.getWithdrawalById(id)
                .orElse(null);

        if (withdrawal == null) {
            redirectAttributes.addFlashAttribute("error", "Không tìm thấy yêu cầu rút tiền");
            return "redirect:/seller/withdrawals";
        }

        if (!withdrawalRequestService.canUserAccessWithdrawal(withdrawal, user)) {
            redirectAttributes.addFlashAttribute("error", "Bạn không có quyền truy cập");
            return "redirect:/seller/withdrawals";
        }

        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            redirectAttributes.addFlashAttribute("error", 
                    "Chỉ có thể sửa yêu cầu đang chờ duyệt");
            return "redirect:/seller/withdrawals";
        }

        model.addAttribute("withdrawal", withdrawal);
        model.addAttribute("currentUser", user);

        return "seller/withdrawals/edit";
    }

    /**
     * Xử lý cập nhật yêu cầu rút tiền
     */
    @PostMapping("/{id}/update")
    public String updateWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @RequestParam BigDecimal amount,
            @RequestParam String bankName,
            @RequestParam String bankAccountNumber,
            @RequestParam String bankAccountName,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            withdrawalRequestService.updateWithdrawalRequest(
                    id, amount, bankName, bankAccountNumber, bankAccountName, user);

            redirectAttributes.addFlashAttribute("success", "Cập nhật yêu cầu rút tiền thành công!");
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException | IllegalStateException | SecurityException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/seller/withdrawals/" + id + "/edit";
        }
    }

    /**
     * Hủy yêu cầu rút tiền
     */
    @PostMapping("/{id}/cancel")
    public String cancelWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            withdrawalRequestService.cancelWithdrawalRequest(id, user);

            redirectAttributes.addFlashAttribute("success", "Đã hủy yêu cầu rút tiền");
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException | IllegalStateException | SecurityException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/seller/withdrawals";
        }
    }

    /**
     * Xem chi tiết yêu cầu rút tiền
     */
    @GetMapping("/{id}")
    public String viewWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            Model model,
            RedirectAttributes redirectAttributes) {

        User user = currentUser.getUser();
        WalletTransaction withdrawal = withdrawalRequestService.getWithdrawalById(id)
                .orElse(null);

        if (withdrawal == null) {
            redirectAttributes.addFlashAttribute("error", "Không tìm thấy yêu cầu rút tiền");
            return "redirect:/seller/withdrawals";
        }

        if (!withdrawalRequestService.canUserAccessWithdrawal(withdrawal, user)) {
            redirectAttributes.addFlashAttribute("error", "Bạn không có quyền truy cập");
            return "redirect:/seller/withdrawals";
        }

        model.addAttribute("withdrawal", withdrawal);
        model.addAttribute("currentUser", user);

        return "seller/withdrawals/detail";
    }
}
