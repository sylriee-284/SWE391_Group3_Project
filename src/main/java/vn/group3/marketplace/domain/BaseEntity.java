package vn.group3.marketplace.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.Filter;
import org.hibernate.annotations.FilterDef;
import org.hibernate.annotations.ParamDef;
import org.springframework.data.annotation.*;

import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@FilterDef(name = "isDeletedFilter", parameters = @ParamDef(name = "isDeleted", type = Boolean.class))
@Filter(name = "isDeletedFilter", condition = "is_deleted = :isDeleted")
public abstract class BaseEntity {

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private Long createdBy;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;

    @Column(name = "deleted_by")
    private Long deletedBy;

    // Business methods for soft delete
    public void softDelete(Long deletedByUserId) {
        this.isDeleted = true;
        this.deletedBy = deletedByUserId;
    }

    public void restore() {
        this.isDeleted = false;
        this.deletedBy = null;
    }

    public boolean isDeleted() {
        return Boolean.TRUE.equals(this.isDeleted);
    }

    public boolean isActive() {
        return !isDeleted();
    }
}
