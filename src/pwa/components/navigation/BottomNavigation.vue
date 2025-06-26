<template>
  <nav class="bottom-navigation">
    <div class="nav-items">
      <router-link 
        v-for="item in navItems" 
        :key="item.name"
        :to="item.path"
        class="nav-item"
        :class="{ 'active': isActive(item.path) }"
        @click="item.action && item.action()"
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
import { useApi } from '@/composables/useApi'

export default {
  name: 'BottomNavigation',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const { request } = useApi()
    
    const webPageUrl = ref('')
    
    const loadWebPageSettings = async () => {
      try {
        // Chercher une page avec un slug spécial 'web-link' ou similaire
        const data = await request('/pages?slug=web-embed')
        if (data.success && data.data.length > 0) {
          const webPage = data.data[0]
          webPageUrl.value = webPage.embed_url || webPage.content || ''
        }
      } catch (error) {
        console.warn('Impossible de charger les paramètres de la page Web:', error)
        // URL par défaut si aucune configuration trouvée
        webPageUrl.value = 'https://www.google.com'
      }
    }
    
    const openWebEmbed = () => {
      if (webPageUrl.value) {
        router.push(`/web-embed?url=${encodeURIComponent(webPageUrl.value)}`)
      }
    }
    
    const navItems = ref([])
    
    const loadNavItems = async () => {
      try {
        const data = await request('/pwa-menu-items')
        if (data.success) {
          navItems.value = data.data.map(item => {
            const navItem = {
              name: item.name,
              path: item.action_type === 'route' ? item.path : '#',
              icon: item.icon,
              label: item.label,
              action_type: item.action_type,
              web_url: item.web_url
            }
            
            // Ajouter l'action appropriée selon le type
            if (item.action_type === 'web_embed') {
              navItem.action = () => {
                if (item.web_url) {
                  router.push(`/web-embed?url=${encodeURIComponent(item.web_url)}`)
                }
              }
            } else if (item.action_type === 'external_link') {
              navItem.action = () => {
                if (item.web_url) {
                  window.open(item.web_url, '_blank')
                }
              }
            }
            
            return navItem
          })
        }
      } catch (error) {
        console.warn('Impossible de charger les éléments de menu:', error)
        // Menu par défaut en cas d'erreur
        navItems.value = [
          { name: 'home', path: '/', icon: 'home', label: 'Accueil' },
          { name: 'recipes', path: '/recipes', icon: 'restaurant', label: 'Recettes' },
          { name: 'tips', path: '/tips', icon: 'lightbulb', label: 'Astuces' },
          { name: 'events', path: '/events', icon: 'event', label: 'Événements' },
          { name: 'dinor-tv', path: '/dinor-tv', icon: 'play_circle', label: 'Dinor TV' },
          { name: 'web', path: '#', icon: 'public', label: 'Web', action: openWebEmbed }
        ]
      }
    }
    
    const isActive = (path) => {
      if (path === '#') return false // L'item Web n'est jamais "actif"
      if (path === '/') {
        return route.path === '/'
      }
      return route.path.startsWith(path)
    }
    
    onMounted(() => {
      loadWebPageSettings()
      loadNavItems()
    })
    
    return {
      navItems,
      isActive,
      loadNavItems
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