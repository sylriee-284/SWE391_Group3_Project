package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import vn.group3.marketplace.domain.enums.BlogStatus;

@Entity
@Table(name = "blog_posts") // để trống unique/index ở đây để tránh Hibernate đổi constraint name
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlogPost {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    private String title;

    // DB là varchar(300)
    @Column(nullable = false, length = 300)
    private String slug;

    // DB là TEXT
    @Column(columnDefinition = "TEXT")
    private String summary;

    // DB đã có cột content (MEDIUMTEXT/LONGTEXT). @Lob là đủ, không ép
    // columnDefinition để tránh alter qua lại.
    @Lob
    private String content;

    // DB là varchar(500)
    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl;

    // DB NOT NULL
    @Column(name = "author_user_id", nullable = false)
    private Long authorUserId;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    // DB NOT NULL, CHECK (DRAFT|PUBLISHED|ARCHIVED)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private BlogStatus status = BlogStatus.DRAFT;

    // DB NOT NULL default 0
    @Column(name = "is_deleted", nullable = false)
    @Builder.Default
    private Boolean isDeleted = false;

    // Join table đúng như DB: blog_post_categories(blog_post_id, blog_category_id)
    @ManyToMany
    @JoinTable(name = "blog_post_categories", joinColumns = @JoinColumn(name = "blog_post_id"), inverseJoinColumns = @JoinColumn(name = "blog_category_id"))
    @Builder.Default
    private Set<BlogCategory> categories = new HashSet<>();
}
