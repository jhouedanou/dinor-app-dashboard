<template>
  <div 
    v-if="showPrompt" 
    class="install-prompt"
    :class="{ 'visible': visible }"
  >
    <div class="prompt-content">
      <div class="prompt-icon">
        <span class="material-symbols-outlined">download</span>
      </div>
      <div class="prompt-text">
        <h3>Installer Dinor App</h3>
        <p>Installez l'app pour une meilleure expérience</p>
      </div>
      <div class="prompt-actions">
        <button @click="dismissPrompt" class="btn-dismiss">
          Plus tard
        </button>
        <button @click="installApp" class="btn-install">
          Installer
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'

export default {
  name: 'InstallPrompt',
  setup() {
    const appStore = useAppStore()
    const visible = ref(false)
    const dismissed = ref(false)
    
    const showPrompt = computed(() => {
      return appStore.installPromptEvent && 
             !appStore.isInstalled && 
             !dismissed.value
    })
    
    const installApp = async () => {
      const success = await appStore.showInstallPrompt()
      if (success) {
        visible.value = false
      }
    }
    
    const dismissPrompt = () => {
      dismissed.value = true
      visible.value = false
      // Remember dismissal for this session
      sessionStorage.setItem('pwa-install-dismissed', 'true')
    }
    
    onMounted(() => {
      // Check if already dismissed in this session
      if (sessionStorage.getItem('pwa-install-dismissed')) {
        dismissed.value = true
        return
      }
      
      // Show prompt with delay
      setTimeout(() => {
        if (showPrompt.value) {
          visible.value = true
        }
      }, 3000)
    })
    
    return {
      showPrompt,
      visible,
      installApp,
      dismissPrompt
    }
  }
}
</script>

<style scoped>
.install-prompt {
  position: fixed;
  bottom: 100px;
  left: 16px;
  right: 16px;
  background: var(--md-sys-color-surface-container-high, #ffffff);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid var(--md-sys-color-outline-variant, #e5e7eb);
  z-index: 1001;
  transform: translateY(100%);
  opacity: 0;
  transition: all 0.3s ease;
}

.install-prompt.visible {
  transform: translateY(0);
  opacity: 1;
}

.prompt-content {
  display: flex;
  align-items: center;
  padding: 16px;
  gap: 12px;
}

.prompt-icon {
  flex-shrink: 0;
  width: 48px;
  height: 48px;
  background: var(--md-sys-color-primary-container, #e3f2fd);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.prompt-icon .material-symbols-outlined {
  font-size: 24px;
  color: var(--md-sys-color-on-primary-container, #1565c0);
}

.prompt-text {
  flex: 1;
  min-width: 0;
}

.prompt-text h3 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.prompt-text p {
  margin: 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #6b7280);
}

.prompt-actions {
  display: flex;
  gap: 8px;
}

.btn-dismiss,
.btn-install {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-dismiss {
  background: transparent;
  color: var(--md-sys-color-on-surface-variant, #6b7280);
}

.btn-dismiss:hover {
  background: var(--md-sys-color-surface-variant, #f3f4f6);
}

.btn-install {
  background: var(--md-sys-color-primary, #2563eb);
  color: var(--md-sys-color-on-primary, #ffffff);
}

.btn-install:hover {
  background: var(--md-sys-color-primary-container, #dbeafe);
  color: var(--md-sys-color-on-primary-container, #1e40af);
}

/* Desktop styles */
@media (min-width: 768px) {
  .install-prompt {
    bottom: 24px;
    right: 24px;
    left: auto;
    max-width: 400px;
  }
}

/* Safe area support */
@supports (padding: max(0px)) {
  .install-prompt {
    bottom: calc(100px + env(safe-area-inset-bottom, 0));
  }
  
  @media (min-width: 768px) {
    .install-prompt {
      bottom: calc(24px + env(safe-area-inset-bottom, 0));
    }
  }
}
</style>