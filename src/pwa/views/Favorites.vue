<template>
  <div class="favorites-page">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p class="md3-body-large">Chargement de vos favoris...</p>
    </div>

    <!-- Not Authenticated State -->
    <div v-else-if="!authStore.isAuthenticated" class="auth-required-state">
      <div class="auth-icon">
        <DinorIcon name="account_circle" :size="40" />
      </div>
      <h2 class="md3-title-large">Connexion requise</h2>
      <p class="md3-body-large dinor-text-gray">
        Connectez-vous pour voir vos contenus favoris
      </p>
      <button @click="showAuthModal = true" class="btn-primary">
        Se connecter
      </button>
    </div>

    <!-- Favorites Content -->
    <div v-else class="favorites-content">
      <!-- Header -->
      <div class="page-header">
        <h1 class="md3-title-large">Mes Favoris</h1>
        <p class="md3-body-medium dinor-text-gray">
          {{ totalFavorites }} {{ totalFavorites > 1 ? 'favoris' : 'favori' }}
        </p>
      </div>

      <!-- Filter Tabs -->
      <div class="filter-tabs" v-if="totalFavorites > 0">
        <button 
          v-for="tab in filterTabs" 
          :key="tab.key"
          @click="selectedFilter = tab.key"
          class="filter-tab"
          :class="{ active: selectedFilter === tab.key }"
        >
          <DinorIcon :name="tab.icon" :size="20" />
          <span>{{ tab.label }}</span>
          <span class="count" v-if="getFilterCount(tab.key) > 0">
            {{ getFilterCount(tab.key) }}
          </span>
        </button>
      </div>

      <!-- Favorites List -->
      <div v-if="filteredFavorites.length > 0" class="favorites-list">
        <div 
          v-for="favorite in filteredFavorites" 
          :key="favorite.id"
          class="favorite-item md3-card"
          @click="goToContent(favorite)"
        >
          <!-- Content Image -->
          <div class="favorite-image">
            <img 
              :src="favorite.content.image || getDefaultImage(favorite.type)" 
              :alt="favorite.content.title"
              @error="handleImageError"
            >
            <div class="content-type-badge">
              <DinorIcon :name="getTypeIcon(favorite.type)" :size="14" />
            </div>
          </div>

          <!-- Content Info -->
          <div class="favorite-info">
            <h3 class="favorite-title md3-title-medium">{{ favorite.content.title }}</h3>
            <p class="favorite-description md3-body-medium dinor-text-gray">
              {{ getShortDescription(favorite.content.description) }}
            </p>
            
            <!-- Meta Info -->
            <div class="favorite-meta">
              <span class="favorite-date md3-body-small dinor-text-gray">
                <DinorIcon name="schedule" :size="16" />
                Ajouté {{ formatDate(favorite.favorited_at) }}
              </span>
              
              <!-- Content Stats -->
              <div class="content-stats">
                <span class="stat" v-if="favorite.content.likes_count > 0">
                  <DinorIcon name="thumb_up" :size="14" />
                  {{ favorite.content.likes_count }}
                </span>
                <span class="stat" v-if="favorite.content.comments_count > 0">
                  <DinorIcon name="comment" :size="14" />
                  {{ favorite.content.comments_count }}
                </span>
              </div>
            </div>
          </div>

          <!-- Favorite Button -->
          <div class="favorite-actions">
            <FavoriteButton
              :type="favorite.type"
              :item-id="favorite.content.id"
              :initial-favorited="true"
              :initial-count="favorite.content.favorites_count || 0"
              :show-count="false"
              size="medium"
              @update:favorited="handleFavoriteUpdate(favorite, $event)"
              @click.stop=""
            />
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="!loading" class="empty-state">
        <div class="empty-icon">
          <DinorIcon name="favorite_border" :size="40" />
        </div>
        <h2 class="md3-title-medium">{{ getEmptyTitle() }}</h2>
        <p class="md3-body-medium dinor-text-gray">{{ getEmptyMessage() }}</p>
        <button @click="goToExplore" class="btn-primary">
          {{ getExploreButtonText() }}
        </button>
      </div>
    </div>

    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" @authenticated="loadFavorites" />
  </div>
</template>

<script>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import apiService from '@/services/api'
import FavoriteButton from '@/components/common/FavoriteButton.vue'
import AuthModal from '@/components/common/AuthModal.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'Favorites',
  components: {
    FavoriteButton,
    AuthModal,
    DinorIcon
  },
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    
    // State
    const favorites = ref([])
    const loading = ref(false)
    const showAuthModal = ref(false)
    const selectedFilter = ref('all')
    
    // Filter configuration
    const filterTabs = ref([
      { key: 'all', label: 'Tout', icon: 'apps', emoji: '📱' },
      { key: 'recipe', label: 'Recettes', icon: 'restaurant', emoji: '🍽️' },
      { key: 'tip', label: 'Astuces', icon: 'lightbulb', emoji: '💡' },
      { key: 'event', label: 'Événements', icon: 'event', emoji: '📅' },
      { key: 'dinor_tv', label: 'Vidéos', icon: 'play_circle', emoji: '📺' }
    ])
    
    // Computed
    const totalFavorites = computed(() => favorites.value.length)
    
    const filteredFavorites = computed(() => {
      if (selectedFilter.value === 'all') {
        return favorites.value
      }
      return favorites.value.filter(favorite => favorite.type === selectedFilter.value)
    })
    
    // Methods
    const loadFavorites = async () => {
      if (!authStore.isAuthenticated) {
        favorites.value = []
        return
      }
      
      loading.value = true
      try {
        const data = await apiService.getFavorites()
        if (data.success) {
          favorites.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des favoris:', error)
      } finally {
        loading.value = false
      }
    }
    
    const getFilterCount = (filterKey) => {
      if (filterKey === 'all') return totalFavorites.value
      return favorites.value.filter(favorite => favorite.type === filterKey).length
    }
    
    const handleFavoriteUpdate = (favorite, isFavorited) => {
      if (!isFavorited) {
        // Remove from favorites list
        favorites.value = favorites.value.filter(f => f.id !== favorite.id)
      }
    }
    
    const goToContent = (favorite) => {
      const routes = {
        recipe: `/recipe/${favorite.content.id}`,
        tip: `/tip/${favorite.content.id}`,
        event: `/event/${favorite.content.id}`,
        dinor_tv: `/dinor-tv`
      }
      
      const route = routes[favorite.type]
      if (route) {
        router.push(route)
      }
    }
    
    const goToExplore = () => {
      const routes = {
        all: '/',
        recipe: '/recipes',
        tip: '/tips',
        event: '/events',
        dinor_tv: '/dinor-tv'
      }
      router.push(routes[selectedFilter.value] || '/')
    }
    
    // Utility functions
    const getTypeIcon = (type) => {
      const icons = {
        recipe: 'restaurant',
        tip: 'lightbulb',
        event: 'event',
        dinor_tv: 'play_circle'
      }
      return icons[type] || 'star'
    }
    
    const getTypeEmoji = (type) => {
      const emojis = {
        recipe: '🍽️',
        tip: '💡',
        event: '📅',
        dinor_tv: '📺'
      }
      return emojis[type] || '⭐'
    }
    
    const getDefaultImage = (type) => {
      const defaults = {
        recipe: '/images/default-recipe.jpg',
        tip: '/images/default-tip.jpg',
        event: '/images/default-event.jpg',
        dinor_tv: '/images/default-video-thumbnail.jpg'
      }
      return defaults[type] || '/images/default-content.jpg'
    }
    
    const getShortDescription = (description) => {
      if (!description) return 'Aucune description disponible'
      const text = description.replace(/<[^>]*>/g, '')
      return text.length > 120 ? text.substring(0, 120) + '...' : text
    }
    
    const formatDate = (dateString) => {
      const date = new Date(dateString)
      const now = new Date()
      const diffTime = Math.abs(now - date)
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      
      if (diffDays === 1) return 'hier'
      if (diffDays < 7) return `il y a ${diffDays} jours`
      if (diffDays < 30) return `il y a ${Math.ceil(diffDays / 7)} semaines`
      return date.toLocaleDateString('fr-FR', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
      })
    }
    
    const getEmptyTitle = () => {
      const titles = {
        all: 'Aucun favori',
        recipe: 'Aucune recette favorite',
        tip: 'Aucune astuce favorite',
        event: 'Aucun événement favori',
        dinor_tv: 'Aucune vidéo favorite'
      }
      return titles[selectedFilter.value] || 'Aucun favori'
    }
    
    const getEmptyMessage = () => {
      const messages = {
        all: 'Ajoutez du contenu à vos favoris en cliquant sur l\'icône cœur',
        recipe: 'Parcourez les recettes et ajoutez vos préférées aux favoris',
        tip: 'Découvrez des astuces utiles et sauvegardez-les',
        event: 'Trouvez des événements intéressants et ajoutez-les aux favoris',
        dinor_tv: 'Regardez des vidéos et ajoutez vos préférées aux favoris'
      }
      return messages[selectedFilter.value] || 'Commencez à explorer le contenu Dinor'
    }
    
    const getExploreButtonText = () => {
      const texts = {
        all: 'Explorer le contenu',
        recipe: 'Voir les recettes',
        tip: 'Voir les astuces',
        event: 'Voir les événements',
        dinor_tv: 'Voir les vidéos'
      }
      return texts[selectedFilter.value] || 'Explorer'
    }
    
    const handleImageError = (event) => {
      event.target.src = '/images/default-content.jpg'
    }
    
    // Watch auth state
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadFavorites()
      } else {
        favorites.value = []
      }
    }, { immediate: true })
    
    // Lifecycle
    onMounted(() => {
      if (authStore.isAuthenticated) {
        loadFavorites()
      }
    })
    
    return {
      authStore,
      favorites,
      loading,
      showAuthModal,
      selectedFilter,
      filterTabs,
      totalFavorites,
      filteredFavorites,
      loadFavorites,
      getFilterCount,
      handleFavoriteUpdate,
      goToContent,
      goToExplore,
      getTypeIcon,
      getTypeEmoji,
      getDefaultImage,
      getShortDescription,
      formatDate,
      getEmptyTitle,
      getEmptyMessage,
      getExploreButtonText,
      handleImageError
    }
  }
}
</script>

<style scoped>
.favorites-page {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

.loading-state,
.auth-required-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
  min-height: 60vh;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 4px solid var(--dinor-primary, #E1251B);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.auth-icon,
.empty-icon {
  width: 80px;
  height: 80px;
  background: var(--md-sys-color-primary-container, #ffdad6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.auth-icon .material-symbols-outlined,
.empty-icon .material-symbols-outlined {
  font-size: 40px;
  color: var(--dinor-primary, #E1251B);
}

.force-emoji .auth-icon .material-symbols-outlined,
.force-emoji .empty-icon .material-symbols-outlined {
  display: none;
}

.force-emoji .emoji-fallback {
  display: block;
  font-size: 40px;
}

.favorites-content {
  padding: 16px;
}

.page-header {
  margin-bottom: 24px;
  text-align: center;
}

.page-header h1 {
  margin: 0 0 8px 0;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.filter-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  overflow-x: auto;
  padding-bottom: 8px;
}

.filter-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: var(--md-sys-color-surface-container-low, #f7f2fa);
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.filter-tab:hover {
  background: var(--md-sys-color-surface-container, #f3edf7);
}

.filter-tab.active {
  background: var(--dinor-primary, #E1251B);
  color: white;
  border-color: var(--dinor-primary, #E1251B);
}

.filter-tab .material-symbols-outlined {
  font-size: 20px;
}

.filter-tab .count {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.filter-tab.active .count {
  background: rgba(255, 255, 255, 0.3);
}

.favorites-list {
  display: grid;
  gap: 16px;
}

.favorite-item {
  display: flex;
  gap: 16px;
  padding: 20px;
  background: var(--md-sys-color-surface-container-low, #f7f2fa);
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.favorite-item:hover {
  background: var(--md-sys-color-surface-container, #f3edf7);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.favorite-image {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 12px;
  overflow: hidden;
  flex-shrink: 0;
}

.favorite-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.content-type-badge {
  position: absolute;
  top: 6px;
  left: 6px;
  width: 24px;
  height: 24px;
  background: var(--dinor-primary, #E1251B);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.content-type-badge .material-symbols-outlined {
  font-size: 14px;
  color: white;
}

.favorite-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.favorite-title {
  margin: 0;
  color: var(--md-sys-color-on-surface, #1c1b1f);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-description {
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}

.favorite-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.favorite-date {
  display: flex;
  align-items: center;
  gap: 4px;
}

.favorite-date .material-symbols-outlined {
  font-size: 16px;
}

.content-stats {
  display: flex;
  gap: 12px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.stat .material-symbols-outlined {
  font-size: 14px;
}

.favorite-actions {
  display: flex;
  align-items: flex-start;
  padding-top: 4px;
}

.btn-primary {
  background: var(--dinor-primary, #E1251B);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 20px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: var(--dinor-primary-dark, #c1201a);
  transform: translateY(-1px);
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
  .favorites-content {
    padding: 12px;
  }
  
  .favorite-item {
    padding: 16px;
  }
  
  .favorite-image {
    width: 60px;
    height: 60px;
  }
  
  .filter-tabs {
    gap: 4px;
  }
  
  .filter-tab {
    padding: 8px 12px;
    font-size: 14px;
  }
}
</style> 