<template>
  <div class="dinor-tv">
    <!-- Bannières pour Dinor TV -->
    <BannerSection 
      type="videos" 
      section="hero" 
      :banners="bannersByType"
    />

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des vidéos...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
        <span class="emoji-fallback">⚠️</span>
      </div>
      <h2 class="md3-title-large">Erreur de chargement</h2>
      <p class="md3-body-large dinor-text-gray">{{ error }}</p>
      <button @click="retry" class="btn-secondary">Réessayer</button>
    </div>

    <!-- Content -->
    <div v-else class="content">
      <!-- Live Section -->
      <section v-if="liveVideos.length" class="live-section">
        <h2 class="section-title">
          <span class="live-indicator"></span>
          En Direct
        </h2>
        <div class="live-grid">
          <article
            v-for="video in liveVideos"
            :key="video.id"
            @click="playVideo(video)"
            class="video-card live-card"
          >
            <div class="video-thumbnail">
              <img
                :src="video.thumbnail_url || getVideoThumbnail(video.video_url)"
                :alt="video.title"
                loading="lazy"
              />
              <div class="video-overlay">
                <div class="play-button">
                  <span class="material-symbols-outlined">play_circle</span>
                  <span class="emoji-fallback">▶️</span>
                </div>
                <div class="live-badge">
                  <span class="live-dot"></span>
                  LIVE
                </div>
              </div>
            </div>
            
            <div class="video-info">
              <h3 class="video-title">{{ video.title }}</h3>
              <p v-if="video.description" class="video-description">
                {{ getShortDescription(video.description) }}
              </p>
              <div class="video-meta">
                <span v-if="video.viewers_count" class="viewers">
                  <span class="material-symbols-outlined">visibility</span>
                  <span class="emoji-fallback">👁️</span>
                  {{ video.viewers_count }} spectateurs
                </span>
                <span v-if="video.scheduled_at" class="scheduled">
                  Programmé à {{ formatTime(video.scheduled_at) }}
                </span>
              </div>
            </div>
          </article>
        </div>
      </section>

      <!-- Videos Section -->
      <section class="videos-section">
        <h2 class="section-title">Toutes les vidéos</h2>
        
        <!-- Empty State -->
        <div v-if="!videos.length && !loading" class="empty-state">
          <div class="empty-icon">
            <span class="material-symbols-outlined">play_circle</span>
          </div>
          <h3>Aucune vidéo disponible</h3>
          <p>Les vidéos culinaires seront bientôt disponibles.</p>
        </div>

        <!-- Videos Grid -->
        <div v-else class="videos-grid">
          <!-- Featured Video -->
          <div v-if="featuredVideo" class="featured-video md3-card">
            <div class="video-thumbnail" @click="playVideo(featuredVideo)">
              <img 
                :src="featuredVideo.thumbnail || '/images/default-video-thumbnail.jpg'" 
                :alt="featuredVideo.title"
                @error="handleImageError">
              <div class="play-overlay">
                <div class="play-button">
                  <span class="material-symbols-outlined">play_circle</span>
                  <span class="emoji-fallback">▶️</span>
                </div>
              </div>
              <div class="video-badge featured-badge">
                <span>À la une</span>
              </div>
            </div>
            <div class="video-info">
              <h2 class="video-title md3-title-medium">{{ featuredVideo.title }}</h2>
              <p v-if="featuredVideo.description" class="video-description md3-body-medium dinor-text-gray">
                {{ featuredVideo.description }}
              </p>
              <div class="video-meta">
                <div class="views-count">
                  <span class="material-symbols-outlined">visibility</span>
                  <span class="emoji-fallback">👁️</span>
                  <span>{{ formatViews(featuredVideo.views_count) }}</span>
                </div>
                <div class="video-date">
                  <span>{{ formatDate(featuredVideo.created_at) }}</span>
                </div>
                <FavoriteButton
                  type="dinor_tv"
                  :item-id="featuredVideo.id"
                  :initial-favorited="false"
                  :initial-count="featuredVideo.favorites_count || 0"
                  :show-count="true"
                  size="medium"
                  @auth-required="showAuthModal = true"
                />
              </div>
            </div>
          </div>

          <!-- Regular Videos -->
          <div class="regular-videos">
            <div 
              v-for="video in regularVideos" 
              :key="video.id" 
              class="video-card md3-card md3-ripple"
              @click="playVideo(video)"
            >
              <div class="video-thumbnail">
                <img 
                  :src="video.thumbnail || '/images/default-video-thumbnail.jpg'" 
                  :alt="video.title"
                  @error="handleImageError">
                <div class="play-overlay">
                  <div class="play-button">
                    <span class="material-symbols-outlined">play_circle</span>
                    <span class="emoji-fallback">▶️</span>
                  </div>
                </div>
                <div class="video-duration" v-if="video.duration">
                  {{ formatDuration(video.duration) }}
                </div>
              </div>
              <div class="video-info">
                <h3 class="video-title md3-title-small">{{ video.title }}</h3>
                <div class="video-meta">
                  <div class="views-count">
                    <span class="material-symbols-outlined">visibility</span>
                    <span class="emoji-fallback">👁️</span>
                    <span>{{ formatViews(video.views_count) }}</span>
                  </div>
                  <div class="video-date">
                    <span>{{ formatDate(video.created_at) }}</span>
                  </div>
                  <FavoriteButton
                    type="dinor_tv"
                    :item-id="video.id"
                    :initial-favorited="false"
                    :initial-count="video.favorites_count || 0"
                    :show-count="true"
                    size="small"
                    variant="minimal"
                    @auth-required="showAuthModal = true"
                    @click.stop=""
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Video Player Modal -->
    <div v-if="selectedVideo" class="video-modal" @click="closeVideo">
      <div class="modal-content" @click.stop>
        <button @click="closeVideo" class="close-button">
          <span class="material-symbols-outlined">close</span>
          <span class="emoji-fallback">✖️</span>
        </button>
        <div class="video-player">
          <iframe
            :src="getEmbedUrl(selectedVideo.video_url)"
            :title="selectedVideo.title"
            frameborder="0"
            allowfullscreen
          ></iframe>
        </div>
        <div class="video-details">
          <h3>{{ selectedVideo.title }}</h3>
          <p v-if="selectedVideo.description">{{ selectedVideo.description }}</p>
        </div>
      </div>
    </div>
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import apiService from '@/services/api'
import { useBanners } from '@/composables/useBanners'
import FavoriteButton from '@/components/common/FavoriteButton.vue'
import AuthModal from '@/components/common/AuthModal.vue'
import BannerSection from '@/components/common/BannerSection.vue'

export default {
  name: 'DinorTV',
  components: {
    FavoriteButton,
    AuthModal,
    BannerSection
  },
  setup() {
    // Banner management
    const { banners, loadBannersForContentType } = useBanners()
    const bannersByType = computed(() => banners.value)
    
    // State
    const videos = ref([])
    const selectedVideo = ref(null)
    const loading = ref(false)
    const error = ref(null)
    const showAuthModal = ref(false)
    
    // Computed
    const liveVideos = computed(() => {
      return videos.value.filter(video => video.is_live)
    })
    
    const featuredVideo = computed(() => {
      // Retourne la première vidéo featured ou la première vidéo disponible
      const featured = videos.value.find(video => video.is_featured)
      return featured || videos.value[0] || null
    })
    
    const regularVideos = computed(() => {
      // Retourne toutes les vidéos sauf la featured
      const featured = featuredVideo.value
      if (!featured) return videos.value
      return videos.value.filter(video => video.id !== featured.id)
    })
    
    // Methods
    const retry = () => {
      error.value = null
      loadVideos()
    }
    
    const loadVideos = async () => {
      loading.value = true
      error.value = null
      
      try {
        const response = await apiService.getVideos()
        
        if (response.success) {
          videos.value = response.data
        } else {
          throw new Error(response.message || 'Failed to fetch videos')
        }
      } catch (err) {
        error.value = err.message
        console.error('Error fetching videos:', err)
      } finally {
        loading.value = false
      }
    }
    
    const playVideo = (video) => {
      selectedVideo.value = video
      document.body.style.overflow = 'hidden'
    }
    
    const closeVideo = () => {
      selectedVideo.value = null
      document.body.style.overflow = 'auto'
    }
    
    const getVideoThumbnail = (videoUrl) => {
      // Extract YouTube video ID and return thumbnail
      if (!videoUrl) return '/images/default-video.jpg'
      
      const youtubeMatch = videoUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://img.youtube.com/vi/${youtubeMatch[1]}/maxresdefault.jpg`
      }
      
      return '/images/default-video.jpg'
    }
    
    const getEmbedUrl = (videoUrl) => {
      if (!videoUrl) return ''
      
      const youtubeMatch = videoUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://www.youtube.com/embed/${youtubeMatch[1]}?autoplay=1`
      }
      
      return videoUrl
    }
    
    const getShortDescription = (description) => {
      if (!description) return ''
      const text = description.replace(/<[^>]*>/g, '')
      return text.length > 100 ? text.substring(0, 100) + '...' : text
    }
    
    const formatDuration = (seconds) => {
      if (!seconds) return ''
      const hours = Math.floor(seconds / 3600)
      const minutes = Math.floor((seconds % 3600) / 60)
      const secs = seconds % 60
      
      if (hours > 0) {
        return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
      }
      return `${minutes}:${secs.toString().padStart(2, '0')}`
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }
    
    const formatTime = (timeString) => {
      if (!timeString) return ''
      return new Date(timeString).toLocaleTimeString('fr-FR', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    const formatViews = (viewsCount) => {
      if (!viewsCount || viewsCount === 0) return '0 vue'
      if (viewsCount === 1) return '1 vue'
      if (viewsCount < 1000) return `${viewsCount} vues`
      if (viewsCount < 1000000) return `${Math.floor(viewsCount / 1000)}k vues`
      return `${Math.floor(viewsCount / 1000000)}M vues`
    }
    
    const handleImageError = (event) => {
      event.target.src = '/images/default-video-thumbnail.jpg'
    }
    
    // Lifecycle
    onMounted(async () => {
      await loadBannersForContentType('videos', true) // Force refresh sans cache
      loadVideos()
    })
    
    return {
      videos,
      liveVideos,
      featuredVideo,
      regularVideos,
      selectedVideo,
      loading,
      error,
      showAuthModal,
      bannersByType,
      retry,
      playVideo,
      closeVideo,
      getVideoThumbnail,
      getEmbedUrl,
      getShortDescription,
      formatDuration,
      formatDate,
      formatTime,
      formatViews,
      handleImageError
    }
  }
}
</script>

<style scoped>
.dinor-tv {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

.loading-state,
.error-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 4px solid var(--md-sys-color-primary, #6750a4);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.content {
  padding: 16px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 16px 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.live-indicator {
  width: 8px;
  height: 8px;
  background: #ff4444;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.live-section {
  margin-bottom: 32px;
}

.live-grid,
.videos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.video-card {
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
}

.video-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.live-card {
  border: 2px solid #ff4444;
}

.video-thumbnail {
  position: relative;
  height: 180px;
  overflow: hidden;
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
  font-size: 48px;
  opacity: 0.8;
  transition: all 0.2s ease;
}

.video-card:hover .play-button {
  opacity: 1;
  transform: scale(1.1);
}

.play-button .material-symbols-outlined {
  font-size: 48px;
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

.duration {
  position: absolute;
  bottom: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.video-info {
  padding: 16px;
}

.video-title {
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

.video-description {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.video-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.views,
.viewers,
.scheduled {
  display: flex;
  align-items: center;
  gap: 4px;
}

.views .material-symbols-outlined,
.viewers .material-symbols-outlined {
  font-size: 14px;
}

/* Video Modal */
.video-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 16px;
}

.modal-content {
  background: var(--md-sys-color-surface, #fefbff);
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow: auto;
  position: relative;
}

.close-button {
  position: absolute;
  top: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 1;
}

.video-player {
  aspect-ratio: 16/9;
  width: 100%;
}

.video-player iframe {
  width: 100%;
  height: 100%;
  border-radius: 16px 16px 0 0;
}

.video-details {
  padding: 20px;
}

.video-details h3 {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.video-details p {
  margin: 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.5;
}

.retry-btn {
  padding: 12px 24px;
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

/* Responsive */
@media (max-width: 768px) {
  .live-grid,
  .videos-grid {
    grid-template-columns: 1fr;
  }
  
  .video-modal {
    padding: 8px;
  }
  
  .modal-content {
    max-height: 95vh;
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

/* Icônes de lecture */
.play-button .material-symbols-outlined {
  font-size: 48px;
  color: #FFFFFF;
  font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 48;
}

.play-button .emoji-fallback {
  font-size: 40px;
  color: #FFFFFF;
}

/* Icônes de vues */
.views .material-symbols-outlined,
.viewers .material-symbols-outlined {
  font-size: 16px;
  margin-right: 4px;
  color: inherit;
}

.views .emoji-fallback,
.viewers .emoji-fallback {
  font-size: 14px;
  margin-right: 4px;
  color: inherit;
}

/* Bouton de fermeture */
.close-button .material-symbols-outlined {
  font-size: 24px;
  color: #FFFFFF;
}

.close-button .emoji-fallback {
  font-size: 20px;
  color: #FFFFFF;
}

/* États d'erreur */
.error-icon .material-symbols-outlined {
  font-size: 48px;
  color: #EF4444;
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 48;
}

.error-icon .emoji-fallback {
  font-size: 48px;
  color: #EF4444;
}
</style>