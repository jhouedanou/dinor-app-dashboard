import { ref, onMounted } from 'vue'
import { useApi } from './useApi'

export function useBanners() {
  const { request } = useApi()
  
  const banners = ref([])
  const loading = ref(false)
  const error = ref(null)

  const loadBanners = async (filters = {}, forceRefresh = false) => {
    loading.value = true
    error.value = null
    
    try {
      const params = {}
      if (filters.position) params.position = filters.position
      if (filters.type_contenu) params.type_contenu = filters.type_contenu
      if (filters.section) params.section = filters.section
      
      console.log('🌐 [useBanners] Requête API /banners avec params:', params)
      
      // Forcer le rechargement sans cache si demandé
      const options = forceRefresh ? { forceRefresh: true } : {}
      const data = await request('/banners', { params, ...options })
      console.log('📦 [useBanners] Réponse API:', data)
      
      if (data.success) {
        banners.value = data.data
        console.log(`✅ [useBanners] ${data.data.length} bannières chargées`)
      } else {
        error.value = data.message || 'Erreur lors du chargement des bannières'
        console.error('❌ [useBanners] Erreur:', error.value)
      }
    } catch (err) {
      error.value = 'Impossible de charger les bannières'
      console.error('❌ [useBanners] Exception:', err)
    } finally {
      loading.value = false
    }
  }

  const loadBannersByType = async (type) => {
    loading.value = true
    error.value = null
    
    try {
      const data = await request(`/banners/type/${type}`)
      
      if (data.success) {
        banners.value = data.data
        return data.data
      } else {
        error.value = data.message || 'Erreur lors du chargement des bannières'
        return []
      }
    } catch (err) {
      error.value = 'Impossible de charger les bannières pour ce type'
      console.error('Erreur bannières par type:', err)
      return []
    } finally {
      loading.value = false
    }
  }

  const getBanner = async (id) => {
    try {
      const data = await request(`/banners/${id}`)
      
      if (data.success) {
        return data.data
      } else {
        throw new Error(data.message || 'Bannière non trouvée')
      }
    } catch (err) {
      console.error('Erreur récupération bannière:', err)
      throw err
    }
  }

  const getActiveBanners = () => {
    return banners.value.filter(banner => banner.is_active)
  }

  const getBannersByPosition = (position) => {
    return banners.value.filter(banner => 
      banner.position === position || banner.position === 'all_pages'
    )
  }

  const getBannersBySection = (section) => {
    return banners.value.filter(banner => banner.section === section)
  }

  const getBannersByTypeAndSection = (type, section) => {
    return banners.value.filter(banner => 
      banner.type_contenu === type && banner.section === section
    )
  }

  // Fonction pour charger les bannières par type de contenu
  const loadBannersForContentType = async (contentType, forceRefresh = false) => {
    console.log(`🎯 [useBanners] Chargement des bannières pour type: ${contentType}`)
    return await loadBanners({ 
      type_contenu: contentType,
      position: contentType === 'home' ? 'home' : 'content'
    }, forceRefresh)
  }

  // Fonction pour vider le cache des bannières
  const clearBannersCache = () => {
    console.log('🗑️ [useBanners] Vidage du cache des bannières')
    banners.value = []
    // Force le rechargement de toutes les bannières sans cache
    return loadBanners({}, true)
  }

  // Auto-charge les bannières au montage UNIQUEMENT pour la page d'accueil
  // Les autres pages devront appeler loadBannersForContentType() explicitement

  return {
    banners,
    loading,
    error,
    loadBanners,
    loadBannersByType,
    loadBannersForContentType, // Nouvelle fonction
    clearBannersCache, // Nouvelle fonction pour vider le cache
    getBanner,
    getActiveBanners,
    getBannersByPosition,
    getBannersBySection,
    getBannersByTypeAndSection
  }
} 