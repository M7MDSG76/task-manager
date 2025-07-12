package com.tam.taskmanager.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import com.tam.taskmanager.entity.UserEntity;
import com.tam.taskmanager.repository.UserRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UserService {

    @Autowired
    SecurityService securityService;

    @Autowired
    UserRepository userRepository;

    public Long getUserId(Authentication authentication) {
        if (authentication != null && securityService.getKeycloakUserId(authentication) != null) {
            String keycloakId = securityService.getKeycloakUserId(authentication);
            log.debug("Looking up user with keycloak ID: {}", keycloakId);

            return userRepository.findByKeycloakUserId(keycloakId)
                    .map(UserEntity::getId)
                    .orElseGet(() -> createNewUser(authentication));
        }

        log.error("Authentication is null or invalid");
        throw new RuntimeException("Invalid authentication");
    }

    private Long createNewUser(Authentication authentication) {
        log.info("Creating new user as no existing user found for authentication: {}", authentication.getName());
        // Create a new UserEntity and save it to the database
        // Assuming you have a method to create a new user entity
        // This is a placeholder, you might want to set other properties as needed
        String keycloakId = securityService.getKeycloakUserId(authentication);
        if (keycloakId == null) {
            log.error("Keycloak user ID is null for authentication: {}", authentication.getName());
            throw new RuntimeException("Keycloak user ID is null");
        }
        log.info("Creating new user for keycloak ID: {}", keycloakId);
        // Create a new UserEntity with the keycloak ID and other necessary details
        UserEntity newUser = new UserEntity();
        newUser.setKeycloakUserId(keycloakId);
        newUser.setUserName(securityService.getUserName(authentication));
        log.info("Creating new user for keycloak ID: {}", keycloakId);
        // You might want to set other user properties here from the authentication
        // object
        UserEntity savedUser = userRepository.saveAndFlush(newUser);
        log.info("Created new user with ID: {} for keycloak ID: {}", savedUser.getId(), keycloakId);
        return savedUser.getId();
    }
}
