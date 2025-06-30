<template>
  <div class="profile">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement du profil...</p>
    </div>

    <!-- Not Authenticated State -->
    <div v-else-if="!authStore.isAuthenticated" class="auth-required">
      <div class="auth-icon">
        <i class="material-icons">person</i>
      </div>
      <h2 class="md3-title-large">Profil utilisateur</h2>
      <p class="md3-body-large">Connectez-vous pour voir votre profil et vos favoris</p>
      <button @click="showAuthModal = true" class="btn-primary">
        Se connecter
      </button>
    </div>

    <!-- Authenticated Content -->
    <div v-else class="profile-content">
      <!-- User Info Section -->
      <div class="user-info-section">
        <div class="user-avatar">
          <i class="material-icons">person</i>
        </div>
        <div class="user-details">
          <h1 class="user-name">{{ authStore.userName }}</h1>
          <p class="user-email">{{ authStore.user?.email }}</p>
          <p class="member-since">Membre depuis {{ formatMemberSince(authStore.user?.created_at) }}</p>
        </div>
        <button @click="authStore.logout()" class="btn-logout">
          <i class="material-icons">logout</i>
          Déconnexion
        </button>
      </div>

      <!-- Stats Section -->
      <div class="user-stats">
        <div class="stat-card">
          <div class="stat-number">{{ totalFavorites }}</div>
          <div class="stat-label">Favoris</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ favoritesStats.recipes || 0 }}</div>
          <div class="stat-label">Recettes</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ favoritesStats.tips || 0 }}</div>
          <div class="stat-label">Astuces</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ favoritesStats.events || 0 }}</div>
          <div class="stat-label">Événements</div>
        </div>
      </div>

      <!-- Favorites Section -->
      <div class="favorites-section">
        <div class="section-header">
          <h2 class="section-title">Mes Favoris</h2>
          <div class="filter-tabs">
            <button 
              v-for="tab in filterTabs" 
              :key="tab.key"
              @click="selectedFilter = tab.key"
              class="filter-tab"
              :class="{ active: selectedFilter === tab.key }"
            >
              <i class="material-icons">{{ tab.icon }}</i>
              <span>{{ tab.label }}</span>
            </button>
          </div>
        </div>

        <!-- Favorites List -->
        <div v-if="filteredFavorites.length" class="favorites-list">
          <div 
            v-for="favorite in filteredFavorites" 
            :key="favorite.id"
            @click="goToContent(favorite)"
            class="favorite-item"
          >
            <div class="favorite-image">
              <img 
                :src="favorite.content.image || getDefaultImage(favorite.type)" 
                :alt="favorite.content.title"
                @error="handleImageError"
              >
              <div class="favorite-type-badge">
                <i class="material-icons">{{ getTypeIcon(favorite.type) }}</i>
              </div>
            </div>
            <div class="favorite-info">
              <h3 class="favorite-title">{{ favorite.content.title }}</h3>
              <p class="favorite-description">
                {{ getShortDescription(favorite.content.description) }}
              </p>
              <div class="favorite-meta">
                <span class="favorite-date">
                  Ajouté {{ formatDate(favorite.favorited_at) }}
                </span>
                <div class="favorite-stats">
                  <span class="stat">
                    <i class="material-icons">favorite</i>
                    {{ favorite.content.likes_count || 0 }}
                  </span>
                  <span class="stat">
                    <i class="material-icons">comment</i>
                    {{ favorite.content.comments_count || 0 }}
                  </span>
                </div>
              </div>
            </div>
            <button 
              @click.stop="removeFavorite(favorite)"
              class="remove-favorite"
              title="Retirer des favoris"
            >
              <i class="material-icons">close</i>
            </button>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-favorites">
          <div class="empty-icon">
            <i class="material-icons">favorite_border</i>
          </div>
          <h3>{{ getEmptyMessage() }}</h3>
          <p>{{ getEmptyDescription() }}</p>
          <router-link :to="getExploreLink()" class="btn-secondary">
            Découvrir du contenu
          </router-link>
        </div>
      </div>
    </div>

    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useApiStore } from '@/stores/api'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'Profile',
  components: {
    AuthModal
  },
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    const apiStore = useApiStore()

    const loading = ref(false)
    const showAuthModal = ref(false)
    const favorites = ref([])
    const selectedFilter = ref('all')

    const filterTabs = ref([
      { key: 'all', label: 'Tout', icon: 'apps' },
      { key: 'recipe', label: 'Recettes', icon: 'restaurant' },
      { key: 'tip', label: 'Astuces', icon: 'lightbulb' },
      { key: 'event', label: 'Événements', icon: 'event' },
      { key: 'dinor_tv', label: 'Vidéos', icon: 'play_circle' }
    ])

    const totalFavorites = computed(() => favorites.value.length)

    const favoritesStats = computed(() => {
      const stats = {}
      favorites.value.forEach(favorite => {
        const type = favorite.type === 'dinor_tv' ? 'videos' : `${favorite.type}s`
        stats[type] = (stats[type] || 0) + 1
      })
      return stats
    })

    const filteredFavorites = computed(() => {
      if (selectedFilter.value === 'all') {
        return favorites.value
      }
      return favorites.value.filter(favorite => favorite.type === selectedFilter.value)
    })

    const loadFavorites = async () => {
      if (!authStore.isAuthenticated) return

      loading.value = true
      try {
        const data = await apiStore.get('/favorites')
        if (data.success) {
          favorites.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des favoris:', error)
      } finally {
        loading.value = false
      }
    }

    const removeFavorite = async (favorite) => {
      if (!confirm('Êtes-vous sûr de vouloir retirer cet élément de vos favoris ?')) {
        return
      }

      try {
        const data = await apiStore.request(`/favorites/${favorite.id}`, {
          method: 'DELETE'
        })
        
        if (data.success) {
          favorites.value = favorites.value.filter(f => f.id !== favorite.id)
        }
      } catch (error) {
        console.error('Erreur lors de la suppression du favori:', error)
        alert('Erreur lors de la suppression du favori')
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

    const getTypeIcon = (type) => {
      const icons = {
        recipe: 'restaurant',
        tip: 'lightbulb',
        event: 'event',
        dinor_tv: 'play_circle'
      }
      return icons[type] || 'star'
    }

    const getDefaultImage = (type) => {
      const defaults = {
        recipe: '/images/default-recipe.jpg',
        tip: '/images/default-tip.jpg',
        event: '/images/default-event.jpg',
        dinor_tv: '/images/default-video.jpg'
      }
      return defaults[type] || '/images/default-content.jpg'
    }

    const getShortDescription = (description) => {
      if (!description) return ''
      return description.length > 100 ? description.substring(0, 100) + '...' : description
    }

    const getEmptyMessage = () => {
      const messages = {
        all: 'Aucun favori pour le moment',
        recipe: 'Aucune recette favorite',
        tip: 'Aucune astuce favorite',
        event: 'Aucun événement favori',
        dinor_tv: 'Aucune vidéo favorite'
      }
      return messages[selectedFilter.value] || 'Aucun favori'
    }

    const getEmptyDescription = () => {
      const descriptions = {
        all: 'Ajoutez du contenu à vos favoris en cliquant sur l\'icône cœur',
        recipe: 'Parcourez les recettes et ajoutez vos préférées à vos favoris',
        tip: 'Découvrez des astuces utiles et sauvegardez-les',
        event: 'Trouvez des événements intéressants et ajoutez-les à vos favoris',
        dinor_tv: 'Regardez des vidéos et ajoutez vos préférées à vos favoris'
      }
      return descriptions[selectedFilter.value] || ''
    }

    const getExploreLink = () => {
      const links = {
        all: '/',
        recipe: '/recipes',
        tip: '/tips',
        event: '/events',
        dinor_tv: '/dinor-tv'
      }
      return links[selectedFilter.value] || '/'
    }

    const formatDate = (date) => {
      return new Date(date).toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short'
      })
    }

    const formatMemberSince = (date) => {
      return new Date(date).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long'
      })
    }

    const handleImageError = (event) => {
      event.target.src = '/images/default-content.jpg'
    }

    // Watch auth state changes
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadFavorites()
      } else {
        favorites.value = []
      }
    }, { immediate: true })

    onMounted(() => {
      if (authStore.isAuthenticated) {
        loadFavorites()
      }
    })

    return {
      loading,
      showAuthModal,
      favorites,
      selectedFilter,
      filterTabs,
      totalFavorites,
      favoritesStats,
      filteredFavorites,
      authStore,
      removeFavorite,
      goToContent,
      getTypeIcon,
      getDefaultImage,
      getShortDescription,
      getEmptyMessage,
      getEmptyDescription,
      getExploreLink,
      formatDate,
      formatMemberSince,
      handleImageError
    }
  }
}
</script>

<style scoped>
.profile {
  min-height: 100vh;
  background: #FFFFFF;
  padding: 16px;
  padding-bottom: 100px; /* Space for bottom nav */
  font-family: 'Roboto', sans-serif;
}

.loading-state,
.auth-required {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  text-align: center;
  padding: 32px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #E2E8F0;
  border-top: 4px solid #E53E3E;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.auth-icon {
  width: 80px;
  height: 80px;
  background: #F4D03F;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.auth-icon i {
  font-size: 40px;
  color: #E53E3E;
}

.btn-primary {
  padding: 12px 24px;
  background: #E53E3E;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.btn-primary:hover {
  background: #C53030;
  transform: translateY(-1px);
}

.user-info-section {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px;
  background: #F4D03F;
  border-radius: 16px;
  margin-bottom: 24px;
  position: relative;
}

.user-avatar {
  width: 64px;
  height: 64px;
  background: rgba(229, 62, 62, 0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-avatar i {
  font-size: 32px;
  color: #E53E3E;
}

.user-details {
  flex: 1;
}

.user-name {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2D3748;
}

.user-email {
  margin: 0 0 4px 0;
  font-size: 14px;
  color: #4A5568;
}

.member-since {
  margin: 0;
  font-size: 12px;
  color: #4A5568;
}

.btn-logout {
  padding: 8px 16px;
  background: rgba(229, 62, 62, 0.1);
  color: #E53E3E;
  border: 1px solid #E53E3E;
  border-radius: 8px;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.2s ease;
}

.btn-logout:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

.user-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 32px;
}

.stat-card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.stat-number {
  font-size: 24px;
  font-weight: 700;
  color: #E53E3E;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #4A5568;
  font-weight: 500;
}

.section-header {
  margin-bottom: 24px;
}

.section-title {
  margin: 0 0 16px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2D3748;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.filter-tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #F7FAFC;
  border: 1px solid #E2E8F0;
  border-radius: 20px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  color: #4A5568;
}

.filter-tab:hover {
  background: #EDF2F7;
}

.filter-tab.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
}

.filter-tab i {
  font-size: 16px;
}

.favorites-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.favorite-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.favorite-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.favorite-image {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.favorite-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.favorite-type-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  width: 24px;
  height: 24px;
  background: rgba(229, 62, 62, 0.9);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.favorite-type-badge i {
  font-size: 12px;
  color: #FFFFFF;
}

.favorite-info {
  flex: 1;
  min-width: 0;
}

.favorite-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2D3748;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-description {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #4A5568;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.favorite-date {
  font-size: 12px;
  color: #4A5568;
}

.favorite-stats {
  display: flex;
  gap: 12px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #4A5568;
}

.stat i {
  font-size: 14px;
}

.remove-favorite {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 32px;
  height: 32px;
  background: rgba(229, 62, 62, 0.1);
  color: #E53E3E;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.remove-favorite:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

.remove-favorite i {
  font-size: 18px;
}

.empty-favorites {
  text-align: center;
  padding: 48px 24px;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background: #F7FAFC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
}

.empty-icon i {
  font-size: 40px;
  color: #CBD5E0;
}

.empty-favorites h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #2D3748;
}

.empty-favorites p {
  margin: 0 0 24px 0;
  font-size: 14px;
  color: #4A5568;
}

.btn-secondary {
  padding: 12px 24px;
  background: #FFFFFF;
  color: #E53E3E;
  border: 1px solid #E53E3E;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  display: inline-block;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

/* Responsive */
@media (max-width: 768px) {
  .user-info-section {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }

  .user-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .filter-tabs {
    justify-content: flex-start;
  }
  
  .favorite-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .profile {
    padding: 12px;
  }
  
  .user-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }
  
  .stat-card {
    padding: 12px;
  }
  
  .favorite-item {
    padding: 12px;
  }
  
  .favorite-image {
    width: 60px;
    height: 60px;
  }
}
</style>