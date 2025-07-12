package com.tam.taskmanager.service;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class SecurityService {

    public Boolean hasAccessToTasks(Authentication authentication) {
        log.info("Checking access for authentication: {}", authentication);
        if (authentication == null) {
            return false;
        }
        log.info("Checking access for user: {}", authentication.getName());
        if (authentication.getAuthorities() == null || authentication.getAuthorities().isEmpty()) {
            log.warn("User {} has no authorities", authentication.getName());
            return false;
        }

        log.debug("User {} has authorities: {}", authentication.getName(), authentication.getAuthorities());
        return authentication.getAuthorities().stream()
                .anyMatch(grantedAuthority -> grantedAuthority.getAuthority().equals("role_manage_task") ||
                        grantedAuthority.getAuthority().equals("role_admin"));
    }


    public String getUserName(Authentication authentication) {
        if (authentication == null) {
            return "Unknown";
        }
        if (authentication instanceof JwtAuthenticationToken) {
            JwtAuthenticationToken jwtAuth = (JwtAuthenticationToken) authentication;
            log.info("Retrieving username for user: {}, preferred_username: {}", jwtAuth.getName(), jwtAuth.getToken().getClaimAsString("preferred_username"));
            return jwtAuth.getToken().getClaimAsString("preferred_username");
        } else {
            log.info("Retrieving username for principal: {}", authentication.getName());
        }

        return authentication.getName();
    }

    public String getKeycloakUserId(Authentication authentication) {
        if (authentication == null) {
            return "Unknown";
        }
        if (authentication instanceof JwtAuthenticationToken) {
            JwtAuthenticationToken jwtAuth = (JwtAuthenticationToken) authentication;
            log.info("Retrieving user ID for user: {}, user_id: {}", jwtAuth.getName(), jwtAuth.getToken().getClaimAsString("sid"));
            return jwtAuth.getToken().getClaimAsString("sub");
        } else {
            log.info("Retrieving user ID for principal: {}", authentication.getName());
        }

        return authentication.getName();
    }

}
