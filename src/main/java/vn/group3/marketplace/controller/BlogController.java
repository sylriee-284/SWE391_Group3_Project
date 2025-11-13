package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.dto.BlogPostCardDTO;
import vn.group3.marketplace.dto.BlogPostDetailDTO;
import vn.group3.marketplace.service.BlogPostService;

@Controller
@RequiredArgsConstructor
@RequestMapping("/blog") // prefix cố định
public class BlogController {

    private final BlogPostService blogPostService;

    // Truy cập /blog sẽ redirect về /blog/list
    @GetMapping({ "", "/" })
    public String index() {
        return "redirect:/blog/list";
    }

    /** LIST: GET /blog/list */
    @GetMapping("/list")
    public String list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(required = false) String q,
            @RequestParam(required = false, name = "category") String categorySlug,
            @RequestParam(required = false, name = "author") Long authorId,
            Model model) {

        String qSafe = (q == null || q.isBlank()) ? null : q.trim();
        String catSafe = normalizeCategory(categorySlug); // <— dùng hàm normalize ở dưới
        Long authorSafe = (authorId != null && authorId == 0L) ? null : authorId;

        Page<BlogPostCardDTO> posts = blogPostService.findPublicPosts(
                qSafe, catSafe, authorSafe, PageRequest.of(Math.max(page, 0), Math.max(size, 1)));

        model.addAttribute("posts", posts);
        model.addAttribute("categories", blogPostService.getCategoryStats());
        model.addAttribute("q", q);
        model.addAttribute("category", categorySlug);
        model.addAttribute("author", authorId);
        model.addAttribute("pageTitle", "Blog");
        return "blog/list";
    }

    /** Chuẩn hoá tham số category từ UI/sidebar thành slug trong DB */
    private String normalizeCategory(String raw) {
        if (raw == null || raw.isBlank())
            return null;
        String s = raw.trim().toLowerCase();
        // các biến thể phổ biến cần map về 'khac'
        if (s.equals("other") || s.equals("khác") || s.equals("khac"))
            return "khac";
        return s; // còn lại dùng nguyên (facebook, tiktok, youtube, marketing, huong-dan,
                  // tin-tuc, cap-nhat, ...)
    }

    /** DETAIL: /blog/{slug} (loại trừ 'list' để không trùng route) */
    @GetMapping("/{slug:^(?!list$).+}")
    public String detail(@PathVariable String slug, Model model, RedirectAttributes ra) {
        BlogPostDetailDTO post = blogPostService.findPublicBySlug(slug);
        if (post == null) {
            ra.addFlashAttribute("errorMessage", "Bài viết không tồn tại hoặc đã ẩn.");
            return "redirect:/blog/list";
        }
        model.addAttribute("post", post);
        model.addAttribute("categories", blogPostService.getCategoryStats());
        model.addAttribute("related", blogPostService.findRelated(post.getId(), 4));
        model.addAttribute("pageTitle", post.getTitle());
        return "blog/detail";
    }
}
