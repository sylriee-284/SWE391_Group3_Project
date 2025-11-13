package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import vn.group3.marketplace.domain.entity.BlogPost;
import vn.group3.marketplace.domain.enums.BlogStatus;
import vn.group3.marketplace.dto.BlogPostCardDTO;
import vn.group3.marketplace.dto.BlogPostDetailDTO;
import vn.group3.marketplace.repository.BlogPostRepository;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class BlogPostService {

    private final BlogPostRepository blogPostRepository;

    public Page<BlogPostCardDTO> findPublicPosts(String q,
            String categorySlug,
            Long authorId,
            Pageable pageable) {
        String qSafe = (q == null || q.isBlank()) ? null : q.trim();
        String catSafe = (categorySlug == null || categorySlug.isBlank())
                ? null
                : normalizeSlug(categorySlug);
        Long authorSafe = (authorId == null || authorId == 0L) ? null : authorId;

        Page<BlogPost> page = (catSafe == null)
                ? blogPostRepository.searchPublicNoCat(qSafe, authorSafe, BlogStatus.PUBLISHED, pageable)
                : blogPostRepository.searchPublicWithCat(qSafe, catSafe, authorSafe, BlogStatus.PUBLISHED, pageable);

        return page.map(this::toCardDto);
    }

    private String normalizeSlug(String raw) {
        String s = raw.trim().toLowerCase();
        if (s.equals("khác") || s.equals("other"))
            return "khac";
        return s; // facebook, tiktok, youtube, marketing, huong-dan, tin-tuc, cap-nhat...
    }

    public BlogPostDetailDTO findPublicBySlug(String slug) {
        return blogPostRepository
                .findBySlugAndIsDeletedFalseAndStatus(slug, BlogStatus.PUBLISHED)
                .map(this::toDetailDto)
                .orElse(null);
    }

    public List<BlogPostCardDTO> findRelated(Long postId, int limit) {
        return blogPostRepository
                .findRelatedByCategory(postId, BlogStatus.PUBLISHED, PageRequest.of(0, limit))
                .stream().map(this::toCardDto).toList();
    }

    /**
     * Get category statistics (name and count of posts)
     * 
     * @return Map of category name to post count
     */
    public Map<String, Long> getCategoryStats() {
        List<Object[]> results = blogPostRepository.findCategoryStatistics(BlogStatus.PUBLISHED);
        return results.stream()
                .collect(Collectors.toMap(
                        row -> (String) row[0], // category name
                        row -> (Long) row[1], // count
                        (a, b) -> a, // In case of duplicates, keep first one
                        java.util.LinkedHashMap::new // Keep order
                ));
    }

    private Date toDate(LocalDateTime ldt) {
        return ldt == null ? null : Date.from(ldt.atZone(ZoneId.systemDefault()).toInstant());
    }

    /* ===== mappers ===== */
    private BlogPostCardDTO toCardDto(BlogPost p) {
        return BlogPostCardDTO.builder()
                .id(p.getId())
                .title(p.getTitle())
                .slug(p.getSlug())
                .summary(p.getSummary())
                .thumbnailUrl(p.getThumbnailUrl())
                .publishedAt(toDate(p.getPublishedAt())) // <— dùng Date cho JSP
                .categories(p.getCategories().stream().map(c -> c.getName()).toList())
                .build();
    }

    private BlogPostDetailDTO toDetailDto(BlogPost p) {
        String authorName = null;
        return BlogPostDetailDTO.builder()
                .id(p.getId())
                .title(p.getTitle())
                .slug(p.getSlug())
                .summary(p.getSummary())
                .content(p.getContent())
                .thumbnailUrl(p.getThumbnailUrl())
                .authorUserId(p.getAuthorUserId())
                .authorName(authorName)
                .publishedAt(toDate(p.getPublishedAt())) // <— dùng Date cho JSP
                .categories(p.getCategories().stream().map(c -> c.getName()).toList())
                .build();
    }

}
