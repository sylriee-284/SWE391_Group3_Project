package vn.group3.marketplace.controller.admin;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.dto.response.SellerStoreResponse;
import vn.group3.marketplace.service.interfaces.SellerStoreService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Admin controller for seller store management
 * Handles administrative operations for stores
 */
@Slf4j
@Controller
@RequestMapping("/admin/stores")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminStoreController {

    private final SellerStoreService sellerStoreService;

    /**
     * Admin store management dashboard
     */
    @GetMapping
    public String adminStoreList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean verified,
            Model model) {

        Sort.Direction sortDirection = "desc".equalsIgnoreCase(direction) ? 
                Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));

        Page<SellerStoreResponse> stores;
        
        if (search != null && !search.trim().isEmpty()) {
            stores = sellerStoreService.searchStores(search.trim(), pageable);
            model.addAttribute("search", search);
        } else if (status != null && !status.trim().isEmpty()) {
            stores = sellerStoreService.getStoresByStatus(status, pageable);
            model.addAttribute("status", status);
        } else if (Boolean.TRUE.equals(verified)) {
            stores = sellerStoreService.getVerifiedStores(pageable);
            model.addAttribute("verified", true);
        } else if (Boolean.FALSE.equals(verified)) {
            stores = sellerStoreService.getStoresPendingVerification(pageable);
            model.addAttribute("verified", false);
        } else {
            stores = sellerStoreService.getAllActiveStores(pageable);
        }

        // Get store statistics
        Map<String, Object> statistics = sellerStoreService.getStoreStatistics();
        model.addAttribute("statistics", statistics);

        model.addAttribute("stores", stores);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", stores.getTotalPages());
        model.addAttribute("totalElements", stores.getTotalElements());
        model.addAttribute("sort", sort);
        model.addAttribute("direction", direction);

        return "admin/store/list";
    }

    /**
     * View store details in admin panel
     */
    @GetMapping("/{storeId}")
    public String viewStoreDetails(@PathVariable Long storeId, Model model) {
        Optional<SellerStore> storeOpt = sellerStoreService.getStoreById(storeId);
        
        if (storeOpt.isEmpty()) {
            return "redirect:/admin/stores?error=store_not_found";
        }

        SellerStore store = storeOpt.get();
        SellerStoreResponse storeResponse = SellerStoreResponse.fromEntity(store);

        model.addAttribute("store", storeResponse);
        // TODO: Add additional admin-specific data like audit logs, financial details

        return "admin/store/detail";
    }

    /**
     * Show stores pending verification
     */
    @GetMapping("/pending-verification")
    public String pendingVerification(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Model model) {

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "createdAt"));
        Page<SellerStoreResponse> stores = sellerStoreService.getStoresPendingVerification(pageable);

        model.addAttribute("stores", stores);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", stores.getTotalPages());
        model.addAttribute("totalElements", stores.getTotalElements());

        return "admin/store/pending-verification";
    }

    /**
     * Verify a store
     */
    @PostMapping("/{storeId}/verify")
    public String verifyStore(
            @PathVariable Long storeId,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        try {
            sellerStoreService.verifyStore(storeId, currentUser.getId());
            redirectAttributes.addFlashAttribute("success", 
                "Cửa hàng ID " + storeId + " đã được xác minh thành công!");
        } catch (Exception e) {
            log.error("Failed to verify store {}: {}", storeId, e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể xác minh cửa hàng: " + e.getMessage());
        }

        return "redirect:/admin/stores/" + storeId;
    }

    /**
     * Suspend a store
     */
    @PostMapping("/{storeId}/suspend")
    public String suspendStore(
            @PathVariable Long storeId,
            @RequestParam String reason,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        if (reason == null || reason.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Lý do khóa cửa hàng là bắt buộc!");
            return "redirect:/admin/stores/" + storeId;
        }

        try {
            sellerStoreService.suspendStore(storeId, currentUser.getId(), reason);
            redirectAttributes.addFlashAttribute("success", 
                "Cửa hàng ID " + storeId + " đã bị khóa!");
        } catch (Exception e) {
            log.error("Failed to suspend store {}: {}", storeId, e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể khóa cửa hàng: " + e.getMessage());
        }

        return "redirect:/admin/stores/" + storeId;
    }

    /**
     * Activate a suspended store
     */
    @PostMapping("/{storeId}/activate")
    public String activateStore(
            @PathVariable Long storeId,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        try {
            sellerStoreService.activateStore(storeId, currentUser.getId());
            redirectAttributes.addFlashAttribute("success", 
                "Cửa hàng ID " + storeId + " đã được kích hoạt!");
        } catch (Exception e) {
            log.error("Failed to activate store {}: {}", storeId, e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể kích hoạt cửa hàng: " + e.getMessage());
        }

        return "redirect:/admin/stores/" + storeId;
    }

    /**
     * Delete a store (soft delete)
     */
    @PostMapping("/{storeId}/delete")
    public String deleteStore(
            @PathVariable Long storeId,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        try {
            sellerStoreService.deleteStore(storeId, currentUser.getId());
            redirectAttributes.addFlashAttribute("success", 
                "Cửa hàng ID " + storeId + " đã được xóa!");
        } catch (Exception e) {
            log.error("Failed to delete store {}: {}", storeId, e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể xóa cửa hàng: " + e.getMessage());
        }

        return "redirect:/admin/stores";
    }

    /**
     * Update store deposit amount
     */
    @PostMapping("/{storeId}/update-deposit")
    public String updateStoreDeposit(
            @PathVariable Long storeId,
            @RequestParam BigDecimal newDepositAmount,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        BigDecimal minDeposit = sellerStoreService.getMinimumDepositAmount();
        if (newDepositAmount.compareTo(minDeposit) < 0) {
            redirectAttributes.addFlashAttribute("error", 
                "Số tiền deposit phải ít nhất " + String.format("%,.0f VND", minDeposit));
            return "redirect:/admin/stores/" + storeId;
        }

        try {
            sellerStoreService.updateStoreDeposit(storeId, newDepositAmount, currentUser.getId());
            redirectAttributes.addFlashAttribute("success", 
                "Deposit của cửa hàng đã được cập nhật!");
        } catch (Exception e) {
            log.error("Failed to update deposit for store {}: {}", storeId, e.getMessage());
            redirectAttributes.addFlashAttribute("error", 
                "Không thể cập nhật deposit: " + e.getMessage());
        }

        return "redirect:/admin/stores/" + storeId;
    }

    /**
     * Get top performing stores
     */
    @GetMapping("/top-performers")
    public String topPerformingStores(
            @RequestParam(defaultValue = "10") int limit,
            Model model) {

        List<SellerStoreResponse> topStores = sellerStoreService.getTopPerformingStores(limit);
        Map<String, Object> statistics = sellerStoreService.getStoreStatistics();

        model.addAttribute("topStores", topStores);
        model.addAttribute("statistics", statistics);
        model.addAttribute("limit", limit);

        return "admin/store/top-performers";
    }

    /**
     * Store analytics dashboard
     */
    @GetMapping("/analytics")
    public String storeAnalytics(Model model) {
        Map<String, Object> statistics = sellerStoreService.getStoreStatistics();
        List<SellerStoreResponse> topStores = sellerStoreService.getTopPerformingStores(5);

        model.addAttribute("statistics", statistics);
        model.addAttribute("topStores", topStores);

        return "admin/store/analytics";
    }

    /**
     * Bulk operations on stores
     */
    @PostMapping("/bulk-action")
    public String bulkAction(
            @RequestParam String action,
            @RequestParam List<Long> storeIds,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        if (storeIds == null || storeIds.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Vui lòng chọn ít nhất một cửa hàng!");
            return "redirect:/admin/stores";
        }

        int successCount = 0;
        int errorCount = 0;

        for (Long storeId : storeIds) {
            try {
                switch (action.toLowerCase()) {
                    case "verify":
                        sellerStoreService.verifyStore(storeId, currentUser.getId());
                        break;
                    case "activate":
                        sellerStoreService.activateStore(storeId, currentUser.getId());
                        break;
                    case "deactivate":
                        sellerStoreService.deactivateStore(storeId, currentUser.getId());
                        break;
                    case "delete":
                        sellerStoreService.deleteStore(storeId, currentUser.getId());
                        break;
                    default:
                        throw new IllegalArgumentException("Unknown action: " + action);
                }
                successCount++;
            } catch (Exception e) {
                log.error("Failed to {} store {}: {}", action, storeId, e.getMessage());
                errorCount++;
            }
        }

        if (successCount > 0) {
            redirectAttributes.addFlashAttribute("success", 
                String.format("Đã thực hiện thành công %d/%d cửa hàng", successCount, storeIds.size()));
        }
        if (errorCount > 0) {
            redirectAttributes.addFlashAttribute("warning", 
                String.format("Có %d cửa hàng không thể thực hiện", errorCount));
        }

        return "redirect:/admin/stores";
    }
}
