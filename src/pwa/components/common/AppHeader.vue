<template>
  <nav class="md3-top-app-bar">
    <div class="md3-app-bar-container">
      <button 
        v-if="showBackButton" 
        @click="handleBack" 
        class="md3-icon-button"
      >
        <DinorIcon name="arrow_back" :size="24" />
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
        <!-- Dev only refresh button -->
        <CacheRefreshButton v-if="isDevelopment" size="small" />
        
        <slot name="actions">
          <button 
            v-if="showFavorite" 
            @click="handleFavoriteToggle" 
            class="md3-icon-button" 
            :class="{ 'liked': isFavorited, 'loading': favoriteLoading }"
            :disabled="favoriteLoading || !canInteractWithFavorites"
            :title="isFavorited ? 'Retirer des favoris' : 'Ajouter aux favoris'"
          >
            <!-- Loading state -->
            <div v-if="favoriteLoading" class="loading-spinner-header"></div>
            <!-- Heart icon -->
            <template v-else>
              <DinorIcon :name="isFavorited ? 'favorite' : 'favorite_border'" :size="24" :filled="isFavorited" />
            </template>
          </button>
          <button 
            v-if="showShare" 
            @click="handleShare" 
            class="md3-icon-button"
          >
            <DinorIcon name="share" :size="24" />
          </button>
        </slot>
      </div>
    </div>
  </nav>
</template>

<script>
import { useRouter, useRoute } from 'vue-router'
import { computed, ref, watch, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import apiService from '@/services/api'
import CacheRefreshButton from './CacheRefreshButton.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'AppHeader',
  components: {
    CacheRefreshButton,
    DinorIcon
  },
  props: {
    title: {
      type: String,
      required: true
    },
    showFavorite: {
      type: Boolean,
      default: false
    },
    favoriteType: {
      type: String,
      validator: (value) => ['recipe', 'tip', 'event', 'dinor_tv'].includes(value)
    },
    favoriteItemId: {
      type: [Number, String]
    },
    initialFavorited: {
      type: Boolean,
      default: false
    },
    showShare: {
      type: Boolean,
      default: false
    },
    backPath: {
      type: String,
      default: null
    }
  },
  emits: ['favorite-updated', 'share', 'back', 'auth-required'],
  setup(props, { emit }) {
    const router = useRouter()
    const route = useRoute()
    const authStore = useAuthStore()
    
    const isDevelopment = computed(() => import.meta.env.DEV)
    
    // URL du logo (avec fallback)
    const logoSrc = ref('/images/LOGO_DINOR_monochrome.svg')
    
    // État des favoris
    const isFavorited = ref(props.initialFavorited)
    const favoriteLoading = ref(false)

    // Masquer le bouton retour sur la page d'accueil
    const showBackButton = computed(() => {
      return route.path !== '/'
    })
    
    // Vérifier si l'utilisateur peut interagir avec les favoris
    const canInteractWithFavorites = computed(() => {
      const result = authStore.isAuthenticated && props.favoriteType && props.favoriteItemId
      console.log('🔍 [AppHeader] canInteractWithFavorites:', {
        isAuthenticated: authStore.isAuthenticated,
        favoriteType: props.favoriteType,
        favoriteItemId: props.favoriteItemId,
        result
      })
      return result
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
    
    // Charger le statut favori
    const loadFavoriteStatus = async () => {
      console.log('📊 [AppHeader] === CHARGEMENT STATUT FAVORI ===')
      console.log('📊 [AppHeader] Vérifications:', {
        isAuthenticated: authStore.isAuthenticated,
        favoriteType: props.favoriteType,
        favoriteItemId: props.favoriteItemId
      })
      
      if (!authStore.isAuthenticated || !props.favoriteType || !props.favoriteItemId) {
        console.log('📊 [AppHeader] Conditions non remplies, favori = false')
        isFavorited.value = false
        return
      }
      
      try {
        console.log('📡 [AppHeader] Vérification API du statut favori...')
        const data = await apiService.checkFavorite(props.favoriteType, props.favoriteItemId)
        console.log('📡 [AppHeader] Réponse statut favori:', data)
        
        if (data.success) {
          isFavorited.value = data.is_favorited
          console.log('✅ [AppHeader] Statut favori chargé:', data.is_favorited)
        }
      } catch (error) {
        console.warn('⚠️ [AppHeader] Erreur lors de la vérification du statut favori:', error)
      }
      
      console.log('📊 [AppHeader] === FIN CHARGEMENT STATUT FAVORI ===')
    }
    
    // Gérer le toggle des favoris
    const handleFavoriteToggle = async () => {
      console.log('🌟 [AppHeader] === DÉBUT TOGGLE FAVORI ===')
      console.log('🌟 [AppHeader] Props reçues:', {
        type: props.favoriteType,
        itemId: props.favoriteItemId,
        showFavorite: props.showFavorite
      })
      
      // Vérification détaillée de l'authentification
      console.log('🔐 [AppHeader] État d\'authentification détaillé:', {
        'authStore.isAuthenticated': authStore.isAuthenticated,
        'authStore.user': authStore.user,
        'authStore.token': authStore.token ? '***existe***' : null,
        'localStorage.auth_token': localStorage.getItem('auth_token') ? '***existe***' : null,
        'localStorage.auth_user': localStorage.getItem('auth_user') ? '***existe***' : null
      })
      
      // Forcer la réinitialisation de l'auth store si nécessaire
      const savedToken = localStorage.getItem('auth_token')
      const savedUser = localStorage.getItem('auth_user')
      
      if (savedToken && savedUser && !authStore.isAuthenticated) {
        console.log('🔄 [AppHeader] Réinitialisation de l\'auth store détectée')
        authStore.initAuth()
        
        // Attendre un peu que l'état se mette à jour
        await new Promise(resolve => setTimeout(resolve, 100))
        
        console.log('🔄 [AppHeader] État après réinitialisation:', {
          'authStore.isAuthenticated': authStore.isAuthenticated,
          'authStore.user': authStore.user
        })
      }
      
      if (!authStore.isAuthenticated) {
        console.log('🔒 [AppHeader] Utilisateur non connecté - affichage modal auth')
        emit('auth-required')
        return
      }
      
      if (!props.favoriteType || !props.favoriteItemId) {
        console.error('❌ [AppHeader] Type ou ID manquant pour les favoris:', {
          favoriteType: props.favoriteType,
          favoriteItemId: props.favoriteItemId
        })
        return
      }
      
      if (favoriteLoading.value) {
        console.log('⏳ [AppHeader] Déjà en cours de chargement')
        return
      }
      
      favoriteLoading.value = true
      const previousState = isFavorited.value
      
      // Optimistic update
      isFavorited.value = !isFavorited.value
      console.log('🔄 [AppHeader] Mise à jour optimiste:', {
        previousState,
        newState: isFavorited.value
      })
      
      try {
        console.log('📡 [AppHeader] Envoi requête API toggle favori...')
        const data = await apiService.toggleFavorite(props.favoriteType, props.favoriteItemId)
        console.log('📡 [AppHeader] Réponse API reçue:', data)
        
        if (data.success) {
          isFavorited.value = data.is_favorited
          
          // Emit events for parent components
          emit('favorite-updated', {
            isFavorited: isFavorited.value,
            favoritesCount: data.data?.total_favorites || 0
          })
          
          console.log('🌟 [AppHeader] Toggle favori réussi:', {
            type: props.favoriteType,
            id: props.favoriteItemId,
            favorited: isFavorited.value,
            favoritesCount: data.data?.total_favorites || 0
          })
        } else {
          throw new Error(data.message || 'Erreur lors de la mise à jour des favoris')
        }
      } catch (error) {
        console.error('❌ [AppHeader] Erreur toggle favori:', error)
        console.error('❌ [AppHeader] Détails erreur:', {
          message: error.message,
          status: error.status,
          response: error.response
        })
        
        // Revert optimistic update
        isFavorited.value = previousState
        console.log('🔄 [AppHeader] Rollback vers état précédent:', previousState)
        
        // Show error message (you could emit an error event here)
        if (error.message.includes('401') || error.status === 401) {
          console.log('🔒 [AppHeader] Erreur 401 - redirection vers auth')
          emit('auth-required')
        }
      } finally {
        favoriteLoading.value = false
        console.log('🌟 [AppHeader] === FIN TOGGLE FAVORI ===')
      }
    }

    const handleBack = () => {
      if (props.backPath) {
        router.push(props.backPath)
      } else {
        router.go(-1)
      }
      emit('back')
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
    
    // Watch for auth changes
    watch(() => authStore.isAuthenticated, (isAuth, oldAuth) => {
      console.log('👀 [AppHeader] Watch authStore.isAuthenticated changé:', {
        oldValue: oldAuth,
        newValue: isAuth,
        user: authStore.user,
        token: authStore.token ? '***existe***' : null
      })
      
      if (isAuth) {
        console.log('✅ [AppHeader] Utilisateur connecté - chargement statut favori')
        loadFavoriteStatus()
      } else {
        console.log('❌ [AppHeader] Utilisateur déconnecté - favori = false')
        isFavorited.value = false
      }
    })
    
    // Watch for prop changes
    watch(() => props.initialFavorited, (newVal, oldVal) => {
      console.log('👀 [AppHeader] Watch initialFavorited changé:', { oldVal, newVal })
      isFavorited.value = newVal
    })
    
    watch(() => [props.favoriteType, props.favoriteItemId], ([newType, newId], [oldType, oldId]) => {
      console.log('👀 [AppHeader] Watch favoriteType/ItemId changé:', {
        oldType, newType,
        oldId, newId,
        isAuthenticated: authStore.isAuthenticated
      })
      
      if (authStore.isAuthenticated && props.favoriteType && props.favoriteItemId) {
        console.log('🔄 [AppHeader] Rechargement statut favori suite à changement props')
        loadFavoriteStatus()
      }
    })
    
    onMounted(() => {
      console.log('🚀 [AppHeader] Composant monté - état initial:', {
        isAuthenticated: authStore.isAuthenticated,
        favoriteType: props.favoriteType,
        favoriteItemId: props.favoriteItemId,
        initialFavorited: props.initialFavorited
      })
      
      if (authStore.isAuthenticated && props.favoriteType && props.favoriteItemId) {
        console.log('🔄 [AppHeader] Chargement initial du statut favori')
        loadFavoriteStatus()
      }
    })

    return {
      showBackButton,
      displayTitle,
      isFavorited,
      favoriteLoading,
      canInteractWithFavorites,
      handleBack,
      handleFavoriteToggle,
      handleShare,
      handleLogoError,
      logoSrc,
      isDevelopment
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

/* Loading state for favorite button */
.md3-icon-button.loading {
  cursor: wait;
  opacity: 0.7;
}

.md3-icon-button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.loading-spinner-header {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid #FFFFFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.md3-icon-button i {
  font-size: 18px;
}

/* Animations */
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style> 