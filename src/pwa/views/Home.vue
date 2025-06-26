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
        </div>
      </div>
    </section>

    <!-- Recipes Carousel -->
    <section class="content-section">
      <div class="section-header">
        <h2>Recettes Populaires</h2>
        <router-link to="/recipes" class="see-all-btn">
          Voir tout
          <span class="material-symbols-outlined">arrow_forward</span>
        </router-link>
      </div>
      
      <div class="carousel-container">
        <div v-if="loadingRecipes" class="carousel-loading">
          <div class="loading-spinner"></div>
        </div>
        <div v-else class="carousel" ref="recipesCarousel">
          <div 
            v-for="recipe in recipes" 
            :key="recipe.id"
            @click="goToRecipe(recipe.id)"
            class="carousel-item recipe-card"
          >
            <div class="card-image">
              <img 
                :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
                :alt="recipe.title"
                loading="lazy"
              />
              <div class="card-overlay">
                <span v-if="recipe.preparation_time" class="time-badge">
                  {{ recipe.preparation_time }}min
                </span>
              </div>
            </div>
            <div class="card-content">
              <h3>{{ recipe.title }}</h3>
              <p>{{ getShortDescription(recipe.short_description) }}</p>
              <div class="card-meta">
                <span class="likes">
                  <span class="material-symbols-outlined">favorite</span>
                  {{ recipe.likes_count || 0 }}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="carousel-controls">
          <button @click="scrollCarousel('recipes', -1)" class="carousel-btn prev">
            <span class="material-symbols-outlined">chevron_left</span>
          </button>
          <button @click="scrollCarousel('recipes', 1)" class="carousel-btn next">
            <span class="material-symbols-outlined">chevron_right</span>
          </button>
        </div>
      </div>
    </section>

    <!-- Tips Carousel -->
    <section class="content-section">
      <div class="section-header">
        <h2>Astuces Culinaires</h2>
        <router-link to="/tips" class="see-all-btn">
          Voir tout
          <span class="material-symbols-outlined">arrow_forward</span>
        </router-link>
      </div>
      
      <div class="carousel-container">
        <div v-if="loadingTips" class="carousel-loading">
          <div class="loading-spinner"></div>
        </div>
        <div v-else class="carousel" ref="tipsCarousel">
          <div 
            v-for="tip in tips" 
            :key="tip.id"
            @click="goToTip(tip.id)"
            class="carousel-item tip-card"
          >
            <div class="tip-icon">
              <span class="material-symbols-outlined">lightbulb</span>
            </div>
            <div class="card-content">
              <h3>{{ tip.title }}</h3>
              <p>{{ getShortDescription(tip.content) }}</p>
              <div class="card-meta">
                <span v-if="tip.estimated_time" class="time">
                  {{ tip.estimated_time }}min
                </span>
                <span class="difficulty">
                  {{ getDifficultyLabel(tip.difficulty_level) }}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="carousel-controls">
          <button @click="scrollCarousel('tips', -1)" class="carousel-btn prev">
            <span class="material-symbols-outlined">chevron_left</span>
          </button>
          <button @click="scrollCarousel('tips', 1)" class="carousel-btn next">
            <span class="material-symbols-outlined">chevron_right</span>
          </button>
        </div>
      </div>
    </section>

    <!-- Events Carousel -->
    <section class="content-section">
      <div class="section-header">
        <h2>Événements à Venir</h2>
        <router-link to="/events" class="see-all-btn">
          Voir tout
          <span class="material-symbols-outlined">arrow_forward</span>
        </router-link>
      </div>
      
      <div class="carousel-container">
        <div v-if="loadingEvents" class="carousel-loading">
          <div class="loading-spinner"></div>
        </div>
        <div v-else class="carousel" ref="eventsCarousel">
          <div 
            v-for="event in events" 
            :key="event.id"
            @click="goToEvent(event.id)"
            class="carousel-item event-card"
          >
            <div class="card-image">
              <img 
                :src="event.featured_image_url || '/images/default-event.jpg'" 
                :alt="event.title"
                loading="lazy"
              />
              <div class="card-overlay">
                <span :class="getStatusClass(event.status)" class="status-badge">
                  {{ getStatusLabel(event.status) }}
                </span>
              </div>
            </div>
            <div class="card-content">
              <h3>{{ event.title }}</h3>
              <p>{{ getShortDescription(event.short_description) }}</p>
              <div class="card-meta">
                <span class="date">
                  <span class="material-symbols-outlined">calendar_today</span>
                  {{ formatDate(event.start_date) }}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="carousel-controls">
          <button @click="scrollCarousel('events', -1)" class="carousel-btn prev">
            <span class="material-symbols-outlined">chevron_left</span>
          </button>
          <button @click="scrollCarousel('events', 1)" class="carousel-btn next">
            <span class="material-symbols-outlined">chevron_right</span>
          </button>
        </div>
      </div>
    </section>

    <!-- Dinor TV Section -->
    <section class="content-section dinor-tv-section">
      <div class="section-header">
        <h2>Dinor TV</h2>
        <router-link to="/dinor-tv" class="see-all-btn">
          Voir tout
          <span class="material-symbols-outlined">arrow_forward</span>
        </router-link>
      </div>
      
      <div v-if="featuredVideo" class="featured-video" @click="goToVideo">
        <div class="video-thumbnail">
          <img 
            :src="featuredVideo.thumbnail_url || getVideoThumbnail(featuredVideo.video_url)"
            :alt="featuredVideo.title"
            loading="lazy"
          />
          <div class="video-overlay">
            <div class="play-button">
              <span class="material-symbols-outlined">play_circle</span>
            </div>
            <div v-if="featuredVideo.is_live" class="live-badge">
              <span class="live-dot"></span>
              LIVE
            </div>
          </div>
        </div>
        <div class="video-info">
          <h3>{{ featuredVideo.title }}</h3>
          <p>{{ getShortDescription(featuredVideo.description) }}</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipes } from '@/composables/useRecipes'
import { useTips } from '@/composables/useTips'
import { useEvents } from '@/composables/useEvents'
import { useDinorTV } from '@/composables/useDinorTV'

export default {
  name: 'Home',
  setup() {
    const router = useRouter()
    
    // Composables avec cache
    const { 
      recipes: recipesData, 
      featuredRecipes,
      loading: loadingRecipes 
    } = useRecipes({ limit: 6, featured: true })
    
    const { 
      tips: tipsData, 
      featuredTips,
      loading: loadingTips 
    } = useTips({ limit: 6, featured: true })
    
    const { 
      events: eventsData, 
      activeEvents,
      loading: loadingEvents 
    } = useEvents({ limit: 6, status: 'active' })
    
    const { 
      videos: videosData, 
      featuredVideos 
    } = useDinorTV({ limit: 1, featured: true })
    
    // Computed pour les données
    const recipes = computed(() => featuredRecipes.value.slice(0, 6))
    const tips = computed(() => featuredTips.value.slice(0, 6))
    const events = computed(() => activeEvents.value.slice(0, 6))
    const featuredVideo = computed(() => featuredVideos.value[0] || null)
    
    const stats = computed(() => ({
      recipes: recipesData.value?.meta?.total || recipes.value.length,
      tips: tipsData.value?.meta?.total || tips.value.length,
      events: eventsData.value?.meta?.total || events.value.length
    }))
    
    const scrollCarousel = (type, direction) => {
      const carousel = {
        recipes: 'recipesCarousel',
        tips: 'tipsCarousel',
        events: 'eventsCarousel'
      }[type]
      
      if (carousel) {
        const element = document.querySelector(`[ref="${carousel}"]`)
        if (element) {
          const scrollAmount = 300
          element.scrollBy({
            left: direction * scrollAmount,
            behavior: 'smooth'
          })
        }
      }
    }
    
    const goToRecipe = (id) => {
      router.push(`/recipe/${id}`)
    }
    
    const goToTip = (id) => {
      router.push(`/tip/${id}`)
    }
    
    const goToEvent = (id) => {
      router.push(`/event/${id}`)
    }
    
    const goToVideo = () => {
      router.push('/dinor-tv')
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
    
    return {
      recipes,
      tips,
      events,
      featuredVideo,
      stats,
      loadingRecipes,
      loadingTips,
      loadingEvents,
      scrollCarousel,
      goToRecipe,
      goToTip,
      goToEvent,
      goToVideo,
      getShortDescription,
      getDifficultyLabel,
      getStatusClass,
      getStatusLabel,
      formatDate,
      getVideoThumbnail
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
  gap: 32px;
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

/* Content Sections */
.content-section {
  padding: 32px 16px;
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