package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.group3.marketplace.domain.entity.BlogCategory;

import java.util.List;
import java.util.Optional;

public interface BlogCategoryRepository extends JpaRepository<BlogCategory, Long> {
    List<BlogCategory> findAllByIsDeletedFalseOrderByNameAsc();

    Optional<BlogCategory> findBySlugAndIsDeletedFalse(String slug);
}