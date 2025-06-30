<template>
  <!-- Loading Screen -->
  <LoadingScreen 
    v-if="showLoading"
    :visible="showLoading"
    :duration="2500"
    @complete="onLoadingComplete"
  />
  
  <!-- App principale (masquée pendant le loading) -->
  <div v-if="!showLoading" id="app">
    <div class="app-container">
      <!-- En-tête de l'application simplifié -->
      <AppHeader 
        :title="currentPageTitle"
        :show-like="showLikeButton"
        :show-share="showShareButton"
        :is-liked="isLiked"
        :back-path="backPath"
        @like="handleLike"
        @share="handleShare"
        @back="handleBack"
      />
      
      <!-- Main Content -->
      <main 
        class="main-content" 
        :class="{ 'with-bottom-nav': showBottomNav, 'with-header': true }"
      >
        <router-view 
          @update-header="updateHeader" 
          @like="handleLike"
          @share="handleShare"
          ref="currentView"
        />
      </main>
      
      <!-- Bottom Navigation -->
      <BottomNavigation v-if="showBottomNav" />
      
      <!-- PWA Install Prompt -->
      <InstallPrompt />
      
      <!-- Share Modal -->
      <ShareModal 
        v-model="showShareModal"
        :share-data="currentShareData"
      />
    </div>
  </div>
</template>

<script>
import { computed, ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSocialShare } from '@/composables/useSocialShare'
import AppHeader from '@/components/common/AppHeader.vue'
import BottomNavigation from '@/components/navigation/BottomNavigation.vue'
import InstallPrompt from '@/components/common/InstallPrompt.vue'
import LoadingScreen from '@/components/common/LoadingScreen.vue'
import ShareModal from '@/components/common/ShareModal.vue'

export default {
  name: 'App',
  components: {
    AppHeader,
    BottomNavigation,
    InstallPrompt,
    LoadingScreen,
    ShareModal
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const { share, showShareModal } = useSocialShare()
    
    // Données de partage courantes
    const currentShareData = ref({})
    
    // État pour le header dynamique
    const currentPageTitle = ref('Dinor')
    const showLikeButton = ref(false)
    const showShareButton = ref(false)
    const isLiked = ref(false)
    const backPath = ref(null)
    
    // Show bottom nav only on main pages
    const showBottomNav = computed(() => {
      const mainRoutes = ['/', '/recipes', '/tips', '/events', '/pages', '/dinor-tv']
      return mainRoutes.some(routePath => route.path === routePath || (routePath !== '/' && route.path.startsWith(routePath)))
    })
    
    // Titre dynamique selon la route
    const updateTitle = () => {
      if (route.path === '/') {
        currentPageTitle.value = 'Dinor'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path === '/recipes') {
        currentPageTitle.value = 'Recettes'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path === '/tips') {
        currentPageTitle.value = 'Astuces'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path === '/events') {
        currentPageTitle.value = 'Événements'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path === '/dinor-tv') {
        currentPageTitle.value = 'Dinor TV'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path === '/pages') {
        currentPageTitle.value = 'Pages'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = null
      } else if (route.path.startsWith('/recipe/')) {
        currentPageTitle.value = 'Recette'
        showLikeButton.value = true
        showShareButton.value = true
        backPath.value = '/recipes'
      } else if (route.path.startsWith('/tip/')) {
        currentPageTitle.value = 'Astuce'
        showLikeButton.value = true
        showShareButton.value = true
        backPath.value = '/tips'
      } else if (route.path.startsWith('/event/')) {
        currentPageTitle.value = 'Événement'
        showLikeButton.value = true
        showShareButton.value = true
        backPath.value = '/events'
      } else {
        currentPageTitle.value = 'Dinor'
        showLikeButton.value = false
        showShareButton.value = false
        backPath.value = '/'
      }
    }
    
    // Mettre à jour le titre quand la route change
    watch(() => route.path, updateTitle, { immediate: true })
    
    // Function pour mettre à jour le header depuis les composants enfants
    const updateHeader = (headerData) => {
      if (headerData.title) currentPageTitle.value = headerData.title
      if (headerData.showLike !== undefined) showLikeButton.value = headerData.showLike
      if (headerData.showShare !== undefined) showShareButton.value = headerData.showShare
      if (headerData.isLiked !== undefined) isLiked.value = headerData.isLiked
      if (headerData.backPath !== undefined) backPath.value = headerData.backPath
    }
    
    // Handlers pour les actions - déléguées aux vues enfants
    const currentView = ref(null)
    
    const handleLike = () => {
      if (currentView.value && currentView.value.toggleLike) {
        currentView.value.toggleLike()
      }
    }
    
    const handleShare = () => {
      console.log('🎯 [App] handleShare appelé!')
      
      // Créer les données de partage basées sur la route actuelle
      const shareData = {
        title: currentPageTitle.value || 'Dinor',
        text: `Découvrez ${currentPageTitle.value} sur Dinor`,
        url: window.location.href
      }
      
      // Si nous sommes sur une page de détail, ajouter des informations spécifiques
      if (route.path.startsWith('/recipe/')) {
        shareData.text = `Découvrez cette délicieuse recette sur Dinor`
        shareData.type = 'recipe'
        shareData.id = route.params.id
      } else if (route.path.startsWith('/tip/')) {
        shareData.text = `Découvrez cette astuce pratique sur Dinor`
        shareData.type = 'tip'
        shareData.id = route.params.id
      } else if (route.path.startsWith('/event/')) {
        shareData.text = `Ne manquez pas cet événement sur Dinor`
        shareData.type = 'event'
        shareData.id = route.params.id
      }
      
      // Stocker les données de partage pour le modal
      currentShareData.value = shareData
      
      console.log('🚀 [App] Déclenchement du partage avec:', shareData)
      share(shareData)
    }
    
    const handleBack = () => {
      if (backPath.value) {
        router.push(backPath.value)
      } else {
        router.go(-1)
      }
    }
    
    // Initialiser le titre
    updateTitle()
    
    const showLoading = ref(true)
    
    const onLoadingComplete = () => {
      showLoading.value = false
      console.log('🎉 [App] Chargement terminé, app prête !')
    }
    
    // Pour tester, on peut forcer le loading à s'arrêter après un délai
    onMounted(() => {
      // Le loading se terminera automatiquement via le composant LoadingScreen
      console.log('🚀 [App] Application démarrée avec loading screen')
    })
    
    return {
      showBottomNav,
      currentPageTitle,
      showLikeButton,
      showShareButton,
      isLiked,
      backPath,
      currentView,
      updateHeader,
      handleLike,
      handleShare,
      handleBack,
      showLoading,
      onLoadingComplete,
      showShareModal,
      currentShareData
    }
  }
}
</script>

<style>
/* Import des polices Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&family=Roboto:wght@300;400;500;600;700&display=swap');

/* Global app styles */
#app {
  font-family: 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100vh;
  overflow: hidden;
}

.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  position: relative;
}

/* Reset global */
*, *::before, *::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  padding: 0;
  background: #F5F5F5;
  font-family: 'Roboto', sans-serif;
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