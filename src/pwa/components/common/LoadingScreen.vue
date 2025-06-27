<template>
  <div class="loading-screen" :class="{ 'fade-out': !isVisible }">
    <!-- Bulles animées en arrière-plan -->
    <div class="bubbles-container">
      <div 
        v-for="bubble in bubbles" 
        :key="bubble.id"
        class="bubble"
        :style="bubble.style"
      ></div>
    </div>

    <!-- Contenu principal -->
    <div class="loading-content">
      <!-- Logo animé -->
      <div class="logo-container">
        <div class="logo-wrapper">
          <!-- Logo principal avec animation -->
          <img 
            v-if="!logoError"
            :src="logoSrc" 
            alt="Dinor" 
            class="loading-logo"
            @error="handleLogoError"
          >
          <!-- Logo fallback SVG avec animation -->
          <svg 
            v-else
            class="loading-logo-fallback" 
            viewBox="0 0 200 80" 
            xmlns="http://www.w3.org/2000/svg"
          >
            <text x="30" y="50" font-family="Arial, sans-serif" font-size="32" font-weight="bold" fill="white">DINOR</text>
          </svg>
          
          <!-- Effet de brillance sur le logo -->
          <div class="logo-shine"></div>
        </div>
        
        <!-- Texte de chargement -->
        <div class="loading-text">
          <h2>{{ loadingText }}</h2>
          <p>{{ loadingSubtext }}</p>
        </div>
      </div>

      <!-- Barre de progression -->
      <div class="progress-container">
        <div class="progress-bar">
          <div 
            class="progress-fill" 
            :style="{ width: progress + '%' }"
          ></div>
          <div class="progress-glow"></div>
        </div>
        <div class="progress-text">{{ Math.round(progress) }}%</div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, computed } from 'vue'

export default {
  name: 'LoadingScreen',
  props: {
    visible: {
      type: Boolean,
      default: true
    },
    duration: {
      type: Number,
      default: 3000 // 3 secondes par défaut
    }
  },
  emits: ['complete'],
  setup(props, { emit }) {
    const isVisible = ref(props.visible)
    const progress = ref(0)
    const logoError = ref(false)
    const logoSrc = ref('/images/LOGO_DINOR_monochrome.svg')
    
    // Textes de chargement dynamiques
    const loadingMessages = [
      { text: 'Dinor se prépare...', sub: 'Chargement de l\'application' },
      { text: 'Presque prêt !', sub: 'Finalisation en cours' },
      { text: 'C\'est parti !', sub: 'Bienvenue sur Dinor' }
    ]
    
    const currentMessageIndex = ref(0)
    const loadingText = computed(() => loadingMessages[currentMessageIndex.value]?.text || 'Chargement...')
    const loadingSubtext = computed(() => loadingMessages[currentMessageIndex.value]?.sub || '')

    // Génération des bulles
    const bubbles = ref([])
    const generateBubbles = () => {
      bubbles.value = []
      for (let i = 0; i < 12; i++) {
        bubbles.value.push({
          id: i,
          style: {
            left: Math.random() * 100 + '%',
            animationDelay: Math.random() * 3 + 's',
            animationDuration: (3 + Math.random() * 4) + 's',
            transform: `scale(${0.3 + Math.random() * 0.7})`
          }
        })
      }
    }

    let progressInterval = null
    let messageInterval = null

    const startLoading = () => {
      // Animation de la barre de progression
      progressInterval = setInterval(() => {
        if (progress.value < 100) {
          // Progression non-linéaire pour plus de réalisme
          const increment = Math.random() * 8 + 2
          progress.value = Math.min(100, progress.value + increment)
        } else {
          clearInterval(progressInterval)
          setTimeout(() => {
            completeLoading()
          }, 500)
        }
      }, props.duration / 20) // 20 étapes

      // Changement des messages
      messageInterval = setInterval(() => {
        currentMessageIndex.value = (currentMessageIndex.value + 1) % loadingMessages.length
      }, props.duration / 3)
    }

    const completeLoading = () => {
      isVisible.value = false
      setTimeout(() => {
        emit('complete')
      }, 500) // Temps pour l'animation de fade out
    }

    const handleLogoError = () => {
      console.warn('❌ [LoadingScreen] Logo externe non trouvé, utilisation du fallback')
      logoError.value = true
    }

    onMounted(() => {
      generateBubbles()
      if (props.visible) {
        startLoading()
      }
    })

    onUnmounted(() => {
      if (progressInterval) {
        clearInterval(progressInterval)
      }
      if (messageInterval) {
        clearInterval(messageInterval)
      }
    })

    return {
      isVisible,
      progress,
      logoError,
      logoSrc,
      loadingText,
      loadingSubtext,
      bubbles,
      handleLogoError
    }
  }
}
</script>

<style scoped>
.loading-screen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #E53E3E 0%, #C53030 50%, #E53E3E 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  transition: opacity 0.5s ease-out;
  overflow: hidden;
}

.loading-screen.fade-out {
  opacity: 0;
  pointer-events: none;
}

/* Bulles animées */
.bubbles-container {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  pointer-events: none;
}

.bubble {
  position: absolute;
  bottom: -50px;
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  animation: bubble-rise linear infinite;
  backdrop-filter: blur(2px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

@keyframes bubble-rise {
  0% {
    bottom: -50px;
    opacity: 0;
    transform: translateX(0) scale(0.5);
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    bottom: calc(100vh + 50px);
    opacity: 0;
    transform: translateX(30px) scale(1.2);
  }
}

/* Contenu principal */
.loading-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
  z-index: 10;
  text-align: center;
}

/* Logo animé */
.logo-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.logo-wrapper {
  position: relative;
  animation: logo-pulse 2s ease-in-out infinite;
}

.loading-logo,
.loading-logo-fallback {
  height: 80px;
  width: auto;
  filter: brightness(0) invert(1) drop-shadow(0 0 20px rgba(255, 255, 255, 0.3));
  animation: logo-glow 3s ease-in-out infinite;
}

/* Effet de brillance sur le logo */
.logo-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shine 2s infinite;
}

@keyframes logo-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

@keyframes logo-glow {
  0%, 100% { 
    filter: brightness(0) invert(1) drop-shadow(0 0 20px rgba(255, 255, 255, 0.3)); 
  }
  50% { 
    filter: brightness(0) invert(1) drop-shadow(0 0 30px rgba(255, 255, 255, 0.6)); 
  }
}

@keyframes shine {
  0% { left: -100%; }
  100% { left: 100%; }
}

/* Texte de chargement */
.loading-text h2 {
  font-size: 24px;
  font-weight: 600;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  animation: text-fade 1s ease-in-out;
}

.loading-text p {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
  text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
  animation: text-fade 1s ease-in-out 0.2s both;
}

@keyframes text-fade {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Barre de progression */
.progress-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  width: 300px;
}

.progress-bar {
  position: relative;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
  overflow: hidden;
  backdrop-filter: blur(5px);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #F4D03F, #F7DC6F, #F4D03F);
  border-radius: 3px;
  transition: width 0.3s ease-out;
  box-shadow: 0 0 10px rgba(244, 208, 63, 0.5);
  animation: progress-shimmer 2s linear infinite;
}

.progress-glow {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  animation: progress-glow-move 1.5s ease-in-out infinite;
}

@keyframes progress-shimmer {
  0%, 100% { box-shadow: 0 0 10px rgba(244, 208, 63, 0.5); }
  50% { box-shadow: 0 0 20px rgba(244, 208, 63, 0.8); }
}

@keyframes progress-glow-move {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(400%); }
}

.progress-text {
  font-size: 14px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.8);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .loading-logo,
  .loading-logo-fallback {
    height: 60px;
  }
  
  .loading-text h2 {
    font-size: 20px;
  }
  
  .loading-text p {
    font-size: 14px;
  }
  
  .progress-container {
    width: 250px;
  }
  
  .loading-content {
    gap: 30px;
    padding: 0 20px;
  }
}

@media (max-width: 480px) {
  .loading-logo,
  .loading-logo-fallback {
    height: 50px;
  }
  
  .loading-text h2 {
    font-size: 18px;
  }
  
  .progress-container {
    width: 200px;
  }
}
</style> 