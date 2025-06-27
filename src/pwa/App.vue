<template>
  <div id="app-container">
    <!-- En-tête de l'application simplifié -->
    <AppHeader />
    
    <!-- Main Content -->
    <main 
      class="main-content" 
      :class="{ 'with-bottom-nav': showBottomNav, 'with-header': true }"
    >
      <router-view />
    </main>
    
    <!-- Bottom Navigation -->
    <BottomNavigation v-if="showBottomNav" />
    
    <!-- PWA Install Prompt -->
    <InstallPrompt />
  </div>
</template>

<script>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@components/common/AppHeader.vue'
import BottomNavigation from '@components/navigation/BottomNavigation.vue'
import InstallPrompt from '@components/common/InstallPrompt.vue'

export default {
  name: 'App',
  components: {
    AppHeader,
    BottomNavigation,
    InstallPrompt
  },
  setup() {
    const route = useRoute()
    
    // Show bottom nav only on main pages
    const showBottomNav = computed(() => {
      const mainRoutes = ['/', '/recipes', '/tips', '/events', '/pages', '/dinor-tv']
      return mainRoutes.some(routePath => route.path === routePath || (routePath !== '/' && route.path.startsWith(routePath)))
    })
    
    return {
      showBottomNav
    }
  }
}
</script>

<style>
/* Import des polices Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&family=Roboto:wght@300;400;500;600;700&display=swap');

/* Global app styles */
#app-container {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  background-color: #FFFFFF; /* Fond blanc */
  min-height: 100vh;
  color: #2D3748;
}

.main-content {
  min-height: 100vh;
  padding-bottom: 0;
  background-color: #FFFFFF; /* Fond blanc pour la zone principale */
}

.main-content.with-bottom-nav {
  padding-bottom: 80px;
}

.main-content.with-header {
  padding-top: 80px; /* Espace réduit pour l'en-tête simplifié */
}

.main-content.with-header.with-bottom-nav {
  padding-top: 0px;
  padding-bottom: 10px;
}

@supports (padding: max(0px)) {
  .main-content.with-bottom-nav {
    padding-bottom: calc(80px + env(safe-area-inset-bottom, 0));
  }
  
  .main-content.with-header {
    padding-top: calc(80px + env(safe-area-inset-top, 0));
  }
}

/* Zone de contenu principal - style clair */
.content-area {
  background: #FFFFFF;
  min-height: calc(100vh - 200px);
  padding: 20px 16px;
}

/* Typographie globale */
h1, h2, h3, h4, h5, h6 {
  font-family: 'Open Sans', sans-serif; /* Open Sans pour les titres */
  font-weight: 600;
  color: #2D3748;
  margin: 0 0 16px 0;
  line-height: 1.3;
}

p, span, div {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  color: #4A5568;
  line-height: 1.5;
}

/* Desktop - navigation on top */
@media (min-width: 768px) {
  .main-content.with-bottom-nav {
    padding-top: 80px;
    padding-bottom: 0;
  }
  
  .main-content.with-header {
    padding-top: 60px; /* Moins d'espace sur desktop */
  }
}

/* Scrollbar personnalisée */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #F7FAFC;
}

::-webkit-scrollbar-thumb {
  background: #E53E3E;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #C53030;
}
</style>