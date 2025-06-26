<template>
  <div class="events-list">
    <!-- Header -->
    <header class="page-header">
      <div class="header-content">
        <h1>Événements</h1>
        <p class="subtitle">Participez à nos événements culinaires</p>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des événements...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
      </div>
      <p>{{ error }}</p>
      <button @click="retry" class="retry-btn">
        Réessayer
      </button>
    </div>

    <!-- Content -->
    <div v-else class="content">
      <!-- Empty State -->
      <div v-if="!events.length && !loading" class="empty-state">
        <div class="empty-icon">
          <span class="material-symbols-outlined">event</span>
        </div>
        <h3>Aucun événement disponible</h3>
        <p>Les événements culinaires seront bientôt disponibles.</p>
      </div>

      <!-- Events List -->
      <div v-else class="events-container">
        <article
          v-for="event in events"
          :key="event.id"
          @click="goToEvent(event.id)"
          class="event-card"
        >
          <div class="event-image">
            <img
              :src="event.featured_image_url || '/images/default-event.jpg'"
              :alt="event.title"
              loading="lazy"
            />
            <div class="event-status">
              <span :class="getStatusClass(event.status)">
                {{ getStatusLabel(event.status) }}
              </span>
            </div>
          </div>
          
          <div class="event-content">
            <div class="event-header">
              <h3 class="event-title">{{ event.title }}</h3>
              <div v-if="event.price" class="event-price">
                <span v-if="event.is_free" class="free-badge">Gratuit</span>
                <span v-else class="price">{{ formatPrice(event.price, event.currency) }}</span>
              </div>
            </div>
            
            <p v-if="event.short_description" class="event-description">
              {{ event.short_description }}
            </p>
            
            <div class="event-details">
              <div class="detail">
                <span class="material-symbols-outlined">calendar_today</span>
                <span>{{ formatDate(event.start_date) }}</span>
              </div>
              <div v-if="event.start_time" class="detail">
                <span class="material-symbols-outlined">schedule</span>
                <span>{{ formatTime(event.start_time) }}</span>
              </div>
              <div v-if="event.location" class="detail">
                <span class="material-symbols-outlined">location_on</span>
                <span>{{ event.location }}</span>
              </div>
              <div v-if="event.event_type" class="detail">
                <span class="material-symbols-outlined">category</span>
                <span>{{ getEventTypeLabel(event.event_type) }}</span>
              </div>
            </div>
            
            <div v-if="event.max_participants" class="participants-info">
              <span class="material-symbols-outlined">group</span>
              <span>{{ event.participants_count || 0 }} / {{ event.max_participants }} participants</span>
            </div>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '@/services/api'

export default {
  name: 'EventsList',
  setup() {
    const router = useRouter()
    
    // State
    const events = ref([])
    const loading = ref(false)
    const error = ref(null)
    
    // Methods
    const goToEvent = (id) => {
      router.push(`/event/${id}`)
    }
    
    const retry = () => {
      error.value = null
      loadEvents()
    }
    
    const loadEvents = async () => {
      loading.value = true
      error.value = null
      
      try {
        const response = await apiService.getEvents()
        
        if (response.success) {
          events.value = response.data
        } else {
          throw new Error(response.message || 'Failed to fetch events')
        }
      } catch (err) {
        error.value = err.message
        console.error('Error fetching events:', err)
      } finally {
        loading.value = false
      }
    }
    
    const getStatusClass = (status) => {
      const classes = {
        'active': 'status-active',
        'cancelled': 'status-cancelled',
        'completed': 'status-completed',
        'upcoming': 'status-upcoming'
      }
      return classes[status] || 'status-default'
    }
    
    const getStatusLabel = (status) => {
      const labels = {
        'active': 'Actif',
        'cancelled': 'Annulé',
        'completed': 'Terminé',
        'upcoming': 'À venir'
      }
      return labels[status] || 'Non défini'
    }
    
    const getEventTypeLabel = (type) => {
      const labels = {
        'festival': 'Festival',
        'cooking_class': 'Cours de cuisine',
        'tasting': 'Dégustation',
        'workshop': 'Atelier',
        'conference': 'Conférence'
      }
      return labels[type] || type
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }
    
    const formatTime = (timeString) => {
      if (!timeString) return ''
      return new Date(`2000-01-01T${timeString}`).toLocaleTimeString('fr-FR', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    const formatPrice = (price, currency = 'XOF') => {
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: currency
      }).format(price)
    }
    
    // Lifecycle
    onMounted(() => {
      loadEvents()
    })
    
    return {
      events,
      loading,
      error,
      goToEvent,
      retry,
      getStatusClass,
      getStatusLabel,
      getEventTypeLabel,
      formatDate,
      formatTime,
      formatPrice
    }
  }
}
</script>

<style scoped>
.events-list {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

.page-header {
  background: linear-gradient(135deg, var(--md-sys-color-secondary-container, #e8def8) 0%, var(--md-sys-color-primary-container, #eaddff) 100%);
  padding: 32px 16px;
  text-align: center;
}

.header-content h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: var(--md-sys-color-on-secondary-container, #1d192b);
}

.subtitle {
  margin: 0;
  font-size: 16px;
  color: var(--md-sys-color-on-secondary-container, #1d192b);
  opacity: 0.8;
}

.loading-state,
.error-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 4px solid var(--md-sys-color-primary, #6750a4);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon,
.empty-icon {
  width: 64px;
  height: 64px;
  background: var(--md-sys-color-error-container, #fce8e6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.empty-icon {
  background: var(--md-sys-color-secondary-container, #e8def8);
}

.error-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.empty-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-secondary-container, #1d192b);
}

.content {
  padding: 16px;
}

.events-container {
  display: grid;
  gap: 16px;
}

.event-card {
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
}

.event-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.event-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.event-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.event-status {
  position: absolute;
  top: 12px;
  right: 12px;
}

.event-status span {
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-active {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.status-upcoming {
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

.status-completed {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.status-cancelled {
  background: var(--md-sys-color-error-container, #fce8e6);
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.event-content {
  padding: 20px;
}

.event-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  gap: 16px;
}

.event-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
  line-height: 1.3;
  flex: 1;
}

.event-price {
  flex-shrink: 0;
}

.free-badge {
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
  color: var(--md-sys-color-on-tertiary-container, #31111d);
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
}

.price {
  font-size: 18px;
  font-weight: 600;
  color: var(--md-sys-color-primary, #6750a4);
}

.event-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.5;
}

.event-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 8px;
  margin-bottom: 16px;
}

.detail {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.detail .material-symbols-outlined {
  font-size: 18px;
  color: var(--md-sys-color-primary, #6750a4);
}

.participants-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  padding: 8px 12px;
  background: var(--md-sys-color-surface-variant, #e7e0ec);
  border-radius: 8px;
}

.participants-info .material-symbols-outlined {
  font-size: 18px;
  color: var(--md-sys-color-primary, #6750a4);
}

.retry-btn {
  padding: 12px 24px;
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

/* Responsive */
@media (min-width: 768px) {
  .events-container {
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  }
  
  .event-card {
    display: flex;
    flex-direction: row;
  }
  
  .event-image {
    width: 200px;
    height: auto;
  }
  
  .event-content {
    flex: 1;
  }
  
  .event-details {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>