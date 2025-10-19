package vn.group3.marketplace.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ImportResult {

    private int successCount;
    private int errorCount;

    @Builder.Default
    private List<ProductStorageImportDTO> errorRecords = new ArrayList<>();

    // Get total records processed
    public int getTotalCount() {
        return successCount + errorCount;
    }

    // Check if import was successful (no errors)
    public boolean isFullSuccess() {
        return errorCount == 0;
    }

    // Check if import had any success
    public boolean hasAnySuccess() {
        return successCount > 0;
    }

    // Get success rate percentage
    public double getSuccessRate() {
        int total = getTotalCount();
        if (total == 0)
            return 0.0;
        return (double) successCount / total * 100;
    }
}
