package vn.group3.marketplace.service.impl;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.Product;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.service.ProductService;

import java.util.List;

@Service
public class ProductServiceImpl implements ProductService {

    private final ProductRepository repo;

    public ProductServiceImpl(ProductRepository repo) {
        this.repo = repo;
    }

    @Override
    @Transactional
    public Product create(Product p) {
        return repo.save(p);
    }

    @Override
    public List<Product> findAll() {
        return repo.findAll();
    }
}
