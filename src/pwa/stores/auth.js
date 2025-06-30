import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useApiStore } from './api'

console.log('🚀 [Auth Store] Store d\'authentification chargé avec les modifications!')

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref(JSON.parse(localStorage.getItem('auth_user') || 'null'))
  const token = ref(localStorage.getItem('auth_token') || null)
  const loading = ref(false)
  const error = ref(null)

  // API store
  const apiStore = useApiStore()

  // Getters
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const userName = computed(() => user.value?.name || '')
  const userEmail = computed(() => user.value?.email || '')

  // Actions
  const setToken = (newToken) => {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('auth_token', newToken)
    } else {
      localStorage.removeItem('auth_token')
    }
  }

  const setUser = (userData) => {
    user.value = userData
    if (userData) {
      localStorage.setItem('auth_user', JSON.stringify(userData))
    } else {
      localStorage.removeItem('auth_user')
    }
  }

  const initAuth = () => {
    const savedToken = localStorage.getItem('auth_token')
    const savedUser = localStorage.getItem('auth_user')
    
    if (savedToken && savedUser) {
      token.value = savedToken
      try {
        user.value = JSON.parse(savedUser)
      } catch {
        // Si erreur de parsing, on clear tout
        clearAuth()
      }
    }
  }

  const clearAuth = () => {
    user.value = null
    token.value = null
    localStorage.removeItem('auth_token')
    localStorage.removeItem('auth_user')
  }

  const register = async (userData) => {
    loading.value = true
    error.value = null

    try {
      console.log('🔐 [Auth] Tentative d\'inscription avec les données:', userData)
      console.log('🔐 [Auth] Store API utilisé:', !!apiStore)
      
      const data = await apiStore.post('/auth/register', userData)
      
      console.log('📄 [Auth] Données de réponse:', data)

      if (data.success) {
        setToken(data.data.token)
        setUser(data.data.user)
        console.log('✅ [Auth] Inscription réussie pour:', data.data.user.name)
        return { success: true, user: data.data.user }
      } else {
        throw new Error(data.message || 'Erreur lors de l\'inscription')
      }
    } catch (err) {
      console.error('❌ [Auth] Erreur d\'inscription:', err.message)
      console.error('❌ [Auth] Stack trace:', err.stack)
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  const login = async (credentials) => {
    loading.value = true
    error.value = null

    try {
      console.log('🔐 [Auth] Tentative de connexion pour:', credentials.email)
      
      const data = await apiStore.post('/auth/login', credentials)
      
      console.log('📩 [Auth] Réponse de connexion:', { success: data.success })

      if (data.success) {
        setToken(data.data.token)
        setUser(data.data.user)
        console.log('✅ [Auth] Connexion réussie pour:', data.data.user.name)
        return { success: true, user: data.data.user }
      } else {
        throw new Error(data.message || 'Erreur lors de la connexion')
      }
    } catch (err) {
      console.error('❌ [Auth] Erreur de connexion:', err.message)
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  const logout = async () => {
    loading.value = true

    try {
      if (token.value) {
        await apiStore.post('/auth/logout')
      }
    } catch (err) {
      console.error('Erreur lors de la déconnexion:', err)
    } finally {
      clearAuth()
      loading.value = false
      console.log('👋 [Auth] Déconnexion terminée')
    }
  }

  const getProfile = async () => {
    if (!token.value) return null

    try {
      const data = await apiStore.get('/auth/profile')
      if (data.success) {
        setUser(data.data)
        return data.data
      }
    } catch (err) {
      console.error('Erreur lors de la récupération du profil:', err)
      if (err.message.includes('401')) {
        // Token invalide, on déconnecte
        clearAuth()
      }
    }

    return null
  }

  // Initialiser au chargement
  initAuth()

  return {
    // État
    user,
    token,
    loading,
    error,
    
    // Getters
    isAuthenticated,
    userName,
    userEmail,
    
    // Actions
    register,
    login,
    logout,
    getProfile,
    clearAuth,
    initAuth
  }
}) 