package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.group3.marketplace.domain.Product;

public interface ProductRepository extends JpaRepository<Product, Integer> {
}
