<template>
  <nav class="bottom-navigation">
    <div class="nav-items">
      <router-link 
        v-for="item in navItems" 
        :key="item.name"
        :to="item.path"
        class="nav-item"
        :class="{ 'active': isActive(item.path) }"
      >
        <div class="nav-icon">
          <span class="material-symbols-outlined">{{ item.icon }}</span>
        </div>
        <span class="nav-label">{{ item.label }}</span>
      </router-link>
    </div>
  </nav>
</template>

<script>
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

export default {
  name: 'BottomNavigation',
  setup() {
    const route = useRoute()
    const router = useRouter()
    
    // Navigation avec les onglets demandés par l'utilisateur
    const navItems = ref([
      { name: 'all', path: '/', icon: 'apps', label: 'All' },
      { name: 'recipes', path: '/recipes', icon: 'restaurant', label: 'Recettes' },
      { name: 'tips', path: '/tips', icon: 'lightbulb', label: 'Astuces' },
      { name: 'events', path: '/events', icon: 'event', label: 'Événements' },
      { name: 'web', path: '/web-embed', icon: 'language', label: 'Web' }
    ])
    
    const isActive = (path) => {
      if (path === '/') {
        return route.path === '/'
      }
      return route.path.startsWith(path)
    }
    
    return {
      navItems,
      isActive
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
  font-variation-settings: 
    'FILL' 0,
    'wght' 400,
    'GRAD' 0,
    'opsz' 24;
}

.nav-item.active .nav-icon .material-symbols-outlined {
  font-variation-settings: 
    'FILL' 1,
    'wght' 600,
    'GRAD' 0,
    'opsz' 24;
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
</style>