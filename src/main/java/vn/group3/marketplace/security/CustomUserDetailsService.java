package vn.group3.marketplace.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.UserRepository;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByUsername(username) // trả về Optional<User>
                .map(CustomUserDetails::new) // ✅ constructor nhận entity User
                .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + username));
    }
}
