package com.example.online_courier.controller;

import com.example.online_courier.entity.User;
import com.example.online_courier.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public TestController(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }

    @GetMapping("/check-password")
    public ResponseEntity<Map<String, Object>> checkPassword(
            @RequestParam String email,
            @RequestParam String password) {
        
        Map<String, Object> result = new HashMap<>();
        
        User user = userRepository.findByEmail(email).orElse(null);
        
        if (user == null) {
            result.put("found", false);
            result.put("message", "User not found");
            return ResponseEntity.ok(result);
        }
        
        result.put("found", true);
        result.put("email", user.getEmail());
        result.put("role", user.getRole());
        result.put("status", user.getStatus());
        result.put("passwordMatches", passwordEncoder.matches(password, user.getPassword()));
        result.put("storedHash", user.getPassword().substring(0, 20) + "...");
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/generate-hash")
    public ResponseEntity<Map<String, String>> generateHash(@RequestParam String password) {
        Map<String, String> result = new HashMap<>();
        String hash = passwordEncoder.encode(password);
        result.put("password", password);
        result.put("hash", hash);
        result.put("verified", String.valueOf(passwordEncoder.matches(password, hash)));
        return ResponseEntity.ok(result);
    }

    @PostMapping("/reset-admin-password")
    public ResponseEntity<Map<String, String>> resetAdminPassword(@RequestParam String newPassword) {
        User admin = userRepository.findByEmail("admin@ocms.com")
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        
        String encodedPassword = passwordEncoder.encode(newPassword);
        admin.setPassword(encodedPassword);
        userRepository.save(admin);
        
        Map<String, String> result = new HashMap<>();
        result.put("message", "Admin password updated successfully");
        result.put("testLogin", "Try logging in with 'admin' / '" + newPassword + "'");
        result.put("passwordMatches", String.valueOf(passwordEncoder.matches(newPassword, encodedPassword)));
        
        return ResponseEntity.ok(result);
    }
}
