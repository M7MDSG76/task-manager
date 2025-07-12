// src/auth/useAuth.js
import { useContext } from 'react';
import { AuthCtx } from './KeycloakProvider';   // make sure AuthCtx is exported

/**
 * Hook returning:
 *   kc            → the Keycloak instance
 *   authenticated → boolean
 *   token         → raw JWT
 *   user          → tokenParsed shortcut (username, roles, etc.)
 */
export default function useAuth() {
  const ctx = useContext(AuthCtx);
  if (!ctx) throw new Error('useAuth must be used inside <KeycloakProvider>');
  const { kc, authenticated } = ctx;
  return {
    kc,
    authenticated,
    token: kc?.token,
    user: kc?.tokenParsed,     // preferred_username, email, roles …
  };
}
