package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByIsDeletedFalse();

    List<Category> findByParentIsNullAndIsDeletedFalse();

    List<Category> findByParentIdAndIsDeletedFalse(Long parentId);

    List<Category> findByParentAndIsDeletedFalse(Category parent);

    List<Category> findByParentIsNullAndIsDeletedFalseOrderByNameAsc();

    List<Category> findByParent_IdAndIsDeletedFalseOrderByNameAsc(Long parentId);

}
