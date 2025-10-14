package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Category;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByIsDeletedFalse();

    // Find parent categories (categories with parent_id = null)
    List<Category> findByParentIsNullAndIsDeletedFalse();

    // Find child categories by parent id
    List<Category> findByParentIdAndIsDeletedFalse(Long parentId);

    // Find categories by parent
    List<Category> findByParentAndIsDeletedFalse(Category parent);

    // CHA
    List<Category> findByParentIdIsNullAndIsDeletedFalseOrderByIdAsc();

    // CON
    Page<Category> findByParentIdAndIsDeletedFalse(Long parentId, Pageable pageable);

    // Lấy 1 bản ghi còn sống
    Optional<Category> findByIdAndIsDeletedFalse(Long id);

}
