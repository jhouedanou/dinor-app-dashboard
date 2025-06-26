import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAppStore = defineStore('app', () => {
  // State
  const loading = ref(false)
  const error = ref(null)
  const online = ref(navigator.onLine)
  const installPromptEvent = ref(null)
  const isInstalled = ref(false)

  // Actions
  function setLoading(state) {
    loading.value = state
  }

  function setError(errorMessage) {
    error.value = errorMessage
  }

  function clearError() {
    error.value = null
  }

  function setOnlineStatus(status) {
    online.value = status
  }

  function setInstallPromptEvent(event) {
    installPromptEvent.value = event
  }

  function setInstallationStatus(status) {
    isInstalled.value = status
  }

  async function showInstallPrompt() {
    if (!installPromptEvent.value) return false

    try {
      const result = await installPromptEvent.value.prompt()
      const accepted = result.outcome === 'accepted'
      
      if (accepted) {
        setInstallationStatus(true)
        setInstallPromptEvent(null)
      }
      
      return accepted
    } catch (error) {
      console.error('Install prompt failed:', error)
      return false
    }
  }

  // Initialize online/offline listeners
  function initializeNetworkListeners() {
    window.addEventListener('online', () => setOnlineStatus(true))
    window.addEventListener('offline', () => setOnlineStatus(false))
  }

  // Initialize PWA install listeners
  function initializePWAListeners() {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()
      setInstallPromptEvent(e)
    })

    window.addEventListener('appinstalled', () => {
      setInstallationStatus(true)
      setInstallPromptEvent(null)
    })

    // Check if already installed
    if (window.matchMedia('(display-mode: standalone)').matches) {
      setInstallationStatus(true)
    }
  }

  return {
    // State
    loading,
    error,
    online,
    installPromptEvent,
    isInstalled,
    
    // Actions
    setLoading,
    setError,
    clearError,
    setOnlineStatus,
    setInstallPromptEvent,
    setInstallationStatus,
    showInstallPrompt,
    initializeNetworkListeners,
    initializePWAListeners
  }
})