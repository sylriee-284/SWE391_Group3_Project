package vn.group3.marketplace.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.repository.ProductStorageRepository;

@Service
public class ProductStorageService {

    private final ProductStorageRepository productStorageRepository;

    public ProductStorageService(ProductStorageRepository productStorageRepository) {
        this.productStorageRepository = productStorageRepository;
    }

    @Transactional
    public List<ProductStorage> findByProductIdWithQuantityAvailable(
            Long productId,
            Integer quantity,
            ProductStorageStatus status) {
        List<ProductStorage> allAvailable = productStorageRepository
                .findByProductIdAndStatusAndOrderIsNull(productId, status);

        // Lấy chỉ số lượng cần thiết (đã valid từ trước)
        List<ProductStorage> productStorages = allAvailable.subList(0, quantity);

        // Update status to DELIVERED
        for (ProductStorage ps : productStorages) {
            ps.setStatus(ProductStorageStatus.DELIVERED);
        }

        productStorageRepository.saveAll(productStorages);
        return productStorages;
    }

    @Transactional
    public List<ProductStorage> saveAll(List<ProductStorage> productStorages) {
        return productStorageRepository.saveAll(productStorages);
    }

    public long getAvailableStock(Long productId) {
        return productStorageRepository.countAvailableStockByProductId(productId, ProductStorageStatus.AVAILABLE);
    }

}
