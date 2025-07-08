<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="share-modal-overlay" @click="handleOverlayClick">
        <div class="share-modal" @click.stop>
          <div class="share-modal-header">
            <h3>Partager</h3>
            <button class="close-btn" @click="close" aria-label="Fermer">
              <i class="material-icons">close</i>
            </button>
          </div>
          
          <div class="share-modal-content">
            <div class="share-buttons">
              <button 
                v-for="network in socialNetworks" 
                :key="network.id"
                @click="shareToNetwork(network.id)"
                :class="['share-btn', network.id]"
                :aria-label="`Partager sur ${network.name}`"
                :style="{ '--network-color': network.color }"
              >
                <i :class="network.icon" class="share-icon"></i>
                <span class="share-btn-label">{{ network.name }}</span>
              </button>
            </div>
            
            <div class="share-link">
              <input 
                type="text" 
                :value="shareData.url || currentUrl" 
                readonly
                ref="linkInput"
                class="share-link-input"
              >
              <button @click="handleCopyLink" class="copy-btn" :class="{ copied: linkCopied }">
                <i class="material-icons">{{ linkCopied ? 'check' : 'content_copy' }}</i>
                {{ linkCopied ? 'Copié!' : 'Copier' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useSocialShare } from '@/composables/useSocialShare'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  shareData: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const { shareToSocial, copyLink } = useSocialShare()

const linkInput = ref(null)
const linkCopied = ref(false)
const currentUrl = computed(() => window.location.href)

const socialNetworks = [
  { id: 'facebook', name: 'Facebook', icon: 'fab fa-facebook-f', color: '#1877f2' },
  { id: 'twitter', name: 'X (Twitter)', icon: 'fab fa-x-twitter', color: '#1da1f2' },
  { id: 'whatsapp', name: 'WhatsApp', icon: 'fab fa-whatsapp', color: '#25d366' },
  { id: 'linkedin', name: 'LinkedIn', icon: 'fab fa-linkedin-in', color: '#0077b5' },
  { id: 'telegram', name: 'Telegram', icon: 'fab fa-telegram-plane', color: '#0088cc' },
  { id: 'pinterest', name: 'Pinterest', icon: 'fab fa-pinterest-p', color: '#e60023' },
  { id: 'email', name: 'Email', icon: 'fas fa-envelope', color: '#ea4335' }
]

const close = () => {
  emit('update:modelValue', false)
}

const handleOverlayClick = (e) => {
  if (e.target === e.currentTarget) {
    close()
  }
}

const shareToNetwork = (platform) => {
  console.log('🚀 [ShareModal] shareToNetwork appelé avec platform:', platform)
  console.log('📋 [ShareModal] shareData:', props.shareData)
  shareToSocial(platform, props.shareData)
  // Fermer le modal après partage
  setTimeout(() => close(), 500)
}

const handleCopyLink = async () => {
  console.log('📋 [ShareModal] handleCopyLink appelé')
  const url = props.shareData.url || currentUrl.value
  console.log('🔗 [ShareModal] URL à copier:', url)
  const success = await copyLink(url)
  
  if (success) {
    console.log('✅ [ShareModal] Lien copié avec succès!')
    linkCopied.value = true
    setTimeout(() => {
      linkCopied.value = false
    }, 2000)
  } else {
    console.error('❌ [ShareModal] Échec de la copie du lien')
  }
}

// Réinitialiser l'état quand le modal se ferme
watch(() => props.modelValue, (newVal) => {
  if (!newVal) {
    linkCopied.value = false
  }
})
</script>

<style scoped>
.share-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.share-modal {
  background: white;
  border-radius: 16px;
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.share-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.share-modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 50%;
  transition: background-color 0.2s;
  color: #666;
}

.close-btn:hover {
  background-color: #f5f5f5;
}

.share-modal-content {
  padding: 1.5rem;
}

.share-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.share-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 0.5rem;
  border: none;
  background: #f5f5f5;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  color: #333;
}

.share-btn:hover {
  background: var(--network-color);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.share-btn:hover .share-icon {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.share-btn span.material-icons {
  font-size: 24px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: white;
}

.share-icon {
  font-size: 20px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: white;
  color: var(--network-color);
}

.share-btn-label {
  font-size: 0.875rem;
  font-weight: 500;
}

/* Couleurs des réseaux sociaux */
.share-btn:hover {
  background: var(--network-color);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.share-btn:hover .share-icon {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.share-link {
  display: flex;
  gap: 0.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e0e0e0;
}

.share-link-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 0.875rem;
  color: #666;
  background: #f9f9f9;
}

.copy-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: #E1251B;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
  white-space: nowrap;
}

.copy-btn:hover {
  background: #c71f16;
}

.copy-btn.copied {
  background: #4caf50;
}

.copy-btn span {
  font-size: 18px;
}

/* Animations */
.modal-enter-active,
.modal-leave-active {
  transition: all 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .share-modal,
.modal-leave-to .share-modal {
  transform: scale(0.9);
}

/* Mobile */
@media (max-width: 480px) {
  .share-modal {
    margin: 0 1rem;
  }
  
  .share-buttons {
    grid-template-columns: repeat(3, 1fr);
    gap: 0.75rem;
  }
  
  .share-btn {
    padding: 0.75rem 0.25rem;
  }
  
  .share-btn-label {
    font-size: 0.75rem;
  }
}
</style> 