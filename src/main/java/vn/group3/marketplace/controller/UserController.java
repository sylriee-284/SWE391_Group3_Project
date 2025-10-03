package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public String listUsers(Model model) {
        // model.addAttribute("users", userService.findAll());
        return "user/list";
    }

    @GetMapping("/{id}")
    public String getUser(@PathVariable Long id, Model model) {
        // model.addAttribute("user", userService.findById(id).orElseThrow());
        return "user/detail";
    }

    @PostMapping
    public String saveUser(@ModelAttribute User user) {
        // userService.save(user);
        return "redirect:/users";
    }
}
