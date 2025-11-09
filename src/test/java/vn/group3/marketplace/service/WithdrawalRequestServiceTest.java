package vn.group3.marketplace.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.util.PerUserSerialExecutor;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.concurrent.Future;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Test cho WithdrawalRequestService
 * 
 * Test cases:
 * 1. Tạo withdrawal request thành công
 * 2. Tạo withdrawal khi đã có pending request -> throw error
 * 3. Tạo withdrawal khi không đủ tiền -> throw error
 * 4. Update withdrawal chỉ được phép sửa bank info, không sửa amount
 * 5. Update withdrawal chỉ khi status = PENDING
 */
@ExtendWith(MockitoExtension.class)
class WithdrawalRequestServiceTest {

    @Mock
    private WalletTransactionRepository walletTransactionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PerUserSerialExecutor perUserSerialExecutor;

    @InjectMocks
    private WithdrawalRequestService withdrawalRequestService;

    private User testUser;
    private BigDecimal withdrawAmount;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("seller1");
        testUser.setBalance(new BigDecimal("1000000")); // 1 triệu

        withdrawAmount = new BigDecimal("500000"); // 500k
    }

    @Test
    @SuppressWarnings("unchecked")
    void testCreateWithdrawalRequest_Success() throws Exception {
        // Given
        when(walletTransactionRepository.existsByUserAndTypeAndPaymentStatus(
                testUser, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING))
                .thenReturn(false);
        
        when(userRepository.findById(testUser.getId()))
                .thenReturn(Optional.of(testUser));
        
        when(userRepository.decrementBalance(testUser.getId(), withdrawAmount))
                .thenReturn(1);

        WalletTransaction expectedTransaction = WalletTransaction.builder()
                .id(1L)
                .user(testUser)
                .type(WalletTransactionType.WITHDRAWAL)
                .amount(withdrawAmount)
                .paymentStatus(WalletTransactionStatus.PENDING)
                .build();
        
        when(walletTransactionRepository.save(any(WalletTransaction.class)))
                .thenReturn(expectedTransaction);

        // Mock PerUserSerialExecutor to execute immediately
        when(perUserSerialExecutor.submit(eq(testUser.getId()), any(java.util.concurrent.Callable.class)))
                .thenAnswer(invocation -> {
                    java.util.concurrent.Callable<WalletTransaction> callable = 
                        (java.util.concurrent.Callable<WalletTransaction>) invocation.getArgument(1);
                    WalletTransaction result = callable.call();
                    Future<WalletTransaction> future = mock(Future.class);
                    when(future.get(anyLong(), any())).thenReturn(result);
                    return future;
                });

        // When
        Future<WalletTransaction> future = withdrawalRequestService.createWithdrawalRequestAsync(
                testUser, withdrawAmount, "VCB", "1234567890", "Nguyen Van A");

        WalletTransaction result = future.get(10, java.util.concurrent.TimeUnit.SECONDS);

        // Then
        assertNotNull(result);
        assertEquals(withdrawAmount, result.getAmount());
        assertEquals(WalletTransactionStatus.PENDING, result.getPaymentStatus());
        verify(userRepository).decrementBalance(testUser.getId(), withdrawAmount);
        verify(walletTransactionRepository).save(any(WalletTransaction.class));
    }

    @Test
    @SuppressWarnings("unchecked")
    void testCreateWithdrawalRequest_HasPendingRequest_ShouldThrowError() {
        // Given: User đã có 1 yêu cầu PENDING
        when(walletTransactionRepository.existsByUserAndTypeAndPaymentStatus(
                testUser, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING))
                .thenReturn(true);

        when(perUserSerialExecutor.submit(eq(testUser.getId()), any(java.util.concurrent.Callable.class)))
                .thenAnswer(invocation -> {
                    java.util.concurrent.Callable<WalletTransaction> callable = 
                        (java.util.concurrent.Callable<WalletTransaction>) invocation.getArgument(1);
                    try {
                        callable.call();
                        fail("Should throw exception");
                    } catch (IllegalStateException e) {
                        // Expected
                        assertTrue(e.getMessage().contains("Đang có 1 yêu cầu rút tiền trước đó"));
                    }
                    return null;
                });

        // When & Then
        assertDoesNotThrow(() -> {
            withdrawalRequestService.createWithdrawalRequestAsync(
                    testUser, withdrawAmount, "VCB", "1234567890", "Nguyen Van A");
        });
    }

    @Test
    void testUpdateWithdrawalRequest_OnlyBankInfo_Success() {
        // Given
        WalletTransaction withdrawal = WalletTransaction.builder()
                .id(1L)
                .user(testUser)
                .type(WalletTransactionType.WITHDRAWAL)
                .amount(withdrawAmount)
                .paymentStatus(WalletTransactionStatus.PENDING)
                .note("Old note")
                .build();

        when(walletTransactionRepository.findById(1L))
                .thenReturn(Optional.of(withdrawal));
        
        when(walletTransactionRepository.save(any(WalletTransaction.class)))
                .thenReturn(withdrawal);

        // When
        WalletTransaction result = withdrawalRequestService.updateWithdrawalRequest(
                1L, "ACB", "9876543210", "Tran Thi B", testUser);

        // Then
        assertNotNull(result);
        assertTrue(result.getNote().contains("ACB"));
        assertTrue(result.getNote().contains("9876543210"));
        assertTrue(result.getNote().contains("Tran Thi B"));
        // Amount không thay đổi
        assertEquals(withdrawAmount, result.getAmount());
        verify(walletTransactionRepository).save(withdrawal);
    }

    @Test
    void testUpdateWithdrawalRequest_NotPending_ShouldThrowError() {
        // Given: Withdrawal đã được approve
        WalletTransaction withdrawal = WalletTransaction.builder()
                .id(1L)
                .user(testUser)
                .type(WalletTransactionType.WITHDRAWAL)
                .amount(withdrawAmount)
                .paymentStatus(WalletTransactionStatus.SUCCESS) // Đã được duyệt
                .note("Old note")
                .build();

        when(walletTransactionRepository.findById(1L))
                .thenReturn(Optional.of(withdrawal));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            withdrawalRequestService.updateWithdrawalRequest(
                    1L, "ACB", "9876543210", "Tran Thi B", testUser);
        });

        assertTrue(exception.getMessage().contains("chưa được chấp nhận"));
        verify(walletTransactionRepository, never()).save(any());
    }

    @Test
    void testUpdateWithdrawalRequest_WrongUser_ShouldThrowError() {
        // Given
        User anotherUser = new User();
        anotherUser.setId(999L);
        anotherUser.setUsername("hacker");

        WalletTransaction withdrawal = WalletTransaction.builder()
                .id(1L)
                .user(testUser) // Thuộc về testUser
                .type(WalletTransactionType.WITHDRAWAL)
                .amount(withdrawAmount)
                .paymentStatus(WalletTransactionStatus.PENDING)
                .build();

        when(walletTransactionRepository.findById(1L))
                .thenReturn(Optional.of(withdrawal));

        // When & Then: anotherUser cố gắng sửa withdrawal của testUser
        SecurityException exception = assertThrows(SecurityException.class, () -> {
            withdrawalRequestService.updateWithdrawalRequest(
                    1L, "ACB", "9876543210", "Hacker", anotherUser);
        });

        assertTrue(exception.getMessage().contains("không có quyền"));
        verify(walletTransactionRepository, never()).save(any());
    }

    @Test
    void testHasPendingWithdrawal() {
        // Given
        when(walletTransactionRepository.existsByUserAndTypeAndPaymentStatus(
                testUser, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING))
                .thenReturn(true);

        // When
        boolean result = withdrawalRequestService.hasPendingWithdrawal(testUser);

        // Then
        assertTrue(result);
        verify(walletTransactionRepository).existsByUserAndTypeAndPaymentStatus(
                testUser, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING);
    }
}
