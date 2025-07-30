<template>
  <section class="content-carousel">
    <div class="section-header">
      <h2>{{ title }}</h2>
      <router-link :to="viewAllLink" class="see-all-btn">
        Voir tout
        <DinorIcon name="arrow_forward" :size="18" />
      </router-link>
    </div>
    
    <div class="carousel-container">
      <div v-if="loading" class="carousel-loading">
        <div class="loading-spinner"></div>
        <p>Chargement...</p>
      </div>
      
      <div v-else-if="error" class="carousel-error">
        <DinorIcon name="error" :size="48" />
        <p>Erreur lors du chargement</p>
      </div>
      
      <div v-else-if="items.length === 0" class="carousel-empty">
        <DinorIcon name="info" :size="48" />
        <p>Aucun contenu disponible</p>
      </div>
      
      <div v-else class="carousel-wrapper">
        <div class="carousel" :ref="carouselRef">
          <div 
            v-for="item in items" 
            :key="item.id"
            @click="handleItemClick(item)"
            class="carousel-item"
            :class="getItemClass()"
          >
            <!-- Slot pour le contenu personnalisé -->
            <slot name="item" :item="item" :getShortDescription="getShortDescription">
              <!-- Contenu par défaut -->
              <div class="default-card">
                <div v-if="item.featured_image_url || item.image_url" class="card-image">
                  <img 
                    :src="getImageUrl(item.featured_image_url || item.image_url, contentType)" 
                    :alt="item.title"
                    loading="lazy"
                    @error="handleImageError"
                  />
                  <div class="card-overlay">
                    <span v-if="getTotalTime(item)" class="time-badge">
                      {{ getTotalTime(item) }}min
                    </span>
                    <span v-if="item.status" :class="getStatusClass(item.status)" class="status-badge">
                      {{ getStatusLabel(item.status) }}
                    </span>
                  </div>
                </div>
                
                <div v-else class="card-icon">
                  <DinorIcon :name="getTypeIcon()" :size="32" />
                </div>
                
                <div class="card-content">
                  <h3>{{ item.title }}</h3>
                  <p>{{ getShortDescription(item.short_description || item.content || item.description) }}</p>
                  <div class="card-meta">
                    <span v-if="item.likes_count" class="likes">
                      <DinorIcon name="thumb_up" :size="16" />
                      {{ item.likes_count }}
                    </span>
                    <span v-if="item.favorites_count" class="favorites">
                      <DinorIcon name="favorite" :size="16" />
                      {{ item.favorites_count }}
                    </span>
                    <span v-if="item.created_at" class="date">
                      {{ formatDate(item.created_at) }}
                    </span>
                    <span v-if="item.difficulty_level" class="difficulty">
                      {{ getDifficultyLabel(item.difficulty_level) }}
                    </span>
                  </div>
                </div>
              </div>
            </slot>
          </div>
        </div>
        
        <!-- Contrôles de navigation -->
        <div v-if="showControls && items.length > 1" class="carousel-controls">
          <button 
            @click="scrollCarousel(-1)" 
            class="carousel-btn prev"
            :disabled="!canScrollLeft"
          >
            <DinorIcon name="chevron_left" :size="24" />
          </button>
          <button 
            @click="scrollCarousel(1)" 
            class="carousel-btn next"
            :disabled="!canScrollRight"
          >
            <DinorIcon name="chevron_right" :size="24" />
          </button>
        </div>
        
        <!-- Indicateurs -->
        <div v-if="showIndicators && items.length > 1" class="carousel-indicators">
          <button
            v-for="(item, index) in items"
            :key="index"
            @click="scrollToIndex(index)"
            class="indicator"
            :class="{ active: currentIndex === index }"
          ></button>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import { ref, onMounted, onUnmounted, computed, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import DinorIcon from '@/components/DinorIcon.vue'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'ContentCarousel',
  components: {
    DinorIcon
  },
  props: {
    title: {
      type: String,
      required: true
    },
    items: {
      type: Array,
      default: () => []
    },
    loading: {
      type: Boolean,
      default: false
    },
    error: {
      type: String,
      default: null
    },
    contentType: {
      type: String,
      required: true,
      validator: value => ['recipes', 'tips', 'events', 'videos'].includes(value)
    },
    viewAllLink: {
      type: String,
      required: true
    },
    showControls: {
      type: Boolean,
      default: true
    },
    showIndicators: {
      type: Boolean,
      default: false
    },
    itemsPerView: {
      type: Number,
      default: 4
    },
    disableAutoNavigation: {
      type: Boolean,
      default: false
    }
  },
  emits: ['item-click'],
  setup(props, { emit }) {
    const router = useRouter()
    const carouselRef = ref(null)
    const currentIndex = ref(0)
    const canScrollLeft = ref(false)
    const canScrollRight = ref(true)
    
    // Gestion du scroll
    const scrollCarousel = (direction) => {
      const carousel = carouselRef.value
      if (!carousel) return
      
      const itemWidth = carousel.querySelector('.carousel-item')?.offsetWidth || 280
      const gap = 16 // Gap entre les items
      const scrollAmount = (itemWidth + gap) * 2 // Scroll de 2 items à la fois
      
      carousel.scrollBy({
        left: direction * scrollAmount,
        behavior: 'smooth'
      })
      
      // Mettre à jour les états des boutons après un délai
      setTimeout(updateScrollButtons, 300)
    }
    
    const scrollToIndex = (index) => {
      const carousel = carouselRef.value
      if (!carousel) return
      
      const itemWidth = carousel.querySelector('.carousel-item')?.offsetWidth || 280
      const gap = 16
      const scrollPosition = index * (itemWidth + gap)
      
      carousel.scrollTo({
        left: scrollPosition,
        behavior: 'smooth'
      })
      
      currentIndex.value = index
    }
    
    const updateScrollButtons = () => {
      const carousel = carouselRef.value
      if (!carousel) return
      
      canScrollLeft.value = carousel.scrollLeft > 0
      canScrollRight.value = carousel.scrollLeft < (carousel.scrollWidth - carousel.clientWidth)
    }
    
    // Gestion des clics sur les items
    const handleItemClick = (item) => {
      emit('item-click', item)
      
      // Navigation par défaut
      const routes = {
        recipes: `/recipe/${item.id}`,
        tips: `/tip/${item.id}`,
        events: `/event/${item.id}`,
        videos: `/video/${item.id}`
      }
      
      const route = routes[props.contentType]
      if (route && !props.disableAutoNavigation) {
        router.push(route)
      }
    }
    
    // Utilitaires pour l'affichage
    const getShortDescription = (text) => {
      if (!text) return 'Aucune description disponible'
      const maxLength = 100
      return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      })
    }
    
    const formatDuration = (seconds) => {
      if (!seconds) return ''
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
    }
    
    const getDifficultyLabel = (difficulty) => {
      const levels = {
        'easy': 'Facile',
        'medium': 'Moyen',
        'hard': 'Difficile',
        'beginner': 'Débutant',
        'intermediate': 'Intermédiaire',
        'advanced': 'Avancé'
      }
      return levels[difficulty] || difficulty || 'Non spécifié'
    }
    
    const getStatusLabel = (status) => {
      const labels = {
        'active': 'Actif',
        'upcoming': 'À venir',
        'completed': 'Terminé',
        'cancelled': 'Annulé',
        'draft': 'Brouillon',
        'published': 'Publié'
      }
      return labels[status] || status || 'Non défini'
    }
    
    const getStatusClass = (status) => {
      return `status-${status}`
    }
    
    const getItemClass = () => {
      return `content-${props.contentType}`
    }
    
    const getTypeIcon = () => {
      const icons = {
        'recipes': 'restaurant',
        'tips': 'lightbulb',
        'events': 'event',
        'videos': 'play_circle'
      }
      return icons[props.contentType] || 'info'
    }

    const getTotalTime = (item) => {
      // Pour les recettes, calculer le temps total
      if (props.contentType === 'recipes') {
        const prepTime = item.preparation_time || 0
        const cookTime = item.cooking_time || 0
        const restTime = item.resting_time || 0
        const total = prepTime + cookTime + restTime
        return total > 0 ? total : null
      }
      
      // Pour les autres types, utiliser le temps estimé
      return item.estimated_time || item.preparation_time || null
    }
    
    const getDefaultImage = () => {
      return getImageUrl(null, props.contentType)
    }
    
    const getVideoThumbnail = (videoUrl) => {
      // Logique pour extraire la miniature de la vidéo
      if (videoUrl?.includes('youtube.com') || videoUrl?.includes('youtu.be')) {
        const videoId = videoUrl.split('v=')[1] || videoUrl.split('/').pop()
        return `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`
      }
      return '/images/default-video-thumbnail.jpg'
    }
    
    const handleImageError = (event) => {
      event.target.src = getDefaultImage()
    }
    
    // Lifecycle
    onMounted(async () => {
      await nextTick()
      updateScrollButtons()
      
      // Écouter les événements de scroll
      const carousel = carouselRef.value
      if (carousel) {
        carousel.addEventListener('scroll', updateScrollButtons)
      }
    })
    
    onUnmounted(() => {
      const carousel = carouselRef.value
      if (carousel) {
        carousel.removeEventListener('scroll', updateScrollButtons)
      }
    })
    
    return {
      carouselRef,
      currentIndex,
      canScrollLeft,
      canScrollRight,
      scrollCarousel,
      scrollToIndex,
      handleItemClick,
      getShortDescription,
      formatDate,
      formatDuration,
      getDifficultyLabel,
      getStatusLabel,
      getStatusClass,
      getItemClass,
      getTypeIcon,
      getTotalTime,
      getDefaultImage,
      getVideoThumbnail,
      handleImageError,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.content-carousel {
  margin-bottom: 32px;
  background: #FFFFFF; /* Fond blanc */
  border-radius: 16px;
  overflow: hidden;
  padding-bottom: 2em !important;
 /* box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); */
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center !important;
  padding: 1em;
  flex-direction:row !important;
  background: #F4D03F; /* Fond doré */
  border-radius: 16px 16px 0 0;
}

.section-header h2 {
  margin: 0;
  font-size: 1.2em;
  font-weight: 700;
  font-family: 'Open Sans', sans-serif;
  color: #000000; /* Noir sur doré - contraste 5.1:1 */
}

.see-all-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 8px 16px;
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  text-decoration: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.see-all-btn:hover {
  background: #C53030; /* Rouge plus foncé */
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
}

.see-all-btn .material-symbols-outlined {
  font-size: 18px;
}

.carousel-container {
  padding: 16px;
}

.carousel-loading,
.carousel-error,
.carousel-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 16px;
  text-align: center;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #E2E8F0;
  border-top: 3px solid #E53E3E;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.carousel-error .material-symbols-outlined,
.carousel-empty .material-symbols-outlined {
  font-size: 48px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
  margin-bottom: 12px;
}

.carousel-error p,
.carousel-empty p {
  margin: 0;
  font-size: 14px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
}

.carousel-wrapper {
  position: relative;
}

.carousel {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  scroll-behavior: smooth;
  padding-bottom: 8px;
  scrollbar-width: thin;
  scrollbar-color: #E53E3E #F7FAFC;
}

.carousel::-webkit-scrollbar {
  height: 6px;
}

.carousel::-webkit-scrollbar-track {
  background: #F7FAFC;
  border-radius: 3px;
}

.carousel::-webkit-scrollbar-thumb {
  background: #E53E3E;
  border-radius: 3px;
}

.carousel::-webkit-scrollbar-thumb:hover {
  background: #C53030;
}

.carousel-item {
  flex: 0 0 280px;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.carousel-item:hover {
  transform: translateY(-4px);
}

/* Styles par défaut pour les cartes */
.default-card,
.recipe-card,
.tip-card,
.event-card,
.video-card {
  background: #FFFFFF;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid #E2E8F0;
  transition: all 0.2s ease;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.default-card:hover,
.recipe-card:hover,
.tip-card:hover,
.event-card:hover,
.video-card:hover {
  box-shadow: 0 4px 16px rgba(229, 62, 62, 0.2);
  border-color: #E53E3E;
}

.card-image,
.video-thumbnail {
  height: 160px;
  overflow: hidden;
  position: relative;
}

.card-image img,
.video-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: brightness(1.1) contrast(1.1);
}

.card-overlay,
.video-overlay {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  gap: 4px;
  flex-direction: column;
  align-items: flex-end;
}

.time-badge,
.difficulty-badge,
.status-badge,
.duration-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.time-badge,
.duration-badge {
  background: #E53E3E;
  color: #FFFFFF;
}

.difficulty-badge {
  background: #F4D03F;
  color: #2D3748;
}

.status-active {
  background: #E53E3E;
  color: #FFFFFF;
}

.status-upcoming {
  background: #F4D03F;
  color: #2D3748;
}

.status-completed {
  background: #4A5568;
  color: #FFFFFF;
}

.status-cancelled {
  background: #FF6B35;
  color: #FFFFFF;
}

.live-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  background: #E53E3E;
  color: #FFFFFF;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
}

.live-dot {
  width: 6px;
  height: 6px;
  background: #FFFFFF;
  border-radius: 50%;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.play-button {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 48px;
  height: 48px;
  background: rgba(229, 62, 62, 0.9);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.play-button:hover {
  background: #E53E3E;
  transform: translate(-50%, -50%) scale(1.1);
}

.play-button .material-symbols-outlined {
  font-size: 28px;
  color: #FFFFFF;
}

.card-icon {
  height: 160px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #F7FAFC;
}

.card-icon .material-symbols-outlined {
  font-size: 64px;
  color: #E53E3E;
}

.tip-icon {
  width: 48px;
  height: 48px;
  background: #F4D03F;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 16px auto 12px;
  flex-shrink: 0;
}

.tip-icon .material-symbols-outlined {
  font-size: 24px;
  color: #2D3748;
}

.card-content {
  padding: 16px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-content h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 700;
  color: #000000;
  font-family: 'Open Sans', sans-serif;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-content p {
  margin: 0 0 12px 0;
  font-size: 13px;
  color: #4A5568;
  line-height: 1.4;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #4A5568;
  margin-top: auto;
}

.likes,
.favorites,
.views {
  display: flex;
  align-items: center;
  gap: 4px;
}

.likes .material-symbols-outlined {
  font-size: 16px;
  color: #3182CE;
}

.favorites .material-symbols-outlined,
.views .material-symbols-outlined {
  font-size: 16px;
  color: #E53E3E;
}

.date,
.created {
  font-size: 11px;
  color: #718096;
}

.time,
.difficulty {
  padding: 2px 6px;
  background: #F7FAFC;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
  color: #2D3748;
}

/* Contrôles du carousel */
.carousel-controls {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  transform: translateY(-50%);
  display: flex;
  justify-content: space-between;
  pointer-events: none;
  padding: 0 8px;
}

.carousel-btn {
  width: 40px;
  height: 40px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  pointer-events: auto;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.carousel-btn:hover:not(:disabled) {
  background: #E53E3E;
  border-color: #E53E3E;
  transform: scale(1.1);
}

.carousel-btn:hover:not(:disabled) .material-symbols-outlined {
  color: #FFFFFF;
}

.carousel-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.carousel-btn .material-symbols-outlined {
  font-size: 24px;
  color: #2D3748;
  transition: color 0.2s ease;
}

/* Indicateurs */
.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 16px;
}

.indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: none;
  background: #CBD5E0;
  cursor: pointer;
  transition: all 0.2s ease;
}

.indicator.active,
.indicator:hover {
  background: #E53E3E;
  transform: scale(1.2);
}

/* Responsive */
@media (max-width: 768px) {
  .carousel-item {
    flex: 0 0 240px;
  }
  
  .section-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
  
  .carousel-controls {
    display: none;
  }
}

@media (max-width: 480px) {
  .carousel-item {
    flex: 0 0 200px;
  }
  
  .card-image,
  .video-thumbnail {
    height: 120px;
  }
  
  .card-content {
    padding: 12px;
  }
  
  .card-content h3 {
    font-size: 14px;
  }
  
  .card-content p {
    font-size: 12px;
  }
}
</style>