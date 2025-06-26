<template>
  <section class="content-carousel">
    <div class="section-header">
      <h2>{{ title }}</h2>
      <router-link :to="viewAllLink" class="see-all-btn">
        Voir tout
        <span class="material-symbols-outlined">arrow_forward</span>
      </router-link>
    </div>
    
    <div class="carousel-container">
      <div v-if="loading" class="carousel-loading">
        <div class="loading-spinner"></div>
        <p>Chargement...</p>
      </div>
      
      <div v-else-if="error" class="carousel-error">
        <span class="material-symbols-outlined">error</span>
        <p>Erreur lors du chargement</p>
      </div>
      
      <div v-else-if="items.length === 0" class="carousel-empty">
        <span class="material-symbols-outlined">info</span>
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
                    :src="item.featured_image_url || item.image_url || getDefaultImage()" 
                    :alt="item.title"
                    loading="lazy"
                    @error="handleImageError"
                  />
                  <div class="card-overlay">
                    <span v-if="item.preparation_time || item.estimated_time" class="time-badge">
                      {{ item.preparation_time || item.estimated_time }}min
                    </span>
                    <span v-if="item.status" :class="getStatusClass(item.status)" class="status-badge">
                      {{ getStatusLabel(item.status) }}
                    </span>
                  </div>
                </div>
                
                <div v-else class="card-icon">
                  <span class="material-symbols-outlined">{{ getTypeIcon() }}</span>
                </div>
                
                <div class="card-content">
                  <h3>{{ item.title }}</h3>
                  <p>{{ getShortDescription(item.short_description || item.content || item.description) }}</p>
                  <div class="card-meta">
                    <span v-if="item.likes_count" class="likes">
                      <span class="material-symbols-outlined">favorite</span>
                      {{ item.likes_count }}
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
            <span class="material-symbols-outlined">chevron_left</span>
          </button>
          <button 
            @click="scrollCarousel(1)" 
            class="carousel-btn next"
            :disabled="!canScrollRight"
          >
            <span class="material-symbols-outlined">chevron_right</span>
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
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'

export default {
  name: 'ContentCarousel',
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
    
    // Gestion des événements
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
      if (route) {
        router.push(route)
      }
    }
    
    const handleImageError = (event) => {
      event.target.src = getDefaultImage()
    }
    
    // Utilitaires
    const getShortDescription = (text) => {
      if (!text) return ''
      const cleanText = text.replace(/<[^>]*>/g, '')
      return cleanText.length > 80 ? cleanText.substring(0, 80) + '...' : cleanText
    }
    
    const getDefaultImage = () => {
      const defaults = {
        recipes: '/images/default-recipe.jpg',
        tips: '/images/default-tip.jpg',
        events: '/images/default-event.jpg',
        videos: '/images/default-video.jpg'
      }
      return defaults[props.contentType] || '/images/default.jpg'
    }
    
    const getTypeIcon = () => {
      const icons = {
        recipes: 'restaurant',
        tips: 'lightbulb',
        events: 'event',
        videos: 'play_circle'
      }
      return icons[props.contentType] || 'info'
    }
    
    const getItemClass = () => {
      return `${props.contentType}-card`
    }
    
    const getStatusClass = (status) => {
      return `status-${status}`
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
      return labels[status] || status
    }
    
    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'beginner': 'Débutant',
        'intermediate': 'Intermédiaire',
        'advanced': 'Avancé'
      }
      return labels[difficulty] || difficulty
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short'
      })
    }
    
    // Lifecycle
    onMounted(() => {
      const carousel = carouselRef.value
      if (carousel) {
        carousel.addEventListener('scroll', updateScrollButtons)
        updateScrollButtons()
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
      handleImageError,
      getShortDescription,
      getDefaultImage,
      getTypeIcon,
      getItemClass,
      getStatusClass,
      getStatusLabel,
      getDifficultyLabel,
      formatDate
    }
  }
}
</script>

<style scoped>
.content-carousel {
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
  font-size: 14px;
  transition: all 0.2s ease;
  padding: 8px 12px;
  border-radius: 20px;
}

.see-all-btn:hover {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

/* États de chargement */
.carousel-loading,
.carousel-error,
.carousel-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.carousel-loading .loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 3px solid var(--md-sys-color-primary, #6750a4);
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
  font-size: 32px;
  margin-bottom: 8px;
  opacity: 0.6;
}

/* Carousel */
.carousel-wrapper {
  position: relative;
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
  cursor: pointer;
  transition: all 0.2s ease;
}

.carousel-item:hover {
  transform: translateY(-4px);
}

/* Cartes */
.default-card {
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  height: 100%;
  display: flex;
  flex-direction: column;
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

.card-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 120px;
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
}

.card-icon .material-symbols-outlined {
  font-size: 48px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

.card-overlay {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  gap: 8px;
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

.status-upcoming {
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
  color: var(--md-sys-color-on-tertiary-container, #31111d);
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
.date,
.difficulty {
  display: flex;
  align-items: center;
  gap: 4px;
}

.likes .material-symbols-outlined {
  font-size: 14px;
}

/* Contrôles */
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

.carousel-btn:hover:not(:disabled) {
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
}

.carousel-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Indicateurs */
.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 12px;
}

.indicator {
  width: 8px;
  height: 8px;
  border: none;
  border-radius: 50%;
  background: var(--md-sys-color-outline-variant, #cac4d0);
  cursor: pointer;
  transition: all 0.2s ease;
}

.indicator.active {
  background: var(--md-sys-color-primary, #6750a4);
}

/* Responsive */
@media (max-width: 768px) {
  .content-carousel {
    padding: 24px 16px;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .carousel-item {
    flex: 0 0 240px;
  }
  
  .section-header h2 {
    font-size: 20px;
  }
}

@media (max-width: 480px) {
  .carousel-item {
    flex: 0 0 200px;
  }
  
  .card-image {
    height: 120px;
  }
  
  .card-content {
    padding: 12px;
  }
}
</style>