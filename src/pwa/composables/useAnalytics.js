/**
 * Composable Vue pour l'utilisation d'Analytics
 * Fournit une interface simple pour le suivi des événements
 */

import { ref, onMounted, onUnmounted } from 'vue'
import analyticsService from '@/services/analyticsService.js'

export function useAnalytics() {
  const isTracking = ref(false)
  const lastPageView = ref(null)

  /**
   * Initialiser le tracking pour un composant
   */
  const initializeTracking = () => {
    isTracking.value = true
  }

  /**
   * Suivre une page vue automatiquement
   */
  const trackPageView = (pagePath = null, pageTitle = null) => {
    const path = pagePath || window.location.pathname
    const title = pageTitle || document.title
    
    analyticsService.trackPageView(path, title)
    lastPageView.value = { path, title, timestamp: Date.now() }
  }

  /**
   * Suivre un clic sur un élément
   */
  const trackClick = (elementName, elementType = 'button', additionalData = {}) => {
    analyticsService.trackEvent('element_click', {
      element_name: elementName,
      element_type: elementType,
      page_path: window.location.pathname,
      ...additionalData
    })
  }

  /**
   * Suivre une interaction avec du contenu
   */
  const trackContentView = (contentType, contentId, contentTitle = null) => {
    analyticsService.trackContentInteraction('view', contentType, contentId, contentTitle)
  }

  const trackContentLike = (contentType, contentId, contentTitle = null) => {
    analyticsService.trackContentInteraction('like', contentType, contentId, contentTitle)
  }

  const trackContentShare = (contentType, contentId, contentTitle = null, shareMethod = null) => {
    analyticsService.trackContentInteraction('share', contentType, contentId, contentTitle)
    
    if (shareMethod) {
      analyticsService.trackSocialInteraction('share', shareMethod, `${contentType}:${contentId}`)
    }
  }

  const trackContentFavorite = (contentType, contentId, contentTitle = null, action = 'add') => {
    analyticsService.trackContentInteraction(action === 'add' ? 'favorite' : 'unfavorite', contentType, contentId, contentTitle)
  }

  /**
   * Suivre les interactions de navigation
   */
  const trackNavigation = (toPath, fromPath = null, method = 'click') => {
    const from = fromPath || (lastPageView.value ? lastPageView.value.path : window.location.pathname)
    analyticsService.trackNavigation(from, toPath, method)
  }

  /**
   * Suivre une recherche
   */
  const trackSearch = (searchTerm, resultsCount = null, filters = {}, searchType = 'general') => {
    analyticsService.trackSearch(searchTerm, resultsCount, { ...filters, search_type: searchType })
  }

  /**
   * Suivre les interactions avec les formulaires
   */
  const trackFormStart = (formName, formType = 'form') => {
    analyticsService.trackEvent('form_start', {
      form_name: formName,
      form_type: formType,
      page_path: window.location.pathname
    })
  }

  const trackFormSubmit = (formName, formType = 'form', success = true, errorMessage = null) => {
    analyticsService.trackEvent('form_submit', {
      form_name: formName,
      form_type: formType,
      success,
      error_message: errorMessage,
      page_path: window.location.pathname
    })
  }

  const trackFormFieldInteraction = (formName, fieldName, action = 'focus') => {
    analyticsService.trackEvent('form_field_interaction', {
      form_name: formName,
      field_name: fieldName,
      action,
      page_path: window.location.pathname
    })
  }

  /**
   * Suivre les erreurs de l'application
   */
  const trackError = (errorType, errorMessage, errorContext = {}) => {
    analyticsService.trackError(errorMessage, errorContext.stack, errorContext.page)
    analyticsService.trackEvent('app_error_detailed', {
      error_type: errorType,
      error_message: errorMessage,
      error_context: JSON.stringify(errorContext),
      page_path: window.location.pathname
    })
  }

  /**
   * Suivre les métriques de performance
   */
  const trackPerformance = (metricName, value, context = {}) => {
    analyticsService.trackPerformance(metricName, value)
    analyticsService.trackEvent('performance_metric', {
      metric_name: metricName,
      value,
      context: JSON.stringify(context),
      page_path: window.location.pathname
    })
  }

  /**
   * Suivre l'engagement utilisateur
   */
  const trackEngagement = (action, category, label = null, value = null) => {
    analyticsService.trackEngagement(action, category, label, value)
  }

  /**
   * Suivre les événements de temps passé
   */
  const trackTimeSpent = (elementName, timeSpent, elementType = 'content') => {
    analyticsService.trackEvent('time_spent', {
      element_name: elementName,
      element_type: elementType,
      time_spent: timeSpent,
      page_path: window.location.pathname
    })
  }

  /**
   * Suivre les événements PWA
   */
  const trackPWAInstall = (method = 'banner') => {
    analyticsService.trackEvent('pwa_install', {
      install_method: method,
      user_agent: navigator.userAgent
    })
  }

  const trackPWALaunch = (displayMode = 'browser') => {
    analyticsService.trackEvent('pwa_launch', {
      display_mode: displayMode,
      is_standalone: window.navigator.standalone || window.matchMedia('(display-mode: standalone)').matches
    })
  }

  /**
   * Créer un tracker pour un élément spécifique
   */
  const createElementTracker = (elementName, elementType = 'component') => {
    let startTime = null
    let isVisible = false

    return {
      onMount: () => {
        startTime = Date.now()
        analyticsService.trackEvent('component_mount', {
          element_name: elementName,
          element_type: elementType,
          page_path: window.location.pathname
        })
      },
      
      onUnmount: () => {
        if (startTime) {
          const duration = Date.now() - startTime
          analyticsService.trackEvent('component_unmount', {
            element_name: elementName,
            element_type: elementType,
            duration,
            page_path: window.location.pathname
          })
        }
      },
      
      onVisible: () => {
        if (!isVisible) {
          isVisible = true
          analyticsService.trackEvent('component_visible', {
            element_name: elementName,
            element_type: elementType,
            page_path: window.location.pathname
          })
        }
      },
      
      onHidden: () => {
        if (isVisible) {
          isVisible = false
          analyticsService.trackEvent('component_hidden', {
            element_name: elementName,
            element_type: elementType,
            page_path: window.location.pathname
          })
        }
      },

      track: (action, data = {}) => {
        analyticsService.trackEvent(`${elementName}_${action}`, {
          element_name: elementName,
          element_type: elementType,
          ...data,
          page_path: window.location.pathname
        })
      }
    }
  }

  /**
   * Hook de cycle de vie pour l'auto-tracking
   */
  onMounted(() => {
    initializeTracking()
  })

  onUnmounted(() => {
    isTracking.value = false
  })

  return {
    // État
    isTracking,
    lastPageView,
    
    // Méthodes de base
    initializeTracking,
    trackPageView,
    trackClick,
    
    // Suivi de contenu
    trackContentView,
    trackContentLike,
    trackContentShare,
    trackContentFavorite,
    
    // Navigation
    trackNavigation,
    
    // Recherche
    trackSearch,
    
    // Formulaires
    trackFormStart,
    trackFormSubmit,
    trackFormFieldInteraction,
    
    // Erreurs et performance
    trackError,
    trackPerformance,
    
    // Engagement
    trackEngagement,
    trackTimeSpent,
    
    // PWA
    trackPWAInstall,
    trackPWALaunch,
    
    // Utilitaires
    createElementTracker
  }
}