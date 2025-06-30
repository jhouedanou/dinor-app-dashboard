<template>
  <button
    @click="handleToggle"
    class="favorite-button"
    :class="{ 
      'is-favorited': isFavorited, 
      'is-loading': loading,
      'is-disabled': !canInteract 
    }"
    :disabled="loading || !canInteract"
    :title="isFavorited ? 'Retirer des favoris' : 'Ajouter aux favoris'"
  >
    <!-- Loading state -->
    <div v-if="loading" class="loading-spinner"></div>
    
    <!-- Heart icon with animation -->
    <div v-else class="heart-container" @click.stop="handleToggle">
      <span class="material-symbols-outlined heart-icon">
        {{ isFavorited ? 'favorite' : 'favorite_border' }}
      </span>
      <span class="emoji-fallback">
        {{ isFavorited ? '❤️' : '🤍' }}
      </span>
    </div>
    
    <!-- Optional count display -->
    <span v-if="showCount && favoritesCount > 0" class="favorite-count">
      {{ formatCount(favoritesCount) }}
    </span>
  </button>
</template>

<script>
import { ref, computed, watch, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import apiService from '@/services/api'

export default {
  name: 'FavoriteButton',
  props: {
    type: {
      type: String,
      required: true,
      validator: (value) => ['recipe', 'tip', 'event', 'dinor_tv'].includes(value)
    },
    itemId: {
      type: [Number, String],
      required: true
    },
    initialFavorited: {
      type: Boolean,
      default: false
    },
    initialCount: {
      type: Number,
      default: 0
    },
    showCount: {
      type: Boolean,
      default: true
    },
    size: {
      type: String,
      default: 'medium',
      validator: (value) => ['small', 'medium', 'large'].includes(value)
    },
    variant: {
      type: String,
      default: 'default',
      validator: (value) => ['default', 'compact', 'minimal'].includes(value)
    }
  },
  emits: ['update:favorited', 'update:count', 'auth-required'],
  setup(props, { emit }) {
    const authStore = useAuthStore()
    
    const loading = ref(false)
    const isFavorited = ref(props.initialFavorited)
    const favoritesCount = ref(props.initialCount)
    
    const canInteract = computed(() => {
      return authStore.isAuthenticated
    })
    
    const formatCount = (count) => {
      if (count < 1000) return count.toString()
      if (count < 1000000) return `${Math.floor(count / 1000)}k`
      return `${Math.floor(count / 1000000)}M`
    }
    
    const loadFavoriteStatus = async () => {
      if (!authStore.isAuthenticated) {
        isFavorited.value = false
        return
      }
      
      try {
        const data = await apiService.checkFavorite(props.type, props.itemId)
        if (data.success) {
          isFavorited.value = data.is_favorited
        }
      } catch (error) {
        console.warn('Erreur lors de la vérification du statut favori:', error)
      }
    }
    
    const handleToggle = async () => {
      console.log('🌟 [FavoriteButton] Clic détecté sur bouton favori', {
        type: props.type,
        itemId: props.itemId,
        isAuthenticated: authStore.isAuthenticated
      })
      
      if (!authStore.isAuthenticated) {
        console.log('🔒 [FavoriteButton] Utilisateur non connecté')
        emit('auth-required')
        return
      }
      
      if (loading.value) {
        console.log('⏳ [FavoriteButton] Déjà en cours de chargement')
        return
      }
      
      loading.value = true
      const previousState = isFavorited.value
      const previousCount = favoritesCount.value
      
      // Optimistic update
      isFavorited.value = !isFavorited.value
      favoritesCount.value += isFavorited.value ? 1 : -1
      
      try {
        const data = await apiService.toggleFavorite(props.type, props.itemId)
        
        if (data.success) {
          isFavorited.value = data.is_favorited
          if (data.data && typeof data.data.total_favorites === 'number') {
            favoritesCount.value = data.data.total_favorites
          }
          
          // Emit events for parent components
          emit('update:favorited', isFavorited.value)
          emit('update:count', favoritesCount.value)
          
          console.log('🌟 [Favorites] Toggle réussi:', {
            type: props.type,
            id: props.itemId,
            favorited: isFavorited.value,
            count: favoritesCount.value
          })
        } else {
          throw new Error(data.message || 'Erreur lors de la mise à jour des favoris')
        }
      } catch (error) {
        console.error('❌ [Favorites] Erreur toggle:', error)
        
        // Revert optimistic update
        isFavorited.value = previousState
        favoritesCount.value = previousCount
        
        // Show error message (you could emit an error event here)
        if (error.message.includes('401')) {
          emit('auth-required')
        }
      } finally {
        loading.value = false
      }
    }
    
    // Watch for auth changes
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadFavoriteStatus()
      } else {
        isFavorited.value = false
      }
    })
    
    // Watch for prop changes
    watch(() => props.initialFavorited, (newVal) => {
      isFavorited.value = newVal
    })
    
    watch(() => props.initialCount, (newVal) => {
      favoritesCount.value = newVal
    })
    
    onMounted(() => {
      if (authStore.isAuthenticated) {
        loadFavoriteStatus()
      }
    })
    
    return {
      loading,
      isFavorited,
      favoritesCount,
      canInteract,
      formatCount,
      handleToggle
    }
  }
}
</script>

<style scoped>
.favorite-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: transparent;
  border: none;
  cursor: pointer;
  border-radius: 50%;
  transition: all 0.2s ease;
  position: relative;
  padding: 8px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.favorite-button:hover:not(.is-disabled) {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
  transform: scale(1.05);
}

.favorite-button.is-favorited {
  color: var(--dinor-primary, #E1251B);
}

.favorite-button.is-favorited .heart-icon {
  animation: heartBeat 0.6s ease-in-out;
}

.favorite-button.is-loading {
  cursor: wait;
  opacity: 0.7;
}

.favorite-button.is-disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 2px solid var(--dinor-primary, #E1251B);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.heart-container {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.heart-icon {
  font-size: 20px;
  transition: all 0.2s ease;
  cursor: pointer;
  user-select: none;
}

.emoji-fallback {
  display: none;
  font-size: 16px;
}

/* Force emoji mode */
.force-emoji .heart-icon {
  display: none;
}

.force-emoji .emoji-fallback {
  display: block;
}

.favorite-count {
  font-size: 12px;
  font-weight: 500;
  min-width: 0;
  white-space: nowrap;
}

/* Size variants */
.favorite-button.size-small {
  padding: 4px;
}

.favorite-button.size-small .heart-icon {
  font-size: 16px;
}

.favorite-button.size-small .emoji-fallback {
  font-size: 14px;
}

.favorite-button.size-large {
  padding: 12px;
}

.favorite-button.size-large .heart-icon {
  font-size: 24px;
}

.favorite-button.size-large .emoji-fallback {
  font-size: 20px;
}

/* Variant styles */
.favorite-button.variant-compact {
  padding: 4px 8px;
  border-radius: 16px;
  background: var(--md-sys-color-surface-container-low, #f7f2fa);
}

.favorite-button.variant-minimal {
  padding: 2px;
}

.favorite-button.variant-minimal:hover {
  background: transparent;
  transform: scale(1.1);
}

/* Animations */
@keyframes heartBeat {
  0% {
    transform: scale(1);
  }
  25% {
    transform: scale(1.2);
  }
  50% {
    transform: scale(1);
  }
  75% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Responsive design */
@media (max-width: 768px) {
  .favorite-button {
    padding: 6px;
  }
  
  .heart-icon {
    font-size: 18px;
  }
  
  .emoji-fallback {
    font-size: 15px;
  }
  
  .favorite-count {
    font-size: 11px;
  }
}
</style> 