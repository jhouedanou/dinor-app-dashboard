/**
 * AUTH STORE - CONVERSION EXACTE PINIA → ZUSTAND
 * 
 * FIDÉLITÉ FONTCTIONNELLE :
 * - États identiques (user, token, loading, error)
 * - Actions identiques (login, register, logout, getProfile)
 * - Persistance AsyncStorage identique localStorage Vue
 * - Gestion erreurs et logs identiques
 */

import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import apiService from '@/services/api';

interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string;
}

interface AuthState {
  // État (identique Vue)
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
  
  // Getters (identique Vue)
  isAuthenticated: boolean;
  userName: string;
  userEmail: string;
  
  // Actions (identiques Vue)
  setToken: (token: string | null) => Promise<void>;
  setUser: (user: User | null) => Promise<void>;
  initAuth: () => Promise<void>;
  clearAuth: () => Promise<void>;
  register: (userData: { name: string; email: string; password: string }) => Promise<{ success: boolean; user?: User; error?: string }>;
  login: (credentials: { email: string; password: string }) => Promise<{ success: boolean; user?: User; error?: string }>;
  logout: () => Promise<void>;
  getProfile: () => Promise<User | null>;
}

console.log('🚀 [Auth Store] Store d\'authentification chargé avec les modifications!');

export const useAuthStore = create<AuthState>((set, get) => ({
  // État initial (identique Vue)
  user: null,
  token: null,
  loading: false,
  error: null,
  
  // Getters computés (identique Vue)
  get isAuthenticated() {
    const state = get();
    return !!state.token && !!state.user;
  },
  
  get userName() {
    const state = get();
    return state.user?.name || '';
  },
  
  get userEmail() {
    const state = get();
    return state.user?.email || '';
  },

  // Actions
  setToken: async (newToken: string | null) => {
    set({ token: newToken });
    if (newToken) {
      await AsyncStorage.setItem('auth_token', newToken);
    } else {
      await AsyncStorage.removeItem('auth_token');
    }
  },

  setUser: async (userData: User | null) => {
    set({ user: userData });
    if (userData) {
      await AsyncStorage.setItem('auth_user', JSON.stringify(userData));
    } else {
      await AsyncStorage.removeItem('auth_user');
    }
  },

  initAuth: async () => {
    try {
      const [savedToken, savedUser] = await Promise.all([
        AsyncStorage.getItem('auth_token'),
        AsyncStorage.getItem('auth_user')
      ]);
      
      if (savedToken && savedUser) {
        try {
          const parsedUser = JSON.parse(savedUser);
          if (parsedUser && typeof parsedUser === 'object') {
            set({ 
              token: savedToken, 
              user: parsedUser 
            });
            console.log('🔍 [Auth Store] Utilisateur restauré:', parsedUser);
          } else {
            console.warn('🔍 [Auth Store] Données utilisateur invalides');
            get().clearAuth();
          }
        } catch (error) {
          console.error('🔍 [Auth Store] Erreur parsing utilisateur:', error);
          // Si erreur de parsing, on clear tout (identique Vue)
          get().clearAuth();
        }
      }
    } catch (error) {
      console.error('🔍 [Auth Store] Erreur initAuth:', error);
    }
  },

  clearAuth: async () => {
    set({ 
      user: null, 
      token: null, 
      error: null 
    });
    await Promise.all([
      AsyncStorage.removeItem('auth_token'),
      AsyncStorage.removeItem('auth_user')
    ]);
  },

  register: async (userData: { name: string; email: string; password: string }) => {
    set({ loading: true, error: null });

    try {
      console.log('🔐 [Auth] Tentative d\'inscription avec les données:', userData);
      
      const data = await apiService.register(userData.name, userData.email, userData.password);
      
      console.log('📄 [Auth] Données de réponse:', data);

      if (data.success) {
        await get().setToken(data.data.token);
        await get().setUser(data.data.user);
        console.log('✅ [Auth] Inscription réussie pour:', data.data.user.name);
        return { success: true, user: data.data.user };
      } else {
        throw new Error(data.message || 'Erreur lors de l\'inscription');
      }
    } catch (err: any) {
      console.error('❌ [Auth] Erreur d\'inscription:', err.message);
      console.error('❌ [Auth] Stack trace:', err.stack);
      set({ error: err.message });
      return { success: false, error: err.message };
    } finally {
      set({ loading: false });
    }
  },

  login: async (credentials: { email: string; password: string }) => {
    const state = get();
    
    // Vérifier si l'utilisateur est déjà connecté (identique Vue)
    if (state.isAuthenticated) {
      console.log('✅ [Auth] Utilisateur déjà connecté, pas besoin de se reconnecter');
      return { success: true, user: state.user! };
    }

    set({ loading: true, error: null });

    try {
      console.log('🔐 [Auth] Tentative de connexion pour:', credentials.email);
      
      const data = await apiService.login(credentials.email, credentials.password);
      
      console.log('📩 [Auth] Réponse de connexion:', { success: data.success });

      if (data.success) {
        await get().setToken(data.data.token);
        await get().setUser(data.data.user);
        console.log('✅ [Auth] Connexion réussie pour:', data.data.user.name);
        return { success: true, user: data.data.user };
      } else {
        throw new Error(data.message || 'Erreur lors de la connexion');
      }
    } catch (err: any) {
      console.error('❌ [Auth] Erreur de connexion:', err.message);
      set({ error: err.message });
      return { success: false, error: err.message };
    } finally {
      set({ loading: false });
    }
  },

  logout: async () => {
    set({ loading: true });

    try {
      const state = get();
      if (state.token) {
        await apiService.logout();
      }
    } catch (err) {
      console.error('Erreur lors de la déconnexion:', err);
    } finally {
      await get().clearAuth();
      set({ loading: false });
      console.log('👋 [Auth] Déconnexion terminée');
    }
  },

  getProfile: async () => {
    const state = get();
    if (!state.token) return null;

    try {
      const data = await apiService.getProfile();
      if (data.success) {
        await get().setUser(data.data);
        return data.data;
      }
    } catch (err: any) {
      console.error('Erreur lors de la récupération du profil:', err);
      if (err.message.includes('401')) {
        // Token invalide, on déconnecte (identique Vue)
        get().clearAuth();
      }
    }

    return null;
  },
}));

// Initialiser au chargement (identique Vue)
useAuthStore.getState().initAuth();