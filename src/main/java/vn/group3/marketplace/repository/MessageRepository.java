package vn.group3.marketplace.repository;

// Pageable removed - not used
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Message;

// List not used at top-level imports

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

        // /**
        // * Get messages between two users with cursor-based pagination (scroll)
        // *
        // * @param userId1 first user ID
        // * @param userId2 second user ID
        // * @param lastMessageId last message ID for cursor (null for first page)
        // * @param limit number of messages to fetch
        // * @return list of messages for scroll pagination
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "((m.senderUser.id = :userId1 AND m.receiverUser.id = :userId2) OR " +
        // "(m.senderUser.id = :userId2 AND m.receiverUser.id = :userId1)) " +
        // "AND (:lastMessageId IS NULL OR m.id < :lastMessageId) " +
        // "ORDER BY m.createdAt DESC")
        // List<Message> findMessagesBetweenUsersWithCursor(@Param("userId1") Long
        // userId1,
        // @Param("userId2") Long userId2,
        // @Param("lastMessageId") Long lastMessageId,
        // Pageable pageable);

        // /**
        // * Get messages between two users with cursor-based pagination (scroll) -
        // * ascending order
        // *
        // * @param userId1 first user ID
        // * @param userId2 second user ID
        // * @param lastMessageId last message ID for cursor (null for first page)
        // * @param limit number of messages to fetch
        // * @return list of messages for scroll pagination
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "((m.senderUser.id = :userId1 AND m.receiverUser.id = :userId2) OR " +
        // "(m.senderUser.id = :userId2 AND m.receiverUser.id = :userId1)) " +
        // "AND (:lastMessageId IS NULL OR m.id > :lastMessageId) " +
        // "ORDER BY m.createdAt ASC")
        // List<Message> findMessagesBetweenUsersWithCursorAsc(@Param("userId1") Long
        // userId1,
        // @Param("userId2") Long userId2,
        // @Param("lastMessageId") Long lastMessageId,
        // Pageable pageable);

        // /**
        // * Get recent conversations for a user (last message from each conversation)
        // *
        // * @param userId the user ID
        // * @return list of recent messages from different conversations
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "(m.senderUser.id = :userId OR m.receiverUser.id = :userId) " +
        // "AND m.id IN (" +
        // " SELECT MAX(m2.id) FROM Message m2 " +
        // " WHERE (m2.senderUser.id = :userId OR m2.receiverUser.id = :userId) " +
        // " GROUP BY " +
        // " CASE " +
        // " WHEN m2.senderUser.id = :userId THEN m2.receiverUser.id " +
        // " ELSE m2.senderUser.id " +
        // " END" +
        // ") " +
        // "ORDER BY m.createdAt DESC")
        // List<Message> findRecentConversationsForUser(@Param("userId") Long userId);

        // /**
        // * Get the last message between two users
        // *
        // * @param userId1 first user ID
        // * @param userId2 second user ID
        // * @return the last message between the two users
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "((m.senderUser.id = :userId1 AND m.receiverUser.id = :userId2) OR " +
        // "(m.senderUser.id = :userId2 AND m.receiverUser.id = :userId1)) " +
        // "ORDER BY m.createdAt DESC " +
        // "LIMIT 1")
        // Message findLastMessageBetweenUsers(@Param("userId1") Long userId1,
        // @Param("userId2") Long userId2);

        // /**
        // * Find messages by client message ID (for idempotency)
        // *
        // * @param senderUserId sender user ID
        // * @param clientMsgId client message ID
        // * @return message if found
        // */
        // @Query("SELECT m FROM Message m WHERE " +
        // "m.senderUser.id = :senderUserId AND m.clientMsgId = :clientMsgId")
        // Message findBySenderAndClientMsgId(@Param("senderUserId") Long senderUserId,
        // @Param("clientMsgId") String clientMsgId);

        // /**
        // * Check if a message with given client message ID exists
        // *
        // * @param senderUserId sender user ID
        // * @param clientMsgId client message ID
        // * @return true if message exists
        // */
        // @Query("SELECT COUNT(m) > 0 FROM Message m WHERE " +
        // "m.senderUser.id = :senderUserId AND m.clientMsgId = :clientMsgId")
        // boolean existsBySenderAndClientMsgId(@Param("senderUserId") Long
        // senderUserId,
        // @Param("clientMsgId") String clientMsgId);
}
