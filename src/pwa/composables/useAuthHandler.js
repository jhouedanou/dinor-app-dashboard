import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'

// État global pour les modales d'authentification
const showAuthModal = ref(false)
const authModalMessage = ref('')

export function useAuthHandler() {
  const authStore = useAuthStore()

  // Fonction pour gérer les erreurs d'authentification
  const handleAuthError = (error, context = '') => {
    console.warn('🔐 [Auth Handler] Erreur d\'authentification détectée:', error)
    
    // Effacer l'authentification expirée
    if (authStore.token && error.status === 401) {
      authStore.clearAuth()
    }
    
    // Préparer le message personnalisé selon le contexte
    let message = ''
    
    if (error.type === 'AUTH_REQUIRED') {
      message = error.message
    } else if (error.status === 401) {
      if (context) {
        message = `Pour ${context}, vous devez être connecté. Veuillez vous connecter ou créer un compte.`
      } else {
        message = 'Vous devez être connecté pour effectuer cette action. Veuillez vous connecter ou créer un compte.'
      }
    } else {
      message = error.message || 'Une erreur s\'est produite lors de l\'authentification.'
    }
    
    // Afficher la modale d'authentification avec le message
    showAuthModal.value = true
    authModalMessage.value = message
    
    return {
      shouldShowModal: true,
      message
    }
  }

  // Fonction pour gérer les actions nécessitant une authentification
  const requireAuth = (action, context = '') => {
    if (!authStore.isAuthenticated) {
      const message = context 
        ? `Pour ${context}, vous devez être connecté. Veuillez vous connecter ou créer un compte.`
        : 'Vous devez être connecté pour effectuer cette action. Veuillez vous connecter ou créer un compte.'
      
      showAuthModal.value = true
      authModalMessage.value = message
      
      return false
    }
    
    return true
  }

  // Fonction pour fermer la modale d'authentification
  const closeAuthModal = () => {
    showAuthModal.value = false
    authModalMessage.value = ''
  }

  // Fonction pour gérer l'authentification réussie
  const handleAuthSuccess = (user) => {
    console.log('✅ [Auth Handler] Authentification réussie:', user)
    closeAuthModal()
  }

  // Fonction helper pour les composants qui ont besoin d'authentification
  const withAuth = async (callback, context = '') => {
    if (!requireAuth(callback, context)) {
      return false
    }
    
    try {
      return await callback()
    } catch (error) {
      if (error.status === 401 || error.type === 'AUTH_REQUIRED') {
        handleAuthError(error, context)
        return false
      }
      throw error
    }
  }

  return {
    // État
    showAuthModal,
    authModalMessage,
    
    // Méthodes
    handleAuthError,
    requireAuth,
    closeAuthModal,
    handleAuthSuccess,
    withAuth
  }
}

// Composable global pour une utilisation simple
export function useGlobalAuth() {
  return useAuthHandler()
}