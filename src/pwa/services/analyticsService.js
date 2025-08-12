/**
 * Service de suivi des événements et analytics pour l'application PWA
 * Intégration avec Firebase Analytics et tracking local
 */

import { logEvent, setUserId, setUserProperties } from 'firebase/analytics'
import { initializeAnalytics, analyticsEnabled } from './firebaseConfig.js'

class AnalyticsService {
  constructor() {
    this.isInitialized = false
    this.eventQueue = []
    this.sessionId = this.generateSessionId()
    this.userId = null
    this.deviceInfo = this.getDeviceInfo()
    this.analytics = null
  }

  /**
   * Initialiser le service d'analytics
   */
  async initialize() {
    try {
      // Initialiser Firebase Analytics si activé
      if (analyticsEnabled) {
        this.analytics = await initializeAnalytics()
        if (this.analytics) {
          console.log('Firebase Analytics initialisé avec succès')
        }
      }
      
      this.isInitialized = true
      this.trackPageView(window.location.pathname)

      // Traiter la queue d'événements en attente
      this.processEventQueue()
      
      // Commencer le suivi de session
      this.startSessionTracking()
    } catch (error) {
      console.error('Erreur lors de l\'initialisation d\'Analytics:', error)
      this.isInitialized = true // Continuer avec le tracking local
    }
  }

  /**
   * Générer un ID de session unique
   */
  generateSessionId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2)
  }

  /**
   * Obtenir les informations de l'appareil
   */
  getDeviceInfo() {
    return {
      userAgent: navigator.userAgent,
      language: navigator.language,
      platform: navigator.platform,
      screenWidth: screen.width,
      screenHeight: screen.height,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
      isStandalone: window.navigator.standalone || window.matchMedia('(display-mode: standalone)').matches
    }
  }

  /**
   * Définir l'utilisateur actuel
   */
  setUser(userId, userProperties = {}) {
    this.userId = userId
    
    if (this.analytics) {
      try {
        setUserId(this.analytics, userId)
        setUserProperties(this.analytics, userProperties)
      } catch (error) {
        console.error('Erreur lors de la définition de l\'utilisateur:', error)
      }
    }

    // Stocker localement pour les analytics
    this.trackEvent('user_login', {
      user_id: userId,
      ...userProperties
    })
  }

  /**
   * Suivre une page vue
   */
  trackPageView(pagePath, pageTitle = null) {
    const event = {
      event_type: 'page_view',
      page_path: pagePath,
      page_title: pageTitle || document.title,
      timestamp: Date.now(),
      session_id: this.sessionId,
      user_id: this.userId
    }

    if (this.analytics) {
      try {
        logEvent(this.analytics, 'page_view', {
          page_path: pagePath,
          page_title: pageTitle || document.title
        })
      } catch (error) {
        console.error('Erreur lors du tracking de page vue:', error)
      }
    }

    this.sendEvent(event)
  }

  /**
   * Suivre un événement personnalisé
   */
  trackEvent(eventName, parameters = {}) {
    const event = {
      event_type: eventName,
      ...parameters,
      timestamp: Date.now(),
      session_id: this.sessionId,
      user_id: this.userId,
      device_info: this.deviceInfo
    }

    if (this.analytics) {
      try {
        logEvent(this.analytics, eventName, parameters)
      } catch (error) {
        console.error('Erreur lors du tracking d\'événement:', error)
      }
    }

    this.sendEvent(event)
  }

  /**
   * Suivre les interactions avec le contenu
   */
  trackContentInteraction(action, contentType, contentId, contentTitle = null) {
    this.trackEvent('content_interaction', {
      action,
      content_type: contentType,
      content_id: contentId,
      content_title: contentTitle,
      page_path: window.location.pathname
    })
  }

  /**
   * Suivre les actions de navigation
   */
  trackNavigation(fromPath, toPath, navigationMethod = 'click') {
    this.trackEvent('navigation', {
      from_path: fromPath,
      to_path: toPath,
      navigation_method: navigationMethod
    })
  }

  /**
   * Suivre les recherches
   */
  trackSearch(searchTerm, resultsCount = null, filters = {}) {
    this.trackEvent('search', {
      search_term: searchTerm,
      results_count: resultsCount,
      filters: JSON.stringify(filters)
    })
  }

  /**
   * Suivre les interactions sociales
   */
  trackSocialInteraction(action, network, target = null) {
    this.trackEvent('social_interaction', {
      action,
      network,
      target
    })
  }

  /**
   * Suivre les erreurs
   */
  trackError(errorMessage, errorStack = null, errorPage = null) {
    this.trackEvent('app_error', {
      error_message: errorMessage,
      error_stack: errorStack,
      error_page: errorPage || window.location.pathname,
      user_agent: navigator.userAgent
    })
  }

  /**
   * Suivre les performances
   */
  trackPerformance(metricName, value, unit = 'ms') {
    this.trackEvent('performance', {
      metric_name: metricName,
      value,
      unit
    })
  }

  /**
   * Suivre l'engagement utilisateur
   */
  trackEngagement(action, category, label = null, value = null) {
    this.trackEvent('user_engagement', {
      action,
      category,
      label,
      value
    })
  }

  /**
   * Envoyer un événement au backend ou Firebase
   */
  async sendEvent(event) {
    if (!this.isInitialized) {
      this.eventQueue.push(event)
      return
    }

    try {
      // Envoyer au backend Laravel
      await fetch('/api/analytics/event', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify(event)
      })
    } catch (error) {
      console.error('Erreur lors de l\'envoi de l\'événement:', error)
      // Stocker localement en cas d'échec
      this.storeEventLocally(event)
    }
  }

  /**
   * Stocker un événement localement
   */
  storeEventLocally(event) {
    try {
      const storedEvents = JSON.parse(localStorage.getItem('analytics_events') || '[]')
      storedEvents.push(event)
      
      // Garder seulement les 100 derniers événements
      if (storedEvents.length > 100) {
        storedEvents.splice(0, storedEvents.length - 100)
      }
      
      localStorage.setItem('analytics_events', JSON.stringify(storedEvents))
    } catch (error) {
      console.error('Erreur lors du stockage local:', error)
    }
  }

  /**
   * Traiter la queue d'événements en attente
   */
  processEventQueue() {
    while (this.eventQueue.length > 0) {
      const event = this.eventQueue.shift()
      this.sendEvent(event)
    }
  }

  /**
   * Commencer le suivi de session
   */
  startSessionTracking() {
    // Suivre le début de session
    this.trackEvent('session_start', {
      session_duration: 0
    })

    // Suivre la fin de session au déchargement
    window.addEventListener('beforeunload', () => {
      this.trackEvent('session_end', {
        session_duration: Date.now() - parseInt(this.sessionId, 36)
      })
    })

    // Suivre l'activité utilisateur
    let lastActivity = Date.now()
    let isActive = true

    const trackActivity = () => {
      lastActivity = Date.now()
      if (!isActive) {
        isActive = true
        this.trackEvent('user_active')
      }
    }

    // Événements d'activité
    ['click', 'scroll', 'keypress', 'touchstart'].forEach(eventType => {
      document.addEventListener(eventType, trackActivity, { passive: true })
    })

    // Vérifier l'inactivité toutes les minutes
    setInterval(() => {
      if (Date.now() - lastActivity > 60000 && isActive) {
        isActive = false
        this.trackEvent('user_inactive')
      }
    }, 60000)
  }

  /**
   * Obtenir les événements stockés localement
   */
  getLocalEvents() {
    try {
      return JSON.parse(localStorage.getItem('analytics_events') || '[]')
    } catch (error) {
      console.error('Erreur lors de la récupération des événements locaux:', error)
      return []
    }
  }

  /**
   * Vider les événements stockés localement
   */
  clearLocalEvents() {
    try {
      localStorage.removeItem('analytics_events')
    } catch (error) {
      console.error('Erreur lors de la suppression des événements locaux:', error)
    }
  }
}

// Instance globale
const analyticsService = new AnalyticsService()

// Auto-initialisation
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    analyticsService.initialize()
  })
} else {
  analyticsService.initialize()
}

export default analyticsService