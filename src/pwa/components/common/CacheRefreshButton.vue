<template>
  <button 
    @click="handleRefresh"
    :disabled="loading"
    class="cache-refresh-btn"
    :class="{ 'loading': loading }"
    :title="tooltip"
  >
    <i class="material-icons">{{ icon }}</i>
    <span v-if="showText" class="btn-text">{{ buttonText }}</span>
    <div v-if="loading" class="loading-spinner"></div>
  </button>
</template>

<script>
import { ref, computed } from 'vue'
import { useApiStore } from '@/stores/api'

export default {
  name: 'CacheRefreshButton',
  props: {
    showText: {
      type: Boolean,
      default: false
    },
    variant: {
      type: String,
      default: 'icon', // 'icon', 'text', 'full'
      validator: value => ['icon', 'text', 'full'].includes(value)
    },
    size: {
      type: String,
      default: 'medium', // 'small', 'medium', 'large'
      validator: value => ['small', 'medium', 'large'].includes(value)
    },
    pattern: {
      type: String,
      default: '' // Pattern spécifique pour invalider
    }
  },
  emits: ['refresh', 'error'],
  setup(props, { emit }) {
    const apiStore = useApiStore()
    const loading = ref(false)

    const buttonText = computed(() => {
      if (loading.value) return 'Actualisation...'
      return 'Actualiser'
    })

    const icon = computed(() => {
      if (loading.value) return 'refresh'
      return 'refresh'
    })

    const tooltip = computed(() => {
      if (loading.value) return 'Actualisation en cours...'
      return props.pattern 
        ? `Actualiser le cache pour ${props.pattern}`
        : 'Actualiser tout le cache'
    })

    const handleRefresh = async () => {
      if (loading.value) return

      loading.value = true
      
      try {
        console.log('🔄 Début de l\'actualisation du cache...')
        
        if (props.pattern) {
          // Invalider un pattern spécifique
          if (typeof apiStore.invalidateCache === 'function') {
            apiStore.invalidateCache(props.pattern)
            console.log('🔄 Cache invalidé pour le pattern:', props.pattern)
          } else {
            console.warn('⚠️ Méthode invalidateCache non disponible')
          }
        } else {
          // Forcer le rechargement complet
          if (typeof apiStore.forceRefresh === 'function') {
            apiStore.forceRefresh()
            console.log('🔄 Rechargement forcé du cache')
          } else if (typeof apiStore.clearAllCache === 'function') {
            apiStore.clearAllCache()
            console.log('🔄 Cache complètement vidé')
          } else {
            console.warn('⚠️ Aucune méthode de refresh disponible')
            // Fallback : recharger la page
            window.location.reload()
            return
          }
        }

        // Attendre un peu pour que l'invalidation se propage
        await new Promise(resolve => setTimeout(resolve, 1000))

        // Émettre l'événement de succès
        emit('refresh', { success: true, pattern: props.pattern })

        // Afficher une notification de succès
        showNotification('Cache actualisé avec succès', 'success')

        // Recharger la page après un délai pour s'assurer que les données sont à jour
        setTimeout(() => {
          window.location.reload()
        }, 1500)

      } catch (error) {
        console.error('❌ Erreur lors de l\'actualisation du cache:', error)
        emit('error', error)
        showNotification('Erreur lors de l\'actualisation', 'error')
      } finally {
        loading.value = false
      }
    }

    const showNotification = (message, type = 'info') => {
      // Créer une notification simple
      const notification = document.createElement('div')
      notification.className = `cache-notification ${type}`
      notification.textContent = message
      
      // Styles de base
      Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '12px 16px',
        borderRadius: '8px',
        color: 'white',
        fontSize: '14px',
        fontWeight: '500',
        zIndex: '9999',
        transform: 'translateX(100%)',
        transition: 'transform 0.3s ease',
        maxWidth: '300px',
        wordWrap: 'break-word'
      })

      // Couleurs selon le type
      if (type === 'success') {
        notification.style.backgroundColor = '#10B981'
      } else if (type === 'error') {
        notification.style.backgroundColor = '#EF4444'
      } else {
        notification.style.backgroundColor = '#3B82F6'
      }

      document.body.appendChild(notification)

      // Animation d'entrée
      setTimeout(() => {
        notification.style.transform = 'translateX(0)'
      }, 100)

      // Suppression automatique
      setTimeout(() => {
        notification.style.transform = 'translateX(100%)'
        setTimeout(() => {
          if (notification.parentNode) {
            notification.parentNode.removeChild(notification)
          }
        }, 300)
      }, 3000)
    }

    return {
      loading,
      buttonText,
      icon,
      tooltip,
      handleRefresh
    }
  }
}
</script>

<style scoped>
.cache-refresh-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
  font-weight: 500;
  position: relative;
  overflow: hidden;
}

.cache-refresh-btn:hover:not(:disabled) {
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(103, 80, 164, 0.3);
}

.cache-refresh-btn:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(103, 80, 164, 0.2);
}

.cache-refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.cache-refresh-btn.loading {
  pointer-events: none;
}

/* Tailles */
.cache-refresh-btn.small {
  padding: 6px 8px;
  font-size: 12px;
}

.cache-refresh-btn.medium {
  padding: 8px 12px;
  font-size: 14px;
}

.cache-refresh-btn.large {
  padding: 12px 16px;
  font-size: 16px;
}

/* Variantes */
.cache-refresh-btn.icon {
  min-width: 40px;
  min-height: 40px;
}

.cache-refresh-btn.text {
  padding: 8px 16px;
}

.cache-refresh-btn.full {
  padding: 12px 20px;
  min-width: 120px;
}

/* Icône */
.cache-refresh-btn .material-icons {
  font-size: 18px;
  transition: transform 0.3s ease;
}

.cache-refresh-btn.loading .material-icons {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Spinner de chargement */
.loading-spinner {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Texte du bouton */
.btn-text {
  white-space: nowrap;
}

/* Responsive */
@media (max-width: 768px) {
  .cache-refresh-btn.full {
    padding: 10px 16px;
    min-width: 100px;
    font-size: 14px;
  }
  
  .cache-refresh-btn .btn-text {
    display: none;
  }
}

/* Notification styles */
.cache-notification {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.cache-notification.success {
  border-left: 4px solid #059669;
}

.cache-notification.error {
  border-left: 4px solid #DC2626;
}

.cache-notification.info {
  border-left: 4px solid #2563EB;
}
</style> 