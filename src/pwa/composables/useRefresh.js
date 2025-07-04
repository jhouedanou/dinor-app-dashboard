import { ref } from 'vue'
import { useApiStore } from '@/stores/api'
import apiService from '@/services/api'

/**
 * Composable pour gérer le rafraîchissement forcé des données
 */
export function useRefresh() {
  const apiStore = useApiStore()
  const refreshing = ref(false)

  /**
   * Forcer le rafraîchissement de toutes les données en cache
   */
  const refreshAll = async () => {
    refreshing.value = true
    console.log('🔄 [useRefresh] Rafraîchissement global...')
    
    try {
      // Nettoyer les caches
      apiService.clearCache()
      apiStore.invalidateCache('/')
      
      // Émettre un événement global pour que les composants se rafraîchissent
      window.dispatchEvent(new CustomEvent('global-refresh', {
        detail: { timestamp: Date.now() }
      }))
      
      console.log('✅ [useRefresh] Rafraîchissement global terminé')
    } catch (error) {
      console.error('❌ [useRefresh] Erreur lors du rafraîchissement global:', error)
    } finally {
      refreshing.value = false
    }
  }

  /**
   * Rafraîchir un type de contenu spécifique
   */
  const refreshContentType = async (type) => {
    refreshing.value = true
    console.log(`🔄 [useRefresh] Rafraîchissement du type: ${type}`)
    
    try {
      // Invalider le cache pour ce type
      apiService.invalidateCache(`/${type}`)
      apiStore.invalidateCache(`/${type}`)
      
      // Émettre un événement spécifique
      window.dispatchEvent(new CustomEvent('content-refresh', {
        detail: { type, timestamp: Date.now() }
      }))
      
      console.log(`✅ [useRefresh] Rafraîchissement du type ${type} terminé`)
    } catch (error) {
      console.error(`❌ [useRefresh] Erreur lors du rafraîchissement de ${type}:`, error)
    } finally {
      refreshing.value = false
    }
  }

  /**
   * Rafraîchir un élément spécifique
   */
  const refreshItem = async (type, id) => {
    console.log(`🔄 [useRefresh] Rafraîchissement de ${type}:${id}`)
    
    try {
      // Invalider le cache pour cet élément
      apiService.invalidateCache(`/${type}/${id}`)
      apiService.invalidateCache(`/${type}`)
      apiStore.invalidateCache(`/${type}/${id}`)
      apiStore.invalidateCache(`/${type}`)
      
      // Émettre un événement spécifique
      window.dispatchEvent(new CustomEvent('item-refresh', {
        detail: { type, id, timestamp: Date.now() }
      }))
      
      console.log(`✅ [useRefresh] Rafraîchissement de ${type}:${id} terminé`)
    } catch (error) {
      console.error(`❌ [useRefresh] Erreur lors du rafraîchissement de ${type}:${id}:`, error)
    }
  }

  /**
   * Écouter les événements de rafraîchissement et exécuter une callback
   */
  const onRefresh = (callback, options = {}) => {
    const { type, global = true } = options
    
    if (global) {
      window.addEventListener('global-refresh', callback)
    }
    
    if (type) {
      window.addEventListener('content-refresh', (event) => {
        if (event.detail.type === type) {
          callback(event)
        }
      })
    }
    
    window.addEventListener('item-refresh', (event) => {
      if (!type || event.detail.type === type) {
        callback(event)
      }
    })
    
    // Fonction de nettoyage
    return () => {
      if (global) {
        window.removeEventListener('global-refresh', callback)
      }
      window.removeEventListener('content-refresh', callback)
      window.removeEventListener('item-refresh', callback)
    }
  }

  return {
    refreshing,
    refreshAll,
    refreshContentType,
    refreshItem,
    onRefresh
  }
} 