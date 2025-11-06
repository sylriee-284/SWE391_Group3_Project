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
import vn.group3.marketplace.service.AuthenticationRefreshService;

import java.math.BigDecimal;
import java.util.concurrent.Future;

@Controller
@RequestMapping("/seller/withdrawals")
public class SellerWithdrawalController {

    private final WithdrawalRequestService withdrawalRequestService;
    private final AuthenticationRefreshService authenticationRefreshService;

    public SellerWithdrawalController(
            WithdrawalRequestService withdrawalRequestService,
            AuthenticationRefreshService authenticationRefreshService) {
        this.withdrawalRequestService = withdrawalRequestService;
        this.authenticationRefreshService = authenticationRefreshService;
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

        // Validate pagination parameters
        if (page < 0) {
            page = 0; // Default page
        }
        if (size <= 0) {
            size = 10; // Default size
        }

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
     * Xử lý tạo yêu cầu rút tiền - Sử dụng PerUserSerialExecutor queue
     * 
     * Flow:
     * 1. Submit task vào queue của seller
     * 2. Queue sẽ check pending withdrawal trước khi xử lý
     * 3. Nếu pass validation -> trừ tiền và tạo giao dịch PENDING
     * 4. Return kết quả hoặc error message
     */
    @PostMapping("/create")
    public String createWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String amount,
            @RequestParam String bankName,
            @RequestParam String bankAccountNumber,
            @RequestParam String bankAccountName,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            
            // Validate và convert amount từ String sang BigDecimal
            BigDecimal amountValue;
            try {
                amountValue = new BigDecimal(amount);
            } catch (NumberFormatException e) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Số tiền không hợp lệ. Vui lòng nhập số.");
                return "redirect:/seller/withdrawals/create";
            }
            
            // Validate số tài khoản ngân hàng (chỉ chứa số và chữ cái, không có ký tự đặc biệt)
            if (bankAccountNumber == null || bankAccountNumber.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Số tài khoản ngân hàng không được để trống.");
                return "redirect:/seller/withdrawals/create";
            }
            if (!bankAccountNumber.matches("^[a-zA-Z0-9]+$")) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Số tài khoản ngân hàng chỉ được chứa chữ cái và số, không có ký tự đặc biệt.");
                return "redirect:/seller/withdrawals/create";
            }
            
            // Validate tên tài khoản ngân hàng (chỉ chứa chữ cái không dấu và số, không có ký tự đặc biệt)
            if (bankAccountName == null || bankAccountName.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Tên tài khoản ngân hàng không được để trống.");
                return "redirect:/seller/withdrawals/create";
            }
            // Chỉ cho phép chữ cái A-Z (không phân biệt hoa thường), số 0-9, và khoảng trắng
            if (!bankAccountName.matches("^[a-zA-Z0-9\\s]+$")) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Tên tài khoản ngân hàng chỉ được chứa chữ cái không dấu, số và khoảng trắng.");
                return "redirect:/seller/withdrawals/create";
            }
            
            // Validate tên ngân hàng
            if (bankName == null || bankName.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", 
                    "❌ Tên ngân hàng không được để trống.");
                return "redirect:/seller/withdrawals/create";
            }
            
            // Gửi vào queue để xử lý async - đảm bảo xử lý tuần tự cho mỗi seller
            Future<WalletTransaction> future = withdrawalRequestService.createWithdrawalRequestAsync(
                    user, amountValue, bankName, bankAccountNumber, bankAccountName);
            
            // Đợi kết quả từ queue (với timeout 10s)
            WalletTransaction withdrawal = future.get(10, java.util.concurrent.TimeUnit.SECONDS);

            // Refresh authentication context để cập nhật số dư trong session
            authenticationRefreshService.refreshAuthenticationContext();

            redirectAttributes.addFlashAttribute("success", 
                    String.format("✅ Tạo yêu cầu rút tiền thành công! Mã yêu cầu: #%d - Số tiền: %s VNĐ", 
                                 withdrawal.getId(), withdrawal.getAmount()));
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException e) {
            // Validation error (amount <= 0, etc.)
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals/create";
            
        } catch (IllegalStateException e) {
            // Business logic error (đã có pending, không đủ tiền, etc.)
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals/create";
            
        } catch (java.util.concurrent.TimeoutException e) {
            // Timeout khi chờ queue xử lý
            redirectAttributes.addFlashAttribute("warning", 
                    "⏱️ Yêu cầu đang được xử lý, vui lòng kiểm tra lại danh sách sau ít phút");
            return "redirect:/seller/withdrawals";
            
        } catch (java.util.concurrent.RejectedExecutionException e) {
            // Queue đầy
            redirectAttributes.addFlashAttribute("error", 
                    "❌ Hệ thống đang bận, vui lòng thử lại sau");
            return "redirect:/seller/withdrawals/create";
            
        } catch (java.util.concurrent.ExecutionException e) {
            // Exception từ task trong queue
            Throwable cause = e.getCause();
            String message;
            if (cause instanceof IllegalArgumentException || cause instanceof IllegalStateException) {
                message = cause.getMessage();
            } else {
                message = "Có lỗi xảy ra khi xử lý yêu cầu";
            }
            redirectAttributes.addFlashAttribute("error", "❌ " + message);
            return "redirect:/seller/withdrawals/create";
            
        } catch (Exception e) {
            // Unexpected error
            redirectAttributes.addFlashAttribute("error", 
                    "❌ Có lỗi không mong muốn: " + e.getMessage());
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
     * 
     * Quy tắc:
     * - CHỈ cho phép sửa thông tin ngân hàng (bankName, bankAccountNumber, bankAccountName)
     * - KHÔNG cho phép sửa số tiền (amount đã được lock)
     * - Yêu cầu phải ở trạng thái PENDING (chưa được chấp nhận)
     */
    @PostMapping("/{id}/update")
    public String updateWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            @RequestParam String bankName,
            @RequestParam String bankAccountNumber,
            @RequestParam String bankAccountName,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            withdrawalRequestService.updateWithdrawalRequest(
                    id, bankName, bankAccountNumber, bankAccountName, user);

            redirectAttributes.addFlashAttribute("success", 
                    "✅ Cập nhật thông tin ngân hàng thành công!");
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals/" + id + "/edit";
            
        } catch (IllegalStateException e) {
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals/" + id + "/edit";
            
        } catch (SecurityException e) {
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals";
        }
    }

    /**
     * Hủy yêu cầu rút tiền - Sử dụng queue để xử lý
     * 
     * Flow:
     * 1. Submit vào queue của seller
     * 2. Trong queue: check status CANCELLED và PENDING
     * 3. Hoàn tiền và cập nhật status
     */
    @PostMapping("/{id}/cancel")
    public String cancelWithdrawal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            RedirectAttributes redirectAttributes) {

        try {
            User user = currentUser.getUser();
            
            // Gửi vào queue để xử lý async
            Future<Void> future = withdrawalRequestService.cancelWithdrawalRequestAsync(id, user);
            
            // Đợi kết quả từ queue (với timeout 10s)
            future.get(10, java.util.concurrent.TimeUnit.SECONDS);

            // Refresh authentication context để cập nhật số dư trong session (đã hoàn tiền)
            authenticationRefreshService.refreshAuthenticationContext();

            redirectAttributes.addFlashAttribute("success", 
                    "✅ Đã hủy yêu cầu rút tiền và hoàn tiền thành công!");
            return "redirect:/seller/withdrawals";

        } catch (IllegalArgumentException e) {
            // Not found
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals";
            
        } catch (IllegalStateException e) {
            // Already cancelled or wrong status
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals";
            
        } catch (SecurityException e) {
            // Wrong user
            redirectAttributes.addFlashAttribute("error", "❌ " + e.getMessage());
            return "redirect:/seller/withdrawals";
            
        } catch (java.util.concurrent.TimeoutException e) {
            // Timeout
            redirectAttributes.addFlashAttribute("warning", 
                    "⏱️ Yêu cầu hủy đang được xử lý, vui lòng kiểm tra lại sau");
            return "redirect:/seller/withdrawals";
            
        } catch (java.util.concurrent.RejectedExecutionException e) {
            // Queue full
            redirectAttributes.addFlashAttribute("error", 
                    "❌ Hệ thống đang bận, vui lòng thử lại sau");
            return "redirect:/seller/withdrawals";
            
        } catch (java.util.concurrent.ExecutionException e) {
            // Exception from queue task
            Throwable cause = e.getCause();
            String message;
            if (cause instanceof IllegalArgumentException || 
                cause instanceof IllegalStateException || 
                cause instanceof SecurityException) {
                message = cause.getMessage();
            } else {
                message = "Có lỗi xảy ra khi hủy yêu cầu";
            }
            redirectAttributes.addFlashAttribute("error", "❌ " + message);
            return "redirect:/seller/withdrawals";
            
        } catch (Exception e) {
            // Unexpected error
            redirectAttributes.addFlashAttribute("error", 
                    "❌ Có lỗi không mong muốn: " + e.getMessage());
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
