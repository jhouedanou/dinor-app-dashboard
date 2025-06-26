import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useCacheStore } from './cache'

export const useApiStore = defineStore('api', () => {
  // State
  const loading = ref(new Set())
  const errors = ref(new Map())
  const baseURL = ref(getBaseURL())
  
  // Cache store
  const cacheStore = useCacheStore()

  function getBaseURL() {
    if (import.meta.env.DEV) {
      return '/api/v1'
    }
    return `${window.location.origin}/api/v1`
  }

  // Actions
  function setLoading(key, isLoading) {
    if (isLoading) {
      loading.value.add(key)
    } else {
      loading.value.delete(key)
    }
  }

  function setError(key, error) {
    if (error) {
      errors.value.set(key, error)
    } else {
      errors.value.delete(key)
    }
  }

  function isLoading(key) {
    return loading.value.has(key)
  }

  function getError(key) {
    return errors.value.get(key)
  }

  function clearError(key) {
    errors.value.delete(key)
  }

  async function request(endpoint, options = {}) {
    const cacheKey = `${endpoint}_${JSON.stringify(options)}`
    
    // Vérifier le cache PWA d'abord (sauf pour POST/PUT/DELETE)
    if (!options.method || options.method === 'GET') {
      const cached = await checkPWACache(endpoint, options)
      if (cached) {
        return cached
      }
    }

    setLoading(cacheKey, true)
    setError(cacheKey, null)

    try {
      const url = `${baseURL.value}${endpoint}`
      const config = {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          ...options.headers
        },
        ...options
      }

      const response = await fetch(url, config)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      
      // Mettre en cache les requêtes GET réussies dans le cache PWA
      if (!options.method || options.method === 'GET') {
        await setPWACache(endpoint, data, options)
      }

      return data
    } catch (error) {
      setError(cacheKey, error.message)
      throw error
    } finally {
      setLoading(cacheKey, false)
    }
  }

  // Fonction pour vérifier le cache PWA
  async function checkPWACache(endpoint, options = {}) {
    try {
      const type = getContentType(endpoint)
      if (!type) return null

      const params = extractParams(options)
      
      const response = await fetch('/api/pwa/cache/get', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ type, params })
      })

      if (response.ok) {
        const result = await response.json()
        if (result.success) {
          return result.data
        }
      }
    } catch (error) {
      console.warn('Erreur cache PWA get:', error)
    }
    return null
  }

  // Fonction pour mettre en cache dans la PWA
  async function setPWACache(endpoint, data, options = {}) {
    try {
      const type = getContentType(endpoint)
      if (!type) return

      const params = extractParams(options)
      
      await fetch('/api/pwa/cache/set', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ type, data, params })
      })
    } catch (error) {
      console.warn('Erreur cache PWA set:', error)
    }
  }

  // Déterminer le type de contenu depuis l'endpoint
  function getContentType(endpoint) {
    if (endpoint.includes('/recipes')) return 'recipes'
    if (endpoint.includes('/tips')) return 'tips'
    if (endpoint.includes('/events')) return 'events'
    if (endpoint.includes('/dinor-tv')) return 'videos'
    if (endpoint.includes('/categories')) return 'categories'
    return null
  }

  // Extraire les paramètres pertinents pour le cache
  function extractParams(options) {
    const url = new URL(`http://example.com${options.url || ''}`)
    const params = {}
    
    for (const [key, value] of url.searchParams) {
      params[key] = value
    }
    
    return params
  }

  // Méthodes spécifiques
  async function get(endpoint, params = {}, options = {}) {
    const queryString = new URLSearchParams(params).toString()
    const fullEndpoint = queryString ? `${endpoint}?${queryString}` : endpoint
    return request(fullEndpoint, { ...options, method: 'GET' })
  }

  async function post(endpoint, data, options = {}) {
    return request(endpoint, {
      ...options,
      method: 'POST',
      body: JSON.stringify(data)
    })
  }

  async function put(endpoint, data, options = {}) {
    return request(endpoint, {
      ...options,
      method: 'PUT',
      body: JSON.stringify(data)
    })
  }

  async function del(endpoint, options = {}) {
    return request(endpoint, {
      ...options,
      method: 'DELETE'
    })
  }

  // Invalider le cache pour un pattern donné
  function invalidateCache(pattern) {
    const cacheInfo = cacheStore.getCacheInfo()
    const keysToRemove = cacheInfo.keys.filter(key => 
      key.includes(pattern) || new RegExp(pattern).test(key)
    )
    
    keysToRemove.forEach(key => cacheStore.remove(key))
  }

  // Précharger des données
  async function preload(endpoints) {
    const promises = endpoints.map(({ endpoint, params, options }) => 
      get(endpoint, params, { ...options, priority: 'low' }).catch(() => null)
    )
    
    return Promise.allSettled(promises)
  }

  return {
    // State
    loading,
    errors,
    baseURL,
    
    // Getters
    isLoading,
    getError,
    
    // Actions
    setLoading,
    setError,
    clearError,
    request,
    get,
    post,
    put,
    del,
    invalidateCache,
    preload
  }
})