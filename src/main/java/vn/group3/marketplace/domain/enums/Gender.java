package vn.group3.marketplace.domain.enums;

/**
 * Enum representing user gender
 * Maps to the 'gender' column in the users table
 */
public enum Gender {
    MALE("male"),
    FEMALE("female"),
    OTHER("other"),
    PREFER_NOT_TO_SAY("prefer_not_to_say");

    private final String value;

    Gender(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static Gender fromValue(String value) {
        if (value == null) {
            return null;
        }
        for (Gender gender : Gender.values()) {
            if (gender.value.equals(value)) {
                return gender;
            }
        }
        throw new IllegalArgumentException("Unknown Gender value: " + value);
    }
}
