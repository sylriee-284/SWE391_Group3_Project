package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for Escrow Summary
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EscrowSummaryDTO {
    private BigDecimal totalHeld;
    private BigDecimal totalReleased;
    private BigDecimal totalRefunded;
    private Integer heldCount;
    private Integer releasedCount;
    private Integer refundedCount;

    // Escrow amount from seller_stores table (current balance in escrow account)
    private BigDecimal escrowAmount;

    // Next release schedule
    private List<ReleaseScheduleDTO> upcomingReleases;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ReleaseScheduleDTO {
        private LocalDateTime releaseDate;
        private BigDecimal amount;
        private Integer orderCount;
    }
}
