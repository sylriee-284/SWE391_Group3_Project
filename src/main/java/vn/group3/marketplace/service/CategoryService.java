package vn.group3.marketplace.service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.repository.CategoryRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    @PersistenceContext
    private EntityManager em;

    public List<Category> getParentCategories() {
        return findParentCategories();
    }

    // ========================= DANH MỤC CHA =========================
    public List<Category> findParentCategories() {
        String jpql = """
                    SELECT c
                    FROM Category c
                    WHERE (c.parentId IS NULL OR c.parentId = 0)
                      AND (c.isDeleted = false OR c.isDeleted IS NULL)
                    ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class).getResultList();
    }

    public Page<Category> findParentCategories(int page, int size) {
        String base = "FROM Category c WHERE (c.parentId IS NULL OR c.parentId = 0) AND (c.isDeleted = false OR c.isDeleted IS NULL)";
        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        TypedQuery<Category> q = em.createQuery(select, Category.class);
        q.setFirstResult(page * size);
        q.setMaxResults(size);
        List<Category> content = q.getResultList();

        Long total = em.createQuery(count, Long.class).getSingleResult();
        return new PageImpl<>(content, PageRequest.of(page, size), total);
    }

    // ========================= DANH MỤC CON =========================
    public List<Category> findSubcategoriesByParentId(Long parentId) {
        String jpql = """
                    SELECT c
                    FROM Category c
                    WHERE c.parentId = :pid
                      AND (c.isDeleted = false OR c.isDeleted IS NULL)
                    ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class)
                .setParameter("pid", parentId)
                .getResultList();
    }

    public Page<Category> findSubcategoriesByParentId(Long parentId, int page, int size) {
        String base = "FROM Category c WHERE c.parentId = :pid AND (c.isDeleted = false OR c.isDeleted IS NULL)";
        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        TypedQuery<Category> q = em.createQuery(select, Category.class)
                .setParameter("pid", parentId);
        q.setFirstResult(page * size);
        q.setMaxResults(size);
        List<Category> content = q.getResultList();

        Long total = em.createQuery(count, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();

        return new PageImpl<>(content, PageRequest.of(page, size), total);
    }

    // ========================= CRUD & TIỆN ÍCH =========================
    public Optional<Category> getById(Long id) {
        return categoryRepository.findByIdAndIsDeletedFalse(id);
    }

    @Transactional
    public Category save(Category c) {
        if (c.getParentId() != null && c.getParentId() == 0) {
            c.setParentId(null);
        }
        if (c.getId() == null) {
            em.persist(c);
            return c;
        } else {
            return em.merge(c);
        }
    }

    @Transactional
    public void softDelete(Long id) {
        Category cat = categoryRepository.findByIdAndIsDeletedFalse(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục ID: " + id));
        cat.setIsDeleted(true);
        cat.setDeletedAt(LocalDateTime.now());
        categoryRepository.save(cat);
    }

    public boolean hasChildren(Long parentId) {
        String jpql = "SELECT COUNT(c) FROM Category c WHERE c.parentId = :pid AND (c.isDeleted = false OR c.isDeleted IS NULL)";
        Long cnt = em.createQuery(jpql, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();
        return cnt != null && cnt > 0;
    }
}
