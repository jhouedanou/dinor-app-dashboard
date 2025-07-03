/**
 * API Service for communicating with Laravel backend
 */

class ApiService {
  constructor() {
    this.baseURL = this.getBaseURL()
    this.cache = new Map()
    this.cacheTimeout = 5 * 60 * 1000 // 5 minutes
  }

  getBaseURL() {
    // In development, use proxy
    if (import.meta.env.DEV) {
      return '/api/v1'
    }
    // In production, use full URL
    return `${window.location.origin}/api/v1`
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`
    const cacheKey = `${url}_${JSON.stringify(options)}`
    
    // Check cache for GET requests
    if (!options.method || options.method === 'GET') {
      const cached = this.cache.get(cacheKey)
      if (cached && Date.now() - cached.timestamp < this.cacheTimeout) {
        console.log('📦 [API] Cache hit for:', endpoint)
        return cached.data
      }
    }

    // Récupérer le token d'authentification du localStorage
    const authToken = localStorage.getItem('auth_token')
    console.log('🔐 [API] Token d\'authentification:', authToken ? '***existe***' : 'null')

    const config = {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        // Ajouter le token d'authentification si disponible
        ...(authToken && { 'Authorization': `Bearer ${authToken}` }),
        ...options.headers
      },
      ...options
    }

    // Sérialiser le body en JSON si c'est un objet
    if (config.body && typeof config.body === 'object') {
      config.body = JSON.stringify(config.body)
    }

    console.log('📡 [API] Requête vers:', endpoint, {
      method: options.method || 'GET',
      hasAuthToken: !!authToken,
      headers: { ...config.headers, Authorization: authToken ? '***Bearer token***' : undefined }
    })

    try {
      const response = await fetch(url, config)
      
      console.log('📡 [API] Réponse reçue:', {
        status: response.status,
        statusText: response.statusText,
        ok: response.ok
      })
      
      if (!response.ok) {
        // Gestion spéciale pour les erreurs 401 (non autorisé)
        if (response.status === 401) {
          console.error('🔒 [API] Erreur 401 - Token invalide ou manquant')
          // Optionnel : nettoyer le localStorage si le token est invalide
          // localStorage.removeItem('auth_token')
          // localStorage.removeItem('auth_user')
        }
        
        const errorData = await response.text()
        throw new Error(`HTTP error! status: ${response.status}, message: ${errorData}`)
      }

      const data = await response.json()
      console.log('✅ [API] Réponse JSON:', { success: data.success, endpoint })
      
      // Cache successful GET requests
      if (!options.method || options.method === 'GET') {
        this.cache.set(cacheKey, {
          data,
          timestamp: Date.now()
        })
        console.log('📦 [API] Réponse mise en cache pour:', endpoint)
      }

      return data
    } catch (error) {
      console.error('❌ [API] Erreur de requête:', {
        endpoint,
        error: error.message,
        status: error.status
      })
      throw error
    }
  }

  // Clear cache manually
  clearCache() {
    this.cache.clear()
    // Also clear service worker cache if available
    if ('serviceWorker' in navigator && 'caches' in window) {
      caches.delete('api-cache')
    }
  }

  // Recipes
  async getRecipes(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/recipes${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async getRecipe(id) {
    return this.request(`/recipes/${id}`)
  }

  // Tips
  async getTips(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/tips${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async getTip(id) {
    return this.request(`/tips/${id}`)
  }

  // Events
  async getEvents(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/events${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async getEvent(id) {
    return this.request(`/events/${id}`)
  }

  // Pages
  async getPages(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/pages${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async getPage(id) {
    return this.request(`/pages/${id}`)
  }

  // Dinor TV
  async getVideos(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/dinor-tv${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async getVideo(id) {
    return this.request(`/dinor-tv/${id}`)
  }

  // Likes
  async toggleLike(type, id) {
    return this.request(`/${type}/${id}/like`, {
      method: 'POST'
    })
  }

  // Comments
  async getComments(type, id) {
    return this.request(`/${type}/${id}/comments`)
  }

  async addComment(type, id, content) {
    return this.request(`/${type}/${id}/comments`, {
      method: 'POST',
      body: JSON.stringify({ content })
    })
  }

  // Categories
  async getCategories() {
    return this.request('/categories')
  }

  async getEventCategories() {
    return this.request('/categories/events')
  }

  async getRecipeCategories() {
    return this.request('/categories/recipes')
  }

  // Search
  async search(query, type = null) {
    const params = { q: query }
    if (type) params.type = type
    
    const queryString = new URLSearchParams(params).toString()
    return this.request(`/search?${queryString}`)
  }

  // Favorites
  async getFavorites(params = {}) {
    const queryString = new URLSearchParams(params).toString()
    const endpoint = `/favorites${queryString ? `?${queryString}` : ''}`
    return this.request(endpoint)
  }

  async toggleFavorite(favoritable_type, favoritable_id) {
    return this.request('/favorites/toggle', {
      method: 'POST',
      body: JSON.stringify({
        type: favoritable_type,
        id: favoritable_id
      })
    })
  }

  async checkFavorite(type, id) {
    const params = new URLSearchParams({ type, id })
    return this.request(`/favorites/check?${params}`)
  }

  async removeFavorite(favoriteId) {
    return this.request(`/favorites/${favoriteId}`, {
      method: 'DELETE'
    })
  }

  // Clear cache
  clearCache() {
    this.cache.clear()
  }

  // Clear expired cache entries
  cleanCache() {
    const now = Date.now()
    for (const [key, value] of this.cache.entries()) {
      if (now - value.timestamp >= this.cacheTimeout) {
        this.cache.delete(key)
      }
    }
  }
}

export default new ApiService()