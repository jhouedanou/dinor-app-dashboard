<template>
  <div class="home">
    <!-- Hero Section -->
    <section class="hero">
      <div class="hero-content">
        <h1>Bienvenue sur Dinor</h1>
        <p>Découvrez les saveurs authentiques de la Côte d'Ivoire</p>
        <div class="hero-stats">
          <div class="stat">
            <span class="stat-number">{{ stats.recipes }}</span>
            <span class="stat-label">Recettes</span>
          </div>
          <div class="stat">
            <span class="stat-number">{{ stats.tips }}</span>
            <span class="stat-label">Astuces</span>
          </div>
          <div class="stat">
            <span class="stat-number">{{ stats.events }}</span>
            <span class="stat-label">Événements</span>
          </div>
          <div class="stat">
            <span class="stat-number">{{ stats.videos }}</span>
            <span class="stat-label">Vidéos</span>
          </div>
        </div>
      </div>
    </section>

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
              <span v-if="item.preparation_time" class="time-badge">
                {{ item.preparation_time }}min
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
                <span class="material-symbols-outlined">favorite</span>
                {{ item.likes_count || 0 }}
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
            <span class="material-symbols-outlined">lightbulb</span>
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
                <span class="material-symbols-outlined">calendar_today</span>
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
                <span class="material-symbols-outlined">play_circle</span>
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
                <span class="material-symbols-outlined">visibility</span>
                {{ item.views_count || 0 }}
              </span>
              <span class="date">{{ formatDate(item.created_at) }}</span>
            </div>
          </div>
        </div>
      </template>
    </ContentCarousel>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipes } from '@/composables/useRecipes'
import { useTips } from '@/composables/useTips'
import { useEvents } from '@/composables/useEvents'
import { useDinorTV } from '@/composables/useDinorTV'
import ContentCarousel from '@/components/common/ContentCarousel.vue'

export default {
  name: 'Home',
  components: {
    ContentCarousel
  },
  setup() {
    const router = useRouter()
    
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
        'advanced': 'Avancé'
      }
      return labels[difficulty] || difficulty
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
    
    return {
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
      getStatusClass,
      getStatusLabel,
      formatDate,
      getVideoThumbnail,
      formatDuration
    }
  }
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

/* Hero Section */
.hero {
  background: linear-gradient(135deg, var(--md-sys-color-primary-container, #eaddff) 0%, var(--md-sys-color-tertiary-container, #ffd8e4) 100%);
  padding: 48px 16px;
  text-align: center;
}

.hero-content h1 {
  margin: 0 0 16px 0;
  font-size: 32px;
  font-weight: 700;
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.hero-content p {
  margin: 0 0 32px 0;
  font-size: 18px;
  color: var(--md-sys-color-on-primary-container, #21005d);
  opacity: 0.8;
}

.hero-stats {
  display: flex;
  justify-content: center;
  gap: 24px;
  flex-wrap: wrap;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-number {
  font-size: 28px;
  font-weight: 700;
  color: var(--md-sys-color-primary, #6750a4);
}

.stat-label {
  font-size: 14px;
  color: var(--md-sys-color-on-primary-container, #21005d);
  opacity: 0.7;
}

/* Cartes spécifiques */
.recipe-card,
.tip-card,
.event-card,
.video-card {
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  height: 100%;
  display: flex;
  flex-direction: column;
  transition: all 0.2s ease;
}

.recipe-card:hover,
.tip-card:hover,
.event-card:hover,
.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
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
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
}

.tip-icon .material-symbols-outlined {
  font-size: 48px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
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

.likes .material-symbols-outlined,
.views .material-symbols-outlined,
.date .material-symbols-outlined {
  font-size: 14px;
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

.likes .material-symbols-outlined,
.date .material-symbols-outlined {
  font-size: 14px;
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

.tip-icon .material-symbols-outlined {
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

/* Responsive */
@media (max-width: 768px) {
  .hero-content h1 {
    font-size: 28px;
  }
  
  .hero-stats {
    gap: 24px;
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
</style>