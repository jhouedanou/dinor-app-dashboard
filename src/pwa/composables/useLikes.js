import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useApiStore } from '@/stores/api'

/**
 * Composable pour gérer les likes et favoris de manière standardisée
 * @param {string} type - Type de contenu ('recipe', 'tip', 'event', 'dinor_tv')
 * @param {number|string} itemId - ID du contenu
 */
export function useLikes(type, itemId) {
  const authStore = useAuthStore()
  const apiStore = useApiStore()
  
  const isLiked = ref(false)
  const likesCount = ref(0)
  const isFavorited = ref(false)
  const favoritesCount = ref(0)
  const loading = ref(false)
  
  /**
   * Charger le statut des likes et favoris pour l'utilisateur actuel
   */
  const loadLikeStatus = async () => {
    if (!authStore.isAuthenticated) {
      isLiked.value = false
      isFavorited.value = false
      return
    }
    
    try {
      console.log(`👍 [Likes] Chargement statut pour ${type}:${itemId}`)
      
      // Charger le statut des likes
      const likeData = await apiStore.get('/likes/check', { type, id: itemId })
      if (likeData.success) {
        isLiked.value = likeData.is_liked
        if (typeof likeData.likes_count === 'number') {
          likesCount.value = likeData.likes_count
        }
      }
      
      // Charger le statut des favoris
      const favoriteData = await apiStore.get('/favorites/check', { type, id: itemId })
      if (favoriteData.success) {
        isFavorited.value = favoriteData.is_favorited
      }
      
      console.log(`✅ [Likes] Statut chargé - Liked: ${isLiked.value}, Favorited: ${isFavorited.value}`)
    } catch (error) {
      console.warn('⚠️ [Likes] Erreur lors du chargement du statut:', error)
    }
  }
  
  /**
   * Toggle le like (et automatiquement le favori selon la logique backend)
   */
  const toggleLike = async () => {
    if (!authStore.isAuthenticated) {
      console.log('🔒 [Likes] Utilisateur non connecté')
      return { 
        success: false, 
        requiresAuth: true,
        message: 'Vous devez être connecté pour aimer ce contenu'
      }
    }
    
    if (loading.value) {
      console.log('⏳ [Likes] Toggle déjà en cours')
      return { success: false, message: 'Action déjà en cours' }
    }
    
    loading.value = true
    const previousLiked = isLiked.value
    const previousCount = likesCount.value
    const previousFavorited = isFavorited.value
    
    // Optimistic update
    isLiked.value = !isLiked.value
    likesCount.value += isLiked.value ? 1 : -1
    
    try {
      console.log(`👍 [Likes] Toggle like pour ${type}:${itemId}`)
      
      const data = await apiStore.post('/likes/toggle', { type, id: itemId })
      
      if (data.success) {
        // Mettre à jour avec les vraies valeurs du serveur
        isLiked.value = data.action === 'liked'
        if (typeof data.likes_count === 'number') {
          likesCount.value = data.likes_count
        }
        if (typeof data.favorites_count === 'number') {
          favoritesCount.value = data.favorites_count
        }
        
        // Le backend toggle automatiquement les favoris aussi
        if (data.favorite_action) {
          isFavorited.value = data.favorite_action === 'favorited'
        }
        
        // Émettre un événement global pour synchroniser l'UI
        window.dispatchEvent(new CustomEvent('content-interaction-updated', {
          detail: {
            type,
            id: itemId,
            liked: isLiked.value,
            likesCount: likesCount.value,
            favorited: isFavorited.value,
            favoritesCount: favoritesCount.value,
            action: 'like-toggle'
          }
        }))
        
        console.log(`✅ [Likes] Toggle réussi - Liked: ${isLiked.value}, Favorited: ${isFavorited.value}`)
        
        return {
          success: true,
          liked: isLiked.value,
          likesCount: likesCount.value,
          favorited: isFavorited.value,
          favoritesCount: favoritesCount.value,
          message: isLiked.value ? 'Contenu aimé et ajouté aux favoris' : 'Like et favori retirés'
        }
      } else {
        throw new Error(data.message || 'Erreur lors du toggle like')
      }
    } catch (error) {
      console.error('❌ [Likes] Erreur toggle:', error)
      
      // Revert optimistic update
      isLiked.value = previousLiked
      likesCount.value = previousCount
      isFavorited.value = previousFavorited
      
      let requiresAuth = false
      if (error.status === 401 || error.type === 'AUTH_REQUIRED') {
        requiresAuth = true
      }
      
      return {
        success: false,
        requiresAuth,
        message: error.message || 'Erreur lors de la mise à jour'
      }
    } finally {
      loading.value = false
    }
  }
  
  /**
   * Toggle uniquement le favori (sans affecter le like)
   */
  const toggleFavorite = async () => {
    if (!authStore.isAuthenticated) {
      return { 
        success: false, 
        requiresAuth: true,
        message: 'Vous devez être connecté pour ajouter aux favoris'
      }
    }
    
    if (loading.value) {
      return { success: false, message: 'Action déjà en cours' }
    }
    
    loading.value = true
    const previousFavorited = isFavorited.value
    
    // Optimistic update
    isFavorited.value = !isFavorited.value
    
    try {
      console.log(`⭐ [Favorites] Toggle favori pour ${type}:${itemId}`)
      
      const data = await apiStore.post('/favorites/toggle', { type, id: itemId })
      
      if (data.success) {
        isFavorited.value = data.is_favorited
        if (typeof data.data?.total_favorites === 'number') {
          favoritesCount.value = data.data.total_favorites
        }
        
        // Émettre un événement global
        window.dispatchEvent(new CustomEvent('content-interaction-updated', {
          detail: {
            type,
            id: itemId,
            liked: isLiked.value,
            likesCount: likesCount.value,
            favorited: isFavorited.value,
            favoritesCount: favoritesCount.value,
            action: 'favorite-toggle'
          }
        }))
        
        console.log(`✅ [Favorites] Toggle réussi - Favorited: ${isFavorited.value}`)
        
        return {
          success: true,
          favorited: isFavorited.value,
          favoritesCount: favoritesCount.value,
          message: data.message || (isFavorited.value ? 'Ajouté aux favoris' : 'Retiré des favoris')
        }
      } else {
        throw new Error(data.message || 'Erreur lors du toggle favori')
      }
    } catch (error) {
      console.error('❌ [Favorites] Erreur toggle:', error)
      
      // Revert optimistic update
      isFavorited.value = previousFavorited
      
      let requiresAuth = false
      if (error.status === 401 || error.type === 'AUTH_REQUIRED') {
        requiresAuth = true
      }
      
      return {
        success: false,
        requiresAuth,
        message: error.message || 'Erreur lors de la mise à jour'
      }
    } finally {
      loading.value = false
    }
  }
  
  // Getters computed
  const canInteract = computed(() => authStore.isAuthenticated)
  
  return {
    // État
    isLiked,
    likesCount,
    isFavorited,
    favoritesCount,
    loading,
    canInteract,
    
    // Actions
    loadLikeStatus,
    toggleLike,
    toggleFavorite
  }
} 