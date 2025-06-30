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
          <p class="member-since" v-if="authStore.user?.created_at">Membre depuis {{ formatMemberSince(authStore.user.created_at) }}</p>
        </div>
      </div>

      <!-- Profile Navigation -->
      <div class="profile-navigation">
        <button 
          v-for="section in profileSections" 
          :key="section.key"
          @click="activeSection = section.key"
          class="nav-button"
          :class="{ active: activeSection === section.key }"
        >
          <i class="material-icons">{{ section.icon }}</i>
          <span>{{ section.label }}</span>
        </button>
      </div>

      <!-- Profile Sections -->
      <div class="profile-sections">
        <!-- Favorites Section -->
        <div v-if="activeSection === 'favorites'" class="section-content">
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

        <!-- Account Section -->
        <div v-if="activeSection === 'account'" class="section-content">
          <h2 class="section-title">Mon Compte</h2>
          
          <!-- Username Update Form -->
          <div class="form-section">
            <h3 class="form-title">Nom d'utilisateur</h3>
            <form @submit.prevent="updateUsername" class="update-form">
              <div class="form-field">
                <label class="form-label">Nouveau nom d'utilisateur</label>
                <input 
                  v-model="usernameForm.name" 
                  type="text" 
                  class="form-input" 
                  placeholder="Votre nom d'utilisateur"
                  required
                  minlength="2"
                  maxlength="255"
                >
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-primary" :disabled="usernameForm.loading">
                  <span v-if="usernameForm.loading">Mise à jour...</span>
                  <span v-else>Mettre à jour</span>
                </button>
              </div>
              <div v-if="usernameForm.message" class="form-message" :class="usernameForm.success ? 'success' : 'error'">
                {{ usernameForm.message }}
              </div>
            </form>
          </div>
        </div>

        <!-- Security Section -->
        <div v-if="activeSection === 'security'" class="section-content">
          <h2 class="section-title">Sécurité</h2>
          
          <!-- Password Change Form -->
          <div class="form-section">
            <h3 class="form-title">Changer le mot de passe</h3>
            <form @submit.prevent="updatePassword" class="update-form">
              <div class="form-field">
                <label class="form-label">Mot de passe actuel</label>
                <input 
                  v-model="passwordForm.currentPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Votre mot de passe actuel"
                  required
                >
              </div>
              <div class="form-field">
                <label class="form-label">Nouveau mot de passe</label>
                <input 
                  v-model="passwordForm.newPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Votre nouveau mot de passe"
                  required
                  minlength="8"
                >
                <small class="form-hint">Au moins 8 caractères avec lettres et chiffres</small>
              </div>
              <div class="form-field">
                <label class="form-label">Confirmer le nouveau mot de passe</label>
                <input 
                  v-model="passwordForm.confirmPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Confirmer votre nouveau mot de passe"
                  required
                  minlength="8"
                >
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-primary" :disabled="passwordForm.loading">
                  <span v-if="passwordForm.loading">Mise à jour...</span>
                  <span v-else>Changer le mot de passe</span>
                </button>
              </div>
              <div v-if="passwordForm.message" class="form-message" :class="passwordForm.success ? 'success' : 'error'">
                {{ passwordForm.message }}
              </div>
            </form>
          </div>
        </div>

        <!-- Legal Section -->
        <div v-if="activeSection === 'legal'" class="section-content">
          <h2 class="section-title">Légal & Confidentialité</h2>
          
          <!-- Terms and Privacy Links -->
          <div class="legal-section">
            <h3 class="form-title">Conditions d'utilisation</h3>
            <div class="legal-links">
              <a href="/terms" class="legal-link">
                <i class="material-icons">description</i>
                <span>Conditions générales d'utilisation</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
              <a href="/privacy" class="legal-link">
                <i class="material-icons">privacy_tip</i>
                <span>Politique de confidentialité</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
              <a href="/cookies" class="legal-link">
                <i class="material-icons">cookie</i>
                <span>Politique des cookies</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
            </div>
          </div>

          <!-- Data Deletion Request -->
          <div class="form-section danger-section">
            <h3 class="form-title danger-title">Suppression des données</h3>
            <p class="danger-description">
              Vous pouvez demander la suppression de toutes vos données personnelles conformément au RGPD. 
              Cette action est irréversible.
            </p>
            <form @submit.prevent="requestDataDeletion" class="update-form">
              <div class="form-field">
                <label class="form-label">Raison de la suppression (optionnel)</label>
                <textarea 
                  v-model="deletionForm.reason" 
                  class="form-textarea" 
                  placeholder="Expliquez pourquoi vous souhaitez supprimer vos données..."
                  rows="3"
                  maxlength="500"
                ></textarea>
              </div>
              <div class="form-field">
                <label class="checkbox-label">
                  <input 
                    v-model="deletionForm.confirm" 
                    type="checkbox" 
                    required
                  >
                  Je confirme vouloir supprimer définitivement toutes mes données
                </label>
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-danger" :disabled="deletionForm.loading || !deletionForm.confirm">
                  <span v-if="deletionForm.loading">Demande en cours...</span>
                  <span v-else>Demander la suppression</span>
                </button>
              </div>
              <div v-if="deletionForm.message" class="form-message" :class="deletionForm.success ? 'success' : 'error'">
                {{ deletionForm.message }}
              </div>
            </form>
          </div>

          <!-- Logout Section -->
          <div class="form-section">
            <h3 class="form-title">Déconnexion</h3>
            <p class="form-description">
              Vous serez déconnecté de votre compte sur cet appareil.
            </p>
            <button @click="authStore.logout()" class="btn-logout-main">
              <i class="material-icons">logout</i>
              <span>Se déconnecter</span>
            </button>
          </div>
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
    const activeSection = ref('favorites')

    // Form states
    const usernameForm = ref({
      name: '',
      loading: false,
      message: '',
      success: false
    })

    const passwordForm = ref({
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      loading: false,
      message: '',
      success: false
    })

    const deletionForm = ref({
      reason: '',
      confirm: false,
      loading: false,
      message: '',
      success: false
    })

    const profileSections = ref([
      { key: 'favorites', label: 'Favoris', icon: 'favorite' },
      { key: 'account', label: 'Compte', icon: 'person' },
      { key: 'security', label: 'Sécurité', icon: 'security' },
      { key: 'legal', label: 'Légal', icon: 'gavel' }
    ])

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
      if (!date) return ''
      
      try {
        const parsedDate = new Date(date)
        if (isNaN(parsedDate.getTime())) {
          return ''
        }
        
        return parsedDate.toLocaleDateString('fr-FR', {
          day: 'numeric',
          month: 'short'
        })
      } catch (error) {
        console.warn('Erreur lors du formatage de la date:', error)
        return ''
      }
    }

    const formatMemberSince = (date) => {
      if (!date) return 'Date inconnue'
      
      try {
        const parsedDate = new Date(date)
        if (isNaN(parsedDate.getTime())) {
          return 'Date inconnue'
        }
        
        return parsedDate.toLocaleDateString('fr-FR', {
          year: 'numeric',
          month: 'long'
        })
      } catch (error) {
        console.warn('Erreur lors du formatage de la date membre:', error)
        return 'Date inconnue'
      }
    }

    const handleImageError = (event) => {
      event.target.src = '/images/default-content.jpg'
    }

    // Form handlers
    const updateUsername = async () => {
      usernameForm.value.loading = true
      usernameForm.value.message = ''
      
      try {
        const data = await apiStore.request('/profile/name', {
          method: 'PUT',
          body: {
            name: usernameForm.value.name
          }
        })
        
        if (data.success) {
          usernameForm.value.success = true
          usernameForm.value.message = 'Nom d\'utilisateur mis à jour avec succès'
          // Update auth store
          authStore.user.name = data.data.name
          usernameForm.value.name = ''
        }
      } catch (error) {
        usernameForm.value.success = false
        usernameForm.value.message = error.response?.data?.message || 'Erreur lors de la mise à jour'
      } finally {
        usernameForm.value.loading = false
      }
    }

    const updatePassword = async () => {
      if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
        passwordForm.value.success = false
        passwordForm.value.message = 'Les mots de passe ne correspondent pas'
        return
      }

      passwordForm.value.loading = true
      passwordForm.value.message = ''
      
      try {
        const data = await apiStore.request('/profile/password', {
          method: 'PUT',
          body: {
            current_password: passwordForm.value.currentPassword,
            new_password: passwordForm.value.newPassword,
            new_password_confirmation: passwordForm.value.confirmPassword
          }
        })
        
        if (data.success) {
          passwordForm.value.success = true
          passwordForm.value.message = 'Mot de passe mis à jour avec succès'
          // Clear form
          passwordForm.value.currentPassword = ''
          passwordForm.value.newPassword = ''
          passwordForm.value.confirmPassword = ''
        }
      } catch (error) {
        passwordForm.value.success = false
        passwordForm.value.message = error.response?.data?.message || 'Erreur lors de la mise à jour'
      } finally {
        passwordForm.value.loading = false
      }
    }

    const requestDataDeletion = async () => {
      if (!confirm('Êtes-vous absolument sûr de vouloir demander la suppression de toutes vos données ? Cette action est irréversible.')) {
        return
      }

      deletionForm.value.loading = true
      deletionForm.value.message = ''
      
      try {
        const data = await apiStore.request('/profile/request-deletion', {
          method: 'POST',
          body: {
            reason: deletionForm.value.reason,
            confirm: deletionForm.value.confirm
          }
        })
        
        if (data.success) {
          deletionForm.value.success = true
          deletionForm.value.message = data.message
          // Clear form
          deletionForm.value.reason = ''
          deletionForm.value.confirm = false
        }
      } catch (error) {
        deletionForm.value.success = false
        deletionForm.value.message = error.response?.data?.message || 'Erreur lors de la demande'
      } finally {
        deletionForm.value.loading = false
      }
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
        // Initialize username form with current name
        usernameForm.value.name = authStore.user?.name || ''
        
        // Debug user data
        console.log('🔍 [Profile] Données utilisateur:', authStore.user)
        console.log('🔍 [Profile] Date création:', authStore.user?.created_at)
      }
    })

    return {
      loading,
      showAuthModal,
      favorites,
      selectedFilter,
      activeSection,
      profileSections,
      filterTabs,
      totalFavorites,
      favoritesStats,
      filteredFavorites,
      authStore,
      usernameForm,
      passwordForm,
      deletionForm,
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
      handleImageError,
      updateUsername,
      updatePassword,
      requestDataDeletion
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

/* Profile Navigation */
.profile-navigation {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.nav-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  color: #4A5568;
  min-width: fit-content;
}

.nav-button:hover {
  background: #F7FAFC;
  border-color: #CBD5E0;
}

.nav-button.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
}

.nav-button i {
  font-size: 20px;
}

/* Profile Sections */
.profile-sections {
  min-height: 400px;
}

.section-content {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 24px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

/* Form Styles */
.form-section {
  margin-bottom: 32px;
  padding: 24px;
  background: #F8F9FA;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
}

.form-title {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
}

.form-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #4A5568;
  line-height: 1.5;
}

.update-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-size: 14px;
  font-weight: 600;
  color: #2D3748;
}

.form-input,
.form-textarea {
  padding: 12px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 14px;
  background: #FFFFFF;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #E53E3E;
  box-shadow: 0 0 0 3px rgba(229, 62, 62, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.form-hint {
  font-size: 12px;
  color: #4A5568;
  margin-top: 4px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #2D3748;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 16px;
  height: 16px;
  accent-color: #E53E3E;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-start;
}

.form-message {
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
}

.form-message.success {
  background: #F0FDF4;
  color: #059669;
  border: 1px solid #10B981;
}

.form-message.error {
  background: #FEF2F2;
  color: #DC2626;
  border: 1px solid #EF4444;
}

/* Button Styles */
.btn-danger {
  padding: 12px 24px;
  background: #DC2626;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-danger:hover {
  background: #B91C1C;
}

.btn-danger:disabled {
  background: #9CA3AF;
  cursor: not-allowed;
}

.btn-logout-main {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #E53E3E;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-logout-main:hover {
  background: #C53030;
  transform: translateY(-1px);
}

.btn-logout-main i {
  font-size: 18px;
}

/* Legal Section */
.legal-section {
  margin-bottom: 32px;
}

.legal-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.legal-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  text-decoration: none;
  color: #2D3748;
  transition: all 0.2s ease;
}

.legal-link:hover {
  background: #F7FAFC;
  border-color: #CBD5E0;
  transform: translateX(4px);
}

.legal-link i:first-child {
  font-size: 20px;
  color: #E53E3E;
}

.legal-link span {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.legal-link i:last-child {
  font-size: 16px;
  color: #9CA3AF;
}

/* Danger Section */
.danger-section {
  border-color: #FCA5A5;
  background: #FEF2F2;
}

.danger-title {
  color: #DC2626;
}

.danger-description {
  color: #7F1D1D;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 16px;
}

/* Responsive Design for New Elements */
@media (max-width: 768px) {
  .profile-navigation {
    justify-content: flex-start;
  }
  
  .nav-button {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .section-content {
    padding: 16px;
  }
  
  .form-section {
    padding: 16px;
  }
  
  .legal-link {
    padding: 12px;
  }
}

@media (max-width: 480px) {
  .nav-button {
    padding: 8px 10px;
    font-size: 12px;
  }
  
  .nav-button i {
    font-size: 18px;
  }
  
  .section-content {
    padding: 12px;
  }
  
  .form-section {
    padding: 12px;
  }
}
</style>