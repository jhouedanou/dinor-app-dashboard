import { ref, onMounted } from 'vue'
import { useApi } from './useApi'

export function useBanners() {
  const { request } = useApi()
  
  const banners = ref([])
  const loading = ref(false)
  const error = ref(null)

  const loadBanners = async (filters = {}) => {
    loading.value = true
    error.value = null
    
    try {
      const params = {}
      if (filters.position) params.position = filters.position
      if (filters.type_contenu) params.type_contenu = filters.type_contenu
      if (filters.section) params.section = filters.section
      
      const data = await request('/banners', { params })
      
      if (data.success) {
        banners.value = data.data
      } else {
        error.value = data.message || 'Erreur lors du chargement des bannières'
      }
    } catch (err) {
      error.value = 'Impossible de charger les bannières'
      console.error('Erreur bannières:', err)
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

  // Auto-charge les bannières au montage
  onMounted(() => {
    loadBanners({ position: 'home' })
  })

  return {
    banners,
    loading,
    error,
    loadBanners,
    loadBannersByType,
    getBanner,
    getActiveBanners,
    getBannersByPosition,
    getBannersBySection,
    getBannersByTypeAndSection
  }
} 