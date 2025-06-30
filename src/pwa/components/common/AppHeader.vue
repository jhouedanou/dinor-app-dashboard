<template>
  <nav class="md3-top-app-bar">
    <div class="md3-app-bar-container">
      <button 
        v-if="showBackButton" 
        @click="handleBack" 
        class="md3-icon-button"
      >
        <span class="material-symbols-outlined">arrow_back</span>
        <span class="emoji-fallback">⬅️</span>
      </button>
      
      <!-- Logo et titre -->
      <div class="md3-app-bar-title">
        <div class="dinor-logo-container">
          <!-- Logo principal (à gauche, plus gros) -->
          <div class="logo-section">
            <img 
              :src="logoSrc" 
              alt="Dinor" 
              class="dinor-logo"
              @error="handleLogoError"
            >
            <!-- Logo fallback SVG inline (masqué par défaut) -->
            <svg 
              class="dinor-logo-fallback" 
              style="display: none;"
              viewBox="0 0 120 50" 
              xmlns="http://www.w3.org/2000/svg"
            >
              <text x="15" y="32" font-family="Arial, sans-serif" font-size="22" font-weight="bold" fill="white">DINOR</text>
            </svg>
          </div>
          
          <!-- Titre (à droite) -->
          <div class="title-section">
            <h1 class="md3-title-large dinor-text-primary">{{ displayTitle }}</h1>
          </div>
        </div>
      </div>
      
      <div class="md3-app-bar-actions">
        <slot name="actions">
          <button 
            v-if="showLike" 
            @click="handleLike" 
            class="md3-icon-button" 
            :class="{ 'liked': isLiked }"
          >
            <span class="material-symbols-outlined">{{ isLiked ? 'favorite' : 'favorite_border' }}</span>
            <span class="emoji-fallback">{{ isLiked ? '❤️' : '🤍' }}</span>
          </button>
          <button 
            v-if="showShare" 
            @click="handleShare" 
            class="md3-icon-button"
          >
            <span class="material-symbols-outlined">share</span>
            <span class="emoji-fallback">📤</span>
          </button>
        </slot>
      </div>
    </div>
  </nav>
</template>

<script>
import { useRouter, useRoute } from 'vue-router'
import { computed, ref } from 'vue'

export default {
  name: 'AppHeader',
  props: {
    title: {
      type: String,
      required: true
    },
    showLike: {
      type: Boolean,
      default: false
    },
    showShare: {
      type: Boolean,
      default: false
    },
    isLiked: {
      type: Boolean,
      default: false
    },
    backPath: {
      type: String,
      default: null
    }
  },
  emits: ['like', 'share', 'back'],
  setup(props, { emit }) {
    const router = useRouter()
    const route = useRoute()
    
    // URL du logo (avec fallback)
    const logoSrc = ref('/images/LOGO_DINOR_monochrome.svg')

    // Masquer le bouton retour sur la page d'accueil
    const showBackButton = computed(() => {
      return route.path !== '/'
    })

    // Titre dynamique selon la page
    const displayTitle = computed(() => {
      if (route.path === '/') {
        return 'Dinor'
      }
      
      // Si un titre est passé en prop, l'utiliser
      if (props.title) {
        return props.title
      }
      
      // Titres par défaut selon la route
      const pageTitles = {
        '/recipes': 'Recettes',
        '/tips': 'Astuces',
        '/events': 'Événements',
        '/dinor-tv': 'Dinor TV',
        '/pages': 'Pages'
      }
      
      // Vérifier si la route correspond à un pattern
      for (const [path, title] of Object.entries(pageTitles)) {
        if (route.path === path || route.path.startsWith(path + '/')) {
          return title
        }
      }
      
      // Titre par défaut
      return 'Dinor'
    })

    const handleBack = () => {
      if (props.backPath) {
        router.push(props.backPath)
      } else {
        router.go(-1)
      }
      emit('back')
    }

    const handleLike = () => {
      emit('like')
    }

    const handleShare = () => {
      emit('share')
    }

    const handleLogoError = () => {
      console.error('❌ [AppHeader] Erreur de chargement du logo DINOR')
      console.log('🔍 [AppHeader] Chemin testé:', logoSrc.value)
      console.log('📁 [AppHeader] Vérifiez que le fichier existe dans public/images/')
      console.log('🔄 [AppHeader] Tentative avec chemin alternatif...')
      
      // Essayer un chemin alternatif
      if (logoSrc.value === '/images/LOGO_DINOR_monochrome.svg') {
        logoSrc.value = './images/LOGO_DINOR_monochrome.svg'
        console.log('🔄 [AppHeader] Nouvel essai avec:', logoSrc.value)
      } else {
        console.error('💥 [AppHeader] Impossible de charger le logo externe')
        console.log('🔄 [AppHeader] Utilisation du logo fallback SVG inline')
        
        // Masquer le logo externe et afficher le fallback SVG
        const logoElement = document.querySelector('.dinor-logo')
        const fallbackElement = document.querySelector('.dinor-logo-fallback')
        
        if (logoElement) {
          logoElement.style.display = 'none'
          console.log('👁️ [AppHeader] Logo externe masqué')
        }
        
        if (fallbackElement) {
          fallbackElement.style.display = 'block'
          console.log('✅ [AppHeader] Logo fallback SVG affiché')
        }
      }
    }

    return {
      showBackButton,
      displayTitle,
      handleBack,
      handleLike,
      handleShare,
      handleLogoError,
      logoSrc
    }
  }
}
</script>

<style scoped>
/* En-tête de navigation */
.md3-top-app-bar {
  background: #E53E3E; /* Rouge Dinor */
  padding: 12px 16px; /* Padding réduit */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.md3-app-bar-container {
  display: flex;
  align-items: center;
  gap: 12px; /* Gap réduit */
  max-width: 1200px;
  margin: 0 auto;
}

.md3-icon-button {
  background: none;
  border: none;
  padding: 6px; /* Padding réduit */
  border-radius: 50%;
  cursor: pointer;
  transition: background-color 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.md3-icon-button:hover {
  background: rgba(255, 255, 255, 0.1);
}

.md3-icon-button span.material-symbols-outlined {
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  font-size: 20px; /* Taille d'icône réduite */
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 20;
}

.md3-icon-button.liked span.material-symbols-outlined {
  color: #F4D03F; /* Doré pour les favoris */
  font-variation-settings: 'FILL' 1, 'wght' 600, 'GRAD' 0, 'opsz' 20;
}

/* Système de fallback pour les icônes - logique simplifiée */
.emoji-fallback {
  display: none; /* Masqué par défaut */
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 20;
}

/* UNIQUEMENT quand .force-emoji est présent sur html, afficher les emoji */
html.force-emoji .material-symbols-outlined {
  display: none !important;
}

html.force-emoji .emoji-fallback {
  display: inline-block !important;
}

.md3-icon-button span.material-symbols-outlined {
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  font-size: 20px; /* Taille d'icône réduite */
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 20;
}

.md3-icon-button.liked span.material-symbols-outlined {
  color: #F4D03F; /* Doré pour les likes/favoris */
  font-variation-settings: 'FILL' 1, 'wght' 600, 'GRAD' 0, 'opsz' 20;
}

/* Styles pour les emoji fallback */
.emoji-fallback {
  font-size: 18px;
  color: #FFFFFF;
}

.md3-icon-button.liked .emoji-fallback {
  color: #F4D03F; /* Doré pour les likes/favoris */
}

.md3-app-bar-title {
  flex: 1;
}

/* Conteneur logo + titre */
.dinor-logo-container {
  display: flex;
  align-items: center;
  justify-content: space-between; /* Logo à gauche, titre à droite */
  width: 100%;
  gap: 16px;
}

/* Section logo (à gauche) */
.logo-section {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

/* Logo Dinor (plus gros) */
.dinor-logo {
  height: 36px; /* Plus gros que les 24px précédents */
  width: auto;
  /* Rendre le logo blanc */
  filter: brightness(0) invert(1);
  flex-shrink: 0; /* Empêche le logo de se compresser */
}

/* Logo fallback SVG (plus gros) */
.dinor-logo-fallback {
  height: 36px; /* Même hauteur que le logo principal */
  width: auto;
  flex-shrink: 0;
}

/* Section titre (à droite) */
.title-section {
  flex: 1;
  text-align: right; /* Alignement à droite */
  min-width: 0; /* Permet la troncature */
}

.md3-app-bar-title h1 {
  margin: 0;
  font-size: 16px; /* Taille de texte réduite */
  font-weight: 600; /* Poids réduit */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  font-family: 'Open Sans', sans-serif;
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.md3-app-bar-actions {
  display: flex;
  gap: 4px; /* Gap réduit */
}

/* Responsive */
@media (max-width: 768px) {
  .md3-top-app-bar {
    padding: 10px 12px; /* Padding encore plus réduit sur mobile */
  }
  
  .dinor-logo-container {
    gap: 12px; /* Gap réduit sur mobile */
  }
  
  .dinor-logo {
    height: 28px; /* Logo plus petit sur mobile mais toujours plus gros qu'avant */
  }
  
  .dinor-logo-fallback {
    height: 28px; /* Logo fallback plus petit sur mobile */
  }
  
  .md3-app-bar-title h1 {
    font-size: 20px;
    font-weight: bold; /* Titre plus petit sur mobile */
  }
}

@media (max-width: 480px) {
  .md3-app-bar-title h1 {
    display: none; /* Masquer le titre sur très petit écran */
  }
  
  .dinor-logo {
    height: 32px; /* Logo encore plus gros quand seul */
  }
  
  .dinor-logo-fallback {
    height: 32px; /* Logo fallback plus grand quand seul */
  }
  
  .dinor-logo-container {
    justify-content: center; /* Centrer le logo quand pas de titre */
  }
}
</style> 