<template>
  <div class="events-list">
    <!-- Header -->
    <header class="page-header">
      <div class="header-content">
        <h1>Événements</h1>
        <p class="subtitle">Participez à nos événements culinaires</p>
      </div>
    </header>

    <!-- Search and Filters -->
    <SearchAndFilters
      v-model:searchQuery="searchQuery"
      v-model:selectedCategory="selectedCategory"
      search-placeholder="Rechercher un événement..."
      :categories="categories"
      :additional-filters="eventFilters"
      :selected-filters="selectedFilters"
      :results-count="filteredEvents.length"
      item-type="événement"
      @update:additionalFilter="updateAdditionalFilter"
    />

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
      <div v-if="!filteredEvents.length && !loading" class="empty-state">
        <div class="empty-icon">
          <span class="material-symbols-outlined">event</span>
        </div>
        <h3>{{ searchQuery || selectedCategory || hasActiveFilters ? 'Aucun événement trouvé' : 'Aucun événement disponible' }}</h3>
        <p v-if="searchQuery || selectedCategory || hasActiveFilters">
          Essayez de modifier vos critères de recherche.
        </p>
        <p v-else>
          Les événements culinaires seront bientôt disponibles.
        </p>
        <button v-if="searchQuery || selectedCategory || hasActiveFilters" @click="clearAllFilters" class="clear-filters-btn">
          Effacer tous les filtres
        </button>
      </div>

      <!-- Events List -->
      <div v-else class="events-container">
        <article
          v-for="event in filteredEvents"
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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '@/services/api'
import SearchAndFilters from '@/components/common/SearchAndFilters.vue'

export default {
  name: 'EventsList',
  components: {
    SearchAndFilters
  },
  setup() {
    const router = useRouter()
    
    // State
    const events = ref([])
    const categories = ref([])
    const loading = ref(false)
    const error = ref(null)
    const searchQuery = ref('')
    const selectedCategory = ref(null)
    const selectedFilters = ref({
      eventType: null,
      eventFormat: null,
      price: null,
      status: null
    })
    
    // Computed
    const filteredEvents = computed(() => {
      let filtered = events.value

      // Filtre par recherche textuelle
      if (searchQuery.value.trim()) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(event => 
          event.title?.toLowerCase().includes(query) ||
          event.description?.toLowerCase().includes(query) ||
          event.short_description?.toLowerCase().includes(query) ||
          event.location?.toLowerCase().includes(query) ||
          event.city?.toLowerCase().includes(query) ||
          event.organizer_name?.toLowerCase().includes(query)
        )
      }

      // Filtre par catégorie
      if (selectedCategory.value) {
        filtered = filtered.filter(event => event.category_id === selectedCategory.value)
      }

      // Filtres additionnels
      if (selectedFilters.value.eventType) {
        filtered = filtered.filter(event => event.event_type === selectedFilters.value.eventType)
      }

      if (selectedFilters.value.eventFormat) {
        filtered = filtered.filter(event => event.event_format === selectedFilters.value.eventFormat)
      }

      if (selectedFilters.value.price) {
        if (selectedFilters.value.price === 'free') {
          filtered = filtered.filter(event => event.is_free)
        } else if (selectedFilters.value.price === 'paid') {
          filtered = filtered.filter(event => !event.is_free)
        }
      }

      if (selectedFilters.value.status) {
        filtered = filtered.filter(event => event.status === selectedFilters.value.status)
      }

      return filtered
    })

    const hasActiveFilters = computed(() => {
      return Object.values(selectedFilters.value).some(value => value !== null)
    })

    const eventFilters = computed(() => [
      {
        key: 'eventType',
        label: 'Type d\'événement',
        icon: 'category',
        allLabel: 'Tous les types',
        options: [
          { value: 'conference', label: 'Conférence' },
          { value: 'workshop', label: 'Atelier' },
          { value: 'seminar', label: 'Séminaire' },
          { value: 'cooking_class', label: 'Cours de cuisine' },
          { value: 'tasting', label: 'Dégustation' },
          { value: 'festival', label: 'Festival' },
          { value: 'competition', label: 'Concours' },
          { value: 'networking', label: 'Networking' },
          { value: 'exhibition', label: 'Exposition' },
          { value: 'party', label: 'Fête' }
        ]
      },
      {
        key: 'eventFormat',
        label: 'Format',
        icon: 'computer',
        allLabel: 'Tous les formats',
        options: [
          { value: 'in_person', label: 'En présentiel' },
          { value: 'online', label: 'En ligne' },
          { value: 'hybrid', label: 'Hybride' }
        ]
      },
      {
        key: 'price',
        label: 'Tarif',
        icon: 'payments',
        allLabel: 'Tous les tarifs',
        options: [
          { value: 'free', label: 'Gratuit' },
          { value: 'paid', label: 'Payant' }
        ]
      },
      {
        key: 'status',
        label: 'Statut',
        icon: 'info',
        allLabel: 'Tous les statuts',
        options: [
          { value: 'active', label: 'Actif' },
          { value: 'upcoming', label: 'À venir' },
          { value: 'completed', label: 'Terminé' }
        ]
      }
    ])

    // Methods
    const goToEvent = (id) => {
      router.push(`/event/${id}`)
    }
    
    const retry = () => {
      error.value = null
      loadEvents()
      loadCategories()
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

    const loadCategories = async () => {
      try {
        const response = await apiService.getEventCategories()
        if (response.success) {
          categories.value = response.data
        }
      } catch (err) {
        console.warn('Error fetching event categories:', err)
      }
    }

    const updateAdditionalFilter = ({ key, value }) => {
      selectedFilters.value[key] = value
    }

    const clearAllFilters = () => {
      searchQuery.value = ''
      selectedCategory.value = null
      selectedFilters.value = {
        eventType: null,
        eventFormat: null,
        price: null,
        status: null
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
      loadCategories()
    })
    
    return {
      events,
      categories,
      loading,
      error,
      searchQuery,
      selectedCategory,
      selectedFilters,
      filteredEvents,
      hasActiveFilters,
      eventFilters,
      goToEvent,
      retry,
      updateAdditionalFilter,
      clearAllFilters,
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
/* Styles globaux */
.events-list {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc pour tous les écrans */
  font-family: 'Roboto', sans-serif;
}

/* Typographie globale */
h1, h2, h3, h4, h5, h6 {
  font-family: 'Open Sans', sans-serif; /* Open Sans pour les titres */
  font-weight: 600;
  color: #000000; /* Noir pour les titres - contraste 21:1 */
  line-height: 1.3;
}

p, span, div {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  color: #2D3748; /* Couleur foncée pour contraste 12.6:1 */
  line-height: 1.5;
}

.page-header {
  background: #F4D03F; /* Fond doré */
  padding: 32px 16px;
  text-align: center;
  border-radius: 0 0 16px 16px;
}

.header-content h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 700;
  color: #000000; /* Noir sur doré - contraste 5.1:1 */
}

.subtitle {
  margin: 0;
  font-size: 16px;
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
  opacity: 1;
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
  border: 4px solid #E2E8F0; /* Bordure claire */
  border-top: 4px solid #E53E3E; /* Rouge Dinor */
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
  background: #F4D03F; /* Fond doré */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.error-icon .material-symbols-outlined,
.empty-icon .material-symbols-outlined {
  font-size: 32px;
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
}

.content {
  padding: 16px;
}

.events-container {
  display: grid;
  gap: 16px;
}

.event-card {
  background: #FFFFFF; /* Fond blanc */
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #E2E8F0; /* Bordure claire */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.event-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(229, 62, 62, 0.2); /* Ombre rouge */
  border-color: #E53E3E; /* Bordure rouge au hover */
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
  filter: brightness(1.1) contrast(1.1); /* Améliorer la luminosité des images */
}

.event-status {
  position: absolute;
  top: 12px;
  right: 12px;
}

.event-status span {
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.status-active {
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
}

.status-upcoming {
  background: #F4D03F; /* Doré */
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
}

.status-completed {
  background: #4A5568; /* Gris foncé */
  color: #FFFFFF; /* Blanc sur gris - contraste 7.5:1 */
}

.status-cancelled {
  background: #FF6B35; /* Orange */
  color: #FFFFFF; /* Blanc sur orange - contraste 3.1:1 */
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
  font-weight: 700;
  color: #000000; /* Noir - contraste 21:1 */
  line-height: 1.3;
  flex: 1;
}

.event-price {
  flex-shrink: 0;
}

.free-badge {
  background: #F4D03F; /* Doré */
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
}

.price {
  font-size: 18px;
  font-weight: 700;
  color: #E53E3E; /* Rouge Dinor */
}

.event-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
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
  color: #2D3748; /* Couleur foncée - contraste 12.6:1 */
}

.detail .material-symbols-outlined {
  font-size: 18px;
  color: #E53E3E; /* Rouge Dinor pour les icônes */
}

.participants-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #2D3748; /* Couleur foncée */
  padding: 8px 12px;
  background: #F7FAFC; /* Fond très clair */
  border-radius: 8px;
  border: 1px solid #E2E8F0;
}

.participants-info .material-symbols-outlined {
  font-size: 18px;
  color: #E53E3E; /* Rouge Dinor */
}

.retry-btn,
.clear-filters-btn {
  padding: 12px 24px;
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover,
.clear-filters-btn:hover {
  background: #C53030; /* Rouge plus foncé */
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .events-container {
    grid-template-columns: 1fr;
  }
  
  .event-details {
    grid-template-columns: 1fr;
  }
  
  .event-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>