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
                SELECT c FROM Category c
                WHERE (c.parentId IS NULL OR c.parentId = 0)
                  AND (c.isDeleted = false OR c.isDeleted IS NULL)
                ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class).getResultList();
    }

    public Page<Category> findParentCategories(int page, int size) {
        String base = """
                FROM Category c
                WHERE (c.parentId IS NULL OR c.parentId = 0)
                  AND (c.isDeleted = false OR c.isDeleted IS NULL)
                """;

        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        List<Category> content = em.createQuery(select, Category.class)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
        Long total = em.createQuery(count, Long.class).getSingleResult();
        return new PageImpl<>(content, PageRequest.of(page, size), total);
    }

    // ========================= DANH MỤC CON =========================
    public List<Category> findSubcategoriesByParentId(Long parentId) {
        String jpql = """
                SELECT c FROM Category c
                WHERE c.parentId = :pid
                  AND (c.isDeleted = false OR c.isDeleted IS NULL)
                ORDER BY c.id ASC
                """;
        return em.createQuery(jpql, Category.class)
                .setParameter("pid", parentId)
                .getResultList();
    }

    public Page<Category> findSubcategoriesByParentId(Long parentId, int page, int size) {
        String base = """
                FROM Category c
                WHERE c.parentId = :pid
                  AND (c.isDeleted = false OR c.isDeleted IS NULL)
                """;

        String select = "SELECT c " + base + " ORDER BY c.id ASC";
        String count = "SELECT COUNT(c) " + base;

        List<Category> content = em.createQuery(select, Category.class)
                .setParameter("pid", parentId)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
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
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy category id=" + id));
        if (Boolean.TRUE.equals(c.getIsDeleted()))
            return; // đã xóa rồi thì thôi
        c.setIsDeleted(true);
        c.setIsActive(false); // tùy bạn: có thể set false luôn cho rõ
        categoryRepository.save(c);
    }

    public boolean hasChildren(Long parentId) {
        String jpql = "SELECT COUNT(c) FROM Category c WHERE c.parentId = :pid AND (c.isDeleted = false OR c.isDeleted IS NULL)";
        Long cnt = em.createQuery(jpql, Long.class)
                .setParameter("pid", parentId)
                .getSingleResult();
        return cnt != null && cnt > 0;
    }

    @Transactional
    public Category create(Category c) {
        // chuẩn hoá parentId
        if (c.getParentId() != null && c.getParentId() == 0) {
            c.setParentId(null);
        }
        c.setIsDeleted(false);
        c.setDeletedAt(null);
        return categoryRepository.save(c);
    }

    @Transactional
    public Category update(Long id, Category form) {
        Category c = categoryRepository.findByIdAndIsDeletedFalse(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy category id=" + id));
        // (tuỳ nhu cầu) nếu được phép đổi parentId thì chuẩn hoá luôn:
        if (form.getParentId() != null && form.getParentId() == 0) {
            form.setParentId(null);
        }
        c.setName(form.getName());
        c.setDescription(form.getDescription());
        // (nếu muốn cho phép đổi parent) c.setParentId(form.getParentId());
        return categoryRepository.save(c);
    }

    @Transactional
    public Category toggleStatusAndReturn(Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy category id=" + id));
        if (Boolean.TRUE.equals(c.getIsDeleted())) {
            throw new IllegalStateException("Bản ghi đã bị xóa, không thể đổi trạng thái.");
        }
        c.setIsActive(!Boolean.TRUE.equals(c.getIsActive())); // chỉ flip isActive
        return categoryRepository.save(c);
    }

}
