package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.ReviewService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/reviews")
public class ReviewController {
    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping("/product/{productId}")
    public String productReviews(@PathVariable Long productId, Model model) {
        // model.addAttribute("reviews", reviewService.getProductReviews(productId));
        return "review/product-reviews";
    }

    @GetMapping("/seller/{storeId}")
    public String sellerReviews(@PathVariable Long storeId, Model model) {
        // model.addAttribute("reviews", reviewService.getSellerReviews(storeId));
        return "review/seller-reviews";
    }
}
