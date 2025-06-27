<template>
  <div class="web-embed">
    <!-- Main Content -->
    <main class="md3-main-content">
      <!-- Error State -->
      <div v-if="error" class="error-state">
        <div class="error-icon">
          <i class="material-icons">error_outline</i>
        </div>
        <h2 class="md3-title-large">Erreur de chargement</h2>
        <p class="md3-body-large dinor-text-gray">{{ errorMessage }}</p>
        <div class="error-actions">
          <button @click="retryLoad" class="btn-primary">Réessayer</button>
          <button @click="openInNewTab" class="btn-secondary" v-if="embedUrl || (currentPage && (currentPage.embed_url || currentPage.url))">Ouvrir dans un nouvel onglet</button>
          <button @click="goBack" class="btn-secondary">Retour</button>
        </div>
      </div>

      <!-- Iframe Container -->
      <div v-else class="iframe-container">
        <!-- Loading Overlay -->
        <div v-if="loading" class="loading-overlay">
          <div class="loading-content">
            <div class="md3-circular-progress"></div>
            <p class="md3-body-large">Chargement de la page...</p>
          </div>
        </div>
        
        <!-- Iframe -->
        <iframe 
          v-if="embedUrl"
          ref="webFrame"
          :src="embedUrl"
          class="web-iframe"
          title="Page Web Intégrée"
          frameborder="0"
          allowfullscreen
          @load="onIframeLoad"
          @error="onIframeError"
          @loadstart="onIframeLoadStart"
          @loadend="onIframeLoadEnd">
        </iframe>
        
        <!-- Placeholder si pas d'URL -->
        <div v-else class="placeholder-container">
          <div class="md3-circular-progress"></div>
          <p class="md3-body-large">Préparation de la page...</p>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted, computed, onUnmounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApi } from '@/composables/useApi'

export default {
  name: 'WebEmbed',
  setup() {
    const router = useRouter()
    const route = useRoute()
    const { request } = useApi()
    
    const webFrame = ref(null)
    const loading = ref(true)
    const error = ref(false)
    const errorMessage = ref('')
    const pageTitle = ref('Page Web')
    const currentPage = ref(null)
    const embedUrl = ref('')
    let timeoutId = null
    
    const loadLatestPage = async () => {
      try {
        console.log('🔄 [WebEmbed] Début du chargement de la dernière page...')
        loading.value = true
        error.value = false
        
        console.log('📡 [WebEmbed] Appel API vers /pages/latest')
        const data = await request('/pages/latest')
        console.log('📋 [WebEmbed] Réponse API reçue:', data)
        
        if (data.success && data.data) {
          currentPage.value = data.data
          pageTitle.value = data.data.title || 'Page Web'
          console.log('📄 [WebEmbed] Page trouvée:', {
            title: data.data.title,
            url: data.data.url,
            embed_url: data.data.embed_url
          })
          
          // Utiliser embed_url s'il existe, sinon l'URL normale
          let targetUrl = data.data.embed_url || data.data.url
          console.log('🔗 [WebEmbed] URL à charger:', targetUrl)
          
          if (targetUrl) {
            // Vérifier si l'URL peut être chargée en iframe
            if (!canLoadInIframe(targetUrl)) {
              console.warn('⚠️ [WebEmbed] URL détectée comme non-compatible iframe:', targetUrl)
              error.value = true
              loading.value = false
              errorMessage.value = `Cette page ne peut pas être affichée en iframe. Cliquez sur "Ouvrir dans un nouvel onglet" pour l'afficher.`
              return
            }
            
            embedUrl.value = targetUrl
            console.log('🚀 [WebEmbed] URL finale définie:', embedUrl.value)
            
            // Attendre le prochain tick pour que l'URL soit définie
            await nextTick()
            
            // Maintenant arrêter le loading pour que l'iframe se rende
            loading.value = false
            console.log('✅ [WebEmbed] Loading arrêté - iframe peut maintenant se rendre')
            
            // Démarrer le timeout de sécurité
            startLoadingTimeout()
          } else {
            console.error('❌ [WebEmbed] Aucune URL disponible dans les données')
            throw new Error('Aucune URL disponible pour cette page')
          }
        } else {
          console.error('❌ [WebEmbed] Réponse API invalide:', data)
          throw new Error(data.message || 'Aucune page disponible')
        }
      } catch (err) {
        console.error('💥 [WebEmbed] Erreur lors du chargement:', err)
        error.value = true
        errorMessage.value = err.message || 'Erreur lors du chargement de la page'
        loading.value = false
      }
    }
    
    // Fallback pour URL en query parameter (pour compatibilité)
    const getUrlFromQuery = () => {
      console.log('🔍 [WebEmbed] Vérification des query parameters...')
      const url = route.query.url
      console.log('📋 [WebEmbed] URL du query parameter:', url)
      
      if (!url) {
        console.log('❌ [WebEmbed] Aucune URL dans les query parameters')
        return ''
      }
      
      try {
        let decodedUrl = decodeURIComponent(url)
        console.log('🔓 [WebEmbed] URL décodée:', decodedUrl)
        
        new URL(decodedUrl) // Valider l'URL
        console.log('✅ [WebEmbed] URL valide, prête à être chargée')
        
        console.log('🚀 [WebEmbed] URL finale du query parameter:', decodedUrl)
        return decodedUrl
      } catch (e) {
        console.error('💥 [WebEmbed] Erreur de validation URL:', e)
        error.value = true
        errorMessage.value = 'URL invalide fournie'
        return ''
      }
    }
    
    const onIframeLoad = () => {
      console.log('✅ [WebEmbed] Iframe chargée avec succès pour:', embedUrl.value)
      error.value = false
      
      // Annuler le timeout car l'iframe s'est chargée
      if (timeoutId) {
        clearTimeout(timeoutId)
        timeoutId = null
        console.log('⏰ [WebEmbed] Timeout annulé - iframe chargée')
      }
      
      // Tentative de récupération du titre de la page (si même domaine)
      try {
        if (webFrame.value && webFrame.value.contentDocument) {
          const title = webFrame.value.contentDocument.title
          if (title) {
            console.log('📖 [WebEmbed] Titre de la page récupéré:', title)
            pageTitle.value = title
          }
        }
      } catch (e) {
        // Erreur CORS attendue pour les domaines externes
        console.log('⚠️ [WebEmbed] Impossible de récupérer le titre (politique CORS):', e.message)
      }
    }
    
    const onIframeError = (event) => {
      console.error('💥 [WebEmbed] Erreur de chargement de l\'iframe pour:', embedUrl.value)
      console.error('💥 [WebEmbed] Détails de l\'événement:', event)
      console.log('🔍 [WebEmbed] Causes possibles :')
      console.log('   • Le site a X-Frame-Options: DENY/SAMEORIGIN')
      console.log('   • URL inaccessible ou inexistante')
      console.log('   • Problème de réseau ou timeout')
      console.log('   • Site nécessitant HTTPS')
      console.log('   • Politique Content-Security-Policy restrictive')
      
      // Annuler le timeout car on a une erreur
      if (timeoutId) {
        clearTimeout(timeoutId)
        timeoutId = null
        console.log('⏰ [WebEmbed] Timeout annulé - erreur détectée')
      }
      
      error.value = true
      errorMessage.value = 'Ce site bloque l\'affichage en iframe. Utilisez "Ouvrir dans un nouvel onglet" pour l\'afficher.'
    }
    
    const onIframeLoadStart = () => {
      console.log('🚀 [WebEmbed] Début du chargement de l\'iframe')
    }
    
    const onIframeLoadEnd = () => {
      console.log('✅ [WebEmbed] Fin du chargement de l\'iframe')
    }
    
    // Fonction pour démarrer le timeout de sécurité
    const startLoadingTimeout = () => {
      // Annuler l'ancien timeout s'il existe
      if (timeoutId) {
        clearTimeout(timeoutId)
        console.log('⏰ [WebEmbed] Ancien timeout annulé')
      }
      
      console.log('⏱️ [WebEmbed] Démarrage du timeout de 30 secondes')
      timeoutId = setTimeout(() => {
        if (!error.value && embedUrl.value) {
          console.error('⏰ [WebEmbed] Timeout atteint - iframe non chargée')
          console.error('⏰ [WebEmbed] URL qui posait problème:', embedUrl.value)
          loading.value = false
          error.value = true
          errorMessage.value = 'Délai de chargement dépassé. La page met trop de temps à répondre.'
        }
      }, 30000)
    }
    
    const refreshPage = () => {
      console.log('🔄 [WebEmbed] Rafraîchissement de la page...')
      if (webFrame.value && embedUrl.value) {
        console.log('🔁 [WebEmbed] Rechargement de l\'iframe avec URL:', embedUrl.value)
        loading.value = true
        error.value = false
        
        // Démarrer le nouveau timeout
        startLoadingTimeout()
        
        webFrame.value.src = embedUrl.value
      } else {
        console.log('🔄 [WebEmbed] Rechargement via API')
        loadLatestPage()
      }
    }
    
    const retryLoad = () => {
      refreshPage()
    }
    
    const openInNewTab = () => {
      const urlToOpen = embedUrl.value || (currentPage.value && (currentPage.value.embed_url || currentPage.value.url))
      if (urlToOpen) {
        console.log('🔗 [WebEmbed] Ouverture dans un nouvel onglet:', urlToOpen)
        window.open(urlToOpen, '_blank', 'noopener,noreferrer')
      } else {
        console.warn('⚠️ [WebEmbed] Aucune URL disponible pour ouvrir dans un nouvel onglet')
      }
    }
    
    const goBack = () => {
      router.go(-1)
    }
    
    onMounted(async () => {
      console.log('🚀 [WebEmbed] Composant monté, initialisation...')
      console.log('📍 [WebEmbed] Route actuelle:', route.path)
      console.log('🔍 [WebEmbed] Query parameters:', route.query)
      
      // Vérifier s'il y a une URL dans les paramètres de query
      const queryUrl = getUrlFromQuery()
      
      if (queryUrl) {
        // Utiliser l'URL de query parameter
        console.log('🎯 [WebEmbed] Utilisation de l\'URL du query parameter')
        
        // Vérifier si l'URL peut être chargée en iframe
        if (!canLoadInIframe(queryUrl)) {
          console.warn('⚠️ [WebEmbed] URL du query parameter non-compatible iframe:', queryUrl)
          error.value = true
          loading.value = false
          errorMessage.value = `Cette page ne peut pas être affichée en iframe. Cliquez sur "Ouvrir dans un nouvel onglet" pour l'afficher.`
          return
        }
        
        embedUrl.value = queryUrl
        pageTitle.value = 'Page Web'
        console.log('🎯 [WebEmbed] URL définie:', embedUrl.value)
        
        // Attendre le rendu puis arrêter le loading
        await nextTick()
        loading.value = false
        console.log('✅ [WebEmbed] Loading arrêté - iframe peut se rendre')
        
        // Démarrer le timeout de sécurité
        startLoadingTimeout()
        
      } else {
        // Charger la dernière page depuis l'API
        console.log('📡 [WebEmbed] Aucune URL en query parameter, chargement via API...')
        await loadLatestPage()
      }
      
      // Logs de diagnostic du DOM
      setTimeout(async () => {
        await nextTick()
        console.log('🔍 [WebEmbed] État final après nextTick:')
        console.log('  - embedUrl:', embedUrl.value)
        console.log('  - loading:', loading.value)
        console.log('  - error:', error.value)
        console.log('  - webFrame présent:', !!webFrame.value)
        if (webFrame.value) {
          console.log('  - iframe src:', webFrame.value.src)
        }
      }, 100)
    })
    
    // Nettoyer le timeout si le composant est démonté
    onUnmounted(() => {
      if (timeoutId) {
        clearTimeout(timeoutId)
        console.log('🧹 [WebEmbed] Composant démonté, timeout nettoyé')
      }
    })
    
    // Fonction pour vérifier si une URL peut être chargée en iframe
    const canLoadInIframe = (url) => {
      // URLs connues qui bloquent l'iframe
      const blockedDomains = [
        'youtube.com',
        'youtu.be',
        'facebook.com',
        'instagram.com',
        'twitter.com',
        'x.com',
        'tiktok.com'
        // 'roue.dinorapp.com' retiré car .htaccess sera modifié pour autoriser iframe
      ]
      
      try {
        const urlObj = new URL(url)
        const isBlocked = blockedDomains.some(domain => urlObj.hostname.includes(domain))
        
        if (isBlocked) {
          console.warn('🚫 [WebEmbed] Domaine connu pour bloquer les iframes:', urlObj.hostname)
        } else {
          console.log('✅ [WebEmbed] Domaine autorisé pour iframe:', urlObj.hostname)
        }
        
        return !isBlocked
      } catch {
        return false
      }
    }
    
    return {
      webFrame,
      loading,
      error,
      errorMessage,
      pageTitle,
      embedUrl,
      currentPage,
      onIframeLoad,
      onIframeError,
      onIframeLoadStart,
      onIframeLoadEnd,
      refreshPage,
      retryLoad,
      openInNewTab,
      goBack,
      loadLatestPage,
      getUrlFromQuery,
      canLoadInIframe
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