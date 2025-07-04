<template>
  <button
    @click="handleToggle"
    class="like-button"
    :class="{ 
      'is-liked': isLiked, 
      'is-loading': loading,
      'is-disabled': !canInteract 
    }"
    :disabled="loading || !canInteract"
    :title="isLiked ? 'Retirer le like' : 'Aimer ce contenu'"
  >
    <!-- Loading state -->
    <div v-if="loading" class="loading-spinner"></div>
    
    <!-- Heart icon with animation -->
    <div v-else class="heart-container" @click.stop="handleToggle">
      <span class="material-symbols-outlined heart-icon">
        {{ isLiked ? 'favorite' : 'favorite_border' }}
      </span>
      <span class="emoji-fallback">
        {{ isLiked ? '❤️' : '🤍' }}
      </span>
    </div>
    
    <!-- Optional count display -->
    <span v-if="showCount && likesCount > 0" class="like-count">
      {{ formatCount(likesCount) }}
    </span>
  </button>
</template>

<script>
import { ref, computed, watch, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import apiService from '@/services/api'

export default {
  name: 'LikeButton',
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
    initialLiked: {
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
  emits: ['update:liked', 'update:count', 'auth-required'],
  setup(props, { emit }) {
    const authStore = useAuthStore()
    
    const loading = ref(false)
    const isLiked = ref(props.initialLiked)
    const likesCount = ref(props.initialCount)
    
    const canInteract = computed(() => {
      return authStore.isAuthenticated
    })
    
    const formatCount = (count) => {
      if (count < 1000) return count.toString()
      if (count < 1000000) return `${Math.floor(count / 1000)}k`
      return `${Math.floor(count / 1000000)}M`
    }
    
    const loadLikeStatus = async () => {
      if (!authStore.isAuthenticated || !props.itemId) {
        isLiked.value = false
        return
      }
      
      try {
        const data = await apiService.request(`/likes/check?type=${props.type}&id=${props.itemId}`)
        if (data.success) {
          isLiked.value = data.is_liked
          // Update count from server if available
          if (typeof data.likes_count === 'number') {
            likesCount.value = data.likes_count
          }
        }
      } catch (error) {
        console.warn('Erreur lors de la vérification du statut like:', error)
      }
    }
    
    const handleToggle = async () => {
      console.log('👍 [LikeButton] Clic détecté sur bouton like', {
        type: props.type,
        itemId: props.itemId,
        isAuthenticated: authStore.isAuthenticated
      })
      
      if (!authStore.isAuthenticated) {
        console.log('🔒 [LikeButton] Utilisateur non connecté')
        emit('auth-required')
        return
      }
      
      if (loading.value) {
        console.log('⏳ [LikeButton] Déjà en cours de chargement')
        return
      }
      
      loading.value = true
      const previousState = isLiked.value
      const previousCount = likesCount.value
      
      // Optimistic update
      isLiked.value = !isLiked.value
      likesCount.value += isLiked.value ? 1 : -1
      
      try {
        const data = await apiService.request('/likes/toggle', {
          method: 'POST',
          body: {
            type: props.type,
            id: props.itemId
          }
        })
        
        if (data.success) {
          isLiked.value = data.action === 'liked'
          if (typeof data.likes_count === 'number') {
            likesCount.value = data.likes_count
          }
          
          // Emit events for parent components
          emit('update:liked', isLiked.value)
          emit('update:count', likesCount.value)
          
          // Émettre un événement global pour informer les autres composants
          window.dispatchEvent(new CustomEvent('like-updated', {
            detail: {
              type: props.type,
              id: props.itemId,
              liked: isLiked.value,
              count: likesCount.value,
              favorited: data.favorite_action === 'favorited',
              favoritesCount: data.favorites_count || 0
            }
          }))
          
          console.log('👍 [Likes] Toggle réussi:', {
            type: props.type,
            id: props.itemId,
            liked: isLiked.value,
            count: likesCount.value,
            favorited: data.favorite_action === 'favorited',
            favoritesCount: data.favorites_count
          })
        } else {
          throw new Error(data.message || 'Erreur lors de la mise à jour des likes')
        }
      } catch (error) {
        console.error('❌ [Likes] Erreur toggle:', error)
        
        // Revert optimistic update
        isLiked.value = previousState
        likesCount.value = previousCount
        
        // Gestion améliorée des erreurs d'authentification
        if (error.status === 401 || error.type === 'AUTH_REQUIRED') {
          emit('auth-required', {
            context: 'aimer ce contenu',
            error: error
          })
        }
      } finally {
        loading.value = false
      }
    }
    
    // Watch for auth changes
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadLikeStatus()
      } else {
        isLiked.value = false
      }
    })
    
    // Watch for prop changes
    watch(() => props.initialLiked, (newVal) => {
      isLiked.value = newVal
    })
    
    watch(() => props.initialCount, (newVal) => {
      likesCount.value = newVal
    })
    
    // Listen for global like updates
    const handleGlobalLikeUpdate = (event) => {
      const { type, id, liked, count } = event.detail
      if (type === props.type && id == props.itemId) {
        isLiked.value = liked
        likesCount.value = count
      }
    }
    
    onMounted(() => {
      if (authStore.isAuthenticated) {
        loadLikeStatus()
      }
      
      // Listen for global like updates
      window.addEventListener('like-updated', handleGlobalLikeUpdate)
    })
    
    return {
      loading,
      isLiked,
      likesCount,
      canInteract,
      formatCount,
      handleToggle
    }
  }
}
</script>

<style scoped>
.like-button {
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

.like-button:hover:not(.is-disabled) {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
  transform: scale(1.05);
}

.like-button.is-liked {
  color: var(--dinor-primary, #E1251B);
}

.like-button.is-liked .heart-icon {
  animation: heartBeat 0.6s ease-in-out;
}

.like-button.is-loading {
  cursor: wait;
  opacity: 0.7;
}

.like-button.is-disabled {
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

.like-count {
  font-size: 12px;
  font-weight: 500;
  min-width: 0;
  white-space: nowrap;
}

/* Size variants */
.like-button.size-small {
  padding: 4px;
}

.like-button.size-small .heart-icon {
  font-size: 16px;
}

.like-button.size-small .emoji-fallback {
  font-size: 14px;
}

.like-button.size-large {
  padding: 12px;
}

.like-button.size-large .heart-icon {
  font-size: 24px;
}

.like-button.size-large .emoji-fallback {
  font-size: 20px;
}

/* Variant styles */
.like-button.variant-compact {
  padding: 4px 8px;
  border-radius: 16px;
  background: var(--md-sys-color-surface-container-low, #f7f2fa);
}

.like-button.variant-minimal {
  padding: 2px;
}

.like-button.variant-minimal:hover {
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
  .like-button {
    padding: 6px;
  }
  
  .heart-icon {
    font-size: 18px;
  }
  
  .emoji-fallback {
    font-size: 15px;
  }
  
  .like-count {
    font-size: 11px;
  }
}
</style> 