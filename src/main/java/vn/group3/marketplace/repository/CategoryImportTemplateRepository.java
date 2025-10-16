package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.CategoryImportTemplate;

@Repository
public interface CategoryImportTemplateRepository extends JpaRepository<CategoryImportTemplate, Long> {

    @Query("SELECT t FROM CategoryImportTemplate t WHERE t.category.id = :categoryId " +
            "AND t.isDeleted = false " +
            "ORDER BY t.fieldOrder")
    List<CategoryImportTemplate> findByCategoryIdOrderByFieldOrder(@Param("categoryId") Long categoryId);
}
