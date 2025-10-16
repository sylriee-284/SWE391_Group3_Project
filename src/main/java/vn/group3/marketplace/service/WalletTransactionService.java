package vn.group3.marketplace.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.repository.WalletTransactionRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class WalletTransactionService {

    private final WalletTransactionRepository walletTransactionRepository;

    public WalletTransactionService(WalletTransactionRepository walletTransactionRepository) {
        this.walletTransactionRepository = walletTransactionRepository;
    }

    public Page<WalletTransaction> getTransactionsByUser(User user, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByUserOrderByIdDesc(user, pageable);
    }

    public Page<WalletTransaction> getTransactionsByUserAndType(User user, WalletTransactionType type, int page,
            int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByUserAndTypeOrderByIdDesc(user, type, pageable);
    }

    public Page<WalletTransaction> getTransactionsByUserAndStatus(User user, WalletTransactionStatus status, int page,
            int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByUserAndPaymentStatusOrderByIdDesc(user, status, pageable);
    }

    public Page<WalletTransaction> getTransactionsByUserAndTypeAndStatus(User user, WalletTransactionType type,
            WalletTransactionStatus status, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByUserAndTypeAndPaymentStatusOrderByIdDesc(user, type, status,
                pageable);
    }

    public Optional<WalletTransaction> findById(Long id) {
        return walletTransactionRepository.findById(id);
    }

    public boolean canUserAccessTransaction(WalletTransaction transaction, User user) {
        if (transaction == null || user == null)
            return false;
        return transaction.getUser() != null && transaction.getUser().getId() != null
                && transaction.getUser().getId().equals(user.getId());
    }

    public List<WalletTransaction> getRecentTransactions(User user) {
        return walletTransactionRepository.findTop10ByUserOrderByIdDesc(user);
    }

    @Transactional
    public WalletTransaction saveTransaction(WalletTransaction transaction) {
        return walletTransactionRepository.save(transaction);
    }

    public long countTransactionsByUser(User user) {
        return walletTransactionRepository.countByUser(user);
    }

    public long countTransactionsByUserAndType(User user, WalletTransactionType type) {
        return walletTransactionRepository.countByUserAndType(user, type);
    }

    public long countTransactionsByUserAndStatus(User user, WalletTransactionStatus status) {
        return walletTransactionRepository.countByUserAndPaymentStatus(user, status);
    }
}
