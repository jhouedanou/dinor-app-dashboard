import { ref, onMounted } from 'vue'
import { useApi } from './useApi'

export function useBanners() {
  const { request } = useApi()
  
  const banners = ref([])
  const loading = ref(false)
  const error = ref(null)

  const loadBanners = async (position = 'home') => {
    loading.value = true
    error.value = null
    
    try {
      const params = position ? { position } : {}
      const data = await request('/api/v1/banners', { params })
      
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

  const getBanner = async (id) => {
    try {
      const data = await request(`/api/v1/banners/${id}`)
      
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

  // Auto-charge les bannières au montage
  onMounted(() => {
    loadBanners()
  })

  return {
    banners,
    loading,
    error,
    loadBanners,
    getBanner,
    getActiveBanners,
    getBannersByPosition
  }
} 