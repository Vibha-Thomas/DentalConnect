package com.dentconnect.auth.controller;

import com.dentconnect.auth.dto.AuthRequest;
import com.dentconnect.auth.repository.RefreshTokenRepository;
import com.dentconnect.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.HashMap;
import java.util.Map;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    public void setup() {
        refreshTokenRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    public void testRegisterNewDentistSuccess() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setFirebaseToken("mock-dentist-token@example.com");
        request.setRole("DENTIST");
        request.setDisplayName("Dr. Test Dentist");
        request.setPhone("+919876543210");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", containsString("Account created")))
                .andExpect(jsonPath("$.data.email", is("mock-dentist-token@example.com")))
                .andExpect(jsonPath("$.data.displayName", is("Dr. Test Dentist")))
                .andExpect(jsonPath("$.data.role", is("DENTIST")))
                .andExpect(jsonPath("$.data.accessToken", notNullValue()))
                .andExpect(jsonPath("$.data.refreshToken", notNullValue()))
                .andExpect(jsonPath("$.data.newUser", is(true)));
    }

    @Test
    public void testLoginExistingUser() throws Exception {
        // First request to register
        AuthRequest registerRequest = new AuthRequest();
        registerRequest.setFirebaseToken("mock-existing-user@example.com");
        registerRequest.setRole("DENTIST");
        registerRequest.setDisplayName("Existing User");
        registerRequest.setPhone("+919998887770");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk());

        // Second request to login
        AuthRequest loginRequest = new AuthRequest();
        loginRequest.setFirebaseToken("mock-existing-user@example.com");
        loginRequest.setDisplayName("Existing User Updated"); // should update display name

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", containsString("Login successful")))
                .andExpect(jsonPath("$.data.displayName", is("Existing User Updated")))
                .andExpect(jsonPath("$.data.newUser", is(false)));
    }

    @Test
    public void testRegisterDuplicateEmailThrowsBadRequest() throws Exception {
        // Register first user
        AuthRequest user1 = new AuthRequest();
        user1.setFirebaseToken("mock-uid1:mock-user1@example.com");
        user1.setRole("DENTIST");
        user1.setDisplayName("User One");
        user1.setPhone("+911111111111");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user1)))
                .andExpect(status().isOk());

        // Register second user with same email but different Firebase token/UID
        AuthRequest user2 = new AuthRequest();
        user2.setFirebaseToken("mock-uid2:mock-user1@example.com");
        user2.setRole("DENTIST");
        user2.setDisplayName("User Two");
        user2.setPhone("+912222222222");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user2)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.message", containsString("Email already in use")));
    }

    @Test
    public void testRegisterDuplicatePhoneThrowsBadRequest() throws Exception {
        // Register first user
        AuthRequest user1 = new AuthRequest();
        user1.setFirebaseToken("mock-phone1@example.com");
        user1.setRole("DENTIST");
        user1.setDisplayName("User Phone One");
        user1.setPhone("+915555555555");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user1)))
                .andExpect(status().isOk());

        // Register second user with same phone but different Firebase token
        AuthRequest user2 = new AuthRequest();
        user2.setFirebaseToken("mock-phone2@example.com");
        user2.setRole("DENTIST");
        user2.setDisplayName("User Phone Two");
        user2.setPhone("+915555555555"); // Duplicate phone

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user2)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.message", containsString("Phone number already in use")));
    }

    @Test
    public void testRefreshTokenSuccess() throws Exception {
        // 1. Register and login
        AuthRequest request = new AuthRequest();
        request.setFirebaseToken("mock-refresh@example.com");
        request.setRole("DENTIST");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andReturn();

        String responseString = result.getResponse().getContentAsString();
        Map<String, Object> responseMap = objectMapper.readValue(responseString, Map.class);
        Map<String, String> data = (Map<String, String>) responseMap.get("data");
        String refreshToken = data.get("refreshToken");

        // 2. Refresh
        Map<String, String> refreshBody = new HashMap<>();
        refreshBody.put("refreshToken", refreshToken);

        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(refreshBody)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.accessToken", notNullValue()))
                .andExpect(jsonPath("$.data.refreshToken", notNullValue()))
                .andExpect(jsonPath("$.data.refreshToken", not(equalTo(refreshToken))));
    }

    @Test
    public void testLogoutSuccess() throws Exception {
        // 1. Register and login
        AuthRequest request = new AuthRequest();
        request.setFirebaseToken("mock-logout@example.com");
        request.setRole("DENTIST");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andReturn();

        String responseString = result.getResponse().getContentAsString();
        Map<String, Object> responseMap = objectMapper.readValue(responseString, Map.class);
        Map<String, String> data = (Map<String, String>) responseMap.get("data");
        String refreshToken = data.get("refreshToken");

        // 2. Logout
        Map<String, String> logoutBody = new HashMap<>();
        logoutBody.put("refreshToken", refreshToken);

        mockMvc.perform(post("/api/v1/auth/logout")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(logoutBody)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", containsString("Logged out successfully")));

        // 3. Verify refresh token is deleted
        assertFalse(refreshTokenRepository.findByToken(refreshToken).isPresent());
    }
}
