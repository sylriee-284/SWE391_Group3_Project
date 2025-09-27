package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Conversation;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Long> {

}
