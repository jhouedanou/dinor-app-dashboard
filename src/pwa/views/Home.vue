<template>
  <div class="home">
    <!-- Zone de contenu principal - maintenant que l'en-tête est séparé -->
    <div class="content-area">

    <!-- Bannières d'accueil -->
    <BannerSection 
      type="home" 
      section="hero" 
      :banners="banners"
    />

    <!-- Recettes - 4 dernières -->
    <ContentCarousel
      title="Dernières Recettes"
      :items="latestRecipes"
      :loading="loadingRecipes"
      :error="errorRecipes"
      content-type="recipes"
      view-all-link="/recipes"
      @item-click="handleRecipeClick"
    >
      <template #item="{ item }">
        <div class="recipe-card">
          <div class="card-image">
            <img 
              :src="item.featured_image_url || '/images/default-recipe.jpg'" 
              :alt="item.title"
              loading="lazy"
            />
            <div class="card-overlay">
              <span v-if="getTotalTime(item)" class="time-badge">
                {{ getTotalTime(item) }}min
              </span>
              <span v-if="item.difficulty" class="difficulty-badge">
                {{ getDifficultyLabel(item.difficulty) }}
              </span>
            </div>
          </div>
          <div class="card-content">
            <h3>{{ item.title }}</h3>
            <p>{{ getShortDescription(item.short_description) }}</p>
            <div class="card-meta">
              <span class="likes">
                <LikeButton
                  type="recipe"
                  :item-id="item.id"
                  :initial-liked="item.is_liked || false"
                  :initial-count="item.likes_count || 0"
                  :show-count="true"
                  size="small"
                  variant="minimal"
                  @auth-required="handleAuthError"
                  @click.stop=""
                />
              </span>
              <span class="date">{{ formatDate(item.created_at) }}</span>
            </div>
          </div>
        </div>
      </template>
    </ContentCarousel>

    <!-- Astuces - 4 dernières -->
    <ContentCarousel
      title="Dernières Astuces"
      :items="latestTips"
      :loading="loadingTips"
      :error="errorTips"
      content-type="tips"
      view-all-link="/tips"
      @item-click="handleTipClick"
    >
      <template #item="{ item }">
        <div class="tip-card">
          <div class="tip-icon">
            <i class="material-icons">lightbulb</i>
            <span class="emoji-fallback">💡</span>
          </div>
          <div class="card-content">
            <h3>{{ item.title }}</h3>
            <p>{{ getShortDescription(item.content) }}</p>
            <div class="card-meta">
              <span v-if="item.estimated_time" class="time">
                {{ item.estimated_time }}min
              </span>
              <span class="difficulty">
                {{ getDifficultyLabel(item.difficulty_level) }}
              </span>
              <span class="date">{{ formatDate(item.created_at) }}</span>
            </div>
          </div>
        </div>
      </template>
    </ContentCarousel>

    <!-- Événements - 4 derniers -->
    <ContentCarousel
      title="Derniers Événements"
      :items="latestEvents"
      :loading="loadingEvents"
      :error="errorEvents"
      content-type="events"
      view-all-link="/events"
      @item-click="handleEventClick"
    >
      <template #item="{ item }">
        <div class="event-card">
          <div class="card-image">
            <img 
              :src="item.featured_image_url || '/images/default-event.jpg'" 
              :alt="item.title"
              loading="lazy"
            />
            <div class="card-overlay">
              <span :class="getStatusClass(item.status)" class="status-badge">
                {{ getStatusLabel(item.status) }}
              </span>
            </div>
          </div>
          <div class="card-content">
            <h3>{{ item.title }}</h3>
            <p>{{ getShortDescription(item.short_description) }}</p>
            <div class="card-meta">
              <span class="date">
                <i class="material-icons">event</i>
                <span class="emoji-fallback">📅</span>
                {{ formatDate(item.start_date) }}
              </span>
              <span class="created">{{ formatDate(item.created_at) }}</span>
            </div>
          </div>
        </div>
      </template>
    </ContentCarousel>

    <!-- Dinor TV - 4 dernières vidéos -->
    <ContentCarousel
      title="Dernières Vidéos Dinor TV"
      :items="latestVideos"
      :loading="loadingVideos"
      :error="errorVideos"
      content-type="videos"
      view-all-link="/dinor-tv"
      @item-click="handleVideoClick"
      class="dinor-tv-section"
    >
      <template #item="{ item }">
        <div class="video-card">
          <div class="video-thumbnail">
            <img 
              :src="item.thumbnail_url || getVideoThumbnail(item.video_url)"
              :alt="item.title"
              loading="lazy"
            />
            <div class="video-overlay">
              <div class="play-button">
                <i class="material-icons">play_circle</i>
                <span class="emoji-fallback">▶️</span>
              </div>
              <div v-if="item.is_live" class="live-badge">
                <span class="live-dot"></span>
                LIVE
              </div>
              <div v-if="item.duration" class="duration-badge">
                {{ formatDuration(item.duration) }}
              </div>
            </div>
          </div>
          <div class="card-content">
            <h3>{{ item.title }}</h3>
            <p>{{ getShortDescription(item.description) }}</p>
            <div class="card-meta">
              <span class="views">
                <i class="material-icons">visibility</i>
                <span class="emoji-fallback">👁️</span>
                {{ item.views_count || 0 }}
              </span>
              <span class="date">{{ formatDate(item.created_at) }}</span>
            </div>
          </div>
        </div>
      </template>
    </ContentCarousel>
    
    </div> <!-- Fermer content-area -->
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal" 
      :initial-message="authModalMessage"
      @update:modelValue="closeAuthModal"
      @authenticated="handleAuthSuccess"
    />
  </div> <!-- Fermer home -->
</template>

<script>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipes } from '@/composables/useRecipes'
import { useTips } from '@/composables/useTips'
import { useEvents } from '@/composables/useEvents'
import { useDinorTV } from '@/composables/useDinorTV'
import { useBanners } from '@/composables/useBanners'
import { useGlobalAuth } from '@/composables/useAuthHandler'
import { useRefresh } from '@/composables/useRefresh'
import ContentCarousel from '@/components/common/ContentCarousel.vue'
import BannerSection from '@/components/common/BannerSection.vue'
import LikeButton from '@/components/common/LikeButton.vue'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'Home',
  components: {
    ContentCarousel,
    BannerSection,
    LikeButton,
    AuthModal
  },
  setup() {
    const router = useRouter()
    
    // Gestion globale de l'authentification
    const { 
      showAuthModal, 
      authModalMessage, 
      handleAuthError, 
      closeAuthModal, 
      handleAuthSuccess 
    } = useGlobalAuth()
    
    // Composable pour les bannières
    const {
      banners,
      loading: loadingBanners,
      error: errorBanners,
      loadBannersForContentType
    } = useBanners()
    
    // Charger uniquement les bannières pour la page d'accueil
    onMounted(async () => {
      await loadBannersForContentType('home', true) // Force refresh sans cache
    })
    
    // Composables optimisés pour récupérer les 4 derniers items de chaque type
    const { 
      recipes: recipesData, 
      error: errorRecipes,
      loading: loadingRecipes 
    } = useRecipes({ 
      limit: 4, 
      sort_by: 'created_at', 
      sort_order: 'desc' 
    })
    
    const { 
      tips: tipsData, 
      error: errorTips,
      loading: loadingTips 
    } = useTips({ 
      limit: 4, 
      sort_by: 'created_at', 
      sort_order: 'desc' 
    })
    
    const { 
      events: eventsData, 
      error: errorEvents,
      loading: loadingEvents 
    } = useEvents({ 
      limit: 4, 
      sort_by: 'created_at', 
      sort_order: 'desc' 
    })
    
    const { 
      videos: videosData, 
      error: errorVideos,
      loading: loadingVideos 
    } = useDinorTV({ 
      limit: 4, 
      sort_by: 'created_at', 
      sort_order: 'desc' 
    })
    
    // Computed pour les derniers items
    const latestRecipes = computed(() => recipesData.value?.data?.slice(0, 4) || [])
    const latestTips = computed(() => tipsData.value?.data?.slice(0, 4) || [])
    const latestEvents = computed(() => eventsData.value?.data?.slice(0, 4) || [])
    const latestVideos = computed(() => videosData.value?.data?.slice(0, 4) || [])
    
    // Système de rafraîchissement
    const { refreshContentType, onRefresh } = useRefresh()
    
    // Écouter les mises à jour de likes
    const handleLikeUpdate = (event) => {
      const { type, id, liked, count } = event.detail
      
      if (type === 'recipe') {
        const recipe = latestRecipes.value.find(r => r.id == id)
        if (recipe) {
          recipe.is_liked = liked
          recipe.likes_count = count
        }
      } else if (type === 'tip') {
        const tip = latestTips.value.find(t => t.id == id)
        if (tip) {
          tip.is_liked = liked
          tip.likes_count = count
        }
      }
    }
    
    // Écouter les événements de rafraîchissement
    const handleContentRefresh = (event) => {
      const { type } = event.detail
      console.log(`🔄 [Home] Rafraîchissement détecté pour: ${type}`)
      
      // Forcer le rechargement des données selon le type
      switch(type) {
        case 'recipes':
          console.log('🔄 [Home] Rechargement des recettes...')
          recipesData.value = null // Force un nouveau chargement
          break
        case 'tips':
          console.log('🔄 [Home] Rechargement des tips...')
          tipsData.value = null // Force un nouveau chargement
          break
        case 'events':
          console.log('🔄 [Home] Rechargement des événements...')
          eventsData.value = null // Force un nouveau chargement
          break
        case 'dinor_tv':
          console.log('🔄 [Home] Rechargement des vidéos...')
          videosData.value = null // Force un nouveau chargement
          break
      }
    }
    
    // Fonction pour rafraîchir toutes les données
    const refreshAllData = () => {
      console.log('🔄 [Home] Rafraîchissement global des données')
      refreshContentType('recipes')
      refreshContentType('tips')
      refreshContentType('events')
      refreshContentType('dinor_tv')
    }
    
    let cleanupRefresh = null
    
    onMounted(() => {
      window.addEventListener('like-updated', handleLikeUpdate)
      
      // Écouter les événements de rafraîchissement
      cleanupRefresh = onRefresh(handleContentRefresh, { global: true })
    })
    
    onUnmounted(() => {
      window.removeEventListener('like-updated', handleLikeUpdate)
      if (cleanupRefresh) {
        cleanupRefresh()
      }
    })
    
    // Stats pour le hero
    const stats = computed(() => ({
      recipes: recipesData.value?.meta?.total || latestRecipes.value.length,
      tips: tipsData.value?.meta?.total || latestTips.value.length,
      events: eventsData.value?.meta?.total || latestEvents.value.length,
      videos: videosData.value?.meta?.total || latestVideos.value.length
    }))
    
    // Handlers pour les clics sur les items
    const handleRecipeClick = (recipe) => {
      router.push(`/recipe/${recipe.id}`)
    }
    
    const handleTipClick = (tip) => {
      router.push(`/tip/${tip.id}`)
    }
    
    const handleEventClick = (event) => {
      router.push(`/event/${event.id}`)
    }
    
    const handleVideoClick = (video) => {
      router.push(`/video/${video.id}`)
    }
    
    const getShortDescription = (text) => {
      if (!text) return ''
      const cleanText = text.replace(/<[^>]*>/g, '')
      return cleanText.length > 80 ? cleanText.substring(0, 80) + '...' : cleanText
    }
    
    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'beginner': 'Débutant',
        'intermediate': 'Intermédiaire',
        'advanced': 'Avancé',
        'easy': 'Facile',
        'medium': 'Moyen',
        'hard': 'Difficile'
      }
      return labels[difficulty] || difficulty
    }
    
    const getTotalTime = (item) => {
      const prepTime = item.preparation_time || 0
      const cookTime = item.cooking_time || 0
      const restTime = item.resting_time || 0
      return prepTime + cookTime + restTime
    }
    
    const getStatusClass = (status) => {
      return `status-${status}`
    }
    
    const getStatusLabel = (status) => {
      const labels = {
        'active': 'Actif',
        'upcoming': 'À venir',
        'completed': 'Terminé',
        'cancelled': 'Annulé'
      }
      return labels[status] || status
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short'
      })
    }
    
    const getVideoThumbnail = (videoUrl) => {
      if (!videoUrl) return '/images/default-video.jpg'
      
      const youtubeMatch = videoUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://img.youtube.com/vi/${youtubeMatch[1]}/maxresdefault.jpg`
      }
      
      return '/images/default-video.jpg'
    }
    
    const formatDuration = (seconds) => {
      if (!seconds) return ''
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
    }
    
    // Fonction pour calculer la couleur de contraste pour les boutons
    const getContrastColor = (hexColor) => {
      // Convertir hex en RGB
      const r = parseInt(hexColor.slice(1, 3), 16)
      const g = parseInt(hexColor.slice(3, 5), 16)
      const b = parseInt(hexColor.slice(5, 7), 16)
      
      // Calculer la luminance
      const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
      
      // Retourner noir ou blanc selon la luminance
      return luminance > 0.5 ? '#000000' : '#FFFFFF'
    }
    
    return {
      // Bannières
      banners,
      loadingBanners,
      errorBanners,
      
      // Données
      latestRecipes,
      latestTips,
      latestEvents,
      latestVideos,
      stats,
      
      // États de chargement
      loadingRecipes,
      loadingTips,
      loadingEvents,
      loadingVideos,
      
      // Erreurs
      errorRecipes,
      errorTips,
      errorEvents,
      errorVideos,
      
      // Handlers
      handleRecipeClick,
      handleTipClick,
      handleEventClick,
      handleVideoClick,
      
      // Utilitaires
      getShortDescription,
      getDifficultyLabel,
      getTotalTime,
      getStatusClass,
      getStatusLabel,
      formatDate,
      getVideoThumbnail,
      formatDuration,
      getContrastColor,
      
      // Auth modal
      showAuthModal,
      authModalMessage,
      handleAuthError,
      closeAuthModal,
      handleAuthSuccess
    }
  }
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc */
  font-family: 'Roboto', sans-serif;
}

/* Zone de contenu principal */
.content-area {
  background: #FFFFFF; /* Grande zone blanche/gris clair */
  min-height: calc(100vh - 200px);
  padding: 20px 16px;
}

/* Suppression de l'ancienne section hero - maintenant gérée par AppHeader */

/* Cartes spécifiques */
.recipe-card,
.tip-card,
.event-card,
.video-card {
  background: #FFFFFF; /* Fond blanc */
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid #E2E8F0; /* Bordure gris clair */
  height: 100%;
  display: flex;
  flex-direction: column;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.recipe-card:hover,
.tip-card:hover,
.event-card:hover,
.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(229, 62, 62, 0.15); /* Ombre rouge */
  border-color: #E53E3E; /* Bordure rouge au hover */
}

/* Images et overlays */
.card-image,
.video-thumbnail {
  position: relative;
  height: 160px;
  overflow: hidden;
}

.card-image img,
.video-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.tip-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 120px;
  background: linear-gradient(135deg, #F4D03F 0%, #FF6B35 100%); /* Dégradé doré vers orange */
}

.tip-icon .material-icons {
  font-size: 48px;
  color: #FFFFFF; /* Icône blanche sur fond coloré */
}

.card-overlay,
.video-overlay {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  gap: 8px;
}

.video-overlay {
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 0%, rgba(0, 0, 0, 0.7) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Badges */
.time-badge,
.difficulty-badge,
.status-badge,
.duration-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
  background: rgba(0, 0, 0, 0.7);
  color: white;
}

.status-active {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.status-upcoming {
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

/* Play button et live badge pour vidéos */
.play-button {
  color: white;
  font-size: 48px;
  opacity: 0.8;
  transition: all 0.2s ease;
}

.video-card:hover .play-button {
  opacity: 1;
  transform: scale(1.1);
}

.live-badge {
  position: absolute;
  top: 12px;
  left: 12px;
  background: #ff4444;
  color: white;
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 4px;
}

.live-dot {
  width: 6px;
  height: 6px;
  background: white;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

/* Contenu des cartes */
.card-content {
  padding: 16px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-content h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-content p {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  margin-top: auto;
}

.likes,
.views,
.date,
.time,
.difficulty,
.created {
  display: flex;
  align-items: center;
  gap: 4px;
}

.likes .material-icons,
.views .material-icons,
.date .material-icons {
  font-size: 18px;
  margin-right: 6px;
  color: #8B7000; /* Couleur dorée pour les icônes */
  font-weight: 500;
  vertical-align: middle;
}

/* Section Dinor TV */
.dinor-tv-section {
  background: linear-gradient(135deg, #1a1a1a 0%, #333333 100%);
  color: white;
}

.dinor-tv-section :deep(.section-header h2),
.dinor-tv-section :deep(.see-all-btn) {
  color: white;
}

/* Responsive */
@media (max-width: 768px) {
  .hero-content h1 {
    font-size: 28px;
  }
  
  .hero-stats {
    gap: 16px;
  }
  
  .stat-number {
    font-size: 24px;
  }
}

@media (max-width: 480px) {
  .hero {
    padding: 32px 16px;
  }
  
  .hero-content h1 {
    font-size: 24px;
  }
  
  .card-image,
  .video-thumbnail {
    height: 120px;
  }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.see-all-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  color: var(--md-sys-color-primary, #6750a4);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.see-all-btn:hover {
  color: var(--md-sys-color-primary-container, #eaddff);
}

/* Carousel */
.carousel-container {
  position: relative;
}

.carousel-loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 3px solid var(--md-sys-color-primary, #6750a4);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.carousel {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  scroll-behavior: smooth;
  padding-bottom: 8px;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.carousel::-webkit-scrollbar {
  display: none;
}

.carousel-item {
  flex: 0 0 280px;
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
}

.carousel-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.card-image {
  position: relative;
  height: 160px;
  overflow: hidden;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card-overlay {
  position: absolute;
  top: 8px;
  right: 8px;
}

.time-badge,
.status-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
  background: rgba(0, 0, 0, 0.7);
  color: white;
}

.status-active {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.card-content {
  padding: 16px;
}

.card-content h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-content p {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.likes,
.time,
.date {
  display: flex;
  align-items: center;
  gap: 4px;
}

.likes .material-icons,
.date .material-icons {
  font-size: 18px;
  margin-right: 6px;
  color: #8B7000; /* Couleur dorée pour les icônes */
  font-weight: 500;
  vertical-align: middle;
}

/* Tip Card */
.tip-card {
  display: flex;
  flex-direction: column;
}

.tip-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 80px;
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
}

.tip-icon .material-icons {
  font-size: 32px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

/* Carousel Controls */
.carousel-controls {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 16px;
}

.carousel-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.carousel-btn:hover {
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
}

/* Dinor TV Section */
.dinor-tv-section {
  background: linear-gradient(135deg, #1a1a1a 0%, #333333 100%);
  color: white;
}

.dinor-tv-section .section-header h2,
.dinor-tv-section .see-all-btn {
  color: white;
}

.featured-video {
  cursor: pointer;
  border-radius: 16px;
  overflow: hidden;
  transition: all 0.2s ease;
}

.featured-video:hover {
  transform: scale(1.02);
}

.video-thumbnail {
  position: relative;
  height: 200px;
}

.video-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 0%, rgba(0, 0, 0, 0.7) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.play-button {
  color: white;
  font-size: 64px;
  opacity: 0.8;
  transition: all 0.2s ease;
}

.featured-video:hover .play-button {
  opacity: 1;
  transform: scale(1.1);
}

.live-badge {
  position: absolute;
  top: 12px;
  left: 12px;
  background: #ff4444;
  color: white;
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 4px;
}

.live-dot {
  width: 6px;
  height: 6px;
  background: white;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.video-info {
  padding: 16px;
  background: rgba(0, 0, 0, 0.8);
}

.video-info h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
}

.video-info p {
  margin: 0;
  font-size: 14px;
  opacity: 0.8;
}

/* Banner Overlay Styles */
.banner {
  position: relative;
  min-height: 300px;
  overflow: hidden;
}

.banner-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1;
}

.hero-content {
  position: relative;
  z-index: 2;
}

.banner-title {
  font-size: 2.5rem;
  font-weight: 700;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  margin-bottom: 1rem;
}

.banner-description {
  font-size: 1.1rem;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
  margin-bottom: 2rem;
  line-height: 1.5;
}

.hero-button {
  display: inline-block;
  padding: 12px 24px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  text-shadow: none;
}

.hero-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* Typographie avec nouvelles polices */
h1, h2, h3, h4, h5, h6 {
  font-family: 'Open Sans', sans-serif; /* Open Sans pour les titres */
  font-weight: 600;
  color: #2D3748;
  margin: 0 0 16px 0;
  line-height: 1.3;
}

p, span, div, .card-content p {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  color: #4A5568;
  line-height: 1.5;
}

/* Titres spécifiques */
.section-header h2 {
  font-family: 'Open Sans', sans-serif;
  font-weight: 700; /* Plus bold */
  font-size: 24px;
  color: #000000; /* Noir pour les titres de section */
}

.card-content h3 {
  font-family: 'Open Sans', sans-serif;
  font-weight: 600;
  font-size: 18px;
  color: #2D3748;
  margin-bottom: 8px;
}

/* Responsive */
@media (max-width: 768px) {
  .section-header h2 {
    font-size: 20px;
  }
  
  .card-content h3 {
    font-size: 16px;
  }
  
  .carousel-item {
    flex: 0 0 240px;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}

/* Système de fallback pour les icônes - logique simplifiée */
.emoji-fallback {
  display: none; /* Masqué par défaut */
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

/* UNIQUEMENT quand .force-emoji est présent sur html, afficher les emoji */
html.force-emoji .material-symbols-outlined {
  display: none !important;
}

html.force-emoji .emoji-fallback {
  display: inline-block !important;
}
</style>