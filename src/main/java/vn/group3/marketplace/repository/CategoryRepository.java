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

    List<Category> findByParentIsNullAndIsDeletedFalse();

    List<Category> findByParentIdAndIsDeletedFalse(Long parentId);

    List<Category> findByParentAndIsDeletedFalse(Category parent);

    List<Category> findByParentIsNullAndIsDeletedFalseOrderByNameAsc();

    List<Category> findByParent_IdAndIsDeletedFalseOrderByNameAsc(Long parentId);

    java.util.Optional<Category> findByNameAndIsDeletedFalse(String name);

    // CHA
    List<Category> findByParentIdIsNullAndIsDeletedFalseOrderByIdAsc();

    // CON
    Page<Category> findByParentIdAndIsDeletedFalse(Long parentId, Pageable pageable);

    // Lấy 1 bản ghi còn sống
    Optional<Category> findByIdAndIsDeletedFalse(Long id);

    org.springframework.data.domain.Page<Category> findByParent_IdAndIsDeletedFalse(Long parentId,
            org.springframework.data.domain.Pageable p);

    // THÊM: lấy con KHÔNG lọc isDeleted (để hiển thị cả ON/OFF)
    org.springframework.data.domain.Page<Category> findByParent_Id(Long parentId,
            org.springframework.data.domain.Pageable p);
}
