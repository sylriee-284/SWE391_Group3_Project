package vn.group3.marketplace.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.concurrent.ExecutionException;

@Service
public class FirebaseChatService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseChatService.class);
    private static final String CONVERSATIONS_COLLECTION = "conversations";
    private static final String MESSAGES_COLLECTION = "messages";

    private final Firestore firestore;

    public FirebaseChatService(Firestore firestore) {
        this.firestore = firestore;
    }

    // Get or create conversation between two users
    public String getOrCreateConversation(Long userId1, Long userId2) throws ExecutionException, InterruptedException {
        // Create unique conversation ID from 2 user IDs (always sort to ensure
        // consistency)
        String conversationId = createConversationId(userId1, userId2);

        DocumentReference conversationRef = firestore.collection(CONVERSATIONS_COLLECTION).document(conversationId);
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

        messageRef.set(messageData).get();

        // Update last message in conversation
        updateConversationLastMessage(conversationId, content);

        logger.info("Message sent to conversation {}: {}", conversationId, messageRef.getId());
        return messageRef.getId();
    }

    // Get messages from conversation
    public List<Map<String, Object>> getMessages(String conversationId, int limit)
            throws ExecutionException, InterruptedException {

        Query query = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .limit(limit);

        QuerySnapshot querySnapshot = query.get().get();
        List<Map<String, Object>> messages = new ArrayList<>();

        for (DocumentSnapshot document : querySnapshot.getDocuments()) {
            Map<String, Object> message = document.getData();
            message.put("id", document.getId());
            messages.add(message);
        }

        return messages;
    }

    // Get conversations of user
    public List<Map<String, Object>> getUserConversations(Long userId)
            throws ExecutionException, InterruptedException {

        Query query = firestore
                .collection(CONVERSATIONS_COLLECTION)
                .whereArrayContains("participants", userId)
                .orderBy("lastMessageAt", Query.Direction.DESCENDING);

        QuerySnapshot querySnapshot = query.get().get();
        List<Map<String, Object>> conversations = new ArrayList<>();

        for (DocumentSnapshot document : querySnapshot.getDocuments()) {
            Map<String, Object> conversation = document.getData();
            conversation.put("id", document.getId());
            conversations.add(conversation);
        }

        return conversations;
    }

    // Mark messages as read
    public void markMessagesAsRead(String conversationId, Long userId)
            throws ExecutionException, InterruptedException {

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
    public int getUnreadMessageCount(Long userId) throws ExecutionException, InterruptedException {
        // Get all conversations of user
        List<Map<String, Object>> conversations = getUserConversations(userId);
        int unreadCount = 0;

        for (Map<String, Object> conversation : conversations) {
            String conversationId = (String) conversation.get("id");

            Query query = firestore
                    .collection(CONVERSATIONS_COLLECTION)
                    .document(conversationId)
                    .collection(MESSAGES_COLLECTION)
                    .whereEqualTo("receiverId", userId)
                    .whereEqualTo("read", false);

            QuerySnapshot querySnapshot = query.get().get();
            unreadCount += querySnapshot.size();
        }

        return unreadCount;
    }

    // Delete message
    public void deleteMessage(String conversationId, String messageId)
            throws ExecutionException, InterruptedException {

        firestore
                .collection(CONVERSATIONS_COLLECTION)
                .document(conversationId)
                .collection(MESSAGES_COLLECTION)
                .document(messageId)
                .delete()
                .get();

        logger.info("Deleted message {} from conversation {}", messageId, conversationId);
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