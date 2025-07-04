import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useApiStore } from '@/stores/api'

/**
 * Composable pour gérer le rafraîchissement automatique des données
 * Résout le problème de cache PWA et mise à jour automatique
 */
export function useRefresh() {
  const apiStore = useApiStore()
  const refreshListeners = ref(new Set())
  const isRefreshing = ref(false)

  // Bus d'événements global pour le rafraîchissement
  const refreshBus = {
    emit(event, data) {
      console.log('🔄 [RefreshBus] Émission événement:', event, data)
      const customEvent = new CustomEvent(event, { detail: data })
      window.dispatchEvent(customEvent)
    },
    
    on(event, callback) {
      console.log('👂 [RefreshBus] Écoute événement:', event)
      window.addEventListener(event, callback)
      return () => window.removeEventListener(event, callback)
    }
  }

  /**
   * Force le rafraîchissement d'un type de contenu spécifique
   */
  const refreshContentType = async (contentType, options = {}) => {
    if (isRefreshing.value && !options.force) {
      console.log('⏳ [Refresh] Rafraîchissement déjà en cours')
      return
    }

    isRefreshing.value = true
    console.log(`🔄 [Refresh] Début rafraîchissement: ${contentType}`)

    try {
      // Invalider le cache API
      apiStore.invalidateCache(`/${contentType}`)
      
      // Invalider le cache local service
      if ('caches' in window) {
        const cacheNames = await caches.keys()
        await Promise.all(
          cacheNames.map(name => {
            if (name.includes(contentType) || name.includes('api')) {
              console.log(`🗑️ [Refresh] Suppression cache: ${name}`)
              return caches.delete(name)
            }
          })
        )
      }

      // Émettre l'événement de rafraîchissement
      refreshBus.emit('content-refresh', { 
        type: contentType, 
        timestamp: Date.now(),
        source: 'manual'
      })

      console.log(`✅ [Refresh] Rafraîchissement terminé: ${contentType}`)
      
    } catch (error) {
      console.error(`❌ [Refresh] Erreur rafraîchissement ${contentType}:`, error)
      throw error
    } finally {
      isRefreshing.value = false
    }
  }

  /**
   * Force le rafraîchissement de tous les types de contenu
   */
  const refreshAll = async () => {
    console.log('🔄 [Refresh] Rafraîchissement global')
    const contentTypes = ['recipes', 'tips', 'events', 'dinor_tv', 'banners']
    
    for (const type of contentTypes) {
      await refreshContentType(type, { force: true })
    }
  }

  /**
   * Écouteur pour les événements de rafraîchissement
   */
  const onRefresh = (callback, options = {}) => {
    const handleRefresh = (event) => {
      const { type, timestamp, source } = event.detail
      console.log(`📡 [Refresh] Événement reçu:`, { type, timestamp, source })
      
      if (options.contentType && options.contentType !== type) {
        return // Ignorer si ce n'est pas le bon type
      }
      
      callback(event)
    }

    const cleanup = refreshBus.on('content-refresh', handleRefresh)
    refreshListeners.value.add(cleanup)
    
    return cleanup
  }

  /**
   * Mise à jour automatique basée sur l'activité
   */
  const setupAutoRefresh = (interval = 5 * 60 * 1000) => { // 5 minutes par défaut
    let autoRefreshTimer = null
    let lastActivity = Date.now()

    const updateActivity = () => {
      lastActivity = Date.now()
    }

    const checkAndRefresh = async () => {
      const now = Date.now()
      const timeSinceActivity = now - lastActivity
      
      // Si l'utilisateur n'est pas actif depuis plus de 2 minutes, pas de rafraîchissement
      if (timeSinceActivity > 2 * 60 * 1000) {
        console.log('😴 [AutoRefresh] Utilisateur inactif, pas de rafraîchissement')
        return
      }

      console.log('🔄 [AutoRefresh] Rafraîchissement automatique')
      try {
        await refreshAll()
      } catch (error) {
        console.error('❌ [AutoRefresh] Erreur:', error)
      }
    }

    // Écouter l'activité utilisateur
    const events = ['click', 'scroll', 'keypress', 'touchstart']
    events.forEach(event => {
      document.addEventListener(event, updateActivity, { passive: true })
    })

    // Démarrer le timer
    autoRefreshTimer = setInterval(checkAndRefresh, interval)

    return () => {
      if (autoRefreshTimer) {
        clearInterval(autoRefreshTimer)
      }
      events.forEach(event => {
        document.removeEventListener(event, updateActivity)
      })
    }
  }

  /**
   * Détection de mise à jour PWA
   */
  const setupPWAUpdateDetection = () => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        console.log('🔄 [PWA] Service Worker mis à jour, rafraîchissement des données')
        refreshAll()
      })

      // Écouter les messages du service worker
      navigator.serviceWorker.addEventListener('message', (event) => {
        if (event.data?.type === 'CACHE_UPDATED') {
          console.log('🔄 [PWA] Cache mis à jour:', event.data.url)
          
          // Déterminer le type de contenu depuis l'URL
          const url = event.data.url
          let contentType = null
          if (url.includes('/recipes')) contentType = 'recipes'
          else if (url.includes('/tips')) contentType = 'tips'
          else if (url.includes('/events')) contentType = 'events'
          else if (url.includes('/dinor-tv')) contentType = 'dinor_tv'
          
          if (contentType) {
            refreshContentType(contentType)
          }
        }
      })
    }
  }

  onMounted(() => {
    setupPWAUpdateDetection()
  })

  onUnmounted(() => {
    // Nettoyer tous les listeners
    refreshListeners.value.forEach(cleanup => cleanup())
    refreshListeners.value.clear()
  })

  return {
    isRefreshing,
    refreshContentType,
    refreshAll,
    onRefresh,
    setupAutoRefresh,
    refreshBus
  }
}

/**
 * Version simplifiée pour les composants qui ont juste besoin de forcer un rafraîchissement
 */
export function useSimpleRefresh() {
  const { refreshContentType, refreshAll, isRefreshing } = useRefresh()
  
  return {
    refresh: refreshContentType,
    refreshAll,
    isRefreshing
  }
}