package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "blog_categories") // không khai unique/index ở đây để tránh Hibernate đổi constraint name
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlogCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // DB unique(name) đã có ở DB → không cần khai unique ở entity, nhưng length
    // khớp 255
    @Column(nullable = false, length = 255)
    private String name;

    // DB length = 300 + unique(slug) → giữ length 300, không cần khai unique ở
    // entity
    @Column(nullable = false, length = 300)
    private String slug;

    // DB NOT NULL default 0
    @Column(name = "is_deleted", nullable = false)
    @Builder.Default
    private Boolean isDeleted = false;

    // Inverse side KHÔNG @JoinTable ở đây (để Post là owning side)
    @ManyToMany(mappedBy = "categories")
    @JsonIgnore
    @Builder.Default
    private Set<BlogPost> posts = new HashSet<>();
}
