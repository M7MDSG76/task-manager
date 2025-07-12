import Keycloak from 'keycloak-js';
import { createContext, useContext, useEffect, useState, useRef } from 'react';

export const AuthCtx = createContext(null);
export const useAuth = () => useContext(AuthCtx);

// Create Keycloak instance outside component to ensure singleton
let keycloakInstance = null;
let isInitializing = false;
let isInitialized = false;

const getKeycloakInstance = () => {
  if (!keycloakInstance) {
    keycloakInstance = new Keycloak({
      url: import.meta.env.VITE_KC_URL,
      realm: import.meta.env.VITE_KC_REALM,
      clientId: import.meta.env.VITE_KC_CLIENT,
    });
  }
  return keycloakInstance;
};

export default function KeycloakProvider({ children }) {
  const [kc] = useState(() => getKeycloakInstance());
  const [authenticated, setAuthenticated] = useState(false);
  const [initialized, setInitialized] = useState(isInitialized);

  useEffect(() => {
    if (!isInitialized && !isInitializing) {
      isInitializing = true;
      
      kc.init({ onLoad: 'login-required', checkLoginIframe: false })
        .then((auth) => {
          setAuthenticated(auth);
          setInitialized(true);
          isInitialized = true;
          isInitializing = false;
          
          // Set up token refresh interval only after successful init
          const refresh = setInterval(() => {
            kc.updateToken(30).catch(console.warn);
          }, 25 * 1000);

          // Store the interval ID for cleanup
          kc._refreshInterval = refresh;
        })
        .catch((error) => {
          console.error('Keycloak init failed:', error);
          isInitializing = false;
        });
    }

    // Cleanup function
    return () => {
      if (kc._refreshInterval) {
        clearInterval(kc._refreshInterval);
        kc._refreshInterval = null;
      }
    };
  }, [kc]);

  return (
    <AuthCtx.Provider value={{ kc, authenticated }}>
      {children}
    </AuthCtx.Provider>
  );
}
