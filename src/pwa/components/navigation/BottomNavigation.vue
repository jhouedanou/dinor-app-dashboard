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
import { computed } from 'vue'
import { useRoute } from 'vue-router'

export default {
  name: 'BottomNavigation',
  setup() {
    const route = useRoute()
    
    const navItems = [
      { 
        name: 'home', 
        path: '/', 
        icon: 'home',
        label: 'Accueil' 
      },
      { 
        name: 'recipes', 
        path: '/recipes', 
        icon: 'restaurant',
        label: 'Recettes' 
      },
      { 
        name: 'tips', 
        path: '/tips', 
        icon: 'lightbulb',
        label: 'Astuces' 
      },
      { 
        name: 'events', 
        path: '/events', 
        icon: 'event',
        label: 'Événements' 
      },
      { 
        name: 'dinor-tv', 
        path: '/dinor-tv', 
        icon: 'play_circle',
        label: 'Dinor TV' 
      }
    ]
    
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
  background: var(--md-sys-color-surface-container, #f3f4f6);
  border-top: 1px solid var(--md-sys-color-outline-variant, #e5e7eb);
  backdrop-filter: blur(10px);
  z-index: 1000;
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
  color: var(--md-sys-color-on-surface-variant, #6b7280);
  transition: all 0.2s ease;
  padding: 8px 4px;
  border-radius: 16px;
  min-width: 0;
  flex: 1;
  max-width: 80px;
}

.nav-item:hover {
  background: var(--md-sys-color-secondary-container, #f3f4f6);
}

.nav-item.active {
  color: var(--md-sys-color-on-secondary-container, #1c1b1f);
  background: var(--md-sys-color-secondary-container, #e3f2fd);
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

/* Desktop styles */
@media (min-width: 768px) {
  .bottom-navigation {
    position: fixed;
    top: 0;
    bottom: auto;
    border-top: none;
    border-bottom: 1px solid var(--md-sys-color-outline-variant, #e5e7eb);
  }
  
  .nav-items {
    justify-content: flex-start;
    gap: 24px;
    padding: 0 24px;
  }
  
  .nav-item {
    flex-direction: row;
    padding: 12px 16px;
    max-width: none;
    flex: none;
  }
  
  .nav-icon {
    margin-bottom: 0;
    margin-right: 8px;
  }
  
  .nav-label {
    font-size: 14px;
    white-space: nowrap;
  }
}

/* Safe area support */
@supports (padding: max(0px)) {
  .bottom-navigation {
    padding-bottom: env(safe-area-inset-bottom, 0);
  }
}
</style>