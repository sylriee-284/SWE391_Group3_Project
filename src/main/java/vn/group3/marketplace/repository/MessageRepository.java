package vn.group3.marketplace.repository;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Message;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

        @Query("SELECT m FROM Message m WHERE ((m.senderUser.id = :userId1 AND m.receiverUser.id = :userId2) OR (m.senderUser.id = :userId2 AND m.receiverUser.id = :userId1)) ORDER BY m.createdAt ASC")
        java.util.List<vn.group3.marketplace.domain.entity.Message> findMessagesBetweenUsers(
                        @Param("userId1") Long userId1, @Param("userId2") Long userId2);

        // /**
        // * Get all messages between two users (both directions)
        // *
        // * @param userId1 first user ID
        // * @param userId2 second user ID
        // * @return list of messages between the two users
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "((m.senderUser.id = :userId1 AND m.receiverUser.id = :userId2) OR " +
        // "(m.senderUser.id = :userId2 AND m.receiverUser.id = :userId1)) " +
        // "ORDER BY m.createdAt ASC")
        // List<Message> findMessagesBetweenUsers(@Param("userId1") Long userId1,
        // @Param("userId2") Long userId2);
        // 1. Load initial 20 tin nhắn mới nhất
        @Query("SELECT m FROM Message m WHERE " +
                        "((m.user.id = :userId1 AND m.sellerUser.id = :userId2) OR " +
                        " (m.user.id = :userId2 AND m.sellerUser.id = :userId1)) " +
                        "AND m.isDeleted = false " +
                        "ORDER BY m.createdAt DESC, m.id DESC")
        List<Message> findLatestMessages(@Param("userId1") Long userId1,
                        @Param("userId2") Long userId2,
                        Pageable pageable);

        // 2. Load thêm 20 tin nhắn cũ hơn khi scroll up (cursor-based pagination)
        @Query("SELECT m FROM Message m WHERE " +
                        "((m.user.id = :userId1 AND m.sellerUser.id = :userId2) OR " +
                        " (m.user.id = :userId2 AND m.sellerUser.id = :userId1)) " +
                        "AND m.id < :cursorId " +
                        "AND m.isDeleted = false " +
                        "ORDER BY m.id DESC")
        List<Message> findOlderMessages(@Param("userId1") Long userId1,
                        @Param("userId2") Long userId2,
                        @Param("cursorId") Long cursorId,
                        Pageable pageable);

        // 3. Danh sách conversations (tin nhắn cuối mỗi conversation)
        @Query("SELECT m FROM Message m WHERE " +
                        "m.id IN (" +
                        "   SELECT MAX(m2.id) FROM Message m2 " +
                        "   WHERE (m2.user.id = :userId OR m2.sellerUser.id = :userId) " +
                        "   AND m2.isDeleted = false " +
                        "   GROUP BY " +
                        "       CASE " +
                        "           WHEN m2.user.id = :userId THEN m2.sellerUser.id " +
                        "           ELSE m2.user.id " +
                        "       END " +
                        ") " +
                        "AND m.isDeleted = false " +
                        "ORDER BY m.createdAt DESC")
        List<Message> findConversationsForUser(@Param("userId") Long userId);

        // 4. Đếm tin nhắn chưa đọc từ một user cụ thể
        @Query("SELECT COUNT(m) FROM Message m WHERE " +
                        "m.receiverUser.id = :userId " +
                        "AND ((m.user.id = :userId AND m.sellerUser.id = :otherUserId) OR " +
                        "     (m.user.id = :otherUserId AND m.sellerUser.id = :userId)) " +
                        "AND m.readAt IS NULL " +
                        "AND m.isDeleted = false")
        Long countUnreadMessages(@Param("userId") Long userId, @Param("otherUserId") Long otherUserId);

        // 5. Đếm tổng tin nhắn chưa đọc (tất cả conversations)
        @Query("SELECT COUNT(m) FROM Message m WHERE " +
                        "m.receiverUser.id = :userId " +
                        "AND m.readAt IS NULL " +
                        "AND m.isDeleted = false")
        Long countTotalUnreadMessages(@Param("userId") Long userId);

        // 6. Kiểm tra tin nhắn đã tồn tại (idempotency check)
        Optional<Message> findBySenderUser_IdAndClientMsgId(Long senderUserId, String clientMsgId);

        // 7. Đánh dấu tin nhắn đã đọc (mark as read)
        @Modifying
        @Query("UPDATE Message m SET m.readAt = :readAt " +
                        "WHERE m.receiverUser.id = :userId " +
                        "AND ((m.user.id = :userId AND m.sellerUser.id = :otherUserId) OR " +
                        "     (m.user.id = :otherUserId AND m.sellerUser.id = :userId)) " +
                        "AND m.readAt IS NULL " +
                        "AND m.isDeleted = false")
        int markAsRead(@Param("userId") Long userId,
                        @Param("otherUserId") Long otherUserId,
                        @Param("readAt") LocalDateTime readAt);
}
