package vn.group3.marketplace.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductStorageImportDTO {

    private Integer rowNumber;

    @Builder.Default
    private Map<String, Object> data = new HashMap<>(); // Dynamic fields based on category template

    @Builder.Default
    private List<String> errors = new ArrayList<>();

    // Add a field value to the data map
    public void addField(String key, Object value) {
        this.data.put(key, value);
    }

    // Add an error message
    public void addError(String error) {
        this.errors.add(error);
    }

    // Check if there are any errors
    public boolean hasErrors() {
        return !this.errors.isEmpty();
    }

    // Get field value by key
    public Object getField(String key) {
        return this.data.get(key);
    }

    // Check if field exists
    public boolean hasField(String key) {
        return this.data.containsKey(key);
    }
}
