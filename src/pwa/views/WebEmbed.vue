<template>
  <div class="web-embed">
    <!-- Navigation Header -->
    <nav class="md3-top-app-bar">
      <div class="md3-app-bar-container">
        <button @click="goBack" class="md3-icon-button">
          <i class="material-icons">arrow_back</i>
        </button>
        <div class="md3-app-bar-title">
          <h1 class="md3-title-large dinor-text-primary">{{ pageTitle }}</h1>
        </div>
        <div class="md3-app-bar-actions">
          <button @click="refreshPage" class="md3-icon-button">
            <i class="material-icons">refresh</i>
          </button>
          <button @click="openInNewTab" class="md3-icon-button">
            <i class="material-icons">open_in_new</i>
          </button>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement de la page...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state">
        <div class="error-icon">
          <i class="material-icons">error_outline</i>
        </div>
        <h2 class="md3-title-large">Erreur de chargement</h2>
        <p class="md3-body-large dinor-text-gray">{{ errorMessage }}</p>
        <div class="error-actions">
          <button @click="retryLoad" class="btn-primary">Réessayer</button>
          <button @click="goBack" class="btn-secondary">Retour</button>
        </div>
      </div>

      <!-- Iframe Container -->
      <div v-else class="iframe-container">
        <iframe 
          ref="webFrame"
          :src="embedUrl"
          class="web-iframe"
          title="Page Web Intégrée"
          frameborder="0"
          allowfullscreen
          @load="onIframeLoad"
          @error="onIframeError">
        </iframe>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

export default {
  name: 'WebEmbed',
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const webFrame = ref(null)
    const loading = ref(true)
    const error = ref(false)
    const errorMessage = ref('')
    const pageTitle = ref('Page Web')
    
    const embedUrl = computed(() => {
      const url = route.query.url
      if (!url) return ''
      
      // Validation basique de l'URL
      try {
        new URL(decodeURIComponent(url))
        return decodeURIComponent(url)
      } catch (e) {
        error.value = true
        errorMessage.value = 'URL invalide fournie'
        return ''
      }
    })
    
    const onIframeLoad = () => {
      loading.value = false
      error.value = false
      
      // Tentative de récupération du titre de la page (si même domaine)
      try {
        if (webFrame.value && webFrame.value.contentDocument) {
          const title = webFrame.value.contentDocument.title
          if (title) {
            pageTitle.value = title
          }
        }
      } catch (e) {
        // Erreur CORS attendue pour les domaines externes
        console.log('Impossible de récupérer le titre (CORS):', e.message)
      }
    }
    
    const onIframeError = () => {
      loading.value = false
      error.value = true
      errorMessage.value = 'Impossible de charger la page demandée. Vérifiez que l\'URL est correcte et accessible.'
    }
    
    const refreshPage = () => {
      if (webFrame.value && embedUrl.value) {
        loading.value = true
        error.value = false
        webFrame.value.src = embedUrl.value
      }
    }
    
    const retryLoad = () => {
      refreshPage()
    }
    
    const openInNewTab = () => {
      if (embedUrl.value) {
        window.open(embedUrl.value, '_blank', 'noopener,noreferrer')
      }
    }
    
    const goBack = () => {
      router.go(-1)
    }
    
    onMounted(() => {
      if (!embedUrl.value) {
        error.value = true
        errorMessage.value = 'Aucune URL fournie pour l\'affichage'
        loading.value = false
      }
      
      // Timeout de sécurité pour le chargement
      setTimeout(() => {
        if (loading.value) {
          loading.value = false
          error.value = true
          errorMessage.value = 'Délai de chargement dépassé'
        }
      }, 15000) // 15 secondes
    })
    
    return {
      webFrame,
      loading,
      error,
      errorMessage,
      pageTitle,
      embedUrl,
      onIframeLoad,
      onIframeError,
      refreshPage,
      retryLoad,
      openInNewTab,
      goBack
    }
  }
}
</script>

<style scoped>
.web-embed {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--md-sys-color-surface);
}

.md3-main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.iframe-container {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.web-iframe {
  width: 100%;
  height: 100%;
  border: none;
  background: white;
}

.loading-container,
.error-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  text-align: center;
}

.error-icon i {
  font-size: 4rem;
  color: var(--md-sys-color-error);
  margin-bottom: 1rem;
}

.error-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1.5rem;
  border-radius: 20px;
  border: none;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary {
  background: var(--md-sys-color-primary);
  color: var(--md-sys-color-on-primary);
}

.btn-primary:hover {
  background: var(--md-sys-color-primary-container);
}

.btn-secondary {
  background: var(--md-sys-color-secondary-container);
  color: var(--md-sys-color-on-secondary-container);
}

.btn-secondary:hover {
  background: var(--md-sys-color-secondary);
  color: var(--md-sys-color-on-secondary);
}

/* Responsive design */
@media (max-width: 768px) {
  .error-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .btn-primary, .btn-secondary {
    width: 100%;
  }
}
</style> 