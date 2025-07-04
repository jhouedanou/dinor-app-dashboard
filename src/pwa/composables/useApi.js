import { ref, computed, watch, onUnmounted } from 'vue'
import { useApiStore } from '@/stores/api'

export function useApi() {
  const apiStore = useApiStore()
  
  return {
    request: apiStore.request,
    get: apiStore.get,
    post: apiStore.post,
    put: apiStore.put,
    del: apiStore.del,
    // invalidateCache: apiStore.invalidateCache, // Cache désactivé
    preload: apiStore.preload,
    isLoading: apiStore.isLoading,
    getError: apiStore.getError,
    clearError: apiStore.clearError
  }
}

export function useApiCall(endpoint, params = {}, options = {}) {
  const apiStore = useApiStore()
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)
  const cacheKey = computed(() => `${endpoint}_${JSON.stringify(params.value || params)}`)
  
  const execute = async (customParams = null, customOptions = {}) => {
    const finalParams = customParams || params.value || params
    const finalOptions = { ...options, ...customOptions }
    
    loading.value = true
    error.value = null
    
    try {
      const result = await apiStore.get(endpoint, finalParams, finalOptions)
      data.value = result
      return result
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const refresh = () => {
    // apiStore.invalidateCache(cacheKey.value) // Cache désactivé
    return execute()
  }
  
  // Auto-execute si autoFetch est true
  if (options.autoFetch !== false) {
    execute()
  }
  
  // Watch des paramètres pour re-exécuter automatiquement
  if (options.watchParams !== false && typeof params === 'object' && params.value !== undefined) {
    watch(params, () => execute(), { deep: true })
  }
  
  return {
    data,
    error,
    loading,
    execute,
    refresh
  }
}

export function useApiMutation(endpoint, options = {}) {
  const apiStore = useApiStore()
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)
  
  const mutate = async (payload, method = 'POST', customOptions = {}) => {
    loading.value = true
    error.value = null
    
    try {
      let result
      const finalOptions = { ...options, ...customOptions }
      
      switch (method.toUpperCase()) {
        case 'POST':
          result = await apiStore.post(endpoint, payload, finalOptions)
          break
        case 'PUT':
          result = await apiStore.put(endpoint, payload, finalOptions)
          break
        case 'DELETE':
          result = await apiStore.del(endpoint, finalOptions)
          break
        default:
          throw new Error(`Unsupported method: ${method}`)
      }
      
      data.value = result
      
      // Cache désactivé - pas d'invalidation nécessaire
      // if (options.invalidatePattern) {
      //   apiStore.invalidateCache(options.invalidatePattern)
      // }
      
      return result
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const post = (payload, options) => mutate(payload, 'POST', options)
  const put = (payload, options) => mutate(payload, 'PUT', options)
  const del = (options) => mutate(null, 'DELETE', options)
  
  return {
    data,
    error,
    loading,
    mutate,
    post,
    put,
    del
  }
}

export function useApiPagination(endpoint, initialParams = {}, options = {}) {
  const apiStore = useApiStore()
  const data = ref([])
  const meta = ref({})
  const error = ref(null)
  const loading = ref(false)
  const hasMore = computed(() => meta.value.current_page < meta.value.last_page)
  
  const params = ref({
    page: 1,
    per_page: 12,
    ...initialParams
  })
  
  const loadPage = async (page = 1, append = false) => {
    loading.value = true
    error.value = null
    
    try {
      const result = await apiStore.get(endpoint, { ...params.value, page }, options)
      
      if (result.success) {
        if (append) {
          data.value = [...data.value, ...result.data]
        } else {
          data.value = result.data
        }
        meta.value = result.meta || {}
        params.value.page = page
      }
      
      return result
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const loadMore = () => {
    if (hasMore.value && !loading.value) {
      return loadPage(params.value.page + 1, true)
    }
  }
  
  const refresh = () => {
    // apiStore.invalidateCache(endpoint) // Cache désactivé
    return loadPage(1, false)
  }
  
  const updateParams = (newParams) => {
    params.value = { ...params.value, ...newParams }
    return loadPage(1, false)
  }
  
  // Auto-load initial data
  if (options.autoFetch !== false) {
    loadPage(1)
  }
  
  return {
    data,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    updateParams
  }
}

export function useApiCache() {
  const apiStore = useApiStore()
  
  const preloadRoutes = async (routes) => {
    const endpoints = routes.map(route => ({
      endpoint: route.endpoint,
      params: route.params || {},
      options: { cacheTTL: route.cacheTTL || 10 * 60 * 1000 } // 10 minutes par défaut
    }))
    
    return apiStore.preload(endpoints)
  }
  
  const warmCache = async () => {
    // Précharger les données essentielles
    const essentialEndpoints = [
      { endpoint: '/recipes', params: { featured: true, limit: 6 } },
      { endpoint: '/tips', params: { featured: true, limit: 6 } },
      { endpoint: '/events', params: { status: 'active', limit: 6 } },
      { endpoint: '/categories' }
    ]
    
    return apiStore.preload(essentialEndpoints)
  }
  
  return {
    preloadRoutes,
    warmCache,
    // invalidateCache: apiStore.invalidateCache // Cache désactivé
  }
}

export function useRecipes(params = {}, options = {}) {
  const {
    data: recipes,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/recipes', params, {
    cacheTTL: 5 * 60 * 1000, // 5 minutes
    ...options
  })

  const featuredRecipes = computed(() => {
    return recipes.value?.data?.filter(recipe => recipe.is_featured) || []
  })

  const popularRecipes = computed(() => {
    return recipes.value?.data?.sort((a, b) => (b.likes_count || 0) - (a.likes_count || 0)) || []
  })

  // Fonction pour forcer le rafraîchissement
  const refreshFresh = async () => {
    console.log('🔄 [useRecipes] Rafraîchissement forcé des recettes')
    // Cache désactivé - recharger directement
    await refresh()
  }

  return {
    recipes,
    featuredRecipes,
    popularRecipes,
    error,
    loading,
    execute,
    refresh,
    refreshFresh
  }
}