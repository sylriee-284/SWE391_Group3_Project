package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByIsDeletedFalse();

    // Find parent categories (categories with parent_id = null)
    List<Category> findByParentIsNullAndIsDeletedFalse();

    // Find child categories by parent id
    List<Category> findByParentIdAndIsDeletedFalse(Long parentId);

    // Find categories by parent
    List<Category> findByParentAndIsDeletedFalse(Category parent);

    java.util.Optional<Category> findByNameAndIsDeletedFalse(String name);

}
