// package vn.group3.marketplace.service;

// import com.google.cloud.firestore.*;
// import org.springframework.scheduling.annotation.Async;
// import org.springframework.stereotype.Service;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;
// import vn.group3.marketplace.domain.entity.User;
// import vn.group3.marketplace.dto.ConversationDTO;
// import vn.group3.marketplace.dto.MessageDTO;
// import vn.group3.marketplace.repository.UserRepository;
// import static vn.group3.marketplace.util.ValidationUtils.*;

// import java.util.*;
// import java.util.concurrent.ExecutionException;
// import java.util.stream.Collectors;
// import java.time.*;
// import java.time.format.DateTimeFormatter;

// @Service
// public class FirebaseChatService {

// private static final Logger logger =
// LoggerFactory.getLogger(FirebaseChatService.class);

// // Collection names
// private static final String CONVERSATIONS_COLLECTION = "conversations";
// private static final String MESSAGES_COLLECTION = "messages";

// // Field names
// private static final String FIELD_PARTICIPANTS = "participants";
// private static final String FIELD_CREATED_AT = "createdAt";
// private static final String FIELD_LAST_MESSAGE_AT = "lastMessageAt";
// private static final String FIELD_LAST_MESSAGE = "lastMessage";
// private static final String FIELD_CONVERSATION_ID = "conversationId";
// private static final String FIELD_SENDER_ID = "senderId";
// private static final String FIELD_RECEIVER_ID = "receiverId";
// private static final String FIELD_CONTENT = "content";
// private static final String FIELD_TIMESTAMP = "timestamp";
// private static final String FIELD_READ = "read";

// private static final DateTimeFormatter CHAT_DATE_FORMATTER =
// DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");

// private String formatTimestamp(Object ts) {
// if (ts == null)
// return "";
// if (ts instanceof com.google.cloud.Timestamp) {
// Instant instant = ((com.google.cloud.Timestamp) ts).toDate().toInstant();
// LocalDateTime ldt = instant.atZone(ZoneId.systemDefault()).toLocalDateTime();
// return CHAT_DATE_FORMATTER.format(ldt);
// }
// if (ts instanceof Date) {
// LocalDateTime ldt = ((Date)
// ts).toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
// return CHAT_DATE_FORMATTER.format(ldt);
// }
// return ts.toString();
// }

// private final Firestore firestore;
// private final SystemSettingService systemSettingService;
// private final UserRepository userRepository;

// public FirebaseChatService(Firestore firestore, SystemSettingService
// systemSettingService,
// UserRepository userRepository) {
// this.firestore = firestore;
// this.systemSettingService = systemSettingService;
// this.userRepository = userRepository;
// }

// // Get or create conversation between two users
// public String getOrCreateConversation(Long userId1, Long userId2) throws
// ExecutionException, InterruptedException {
// validateUserId(userId1, "userId1");
// validateUserId(userId2, "userId2");

// if (userId1.equals(userId2)) {
// throw new IllegalArgumentException("User IDs cannot be the same");
// }

// String conversationId = createConversationId(userId1, userId2);
// DocumentReference conversationRef =
// firestore.collection(CONVERSATIONS_COLLECTION).document(conversationId);
// DocumentSnapshot document = conversationRef.get().get();

// if (!document.exists()) {
// createNewConversation(conversationRef, userId1, userId2);
// logger.info("Created new conversation: {}", conversationId);
// }

// return conversationId;
// }

// // Get last conversation for a user
// public ConversationDTO getLastConversation(Long userId) throws
// ExecutionException, InterruptedException {
// validateUserId(userId, "userId");

// Query query = firestore.collection(CONVERSATIONS_COLLECTION)
// .whereArrayContains(FIELD_PARTICIPANTS, userId)
// .orderBy(FIELD_LAST_MESSAGE_AT, Query.Direction.DESCENDING)
// .limit(1);

// QuerySnapshot querySnapshot = query.get().get();

// if (querySnapshot.isEmpty()) {
// return null;
// }

// return convertToConversationDTO(querySnapshot.getDocuments().get(0), userId);
// }

// // Get all conversations for a user
// public List<ConversationDTO> getUserConversations(Long userId) throws
// ExecutionException, InterruptedException {
// validateUserId(userId, "userId");

// Query query = firestore.collection(CONVERSATIONS_COLLECTION)
// .whereArrayContains(FIELD_PARTICIPANTS, userId)
// .orderBy(FIELD_LAST_MESSAGE_AT, Query.Direction.DESCENDING);

// QuerySnapshot querySnapshot = query.get().get();
// return querySnapshot.getDocuments().stream()
// .map(doc -> convertToConversationDTO(doc, userId))
// .collect(Collectors.toList());
// }

// // Get the partner's user ID from a conversation
// public Long getConversationPartnerId(String conversationId, Long userId)
// throws ExecutionException, InterruptedException {
// DocumentReference conversationRef =
// firestore.collection(CONVERSATIONS_COLLECTION).document(conversationId);
// DocumentSnapshot document = conversationRef.get().get();

// if (!document.exists()) {
// throw new IllegalArgumentException("Conversation not found: " +
// conversationId);
// }

// Map<String, Object> conversation = document.getData();
// if (conversation == null) {
// throw new IllegalArgumentException("Conversation data is null");
// }

// @SuppressWarnings("unchecked")
// List<Long> participants = (List<Long>) conversation.get(FIELD_PARTICIPANTS);

// if (participants == null || participants.size() != 2) {
// throw new IllegalArgumentException("Invalid participants data");
// }

// return participants.stream()
// .filter(id -> !id.equals(userId))
// .findFirst()
// .orElseThrow(() -> new IllegalArgumentException(
// "User " + userId + " is not a participant in conversation " +
// conversationId));
// }

// // Get the display name of the conversation partner
// public String getConversationPartnerName(String conversationId, Long userId)
// throws ExecutionException, InterruptedException {
// validateConversationId(conversationId);
// validateUserId(userId, "userId");

// Long partnerId = getConversationPartnerId(conversationId, userId);
// return getDisplayNameForUser(partnerId);
// }

// // Get or create conversation by partner name (storeName/fullName/username)
// public String getOrCreateConversationByPartnerName(Long userId, String
// partnerName)
// throws ExecutionException, InterruptedException {
// Optional<User> userOpt = userRepository.findByUsername(partnerName);
// if (userOpt.isEmpty()) {
// throw new IllegalArgumentException("Không tìm thấy user với username: " +
// partnerName);
// }
// User partner = userOpt.get();
// return getOrCreateConversation(userId, partner.getId());
// }

// // ==================== MESSAGE OPERATIONS ====================

// // Send message to conversation
// public String sendMessage(String conversationId, Long senderId, Long
// receiverId, String content)
// throws ExecutionException, InterruptedException {
// validateConversationId(conversationId);
// validateUserId(senderId, "senderId");
// validateUserId(receiverId, "receiverId");
// validateContent(content);

// if (senderId.equals(receiverId)) {
// throw new IllegalArgumentException("Sender and receiver cannot be the same");
// }

// Map<String, Object> messageData = createMessageData(conversationId, senderId,
// receiverId, content);

// DocumentReference messageRef = firestore
// .collection(CONVERSATIONS_COLLECTION)
// .document(conversationId)
// .collection(MESSAGES_COLLECTION)
// .document();

// messageRef.set(messageData).get();
// updateConversationLastMessage(conversationId, content);

// logger.info("Message sent to conversation {}: {}", conversationId,
// messageRef.getId());
// return messageRef.getId();
// }

// // Get messages from a conversation
// public List<MessageDTO> getMessages(String conversationId, int limit)
// throws ExecutionException, InterruptedException {
// validateConversationId(conversationId);
// validateLimit(limit, "limit");

// Query query = firestore
// .collection(CONVERSATIONS_COLLECTION)
// .document(conversationId)
// .collection(MESSAGES_COLLECTION)
// .orderBy(FIELD_TIMESTAMP, Query.Direction.DESCENDING)
// .limit(limit);

// QuerySnapshot querySnapshot = query.get().get();
// return querySnapshot.getDocuments().stream()
// .map(this::convertToMessageDTO)
// .collect(Collectors.toList());
// }

// // Get older messages from a conversation (pagination)
// public List<MessageDTO> getOlderMessages(String conversationId, int pageSize,
// DocumentSnapshot lastDoc)
// throws ExecutionException, InterruptedException {
// validateConversationId(conversationId);
// validateLimit(pageSize, "pageSize");
// validateLastDocument(lastDoc, FIELD_TIMESTAMP);

// Query query = firestore.collection(CONVERSATIONS_COLLECTION)
// .document(conversationId)
// .collection(MESSAGES_COLLECTION)
// .orderBy(FIELD_TIMESTAMP, Query.Direction.DESCENDING)
// .orderBy(FieldPath.documentId(), Query.Direction.DESCENDING)
// .startAfter(lastDoc.get(FIELD_TIMESTAMP), lastDoc.getId())
// .limit(pageSize);

// QuerySnapshot querySnapshot = query.get().get();
// return querySnapshot.getDocuments().stream()
// .map(this::convertToMessageDTO)
// .collect(Collectors.toList());
// }

// // Mark all messages in a conversation as read for a user
// public void markMessagesAsRead(String conversationId, Long userId)
// throws ExecutionException, InterruptedException {
// validateConversationId(conversationId);
// validateUserId(userId, "userId");

// Query query = firestore
// .collection(CONVERSATIONS_COLLECTION)
// .document(conversationId)
// .collection(MESSAGES_COLLECTION)
// .whereEqualTo(FIELD_RECEIVER_ID, userId)
// .whereEqualTo(FIELD_READ, false);

// QuerySnapshot querySnapshot = query.get().get();

// WriteBatch batch = firestore.batch();
// for (DocumentSnapshot document : querySnapshot.getDocuments()) {
// batch.update(document.getReference(), FIELD_READ, true);
// }
// batch.commit().get();

// logger.info("Marked messages as read in conversation {} for user {}",
// conversationId, userId);
// }

// // Get the count of unread messages for a user
// public long getUnreadMessageCount(Long userId) throws ExecutionException,
// InterruptedException {
// validateUserId(userId, "userId");

// AggregateQuery countAgg = firestore
// .collectionGroup(MESSAGES_COLLECTION)
// .whereEqualTo(FIELD_RECEIVER_ID, userId)
// .whereEqualTo(FIELD_READ, false)
// .count();

// AggregateQuerySnapshot snap = countAgg.get().get();
// return snap.getCount();
// }

// // Send a welcome message to a new user asynchronously
// @Async("chatTaskExecutor")
// public void sendWelcomeMessageAsync(Long userId) throws ExecutionException,
// InterruptedException {
// validateUserId(userId, "userId");

// Long adminUserId = systemSettingService.getAdminUserId();
// String conversationId = getOrCreateConversation(adminUserId, userId);

// String welcomeMessage = "MMO Market System rất vui được đồng hành cùng bạn
// trên hành trình kiếm tiền online an toàn và minh bạch. "
// + "Chúng tôi cam kết cung cấp sản phẩm/dịch vụ chất lượng, giao dịch nhanh
// chóng và hỗ trợ tận tâm. "
// + "Nếu cần trợ giúp, đừng ngần ngại liên hệ với chúng tôi. "
// + "Chúc bạn trải nghiệm mua bán thật hiệu quả tại MMO Market System!";

// String messageId = sendMessage(conversationId, adminUserId, userId,
// welcomeMessage);
// logger.info("Sent welcome message to user {} with messageId {}", userId,
// messageId);
// }

// // Convert Firestore DocumentSnapshot to ConversationDTO
// private ConversationDTO convertToConversationDTO(DocumentSnapshot document,
// Long currentUserId) {
// Map<String, Object> data = document.getData();
// if (data == null) {
// return null;
// }

// @SuppressWarnings("unchecked")
// ConversationDTO dto = ConversationDTO.builder()
// .id(document.getId())
// .participants((List<Long>) data.get(FIELD_PARTICIPANTS))
// .createdAt(formatTimestamp(data.get(FIELD_CREATED_AT)))
// .lastMessageAt(formatTimestamp(data.get(FIELD_LAST_MESSAGE_AT)))
// .lastMessage((String) data.get(FIELD_LAST_MESSAGE))
// .build();

// enrichConversationWithPartnerInfo(dto, document.getId(), currentUserId);
// return dto;
// }

// // Convert Firestore DocumentSnapshot to MessageDTO
// private MessageDTO convertToMessageDTO(DocumentSnapshot document) {
// Map<String, Object> data = document.getData();
// if (data == null) {
// return null;
// }

// return MessageDTO.builder()
// .id(document.getId())
// .conversationId((String) data.get(FIELD_CONVERSATION_ID))
// .senderId(getLongValue(data.get(FIELD_SENDER_ID)))
// .receiverId(getLongValue(data.get(FIELD_RECEIVER_ID)))
// .content((String) data.get(FIELD_CONTENT))
// .timestamp(formatTimestamp(data.get(FIELD_TIMESTAMP)))
// .read((Boolean) data.get(FIELD_READ))
// .build();
// }

// private void enrichConversationWithPartnerInfo(ConversationDTO dto, String
// conversationId, Long currentUserId) {
// try {
// Long partnerId = getConversationPartnerId(conversationId, currentUserId);
// String partnerName = getDisplayNameForUser(partnerId);
// dto.setConversationPartnerId(partnerId);
// dto.setConversationPartnerName(partnerName);
// // Set partnerUsername
// User user = userRepository.findById(partnerId).orElse(null);
// if (user != null) {
// dto.setPartnerUsername(user.getUsername());
// }
// } catch (Exception e) {
// logger.warn("Failed to get partner info for conversation {}: {}",
// conversationId, e.getMessage());
// dto.setConversationPartnerName("Unknown");
// dto.setConversationPartnerId(null);
// dto.setPartnerUsername(null);
// if (e instanceof InterruptedException) {
// Thread.currentThread().interrupt();
// }
// }
// }

// private String getDisplayNameForUser(Long userId) {
// User user = userRepository.findById(userId).orElse(null);

// if (user == null) {
// return "Unknown User";
// }

// if (user.getSellerStore() != null && user.getSellerStore().getStoreName() !=
// null) {
// return user.getSellerStore().getStoreName();
// }

// if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
// return user.getFullName();
// }

// return user.getUsername();
// }

// private String createConversationId(Long userId1, Long userId2) {
// List<Long> ids = Arrays.asList(userId1, userId2);
// Collections.sort(ids);
// return ids.get(0) + "_" + ids.get(1);
// }

// private void createNewConversation(DocumentReference conversationRef, Long
// userId1, Long userId2)
// throws ExecutionException, InterruptedException {
// Map<String, Object> conversationData = new HashMap<>();
// conversationData.put(FIELD_PARTICIPANTS, Arrays.asList(userId1, userId2));
// conversationData.put(FIELD_CREATED_AT, FieldValue.serverTimestamp());
// conversationData.put(FIELD_LAST_MESSAGE_AT, FieldValue.serverTimestamp());
// conversationData.put(FIELD_LAST_MESSAGE, "");
// conversationRef.set(conversationData).get();
// }

// private Map<String, Object> createMessageData(String conversationId, Long
// senderId, Long receiverId,
// String content) {
// Map<String, Object> messageData = new HashMap<>();
// messageData.put(FIELD_CONVERSATION_ID, conversationId);
// messageData.put(FIELD_SENDER_ID, senderId);
// messageData.put(FIELD_RECEIVER_ID, receiverId);
// messageData.put(FIELD_CONTENT, content);
// messageData.put(FIELD_TIMESTAMP, FieldValue.serverTimestamp());
// messageData.put(FIELD_READ, false);
// return messageData;
// }

// private void updateConversationLastMessage(String conversationId, String
// lastMessage) {
// Map<String, Object> updates = new HashMap<>();
// updates.put(FIELD_LAST_MESSAGE, lastMessage);
// updates.put(FIELD_LAST_MESSAGE_AT, FieldValue.serverTimestamp());

// firestore.collection(CONVERSATIONS_COLLECTION)
// .document(conversationId)
// .update(updates);
// }

// private Long getLongValue(Object value) {
// return value != null ? ((Number) value).longValue() : null;
// }
// }
