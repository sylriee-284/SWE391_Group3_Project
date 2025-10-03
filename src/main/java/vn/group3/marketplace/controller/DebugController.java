package vn.group3.marketplace.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/debug")
public class DebugController {

    @GetMapping("/page")
    public String debugPage() {
        return "debug-auth";
    }

    @GetMapping("/auth")
    @ResponseBody
    public String debugAuth(HttpSession session) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        StringBuilder sb = new StringBuilder();
        sb.append("=== DEBUG AUTHENTICATION ===\n");
        sb.append("Session ID: ").append(session.getId()).append("\n");
        sb.append("Authentication: ").append(auth != null ? auth.toString() : "null").append("\n");

        if (auth != null) {
            sb.append("Is Authenticated: ").append(auth.isAuthenticated()).append("\n");
            sb.append("Principal: ").append(auth.getPrincipal()).append("\n");
            sb.append("Authorities: ").append(auth.getAuthorities()).append("\n");
            sb.append("Name: ").append(auth.getName()).append("\n");
        }

        sb.append("Session Attributes:\n");
        session.getAttributeNames().asIterator().forEachRemaining(name -> {
            sb.append("  ").append(name).append(": ").append(session.getAttribute(name)).append("\n");
        });

        return sb.toString();
    }
}
