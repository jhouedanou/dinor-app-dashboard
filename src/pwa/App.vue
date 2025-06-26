<template>
  <div id="app-container">
    <!-- Main Content -->
    <main 
      class="main-content md3-main-content" 
      :class="{ 'with-bottom-nav': showBottomNav }"
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
import BottomNavigation from '@components/navigation/BottomNavigation.vue'
import InstallPrompt from '@components/common/InstallPrompt.vue'

export default {
  name: 'App',
  components: {
    BottomNavigation,
    InstallPrompt
  },
  setup() {
    const route = useRoute()
    
    // Show bottom nav only on main pages
    const showBottomNav = computed(() => {
      const mainRoutes = ['/recipes', '/tips', '/events', '/pages', '/dinor-tv']
      return mainRoutes.some(routePath => route.path.startsWith(routePath))
    })
    
    return {
      showBottomNav
    }
  }
}
</script>

<style>
/* Global app styles */
.main-content {
  min-height: 100vh;
  padding-bottom: 0;
}

.main-content.with-bottom-nav {
  padding-bottom: 80px;
}

@supports (padding: max(0px)) {
  .main-content.with-bottom-nav {
    padding-bottom: calc(80px + env(safe-area-inset-bottom, 0));
  }
}

/* Desktop - navigation on top */
@media (min-width: 768px) {
  .main-content.with-bottom-nav {
    padding-top: 80px;
    padding-bottom: 0;
  }
}
</style>