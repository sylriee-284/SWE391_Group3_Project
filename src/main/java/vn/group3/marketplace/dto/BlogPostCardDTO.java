package vn.group3.marketplace.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlogPostCardDTO {
    private Long id;
    private String title;
    private String slug;
    private String summary;
    private String thumbnailUrl;
    private Date publishedAt; // <— dùng java.util.Date
    private java.util.List<String> categories;
    private String authorUsername;
}
