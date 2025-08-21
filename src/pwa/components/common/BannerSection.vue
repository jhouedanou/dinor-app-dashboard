<template>
  <section 
    v-if="visibleBanners && visibleBanners.length > 0" 
    class="banner-section"
    :class="`banner-section--${section}`"
  >
    <!-- Conteneur du carousel -->
    <div 
      class="banner-carousel" 
      ref="carousel"
      @mouseenter="pauseAutoPlay"
      @mouseleave="resumeAutoPlay"
    >
      <div 
        v-for="(banner, index) in visibleBanners" 
        :key="banner.id"
        class="banner-item"
        :class="{ 'active': index === currentSlide }"
        :style="getBannerStyle(banner)"
      >
      <!-- Image de fond si disponible -->
      <div 
        v-if="banner.image_url" 
        class="banner-background"
        :style="{ backgroundImage: `url(${banner.image_url})` }"
      ></div>
      
      <!-- Contenu de la bannière -->
      <div class="banner-content">
        <!-- Titre principal -->
        <h2 
          v-if="banner.titre" 
          class="banner-title"
          :style="{ color: banner.text_color || '#FFFFFF' }"
        >
          {{ banner.titre }}
        </h2>
        
        <!-- Sous-titre -->
        <h3 
          v-if="banner.sous_titre" 
          class="banner-subtitle"
          :style="{ color: banner.text_color || '#FFFFFF' }"
        >
          {{ banner.sous_titre }}
        </h3>
        
        <!-- Description -->
        <p 
          v-if="banner.description" 
          class="banner-description"
          :style="{ color: banner.text_color || '#FFFFFF' }"
        >
          {{ banner.description }}
        </p>
        
        <!-- Vidéo demo -->
        <div 
          v-if="banner.demo_video_url" 
          class="banner-video"
        >
          <button 
            @click="playDemoVideo(banner.demo_video_url)"
            class="video-play-button"
            :style="{ color: banner.text_color || '#FFFFFF' }"
          >
            <DinorIcon name="play_circle" :size="20" />
            <span>Voir la démo</span>
          </button>
        </div>
        
        <!-- Bouton d'action -->
        <button 
          v-if="banner.button_text && banner.button_url"
          class="banner-button"
          :style="getBannerButtonStyle(banner)"
          @click="handleButtonClick(banner.button_url)"
        >
          {{ banner.button_text }}
        </button>
      </div>
      </div>
    </div>

    <!-- Contrôles du carousel (seulement si plusieurs bannières) -->
    <div v-if="visibleBanners.length > 1" class="carousel-controls">
      <!-- Indicateurs -->
      <div class="carousel-indicators">
        <button
          v-for="(banner, index) in visibleBanners"
          :key="`indicator-${banner.id}`"
          class="indicator"
          :class="{ 'active': index === currentSlide }"
          @click="goToSlide(index)"
          :aria-label="`Aller à la bannière ${index + 1}`"
        ></button>
      </div>

      <!-- Boutons précédent/suivant -->
      <div class="carousel-nav">
        <button
          class="nav-btn prev-btn"
          @click="prevSlide"
          :disabled="isTransitioning"
          aria-label="Bannière précédente"
        >
          <DinorIcon name="chevron_left" :size="24" />
        </button>
        <button
          class="nav-btn next-btn"
          @click="nextSlide"
          :disabled="isTransitioning"
          aria-label="Bannière suivante"
        >
          <DinorIcon name="chevron_right" :size="24" />
        </button>
      </div>
    </div>
  </section>
</template>

<script>
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'BannerSection',
  components: {
    DinorIcon
  },
  props: {
    type: {
      type: String,
      required: true,
      validator: (value) => ['recipes', 'tips', 'events', 'dinor_tv', 'pages', 'home'].includes(value)
    },
    section: {
      type: String,
      default: 'hero',
      validator: (value) => ['header', 'hero', 'featured', 'footer'].includes(value)
    },
    banners: {
      type: Array,
      default: () => []
    },
    autoPlay: {
      type: Boolean,
      default: true
    },
    interval: {
      type: Number,
      default: 5000
    }
  },
  data() {
    return {
      currentSlide: 0,
      isTransitioning: false,
      autoPlayInterval: null,
      isPaused: false
    }
  },
  computed: {
    visibleBanners() {
      return this.banners.filter(banner => banner.image_url);
    }
  },
  watch: {
    visibleBanners: {
      handler() {
        // Réinitialiser le slide si les bannières changent
        this.currentSlide = 0;
        this.setupAutoPlay();
      },
      immediate: true
    }
  },
  mounted() {
    this.setupAutoPlay();
  },
  beforeUnmount() {
    this.clearAutoPlay();
  },
  methods: {
    // Méthodes du carousel
    setupAutoPlay() {
      this.clearAutoPlay();
      if (this.autoPlay && this.visibleBanners.length > 1 && !this.isPaused) {
        this.autoPlayInterval = setInterval(() => {
          if (!this.isPaused) {
            this.nextSlide();
          }
        }, this.interval);
      }
    },
    pauseAutoPlay() {
      this.isPaused = true;
      this.clearAutoPlay();
    },
    resumeAutoPlay() {
      this.isPaused = false;
      this.setupAutoPlay();
    },
    clearAutoPlay() {
      if (this.autoPlayInterval) {
        clearInterval(this.autoPlayInterval);
        this.autoPlayInterval = null;
      }
    },
    goToSlide(index) {
      if (this.isTransitioning || index === this.currentSlide) return;
      
      this.isTransitioning = true;
      this.currentSlide = index;
      
      setTimeout(() => {
        this.isTransitioning = false;
      }, 500);

      // Réinitialiser l'autoplay
      this.setupAutoPlay();
    },
    nextSlide() {
      const nextIndex = (this.currentSlide + 1) % this.visibleBanners.length;
      this.goToSlide(nextIndex);
    },
    prevSlide() {
      const prevIndex = this.currentSlide === 0 
        ? this.visibleBanners.length - 1 
        : this.currentSlide - 1;
      this.goToSlide(prevIndex);
    },
    // Méthodes existantes
    getBannerStyle(banner) {
      return {
        backgroundColor: banner.background_color || '#E1251B',
        color: banner.text_color || '#FFFFFF'
      };
    },
    getBannerButtonStyle(banner) {
      return {
        backgroundColor: banner.button_color || '#FFFFFF',
        color: this.getContrastColor(banner.button_color || '#FFFFFF'),
        border: `2px solid ${banner.button_color || '#FFFFFF'}`
      };
    },
    getContrastColor(hexColor) {
      // Fonction pour déterminer si le texte doit être noir ou blanc basé sur la couleur de fond
      const r = parseInt(hexColor.slice(1, 3), 16);
      const g = parseInt(hexColor.slice(3, 5), 16);
      const b = parseInt(hexColor.slice(5, 7), 16);
      const brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
      return brightness > 128 ? '#000000' : '#FFFFFF';
    },
    handleButtonClick(url) {
      // Gestion des liens internes et externes
      if (url.startsWith('/')) {
        // Lien interne - utiliser le router Vue
        this.$router.push(url);
      } else if (url.startsWith('http')) {
        // Lien externe - ouvrir dans un nouvel onglet
        window.open(url, '_blank');
      } else {
        // Essayer de naviguer vers la route
        this.$router.push(url);
      }
    },
    playDemoVideo(videoUrl) {
      // Ouvrir la vidéo demo dans un nouvel onglet
      if (videoUrl) {
        window.open(videoUrl, '_blank');
      }
    }
  }
};
</script>

<style scoped>
.banner-section {
  width: 100%;
  margin-bottom: 1rem;
  position: relative;
}

/* Conteneur du carousel */
.banner-carousel {
  position: relative;
  width: 100%;
  height: 400px;
  overflow: hidden;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.banner-item {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  padding: 2rem 1.5rem;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transform: translateX(100%);
  transition: all 0.5s ease-in-out;
}

.banner-item.active {
  opacity: 1;
  visibility: visible;
  transform: translateX(0);
}

.banner-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.3;
  z-index: 0;
}

.banner-content {
  position: relative;
  z-index: 1;
  max-width: 100%;
  text-align: center;
}

.banner-title {
  font-size: 1.75rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
  line-height: 1.2;
}

.banner-subtitle {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 1rem;
  line-height: 1.3;
}

.banner-description {
  font-size: 1rem;
  line-height: 1.5;
  margin-bottom: 1.5rem;
  opacity: 0.9;
}

.banner-button {
  padding: 0.75rem 2rem;
  border-radius: 50px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.banner-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* Styles pour la vidéo demo */
.banner-video {
  margin-bottom: 1rem;
}

.video-play-button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: rgba(0, 0, 0, 0.2);
  border: 2px solid currentColor;
  border-radius: 50px;
  color: inherit;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.video-play-button:hover {
  background: rgba(0, 0, 0, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.video-play-button .material-symbols-outlined {
  font-size: 1.5rem;
}

.video-play-button .emoji-fallback {
  font-size: 1.25rem;
  display: none;
}

/* Système de fallback pour les icônes */
html.force-emoji .video-play-button .material-symbols-outlined {
  display: none !important;
}

html.force-emoji .video-play-button .emoji-fallback {
  display: inline-block !important;
}

/* Contrôles du carousel */
.carousel-controls {
  margin-top: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* Indicateurs */
.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  flex: 1;
}

.indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.5);
  cursor: pointer;
  transition: all 0.3s ease;
}

.indicator.active {
  background: #E1251B;
  transform: scale(1.2);
}

.indicator:hover {
  background: rgba(225, 37, 27, 0.7);
}

/* Navigation */
.carousel-nav {
  display: flex;
  gap: 0.5rem;
  position: absolute;
  top: 50%;
  width: 100%;
  padding: 0 1rem;
  pointer-events: none;
  transform: translateY(-50%);
}

.nav-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  pointer-events: auto;
  backdrop-filter: blur(10px);
}

.nav-btn:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.8);
  transform: scale(1.1);
}

.nav-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.prev-btn {
  margin-right: auto;
}

.next-btn {
  margin-left: auto;
}

/* Variations par section */
.banner-section--header .banner-carousel {
  height: 200px;
}

.banner-section--header .banner-item {
  padding: 1rem 1.5rem;
}

.banner-section--header .banner-title {
  font-size: 1.5rem;
}

.banner-section--hero .banner-carousel {
  height: 400px;
}

.banner-section--hero .banner-item {
  padding: 3rem 2rem;
}

.banner-section--hero .banner-title {
  font-size: 2.5rem;
}

.banner-section--featured .banner-carousel {
  height: 250px;
}

.banner-section--featured .banner-item {
  padding: 1.5rem;
}

.banner-section--footer .banner-carousel {
  height: 200px;
}

.banner-section--footer .banner-item {
  padding: 1.5rem;
}

/* Responsive */
@media (max-width: 768px) {
  .banner-carousel {
    height: 300px;
  }
  
  .banner-item {
    padding: 1.5rem 1rem;
  }
  
  .banner-title {
    font-size: 1.5rem;
  }
  
  .banner-subtitle {
    font-size: 1.1rem;
  }
  
  .banner-section--hero .banner-carousel {
    height: 350px;
  }
  
  .banner-section--hero .banner-item {
    padding: 2rem 1rem;
  }
  
  .banner-section--hero .banner-title {
    font-size: 2rem;
  }
  
  .banner-section--header .banner-carousel {
    height: 180px;
  }
  
  .nav-btn {
    width: 35px;
    height: 35px;
  }
  
  .carousel-nav {
    padding: 0 0.5rem;
  }
}

@media (max-width: 480px) {
  .banner-carousel {
    height: 250px;
  }
  
  .banner-item {
    padding: 1rem;
  }
  
  .banner-title {
    font-size: 1.25rem;
  }
  
  .banner-subtitle {
    font-size: 1rem;
  }
  
  .banner-section--hero .banner-carousel {
    height: 280px;
  }
  
  .banner-section--hero .banner-title {
    font-size: 1.75rem;
  }
  
  .banner-section--header .banner-carousel {
    height: 150px;
  }
  
  .nav-btn {
    width: 30px;
    height: 30px;
  }
  
  .indicator {
    width: 10px;
    height: 10px;
  }
  
  .carousel-controls {
    margin-top: 0.5rem;
  }
}
</style>