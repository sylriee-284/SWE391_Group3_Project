package vn.group3.marketplace.service;

import vn.group3.marketplace.domain.Product;
import java.util.List;

public interface ProductService {
    Product create(Product p);

    List<Product> findAll();
}
