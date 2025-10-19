package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Notification;
import vn.group3.marketplace.domain.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUser(User user);

    Optional<Notification> findById(Long id);

    Optional<Notification> findTopByUserOrderByCreatedAtDesc(User user);

    List<Notification> findByUserOrderByCreatedAtDesc(User user);

    // Find unread notifications for a user
    List<Notification> findByUserAndReadAtIsNullOrderByCreatedAtDesc(User user);

    // Find latest unread notification for a user
    Optional<Notification> findTopByUserAndReadAtIsNullOrderByCreatedAtDesc(User user);
}
