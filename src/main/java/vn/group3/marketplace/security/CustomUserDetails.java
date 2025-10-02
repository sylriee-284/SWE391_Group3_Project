package vn.group3.marketplace.security;

import java.math.BigDecimal;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.User;

import java.util.Collection;
import java.util.stream.Collectors;

public class CustomUserDetails implements UserDetails {

    private final User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    // Lấy danh sách quyền
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return user.getRoles().stream()
                .map(Role::getCode)
                .map(role -> (GrantedAuthority) () -> role.startsWith("ROLE_") ? role : "ROLE_" + role)
                .collect(Collectors.toSet());
    }

    // Lấy mật khẩu
    @Override
    public String getPassword() {
        return user.getPasswordHash();
    }

    // Lấy username
    @Override
    public String getUsername() {
        return user.getUsername();
    }

    // Trạng thái tài khoản
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return user.getStatus() != null && user.getStatus().name().equalsIgnoreCase("ACTIVE");
    }

    // ✅ Getter bổ sung cho JSP
    public BigDecimal getBalance() {
        return user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
    }

    public Long getId() {
        return user.getId();
    }

    public String getEmail() {
        return user.getEmail();
    }

    public User getUser() {
        return user;
    }
}
