<template>
  <nav class="bottom-navigation">
    <div class="nav-items">
      <a 
        v-for="item in menuItems" 
        :key="item.name"
        @click.prevent="handleItemClick(item)"
        @touchstart.passive="handleTouchStart"
        @touchend.passive="handleTouchEnd"
        class="nav-item"
        :class="{ 'active': isActive(item) }"
        :data-item-name="item.name"
        href="#"
        role="button"
        :aria-label="item.label"
      >
        <div class="nav-icon">
          <DinorIcon :name="item.icon" :size="24" :filled="isActive(item)" />
        </div>
        <span class="nav-label">{{ item.label }}</span>
      </a>
    </div>
  </nav>

  <!-- Auth Modal -->
  <AuthModal 
    v-model="showAuthModal" 
    :initial-message="authModalMessage"
    @authenticated="onAuthSuccess"
  />
</template>

<script>
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApiStore } from '@/stores/api'
import { useAuthHandler } from '@/composables/useAuthHandler'
import { useAnalytics } from '@/composables/useAnalytics'
import AuthModal from '@/components/common/AuthModal.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'BottomNavigation',
  components: {
    AuthModal,
    DinorIcon
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const apiStore = useApiStore()
    const { requireAuth, showAuthModal, authModalMessage, closeAuthModal, handleAuthSuccess } = useAuthHandler()
    const { trackNavigation, trackClick } = useAnalytics()
    
    // Menu statique avec icônes Lucide
    const menuItems = ref([
      { name: 'all', path: '/', icon: 'home', label: 'Accueil', action_type: 'route' },
      { name: 'recipes', path: '/recipes', icon: 'chef-hat', label: 'Recettes', action_type: 'route' },
      { name: 'tips', path: '/tips', icon: 'lightbulb', label: 'Astuces', action_type: 'route' },
      { name: 'events', path: '/events', icon: 'calendar', label: 'Événements', action_type: 'route' },
      { name: 'dinor-tv', path: '/dinor-tv', icon: 'play-circle', label: 'DinorTV', action_type: 'route' },
      { name: 'profile', path: '/profile', icon: 'user', label: 'Profil', action_type: 'route' }
    ])
    const loading = ref(false)

    const handleItemClick = (item) => {
      // Tracking analytics
      trackClick(`bottom_nav_${item.name}`, 'navigation', {
        label: item.label,
        action_type: item.action_type,
        path: item.path
      })

      // Vérifier l'authentification pour le profil
      if (item.name === 'profile') {
        if (!requireAuth('accéder à votre profil')) {
          return // Le modal d'auth s'ouvrira automatiquement
        }
      }
      
      switch (item.action_type) {
        case 'route':
          // Navigation interne standard
          if (item.path) {
            trackNavigation(item.path, route.path, 'bottom_navigation')
            router.push(item.path)
          }
          break
          
        case 'web_embed':
          // Charger la dernière page depuis le système Pages dans WebEmbed
          trackNavigation('/web-embed', route.path, 'bottom_navigation')
          router.push('/web-embed')
          break
          
        case 'external_link':
          // Ouvrir dans un nouvel onglet
          if (item.web_url) {
            trackClick(`external_link_${item.name}`, 'external_navigation', {
              url: item.web_url,
              label: item.label
            })
            window.open(item.web_url, '_blank', 'noopener,noreferrer')
          } else {
            // Aucune web_url définie
          }
          break
          
        default:
          // Type d'action non géré
          // Fallback vers navigation route si définie
          if (item.path) {
            trackNavigation(item.path, route.path, 'bottom_navigation')
            router.push(item.path)
          }
      }
    }
    
    const isActive = (item) => {
      // Pour les routes normales
      if (item.action_type === 'route' && item.path) {
        return route.path === item.path || (item.path !== '/' && route.path.startsWith(item.path))
      }
      
      // Pour web_embed, vérifier si nous sommes sur /web-embed
      if (item.action_type === 'web_embed') {
        return route.path === '/web-embed'
      }
      
      return false
    }
    

    // Gestion des événements tactiles
    const handleTouchStart = (event) => {
      // Trouver l'élément nav-item parent
      const navItem = event.target.closest('.nav-item')
      if (navItem) {
        // Ajouter une classe d'état tactile sans affecter la visibilité
        navItem.classList.add('touching')
        navItem.style.transform = 'scale(0.95)'
        
        // S'assurer que les enfants restent visibles
        const icon = navItem.querySelector('.nav-icon')
        const label = navItem.querySelector('.nav-label')
        if (icon) {
          icon.style.opacity = '1'
          icon.style.visibility = 'visible'
        }
        if (label) {
          label.style.opacity = '1'
          label.style.visibility = 'visible'
        }
      }
    }

    const handleTouchEnd = (event) => {
      // Trouver l'élément nav-item parent
      const navItem = event.target.closest('.nav-item')
      if (navItem) {
        // Remettre l'élément à sa taille normale
        setTimeout(() => {
          navItem.classList.remove('touching')
          navItem.style.transform = 'scale(1)'
        }, 100)
      }
    }

    // Gestion de l'authentification réussie
    const onAuthSuccess = (user) => {
      // Authentification réussie, redirection vers le profil
      handleAuthSuccess(user)
      router.push('/profile')
    }

    // Menu statique - pas besoin de charger depuis l'API

    return {
      menuItems,
      loading,
      handleItemClick,
      handleTouchStart,
      handleTouchEnd,
      isActive,
      showAuthModal,
      authModalMessage,
      closeAuthModal,
      onAuthSuccess
    }
  }
}
</script>

<style scoped>
.bottom-navigation {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #F4D03F; /* Fond doré comme spécifié */
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  z-index: 1000;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.1);
  
  /* Empêcher les problèmes de scroll et swipe */
  overscroll-behavior: contain;
  -webkit-overflow-scrolling: touch;
}

.nav-items {
  display: flex;
  justify-content: space-around;
  align-items: center;
  height: 80px;
  padding: 0 16px;
  max-width: 100%;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: rgba(0, 0, 0, 0.7); /* Texte sombre sur fond doré */
  transition: all 0.2s ease;
  padding: 8px 4px;
  border-radius: 16px;
  min-width: 0;
  flex: 1;
  max-width: 80px;
  font-family: 'Roboto', sans-serif; /* Police Roboto pour les textes */
  
  /* Améliorer les interactions tactiles */
  touch-action: manipulation;
  user-select: none;
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  
  /* Empêcher les problèmes de swipe */
  overflow: visible;
  position: relative;
}

.nav-item:hover {
  background: rgba(0, 0, 0, 0.1);
  color: rgba(0, 0, 0, 0.9);
}

.nav-item.active {
  color: #FF6B35 !important; /* Orange accent pour l'item actif */
  background: rgba(255, 107, 53, 0.1);
  position: relative;
  
  /* S'assurer que l'état actif est visible pendant les transitions */
  z-index: 2;
  transform: translateZ(0); /* Force hardware acceleration */
}

/* Soulignement orange pour l'item actif */
.nav-item.active::after {
  content: '';
  position: absolute;
  bottom: 4px;
  left: 50%;
  transform: translateX(-50%);
  width: 24px;
  height: 2px;
  background: #FF6B35;
  border-radius: 1px;
}

.nav-icon {
  margin-bottom: 4px;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* S'assurer que l'icône hérite bien de la couleur */
.nav-item.active .nav-icon {
  color: #FF6B35 !important;
  opacity: 1 !important;
  visibility: visible !important;
  display: flex !important;
  
  /* Force l'affichage pendant les transitions */
  will-change: transform, opacity;
  backface-visibility: hidden;
  transform: translateZ(0);
}

/* Forcer la visibilité de l'icône à l'intérieur */
.nav-item.active .nav-icon svg,
.nav-item.active .nav-icon *:not(.nav-label) {
  color: #FF6B35 !important;
  fill: #FF6B35 !important;
  stroke: #FF6B35 !important;
  opacity: 1 !important;
  visibility: visible !important;
}

.nav-icon,
.nav-icon * {
  color: inherit !important;
  transition: color 0.2s ease !important;
  opacity: 1 !important;
  visibility: visible !important;
}

/* Style de base pour toutes les icônes */
.nav-icon svg {
  display: block !important;
  opacity: 1 !important;
  visibility: visible !important;
}

/* Force la visibilité pendant les interactions tactiles */
.nav-item.touching .nav-icon,
.nav-item.touching .nav-label,
.nav-item:active .nav-icon,
.nav-item:active .nav-label {
  opacity: 1 !important;
  visibility: visible !important;
  display: block !important;
}

/* Styles spécifiques pour les éléments actifs pendant le touch */
.nav-item.active.touching .nav-icon,
.nav-item.active:active .nav-icon {
  color: #FF6B35 !important;
  opacity: 1 !important;
  visibility: visible !important;
}

.nav-item.active.touching .nav-label,
.nav-item.active:active .nav-label {
  color: #FF6B35 !important;
  opacity: 1 !important;
  visibility: visible !important;
  font-weight: 600 !important;
}

.nav-label {
  font-size: 12px;
  font-weight: 500;
  text-align: center;
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
  color: inherit;
  opacity: 1;
  visibility: visible;
  transition: color 0.2s ease, font-weight 0.2s ease;
  
  /* Empêcher la disparition pendant les transitions */
  will-change: color, font-weight;
  backface-visibility: hidden;
}

.nav-item.active .nav-label {
  font-weight: 600;
  color: #FF6B35 !important;
  opacity: 1 !important;
  visibility: visible !important;
  
  /* Force l'affichage */
  display: block !important;
}

/* Safe area pour iPhone */
@supports (padding: max(0px)) {
  .bottom-navigation {
    padding-bottom: env(safe-area-inset-bottom, 0);
  }
}

/* Adaptation responsive pour desktop et tablette */
@media (min-width: 768px) {
  .bottom-navigation {
    /* Réduire légèrement la hauteur sur desktop */
    border-top: 2px solid rgba(0, 0, 0, 0.1);
  }
  
  .nav-items {
    max-width: 600px; /* Limite la largeur sur grand écran */
    margin: 0 auto; /* Centre la navigation */
    height: 70px; /* Légèrement plus bas sur desktop */
  }
  
  .nav-item {
    max-width: 120px; /* Plus d'espace pour les labels sur grand écran */
    padding: 10px 8px; /* Plus de padding sur desktop */
  }
  
  .nav-label {
    font-size: 13px; /* Label légèrement plus grand sur desktop */
  }
  
  .nav-icon .material-symbols-outlined {
    font-size: 26px; /* Icônes légèrement plus grandes sur desktop */
  }
}

/* Très grands écrans */
@media (min-width: 1200px) {
  .nav-items {
    max-width: 800px; /* Plus d'espace sur très grand écran */
  }
  
  .nav-item {
    max-width: 160px;
  }
}

/* DEBUG: Force visible pour tous les éléments d'icônes */
.nav-icon,
.nav-icon *,
.nav-icon svg,
.nav-icon svg *,
.dinor-icon,
.dinor-icon * {
  opacity: 1 !important;
  visibility: visible !important;
  display: block !important;
}

.nav-icon {
  display: flex !important;
}

/* DEBUG: S'assurer que rien ne cache les icônes */
.nav-item * {
  pointer-events: auto !important;
}


</style>