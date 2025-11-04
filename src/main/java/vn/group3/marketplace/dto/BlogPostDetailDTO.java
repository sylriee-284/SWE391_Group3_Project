package vn.group3.marketplace.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Date;
import lombok.Builder;
import lombok.Data;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlogPostDetailDTO {
    private Long id;
    private String title;
    private String slug;
    private String summary;
    private String content;
    private String thumbnailUrl;
    private Long authorUserId;
    private String authorName;
    private Date publishedAt; // <— dùng java.util.Date
    private java.util.List<String> categories;
}
