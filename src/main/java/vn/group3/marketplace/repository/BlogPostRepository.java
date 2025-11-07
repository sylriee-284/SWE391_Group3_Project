package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.group3.marketplace.domain.entity.BlogPost;
import vn.group3.marketplace.domain.enums.BlogStatus;

import java.util.List;
import java.util.Optional;

public interface BlogPostRepository extends JpaRepository<BlogPost, Long> {

        /* KHÔNG lọc category: tránh DISTINCT + paginate */
        @Query(value = """
                        SELECT p
                        FROM BlogPost p
                        WHERE p.isDeleted = false
                          AND p.status = :published
                          AND (:q IS NULL OR LOWER(p.title)   LIKE LOWER(CONCAT('%', :q, '%'))
                                           OR LOWER(p.summary) LIKE LOWER(CONCAT('%', :q, '%')))
                          AND (:authorId IS NULL OR p.authorUserId = :authorId)
                        ORDER BY p.publishedAt DESC, p.id DESC
                        """, countQuery = """
                        SELECT COUNT(p)
                        FROM BlogPost p
                        WHERE p.isDeleted = false
                          AND p.status = :published
                          AND (:q IS NULL OR LOWER(p.title)   LIKE LOWER(CONCAT('%', :q, '%'))
                                           OR LOWER(p.summary) LIKE LOWER(CONCAT('%', :q, '%')))
                          AND (:authorId IS NULL OR p.authorUserId = :authorId)
                        """)
        Page<BlogPost> searchPublicNoCat(@Param("q") String q,
                        @Param("authorId") Long authorId,
                        @Param("published") BlogStatus published,
                        Pageable pageable);

        /* CÓ lọc category */
        /* CÓ lọc category – chấp nhận slug HOẶC name, không phân biệt hoa-thường */
        @Query(value = """
                        SELECT p
                        FROM BlogPost p JOIN p.categories c
                        WHERE p.isDeleted = false
                          AND p.status = :published
                          AND ( :categorySlug IS NULL
                                OR LOWER(c.slug) = LOWER(:categorySlug)
                                OR LOWER(c.name) = LOWER(:categorySlug) )
                          AND ( :q IS NULL
                                OR LOWER(p.title)   LIKE LOWER(CONCAT('%', :q, '%'))
                                OR LOWER(p.summary) LIKE LOWER(CONCAT('%', :q, '%')) )
                          AND ( :authorId IS NULL OR p.authorUserId = :authorId )
                        ORDER BY p.publishedAt DESC, p.id DESC
                        """, countQuery = """
                        SELECT COUNT(p)
                        FROM BlogPost p JOIN p.categories c
                        WHERE p.isDeleted = false
                          AND p.status = :published
                          AND ( :categorySlug IS NULL
                                OR LOWER(c.slug) = LOWER(:categorySlug)
                                OR LOWER(c.name) = LOWER(:categorySlug) )
                          AND ( :q IS NULL
                                OR LOWER(p.title)   LIKE LOWER(CONCAT('%', :q, '%'))
                                OR LOWER(p.summary) LIKE LOWER(CONCAT('%', :q, '%')) )
                          AND ( :authorId IS NULL OR p.authorUserId = :authorId )
                        """)
        Page<BlogPost> searchPublicWithCat(
                        @Param("q") String q,
                        @Param("categorySlug") String categorySlug, // có thể là slug HOẶC name
                        @Param("authorId") Long authorId,
                        @Param("published") BlogStatus published,
                        Pageable pageable);

        Optional<BlogPost> findBySlugAndIsDeletedFalseAndStatus(String slug, BlogStatus status);

        /* Related posts: dùng subquery EXISTS, KHÔNG đụng tới createdAt */
        @Query("""
                        SELECT p2
                        FROM BlogPost p2
                        WHERE p2.isDeleted = false
                          AND p2.status = :published
                          AND p2.id <> :postId
                          AND EXISTS (
                             SELECT 1
                             FROM BlogPost p
                             JOIN p.categories c
                             JOIN p2.categories c2
                             WHERE p.id = :postId AND c.id = c2.id
                          )
                        ORDER BY p2.publishedAt DESC, p2.id DESC
                        """)
        List<BlogPost> findRelatedByCategory(@Param("postId") Long postId,
                        @Param("published") BlogStatus published,
                        Pageable pageable);

        @Query("""
                        SELECT c.name as category, COUNT(DISTINCT p.id) as count
                        FROM BlogPost p
                        JOIN p.categories c
                        WHERE p.isDeleted = false
                          AND p.status = :published
                        GROUP BY c.name
                        ORDER BY count DESC, c.name ASC
                        """)
        List<Object[]> findCategoryStatistics(@Param("published") BlogStatus published);
}
