<template>
  <nav class="bottom-navigation">
    <div class="nav-items">
      <a 
        v-for="item in menuItems" 
        :key="item.name"
        @click.prevent="handleItemClick(item)"
        class="nav-item"
        :class="{ 'active': isActive(item) }"
        href="#"
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
            router.push(item.path)
          }
          break
          
        case 'web_embed':
          // Charger la dernière page depuis le système Pages dans WebEmbed
          router.push('/web-embed')
          break
          
        case 'external_link':
          // Ouvrir dans un nouvel onglet
          if (item.web_url) {
            window.open(item.web_url, '_blank', 'noopener,noreferrer')
          } else {
            // Aucune web_url définie
          }
          break
          
        default:
          // Type d'action non géré
          // Fallback vers navigation route si définie
          if (item.path) {
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
}

.nav-item:hover {
  background: rgba(0, 0, 0, 0.1);
  color: rgba(0, 0, 0, 0.9);
}

.nav-item.active {
  color: #FF6B35; /* Orange accent pour l'item actif */
  background: rgba(255, 107, 53, 0.1);
  position: relative;
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
}

.nav-icon .material-symbols-outlined {
  font-size: 24px;
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.nav-item.active .nav-icon .material-symbols-outlined {
  font-variation-settings: 'FILL' 1, 'wght' 600, 'GRAD' 0, 'opsz' 24;
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
}

.nav-item.active .nav-label {
  font-weight: 600;
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

.nav-icon .material-symbols-outlined {
  font-size: 24px;
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.nav-icon .emoji-fallback {
  font-size: 20px;
}

.nav-item.active .nav-icon .material-symbols-outlined {
  font-variation-settings: 'FILL' 1, 'wght' 600, 'GRAD' 0, 'opsz' 24;
}

.nav-item.active .nav-icon .emoji-fallback {
  font-size: 22px;
  filter: brightness(1.2);
}

/* Responsive pour petit écran */
@media (max-width: 480px) {
  .nav-icon .material-symbols-outlined {
    font-size: 20px;
  }

  .nav-icon .emoji-fallback {
    font-size: 18px;
  }
}
</style>