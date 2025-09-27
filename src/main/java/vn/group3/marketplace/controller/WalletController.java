package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.WalletService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/wallet")
public class WalletController {
    private final WalletService walletService;

    public WalletController(WalletService walletService) {
        this.walletService = walletService;
    }

    @GetMapping("/{userId}")
    public String getWallet(@PathVariable Long userId, Model model) {
        // model.addAttribute("wallet", walletService.findByUser(userId).orElseThrow());
        return "wallet/detail";
    }
}
