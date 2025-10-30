package vn.group3.marketplace.service;

import com.google.cloud.firestore.*;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.dto.ConversationDTO;
import vn.group3.marketplace.dto.MessageDTO;
import vn.group3.marketplace.repository.UserRepository;

import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class FirebaseChatService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseChatService.class);
    private static final String CONVERSATIONS_COLLECTION = "conversations";
    private static final String MESSAGES_COLLECTION = "messages";
    private final SystemSettingService systemSettingService;
    private final UserRepository userRepository;

    private final Firestore firestore;

    public FirebaseChatService(Firestore firestore, SystemSettingService systemSettingService,
            UserRepository userRepository) {
        this.firestore = firestore;
        this.systemSettingService = systemSettingService;
        this.userRepository = userRepository;
    }

    // Get or create conversation between two users
    public String getOrCreateConversation(Long userId1, Long userId2) throws ExecutionException, InterruptedException {
        // Validate user IDs
        if (userId1 == null || userId2 == null) {
            throw new IllegalArgumentException("User IDs cannot be null");
        }

        if (userId1.equals(userId2)) {
            throw new IllegalArgumentException("User IDs cannot be the same");
        }

        // Create unique conversation ID from 2 user IDs (always sort to ensure
        // consistency)
        String conversationId = createConversationId(userId1, userId2);

        // Lấy tham chiếu đến document conversation trong Firestore
        DocumentReference conversationRef = firestore.collection(CONVERSATIONS_COLLECTION).document(conversationId);
        // Lấy snapshot của document để kiểm tra xem conversation đã tồn tại chưa
        DocumentSnapshot document = conversationRef.get().get();

        if (!document.exists()) {
            // Create new conversation
            Map<String, Object> conversationData = new HashMap<>();
            conversationData.put("participants", Arrays.asList(userId1, userId2));
            conversationData.put("createdAt", FieldValue.serverTimestamp());
            conversationData.put("lastMessageAt", FieldValue.serverTimestamp());
            conversationData.put("lastMessage", "");

            conversationRef.set(conversationData).get();
            logger.info("Created new conversation: {}", conversationId);
        }

        return conversationId;
    }

    // Send message to conversation
    public String sendMessage(String conversationId, Long senderId, Long receiverId, String content)
            throws ExecutionException, InterruptedException {
        // Validate user IDs
        if (senderId == null || receiverId == null) {
            throw new IllegalArgumentException("User IDs cannot be null");
        }

        if (senderId.equals(receiverId)) {
            throw new IllegalArgumentException("User IDs cannot be the same");
        }

        // Validate conversation ID
        if (conversationId == null || conversationId.isEmpty()) {
            throw new IllegalArgumentException("Conversation ID cannot be null or empty");
        }

        // Validate content
        if (content == null || content.isEmpty()) {
            throw new IllegalArgumentException("Content cannot be null or empty");
        }

        Map<String, Object> messageData = new HashMap<>();
        messageData.put("conversationId", conversationId);
        messageData.put("senderId", senderId);
        messageData.put("receiverId", receiverId);
        messageData.put("content", content);
        messageData.put("timestamp", FieldValue.serverTimestamp());
        messageData.put("read", false);

        // Add message to collection
        DocumentReference messageRef = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .document();
        // .document() không truyền id → Firestore tạo Auto-ID (phân phối ghi tốt, tránh
        // xung đột).

        messageRef.set(messageData).get();

        // Update last message in conversation
        updateConversationLastMessage(conversationId, content);

        logger.info("Message sent to conversation {}: {}", conversationId, messageRef.getId());
        return messageRef.getId();
    }

    // Get last conversation
    public ConversationDTO getLastConversation(Long userId) throws ExecutionException, InterruptedException {
        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        Query query = firestore.collection(CONVERSATIONS_COLLECTION)
                .whereArrayContains("participants", userId)
                .orderBy("lastMessageAt", Query.Direction.DESCENDING)
                .limit(1);

        QuerySnapshot querySnapshot = query.get().get();

        if (querySnapshot.isEmpty()) {
            return null;
        }

        DocumentSnapshot document = querySnapshot.getDocuments().get(0);
        return convertToConversationDTO(document, userId);
    }

    // Get conversation Partner ID
    public Long getConversationPartnerId(String conversationId, Long userId)
            throws ExecutionException, InterruptedException {
        DocumentReference conversationRef = firestore.collection(CONVERSATIONS_COLLECTION).document(conversationId);
        DocumentSnapshot document = conversationRef.get().get();

        if (!document.exists()) {
            throw new IllegalArgumentException("Conversation not found: " + conversationId);
        }

        Map<String, Object> conversation = document.getData();
        if (conversation == null) {
            throw new IllegalArgumentException("Conversation data is null");
        }

        @SuppressWarnings("unchecked")
        List<Long> participants = (List<Long>) conversation.get("participants");

        if (participants == null || participants.size() != 2) {
            throw new IllegalArgumentException("Invalid participants data");
        }

        // Find the partner (the other user that's not the current userId)
        for (Long participantId : participants) {
            if (!participantId.equals(userId)) {
                return participantId;
            }
        }

        throw new IllegalArgumentException(
                "User " + userId + " is not a participant in conversation " + conversationId);
    }

    // Get conversation Partner Name
    public String getConversationPartnerName(String conversationId, Long userId)
            throws ExecutionException, InterruptedException {
        // Validate conversation ID
        if (conversationId == null || conversationId.isEmpty()) {
            throw new IllegalArgumentException("Conversation ID cannot be null or empty");
        }

        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        // Get partner ID first
        Long partnerId = getConversationPartnerId(conversationId, userId);

        return getDisplayNameForUser(partnerId);
    }

    // Helper: Get display name for a user (store name > full name > username)
    private String getDisplayNameForUser(Long userId) {
        User user = userRepository.findById(userId).orElse(null);

        if (user == null) {
            return "Unknown User";
        }

        // If user has a store, return store name
        if (user.getSellerStore() != null && user.getSellerStore().getStoreName() != null) {
            return user.getSellerStore().getStoreName();
        }

        // Otherwise return fullName if available, else username
        if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
            return user.getFullName();
        }

        return user.getUsername();
    }

    // Converter: DocumentSnapshot to ConversationDTO
    private ConversationDTO convertToConversationDTO(DocumentSnapshot document, Long currentUserId) {
        Map<String, Object> data = document.getData();
        if (data == null) {
            return null;
        }

        ConversationDTO dto = ConversationDTO.builder()
                .id(document.getId())
                .participants((List<Long>) data.get("participants"))
                .createdAt(data.get("createdAt"))
                .lastMessageAt(data.get("lastMessageAt"))
                .lastMessage((String) data.get("lastMessage"))
                .build();

        // Enrich with partner info
        try {
            Long partnerId = getConversationPartnerId(document.getId(), currentUserId);
            String partnerName = getDisplayNameForUser(partnerId);
            dto.setConversationPartnerId(partnerId);
            dto.setConversationPartnerName(partnerName);
        } catch (Exception e) {
            logger.warn("Failed to get partner info for conversation {}: {}", document.getId(), e.getMessage());
            dto.setConversationPartnerName("Unknown");
            dto.setConversationPartnerId(null);
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
        }

        return dto;
    }

    // Converter: DocumentSnapshot to MessageDTO
    private MessageDTO convertToMessageDTO(DocumentSnapshot document) {
        Map<String, Object> data = document.getData();
        if (data == null) {
            return null;
        }

        return MessageDTO.builder()
                .id(document.getId())
                .conversationId((String) data.get("conversationId"))
                .senderId(data.get("senderId") != null ? ((Number) data.get("senderId")).longValue() : null)
                .receiverId(data.get("receiverId") != null ? ((Number) data.get("receiverId")).longValue() : null)
                .content((String) data.get("content"))
                .timestamp(data.get("timestamp"))
                .read((Boolean) data.get("read"))
                .build();
    }

    // Get messages from conversation
    public List<MessageDTO> getMessages(String conversationId, int limit)
            throws ExecutionException, InterruptedException {
        // Validate conversation ID
        if (conversationId == null || conversationId.isEmpty()) {
            throw new IllegalArgumentException("Conversation ID cannot be null or empty");
        }

        // Validate limit
        if (limit <= 0) {
            throw new IllegalArgumentException("Limit must be greater than 0");
        }

        Query query = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .limit(limit);

        QuerySnapshot querySnapshot = query.get().get();
        return querySnapshot.getDocuments().stream()
                .map(this::convertToMessageDTO)
                .collect(Collectors.toList());
    }

    public List<MessageDTO> getOlderMessages(String conversationId, int pageSize,
            DocumentSnapshot lastDoc)
            throws ExecutionException, InterruptedException {
        // Validate conversation ID
        if (conversationId == null || conversationId.isEmpty()) {
            throw new IllegalArgumentException("Conversation ID cannot be null or empty");
        }

        // Validate page size
        if (pageSize <= 0) {
            throw new IllegalArgumentException("Page size must be greater than 0");
        }

        // Validate last document
        if (lastDoc == null) {
            throw new IllegalArgumentException("Last document cannot be null");
        }

        // Validate last document timestamp
        if (lastDoc.get("timestamp") == null) {
            throw new IllegalArgumentException("Last document timestamp cannot be null");
        }

        // Validate last document id
        if (lastDoc.getId() == null || lastDoc.getId().isEmpty()) {
            throw new IllegalArgumentException("Last document id cannot be null or empty");
        }

        Query query = firestore.collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .orderBy(FieldPath.documentId(), Query.Direction.DESCENDING)
                .startAfter(
                        lastDoc.get("timestamp"), // Giá trị của field đã order
                        lastDoc.getId() // documentId cho order phụ (đảm bảo unique)
                )
                .limit(pageSize);

        QuerySnapshot querySnapshot = query.get().get();
        return querySnapshot.getDocuments().stream()
                .map(this::convertToMessageDTO)
                .collect(Collectors.toList());
    }

    // Get conversations of user
    public List<ConversationDTO> getUserConversations(Long userId)
            throws ExecutionException, InterruptedException {

        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        Query query = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .whereArrayContains("participants", userId)
                .orderBy("lastMessageAt", Query.Direction.DESCENDING);

        QuerySnapshot querySnapshot = query.get().get();
        return querySnapshot.getDocuments().stream()
                .map(doc -> convertToConversationDTO(doc, userId))
                .collect(Collectors.toList());
    }

    // Mark messages as read
    public void markMessagesAsRead(String conversationId, Long userId)
            throws ExecutionException, InterruptedException {

        // Validate conversation ID
        if (conversationId == null || conversationId.isEmpty()) {
            throw new IllegalArgumentException("Conversation ID cannot be null or empty");
        }

        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        Query query = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .whereEqualTo("receiverId", userId)
                .whereEqualTo("read", false);

        QuerySnapshot querySnapshot = query.get().get();

        WriteBatch batch = firestore.batch();
        for (DocumentSnapshot document : querySnapshot.getDocuments()) {
            batch.update(document.getReference(), "read", true);
        }
        batch.commit().get();

        logger.info("Marked messages as read in conversation {} for user {}", conversationId, userId);
    }

    // Get unread message count
    public long getUnreadMessageCount(Long userId) throws ExecutionException, InterruptedException {
        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        AggregateQuery countAgg = firestore
                .collectionGroup(MESSAGES_COLLECTION) // conversations/*/messages
                .whereEqualTo("receiverId", userId)
                .whereEqualTo("read", false)
                .count();

        AggregateQuerySnapshot snap = countAgg.get().get();
        return snap.getCount(); // long
    }

    // Send welcome message to user
    @Async("chatTaskExecutor")
    public void sendWelcomeMessageAsync(Long userId) throws ExecutionException, InterruptedException {
        // Validate user ID
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        // Get admin user ID
        Long adminUserId = systemSettingService.getAdminUserId();

        // Create or get conversation between admin and new user
        String conversationId = getOrCreateConversation(adminUserId, userId);

        // Admin sends welcome message to new user
        String messageId = sendMessage(conversationId, adminUserId, userId,
                "MMO Market System rất vui được đồng hành cùng bạn trên hành trình kiếm tiền online an toàn và minh bạch. Chúng tôi cam kết cung cấp sản phẩm/dịch vụ chất lượng, giao dịch nhanh chóng và hỗ trợ tận tâm. Nếu cần trợ giúp, đừng ngần ngại liên hệ với chúng tôi. Chúc bạn trải nghiệm mua bán thật hiệu quả tại MMO Market System!");
        logger.info("Sent welcome message to user {} with messageId {}", userId, messageId);
    }

    // Helper methods

    private String createConversationId(Long userId1, Long userId2) {
        List<Long> ids = Arrays.asList(userId1, userId2);
        Collections.sort(ids);
        return ids.get(0) + "_" + ids.get(1);
    }

    private void updateConversationLastMessage(String conversationId, String lastMessage) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("lastMessage", lastMessage);
        updates.put("lastMessageAt", FieldValue.serverTimestamp());

        firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .update(updates);
    }
}