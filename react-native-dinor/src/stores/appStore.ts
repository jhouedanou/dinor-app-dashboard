/**
 * APP STORE - CONVERSION EXACTE PINIA → ZUSTAND
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - États identiques (loading, error, online)
 * - Actions identiques adaptées React Native
 * - Gestion réseau avec NetInfo
 * - Gestion erreurs identique
 */

import { create } from 'zustand';
import NetInfo from '@react-native-community/netinfo';

interface AppState {
  // État (identique Vue)
  loading: boolean;
  error: string | null;
  online: boolean;
  
  // Actions (identiques Vue adaptées RN)
  setLoading: (state: boolean) => void;
  setError: (errorMessage: string | null) => void;
  clearError: () => void;
  setOnlineStatus: (status: boolean) => void;
  initializeNetworkListeners: () => void;
}

export const useAppStore = create<AppState>((set, get) => ({
  // État initial (identique Vue)
  loading: false,
  error: null,
  online: true, // Assume online par défaut

  // Actions (identiques Vue)
  setLoading: (state: boolean) => {
    set({ loading: state });
  },

  setError: (errorMessage: string | null) => {
    set({ error: errorMessage });
  },

  clearError: () => {
    set({ error: null });
  },

  setOnlineStatus: (status: boolean) => {
    set({ online: status });
    console.log('🌐 [App Store] Statut réseau:', status ? 'En ligne' : 'Hors ligne');
  },

  // Initialiser les listeners réseau (adapté React Native avec NetInfo)
  initializeNetworkListeners: () => {
    // État initial
    NetInfo.fetch().then(state => {
      get().setOnlineStatus(state.isConnected ?? true);
    });

    // Écouter les changements
    const unsubscribe = NetInfo.addEventListener(state => {
      get().setOnlineStatus(state.isConnected ?? true);
    });

    // Retourner la fonction de cleanup (utilisable si nécessaire)
    return unsubscribe;
  },
}));

// Initialiser les listeners au chargement (identique Vue)
useAppStore.getState().initializeNetworkListeners();