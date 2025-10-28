package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.Gender;
import vn.group3.marketplace.service.UserService;
import vn.group3.marketplace.security.CustomUserDetails;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;

@Controller
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Refresh Spring Security Authentication Context with updated user data
     */
    private void refreshAuthenticationContext(String username) {
        try {
            System.out.println("🔄 Refreshing authentication context for: " + username);

            // Get fresh user data from database
            User freshUser = userService.getFreshUserByUsername(username);
            if (freshUser == null) {
                System.out.println("❌ Cannot refresh context: user not found");
                return;
            }

            // Create new CustomUserDetails with fresh data
            CustomUserDetails newUserDetails = new CustomUserDetails(freshUser);

            // Get current authentication
            Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();

            // Create new authentication with updated user details
            UsernamePasswordAuthenticationToken newAuth = new UsernamePasswordAuthenticationToken(
                    newUserDetails,
                    currentAuth.getCredentials(),
                    newUserDetails.getAuthorities());

            // Set the new authentication in SecurityContext
            SecurityContextHolder.getContext().setAuthentication(newAuth);

            System.out.println("✅ Authentication context refreshed successfully!");
            System.out.println("🔄 New context user: " + newUserDetails.getFullName());

        } catch (Exception e) {
            System.out.println("❌ Error refreshing authentication context: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Display user profile page
     */
    @GetMapping("/user/profile")
    public String showProfile(Model model) {
        try {
            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth.getName();

            // Get fresh user data from database (bypass any cache)
            User user = userService.getFreshUserByUsername(username);
            if (user == null) {
                model.addAttribute("errorMessage", "Không tìm thấy thông tin người dùng");
                return "redirect:/";
            }

            // Debug thông tin user (FRESH FROM DATABASE)
            System.out.println("=== FRESH USER DEBUG INFO ===");
            System.out.println("User ID: " + user.getId());
            System.out.println("Username: " + user.getUsername());
            System.out.println("Email: " + user.getEmail());
            System.out.println("Full Name: " + user.getFullName());
            System.out.println("Phone: " + user.getPhone());
            System.out.println("Date of Birth: " + user.getDateOfBirth());
            System.out.println("Gender: " + user.getGender());
            System.out.println("Status: " + user.getStatus());
            System.out.println("Balance: " + user.getBalance());
            System.out.println("Created At: " + user.getCreatedAt());
            System.out.println("============================");

            model.addAttribute("user", user);
            return "user/profile";

        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "Có lỗi xảy ra khi tải thông tin người dùng: " + e.getMessage());
            return "redirect:/";
        }
    }

    /**
     * Update user profile - SIMPLE APPROACH
     */
    @PostMapping("/user/profile/update")
    public String updateProfile(
            @RequestParam String email,
            @RequestParam String fullName,
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) String dateOfBirth,
            @RequestParam(required = false) String gender,
            Model model,
            RedirectAttributes redirectAttributes) {

        System.out.println("=== RECEIVED UPDATE REQUEST ===");
        System.out.println("Email: " + email);
        System.out.println("Full Name: " + fullName);
        System.out.println("Phone: " + phone);
        System.out.println("Date of Birth: " + dateOfBirth);
        System.out.println("Gender: " + gender);
        System.out.println("===============================");

        try {
            // Validate fullName - chỉ được chứa chữ cái, dấu cách và dấu tiếng Việt
            String namePattern = "^[a-zA-ZàáảãạầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵĂăĐđĨĩŨũƠơƯưÀÁẢÃẠẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ\\s]+$";
            if (fullName == null || fullName.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Lỗi tên: Tên không được để trống. Nguyên nhân: Bạn chưa nhập tên hoặc chỉ nhập khoảng trắng.");
                return "redirect:/user/profile";
            }
            if (!fullName.trim().matches(namePattern)) {
                // Phân tích nguyên nhân cụ thể
                String reason = "";
                if (fullName.trim().matches(".*\\d.*")) {
                    reason = "Tên chứa số (0-9)";
                } else if (fullName.trim().matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) {
                    reason = "Tên chứa ký tự đặc biệt (!@#$%^&*...)";
                } else {
                    reason = "Tên chứa ký tự không được phép";
                }
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Lỗi tên: Tên chỉ được chứa chữ cái và khoảng trắng. Nguyên nhân: " + reason
                                + ". Bạn đã nhập: \"" + fullName + "\"");
                return "redirect:/user/profile";
            }

            // Validate phone - chỉ được chứa số và độ dài 10-11 số
            if (phone != null && !phone.trim().isEmpty()) {
                String phonePattern = "^\\d{10,11}$";
                if (!phone.trim().matches(phonePattern)) {
                    // Phân tích nguyên nhân cụ thể
                    String reason = "";
                    int phoneLength = phone.trim().length();

                    if (phoneLength < 10) {
                        reason = "Số điện thoại quá ngắn (chỉ có " + phoneLength + " số, cần 10-11 số)";
                    } else if (phoneLength > 11) {
                        reason = "Số điện thoại quá dài (có " + phoneLength + " số, chỉ được phép 10-11 số)";
                    } else if (phone.trim().matches(".*[a-zA-Z].*")) {
                        reason = "Số điện thoại chứa chữ cái";
                    } else if (phone.trim().matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?\\s].*")) {
                        reason = "Số điện thoại chứa ký tự đặc biệt hoặc khoảng trắng";
                    } else {
                        reason = "Số điện thoại không đúng định dạng";
                    }

                    redirectAttributes.addFlashAttribute("errorMessage",
                            "Lỗi số điện thoại: Chỉ được chứa số và có độ dài từ 10-11 số. Nguyên nhân: " + reason
                                    + ". Bạn đã nhập: \"" + phone + "\"");
                    return "redirect:/user/profile";
                }
            }

            // Get current authenticated user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth.getName();

            // Debug current authentication context
            System.out.println("🔐 BEFORE UPDATE - Authentication Context:");
            if (auth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails currentUserDetails = (CustomUserDetails) auth.getPrincipal();
                System.out.println("🔐 Context User: " + currentUserDetails.getFullName());
                System.out.println("🔐 Context Email: " + currentUserDetails.getEmail());
            }

            // Get fresh user data for update (bypass cache)
            User user = userService.getFreshUserByUsername(username);
            if (user == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy thông tin người dùng");
                return "redirect:/user/profile";
            }

            // Debug BEFORE update
            System.out.println("=== USER BEFORE UPDATE ===");
            System.out.println("Email: " + user.getEmail());
            System.out.println("Full Name: " + user.getFullName());
            System.out.println("Phone: " + user.getPhone());
            System.out.println("Date of Birth: " + user.getDateOfBirth());
            System.out.println("Gender: " + user.getGender());
            System.out.println("==========================");

            // Update user information
            user.setEmail(email);
            user.setFullName(fullName);

            if (phone != null && !phone.trim().isEmpty()) {
                user.setPhone(phone.trim());
            }

            if (dateOfBirth != null && !dateOfBirth.trim().isEmpty()) {
                try {
                    LocalDate birthDate = LocalDate.parse(dateOfBirth);
                    user.setDateOfBirth(birthDate);
                } catch (Exception e) {
                    System.out.println("Error parsing date: " + e.getMessage());
                }
            }

            if (gender != null && !gender.trim().isEmpty()) {
                try {
                    Gender genderEnum = Gender.valueOf(gender.toUpperCase());
                    user.setGender(genderEnum);
                } catch (Exception e) {
                    System.out.println("Error parsing gender: " + e.getMessage());
                }
            }

            // Save updated user
            User updatedUser = userService.updateUser(user);

            // Debug AFTER update
            System.out.println("=== USER AFTER UPDATE ===");
            System.out.println("Email: " + updatedUser.getEmail());
            System.out.println("Full Name: " + updatedUser.getFullName());
            System.out.println("Phone: " + updatedUser.getPhone());
            System.out.println("Date of Birth: " + updatedUser.getDateOfBirth());
            System.out.println("Gender: " + updatedUser.getGender());
            System.out.println("=========================");

            // 🔄 REFRESH AUTHENTICATION CONTEXT với thông tin mới
            refreshAuthenticationContext(username);

            // Debug authentication context sau khi refresh
            Authentication newAuth = SecurityContextHolder.getContext().getAuthentication();
            System.out.println("🔐 AFTER REFRESH - Authentication Context:");
            if (newAuth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails newUserDetails = (CustomUserDetails) newAuth.getPrincipal();
                System.out.println("🔐 New Context User: " + newUserDetails.getFullName());
                System.out.println("🔐 New Context Email: " + newUserDetails.getEmail());
            }

            System.out.println("=== UPDATE SUCCESS - SIMPLE APPROACH ===");
            redirectAttributes.addFlashAttribute("successMessage", "Cập nhật thông tin thành công!");

            // Redirect to profile page with success message
            return "redirect:/user/profile";

        } catch (Exception e) {
            System.out.println("=== UPDATE ERROR ===");
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            return "redirect:/user/profile";
        }
    }
}
