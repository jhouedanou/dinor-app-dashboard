<template>
  <section 
    v-if="banners && banners.length > 0" 
    class="banner-section"
    :class="`banner-section--${section}`"
  >
    <div 
      v-for="banner in banners" 
      :key="banner.id"
      class="banner-item"
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
  </section>
</template>

<script>
export default {
  name: 'BannerSection',
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
    }
  },
  methods: {
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
    }
  }
};
</script>

<style scoped>
.banner-section {
  width: 100%;
  margin-bottom: 1rem;
}

.banner-item {
  position: relative;
  padding: 2rem 1.5rem;
  border-radius: 12px;
  margin-bottom: 1rem;
  overflow: hidden;
  min-height: 200px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
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

/* Variations par section */
.banner-section--header .banner-item {
  min-height: 120px;
  padding: 1rem 1.5rem;
}

.banner-section--header .banner-title {
  font-size: 1.5rem;
}

.banner-section--hero .banner-item {
  min-height: 300px;
  padding: 3rem 2rem;
}

.banner-section--hero .banner-title {
  font-size: 2.5rem;
}

.banner-section--featured .banner-item {
  min-height: 180px;
  padding: 1.5rem;
}

.banner-section--footer .banner-item {
  min-height: 150px;
  padding: 1.5rem;
}

/* Responsive */
@media (max-width: 768px) {
  .banner-item {
    padding: 1.5rem 1rem;
    min-height: 160px;
  }
  
  .banner-title {
    font-size: 1.5rem;
  }
  
  .banner-subtitle {
    font-size: 1.1rem;
  }
  
  .banner-section--hero .banner-item {
    min-height: 250px;
    padding: 2rem 1rem;
  }
  
  .banner-section--hero .banner-title {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .banner-item {
    padding: 1rem;
    min-height: 140px;
  }
  
  .banner-title {
    font-size: 1.25rem;
  }
  
  .banner-subtitle {
    font-size: 1rem;
  }
  
  .banner-section--hero .banner-title {
    font-size: 1.75rem;
  }
}
</style>