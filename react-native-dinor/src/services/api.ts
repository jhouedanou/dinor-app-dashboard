/**
 * API Service for communicating with Laravel backend
 * CONVERSION EXACTE depuis Vue.js vers React Native
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Même structure de requêtes et réponses
 * - Même gestion d'authentification (Bearer token)
 * - Mêmes endpoints et paramètres
 * - Même gestion d'erreurs
 */

import AsyncStorage from '@react-native-async-storage/async-storage';

interface RequestOptions {
  method?: string;
  headers?: Record<string, string>;
  body?: any;
}

interface ApiResponse {
  success: boolean;
  data?: any;
  message?: string;
}

class ApiService {
  private baseURL: string;

  constructor() {
    this.baseURL = this.getBaseURL();
  }

  getBaseURL(): string {
    // Configuration identique Vue mais adaptée React Native
    if (__DEV__) {
      // En développement, utiliser l'IP de votre machine Laravel
      return 'http://192.168.1.100/api/v1'; // Ajuster selon votre réseau
    }
    // En production, utiliser l'URL de l'API
    return 'https://new.dinorapp.com/api/v1';
  }

  async request(endpoint: string, options: RequestOptions = {}): Promise<ApiResponse> {
    const url = `${this.baseURL}${endpoint}`;
    
    // Récupérer le token d'authentification d'AsyncStorage (identique localStorage Vue)
    const authToken = await AsyncStorage.getItem('auth_token');
    console.log('🔐 [API] Token d\'authentification:', authToken ? '***existe***' : 'null');

    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        // Ajouter le token d'authentification si disponible (identique Vue)
        ...(authToken && { 'Authorization': `Bearer ${authToken}` }),
        ...options.headers
      },
      ...options
    };

    // Sérialiser le body en JSON si c'est un objet (identique Vue)
    if (config.body && typeof config.body === 'object') {
      config.body = JSON.stringify(config.body);
    }

    console.log('📡 [API] Requête vers:', endpoint, {
      method: options.method || 'GET',
      hasAuthToken: !!authToken,
      headers: { ...config.headers, Authorization: authToken ? '***Bearer token***' : undefined }
    });

    try {
      const response = await fetch(url, config);
      
      console.log('📡 [API] Réponse reçue:', {
        status: response.status,
        statusText: response.statusText,
        ok: response.ok
      });
      
      if (!response.ok) {
        // Gestion spéciale pour les erreurs 401 (identique Vue)
        if (response.status === 401) {
          console.error('🔒 [API] Erreur 401 - Token invalide ou manquant');
          // Optionnel : nettoyer AsyncStorage si le token est invalide
          // await AsyncStorage.removeItem('auth_token');
          // await AsyncStorage.removeItem('auth_user');
        }
        
        const errorData = await response.text();
        throw new Error(`HTTP error! status: ${response.status}, message: ${errorData}`);
      }

      const data = await response.json() as ApiResponse;
      console.log('✅ [API] Réponse JSON:', { success: data.success, endpoint });
      
      return data;
    } catch (error: any) {
      console.error('❌ [API] Erreur de requête:', {
        endpoint,
        error: error.message,
        status: error.status
      });
      throw error;
    }
  }

  // Requête forcée sans cache (identique Vue)
  async requestFresh(endpoint: string, options: RequestOptions = {}): Promise<ApiResponse> {
    const url = `${this.baseURL}${endpoint}`;
    
    // Récupérer le token d'authentification d'AsyncStorage
    const authToken = await AsyncStorage.getItem('auth_token');
    console.log('🔄 [API] Requête fraîche vers:', endpoint);

    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        // Ajouter un en-tête pour éviter le cache du navigateur (identique Vue)
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        ...(authToken && { 'Authorization': `Bearer ${authToken}` }),
        ...options.headers
      },
      ...options
    };

    // Sérialiser le body en JSON si c'est un objet
    if (config.body && typeof config.body === 'object') {
      config.body = JSON.stringify(config.body);
    }

    try {
      const response = await fetch(url, config);
      
      console.log('📡 [API] Réponse fraîche reçue:', {
        status: response.status,
        statusText: response.statusText,
        ok: response.ok
      });
      
      if (!response.ok) {
        if (response.status === 401) {
          console.error('🔒 [API] Erreur 401 - Token invalide ou manquant');
        }
        
        const errorData = await response.text();
        throw new Error(`HTTP error! status: ${response.status}, message: ${errorData}`);
      }

      const data = await response.json() as ApiResponse;
      console.log('✅ [API] Réponse fraîche JSON:', { success: data.success, endpoint });
      
      return data;
    } catch (error: any) {
      console.error('❌ [API] Erreur de requête fraîche:', {
        endpoint,
        error: error.message,
        status: error.status
      });
      throw error;
    }
  }

  // RECIPES - Méthodes identiques Vue
  async getRecipes(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/recipes${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async getRecipe(id: string | number): Promise<ApiResponse> {
    return this.request(`/recipes/${id}`);
  }

  async getRecipesFresh(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/recipes${queryString ? `?${queryString}` : ''}`;
    return this.requestFresh(endpoint);
  }

  async getRecipeFresh(id: string | number): Promise<ApiResponse> {
    return this.requestFresh(`/recipes/${id}`);
  }

  // TIPS - Méthodes identiques Vue
  async getTips(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/tips${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async getTip(id: string | number): Promise<ApiResponse> {
    return this.request(`/tips/${id}`);
  }

  async getTipsFresh(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/tips${queryString ? `?${queryString}` : ''}`;
    return this.requestFresh(endpoint);
  }

  async getTipFresh(id: string | number): Promise<ApiResponse> {
    return this.requestFresh(`/tips/${id}`);
  }

  // EVENTS - Méthodes identiques Vue
  async getEvents(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/events${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async getEvent(id: string | number): Promise<ApiResponse> {
    return this.request(`/events/${id}`);
  }

  async getEventsFresh(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/events${queryString ? `?${queryString}` : ''}`;
    return this.requestFresh(endpoint);
  }

  async getEventFresh(id: string | number): Promise<ApiResponse> {
    return this.requestFresh(`/events/${id}`);
  }

  // PAGES - Méthodes identiques Vue
  async getPages(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/pages${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async getPage(id: string | number): Promise<ApiResponse> {
    return this.request(`/pages/${id}`);
  }

  // DINOR TV - Méthodes identiques Vue
  async getVideos(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/dinor-tv${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async getVideo(id: string | number): Promise<ApiResponse> {
    return this.request(`/dinor-tv/${id}`);
  }

  async getVideosFresh(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/dinor-tv${queryString ? `?${queryString}` : ''}`;
    return this.requestFresh(endpoint);
  }

  async getVideoFresh(id: string | number): Promise<ApiResponse> {
    return this.requestFresh(`/dinor-tv/${id}`);
  }

  // LIKES - Méthode identique Vue
  async toggleLike(type: string, id: string | number): Promise<ApiResponse> {
    const result = await this.request(`/${type}/${id}/like`, {
      method: 'POST'
    });
    
    console.log('🔄 [API] Communication directe avec l\'API pour toggle like:', type, id);
    return result;
  }

  // COMMENTS - Méthodes identiques Vue
  async getComments(type: string, id: string | number): Promise<ApiResponse> {
    return this.request(`/${type}/${id}/comments`);
  }

  async addComment(type: string, id: string | number, content: string): Promise<ApiResponse> {
    return this.request(`/${type}/${id}/comments`, {
      method: 'POST',
      body: { content }
    });
  }

  // CATEGORIES - Méthodes identiques Vue
  async getCategories(): Promise<ApiResponse> {
    return this.request('/categories');
  }

  async getEventCategories(): Promise<ApiResponse> {
    return this.request('/categories/events');
  }

  async getRecipeCategories(): Promise<ApiResponse> {
    return this.request('/categories/recipes');
  }

  // SEARCH - Méthode identique Vue
  async search(query: string, type?: string): Promise<ApiResponse> {
    const params: Record<string, string> = { q: query };
    if (type) params.type = type;
    
    const queryString = new URLSearchParams(params).toString();
    return this.request(`/search?${queryString}`);
  }

  // FAVORITES - Méthodes identiques Vue
  async getFavorites(params: Record<string, any> = {}): Promise<ApiResponse> {
    const queryString = new URLSearchParams(params).toString();
    const endpoint = `/favorites${queryString ? `?${queryString}` : ''}`;
    return this.request(endpoint);
  }

  async toggleFavorite(favoritable_type: string, favoritable_id: string | number): Promise<ApiResponse> {
    return this.request('/favorites/toggle', {
      method: 'POST',
      body: {
        type: favoritable_type,
        id: favoritable_id
      }
    });
  }

  async checkFavorite(type: string, id: string | number): Promise<ApiResponse> {
    const params = new URLSearchParams({ type, id: id.toString() });
    return this.request(`/favorites/check?${params}`);
  }

  async removeFavorite(favoriteId: string | number): Promise<ApiResponse> {
    return this.request(`/favorites/${favoriteId}`, {
      method: 'DELETE'
    });
  }

  // AUTH - Méthodes pour authentification
  async login(email: string, password: string): Promise<ApiResponse> {
    return this.request('/auth/login', {
      method: 'POST',
      body: { email, password }
    });
  }

  async register(name: string, email: string, password: string): Promise<ApiResponse> {
    return this.request('/auth/register', {
      method: 'POST',
      body: { name, email, password }
    });
  }

  async logout(): Promise<ApiResponse> {
    return this.request('/auth/logout', {
      method: 'POST'
    });
  }

  async getProfile(): Promise<ApiResponse> {
    return this.request('/auth/profile');
  }
}

export default new ApiService();