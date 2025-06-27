<template>
  <nav class="md3-top-app-bar">
    <div class="md3-app-bar-container">
      <button 
        v-if="showBackButton" 
        @click="handleBack" 
        class="md3-icon-button"
      >
        <i class="material-icons">arrow_back</i>
      </button>
      <div class="md3-app-bar-title">
        <h1 class="md3-title-large dinor-text-primary">{{ displayTitle }}</h1>
      </div>
      <div class="md3-app-bar-actions">
        <slot name="actions">
          <button 
            v-if="showLike" 
            @click="handleLike" 
            class="md3-icon-button" 
            :class="{ 'liked': isLiked }"
          >
            <i class="material-icons">{{ isLiked ? 'favorite' : 'favorite_border' }}</i>
          </button>
          <button 
            v-if="showShare" 
            @click="handleShare" 
            class="md3-icon-button"
          >
            <i class="material-icons">share</i>
          </button>
        </slot>
      </div>
    </div>
  </nav>
</template>

<script>
import { useRouter, useRoute } from 'vue-router'
import { computed } from 'vue'

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

    return {
      showBackButton,
      displayTitle,
      handleBack,
      handleLike,
      handleShare
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

.md3-icon-button i {
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  font-size: 20px; /* Taille d'icône réduite */
}

.md3-app-bar-title {
  flex: 1;
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

.md3-icon-button.liked i {
  color: #F4D03F; /* Doré pour les favoris */
}

/* Responsive */
@media (max-width: 768px) {
  .md3-top-app-bar {
    padding: 10px 12px; /* Padding encore plus réduit sur mobile */
  }
  
  .md3-app-bar-container {
    gap: 8px;
  }
  
  .md3-app-bar-title h1 {
    font-size: 14px; /* Taille encore plus petite sur mobile */
  }
  
  .md3-icon-button i {
    font-size: 18px;
  }
}
</style> 