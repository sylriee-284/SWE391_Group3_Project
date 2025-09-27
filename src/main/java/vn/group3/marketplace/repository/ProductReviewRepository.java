package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.ProductReview;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {

}
