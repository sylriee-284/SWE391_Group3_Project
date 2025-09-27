package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

}
