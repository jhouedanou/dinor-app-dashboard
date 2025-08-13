<template>
  <div class="notification-button">
    <button 
      @click="toggleNotifications"
      :class="['btn', notificationStatus.permission === 'granted' ? 'btn-success' : 'btn-primary']"
      :disabled="!notificationStatus.isSupported || loading"
    >
      <DinorIcon 
        :name="notificationStatus.permission === 'granted' ? 'notifications_active' : 'notifications'" 
        :size="16" 
      />
      {{ buttonText }}
    </button>
    
    <button 
      v-if="notificationStatus.permission === 'granted'"
      @click="testNotification"
      class="btn btn-secondary"
      :disabled="loading"
    >
      <DinorIcon name="send" :size="16" />
      Test
    </button>
    
    <div v-if="statusMessage" class="status-message" :class="statusType">
      {{ statusMessage }}
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { notificationService } from '@/services/notificationService'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'NotificationButton',
  components: {
    DinorIcon
  },
  setup() {
    const loading = ref(false)
    const notificationStatus = ref({
      isSupported: false,
      permission: 'default',
      isInitialized: false,
      hasServiceWorker: false
    })
    const statusMessage = ref('')
    const statusType = ref('')

    const buttonText = computed(() => {
      if (loading.value) return 'Chargement...'
      
      switch (notificationStatus.value.permission) {
        case 'granted':
          return 'Notifications activées'
        case 'denied':
          return 'Notifications refusées'
        default:
          return 'Activer notifications'
      }
    })

    const updateStatus = () => {
      notificationStatus.value = notificationService.getStatus()
    }

    const showStatus = (message, type = 'info') => {
      statusMessage.value = message
      statusType.value = type
      setTimeout(() => {
        statusMessage.value = ''
        statusType.value = ''
      }, 3000)
    }

    const toggleNotifications = async () => {
      loading.value = true
      
      try {
        if (notificationStatus.value.permission === 'granted') {
          // Désactiver les notifications
          await notificationService.unsubscribe()
          showStatus('Notifications désactivées', 'success')
        } else {
          // Activer les notifications
          const permission = await notificationService.requestPermissionWithPrompt()
          
          if (permission === 'granted') {
            showStatus('Notifications activées avec succès !', 'success')
          } else if (permission === 'denied') {
            showStatus('Permission refusée. Vous pouvez la réactiver dans les paramètres de votre navigateur.', 'warning')
          } else {
            showStatus('Permission en attente. Veuillez réessayer.', 'info')
          }
        }
      } catch (error) {
        console.error('Erreur notifications:', error)
        showStatus('Erreur lors de la configuration des notifications', 'error')
      } finally {
        loading.value = false
        updateStatus()
      }
    }

    const testNotification = async () => {
      loading.value = true
      
      try {
        await notificationService.showLocalNotification(
          'Test Dinor',
          {
            body: 'Cette notification de test confirme que le système fonctionne correctement !',
            icon: '/pwa/icons/icon-192x192.png',
            tag: 'test-notification'
          }
        )
        showStatus('Notification de test envoyée !', 'success')
      } catch (error) {
        console.error('Erreur test notification:', error)
        showStatus('Erreur lors de l\'envoi de la notification de test', 'error')
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      updateStatus()
      
      // Mettre à jour le statut régulièrement
      const interval = setInterval(updateStatus, 1000)
      
      return () => {
        clearInterval(interval)
      }
    })

    return {
      loading,
      notificationStatus,
      buttonText,
      statusMessage,
      statusType,
      toggleNotifications,
      testNotification
    }
  }
}
</script>

<style scoped>
.notification-button {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: flex-start;
  margin: 16px 0;
}

.notification-button .btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
}

.btn-primary {
  background: #E53E3E;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #C53030;
  transform: translateY(-1px);
}

.btn-success {
  background: #38A169;
  color: white;
}

.btn-success:hover:not(:disabled) {
  background: #2F855A;
  transform: translateY(-1px);
}

.btn-secondary {
  background: #F7FAFC;
  color: #2D3748;
  border: 1px solid #E2E8F0;
}

.btn-secondary:hover:not(:disabled) {
  background: #EDF2F7;
  transform: translateY(-1px);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.status-message {
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 12px;
  margin-top: 8px;
}

.status-message.success {
  background: #F0FFF4;
  color: #38A169;
  border: 1px solid #9AE6B4;
}

.status-message.error {
  background: #FED7D7;
  color: #E53E3E;
  border: 1px solid #FEB2B2;
}

.status-message.warning {
  background: #FFFAF0;
  color: #DD6B20;
  border: 1px solid #F6D55C;
}

.status-message.info {
  background: #EBF8FF;
  color: #3182CE;
  border: 1px solid #90CDF4;
}

@media (max-width: 480px) {
  .notification-button {
    width: 100%;
  }
  
  .notification-button .btn {
    width: 100%;
    justify-content: center;
  }
}
</style>