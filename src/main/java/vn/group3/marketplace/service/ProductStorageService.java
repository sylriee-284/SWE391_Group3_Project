package vn.group3.marketplace.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.repository.ProductStorageRepository;

@Service
public class ProductStorageService {

    @Autowired
    private ProductStorageRepository productStorageRepository;

    public List<ProductStorage> findAllAvailable(Long productId, ProductStorageStatus status) {
        return productStorageRepository.findByProductIdAndStatus(productId, status);
    }

    @Transactional
    public List<ProductStorage> findByProductIdWithQuantityAvailable(
            Long productId,
            Integer quantity,
            ProductStorageStatus status) {
        List<ProductStorage> allAvailable = productStorageRepository
                .findByProductIdAndStatusOrderByCreatedAtAsc(productId, status);

        if (allAvailable.size() < quantity) {
            throw new RuntimeException("Not enough inventory, only " + allAvailable.size() + " available");
        }

        // Lấy chỉ số lượng cần thiết
        List<ProductStorage> productStorages = allAvailable.subList(0, quantity);

        for (ProductStorage ps : productStorages) {
            ps.setStatus(ProductStorageStatus.DELIVERED);
        }

        productStorageRepository.saveAll(productStorages);
        return productStorages;
    }

}
