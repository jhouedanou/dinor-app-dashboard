// Composant Liste des Événements
const EventsList = {
    template: `
        <div class="events-page recipe-page">
            <!-- Top App Bar Material Design 3 -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <div class="md3-app-bar-title">
                        <i class="material-icons dinor-text-primary">event</i>
                        <span class="dinor-text-primary">Événements</span>
                    </div>
                </div>
            </nav>

            <!-- Filtres de statut -->
            <div class="md3-filter-container">
                <div class="md3-filter-scroll">
                    <button 
                        @click="selectedStatus = null"
                        :class="['md3-chip', { 'md3-chip-selected': !selectedStatus }]">
                        Tous
                    </button>
                    <button 
                        v-for="status in statusFilters"
                        :key="status.value"
                        @click="selectedStatus = status.value"
                        :class="['md3-chip', { 'md3-chip-selected': selectedStatus === status.value }]">
                        {{ status.label }}
                    </button>
                </div>
            </div>

            <!-- Main Content -->
            <main class="md3-main-content">
                <!-- Loading -->
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement des événements...</p>
                </div>

                <!-- Liste des événements Material Design 3 -->
                <div v-else-if="filteredEvents.length > 0" class="md3-events-grid">
                    <div 
                        v-for="event in filteredEvents" 
                        :key="event.id"
                        @click="goToEvent(event.id)"
                        class="md3-card md3-card-elevated event-card-md3">
                        <div v-if="event.featured_image_url" class="event-image-container">
                            <img 
                                :src="event.featured_image_url" 
                                :alt="event.title"
                                class="event-image"
                                loading="lazy"
                                @error="handleImageError">
                        </div>
                        <div class="event-content">
                            <div class="event-header-info">
                                <div class="event-date-chip">
                                    <i class="material-icons dinor-text-secondary">calendar_today</i>
                                    <span class="md3-body-small">{{ formatDay(event.start_date) }} {{ formatMonth(event.start_date) }}</span>
                                </div>
                                <div class="md3-chip event-status" :class="getStatusClass(event.status)">
                                    {{ getStatusLabel(event.status) }}
                                </div>
                            </div>
                            <h3 class="md3-title-large event-title dinor-text-primary">{{ event.title }}</h3>
                            <p class="md3-body-medium event-description dinor-text-gray">{{ truncateText(event.short_description, 100) }}</p>
                            
                            <div class="event-meta">
                                <div class="event-meta-item">
                                    <i class="material-icons dinor-text-secondary">schedule</i>
                                    <span class="md3-body-small">{{ formatTime(event.start_time) }}<span v-if="event.end_time"> - {{ formatTime(event.end_time) }}</span></span>
                                </div>
                                <div v-if="event.location" class="event-meta-item">
                                    <i class="material-icons dinor-text-secondary">location_on</i>
                                    <span class="md3-body-small">{{ event.location }}</span>
                                </div>
                                <div v-if="event.is_online" class="event-meta-item">
                                    <i class="material-icons dinor-text-secondary">computer</i>
                                    <span class="md3-body-small">Événement en ligne</span>
                                </div>
                            </div>
                            
                            <div class="event-footer-stats">
                                <div class="event-price">
                                    <span v-if="event.is_free" class="md3-chip dinor-bg-secondary">Gratuit</span>
                                    <span v-else-if="event.price" class="md3-chip">{{ event.price }}€</span>
                                </div>
                                <div class="event-stats">
                                    <div v-if="event.max_participants" class="stat-item">
                                        <i class="material-icons dinor-text-secondary">people</i>
                                        <span class="md3-body-small">{{ event.current_participants || 0 }}/{{ event.max_participants }}</span>
                                    </div>
                                    <div class="stat-item">
                                        <i class="material-icons dinor-text-secondary">favorite</i>
                                        <span class="md3-body-small">{{ event.likes_count || 0 }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            <!-- État vide -->
            <div v-else class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-calendar-alt"></i>
                </div>
                <h3 class="empty-title">Aucun événement disponible</h3>
                <p class="empty-description">
                    Les événements apparaîtront ici bientôt
                </p>
            </div>

            <!-- Pull to refresh indicator -->
            <div v-if="isRefreshing" class="refresh-indicator">
                <div class="spinner"></div>
                <span>Actualisation...</span>
            </div>
        </div>
    `,
    setup() {
        const { ref, computed, onMounted } = Vue;
        const router = VueRouter.useRouter();
        
        const loading = ref(true);
        const isRefreshing = ref(false);
        const events = ref([]);
        const selectedStatus = ref(null);
        
        const statusFilters = [
            { value: 'active', label: 'Actifs' },
            { value: 'upcoming', label: 'À venir' },
            { value: 'completed', label: 'Terminés' },
            { value: 'cancelled', label: 'Annulés' }
        ];
        
        const { request } = useApi();
        
        const filteredEvents = computed(() => {
            let filtered = events.value;
            
            if (selectedStatus.value) {
                filtered = filtered.filter(event => event.status === selectedStatus.value);
            }
            
            // Trier par date de début
            return filtered.sort((a, b) => new Date(a.start_date) - new Date(b.start_date));
        });
        
        const loadEvents = async (refresh = false) => {
            if (refresh) {
                isRefreshing.value = true;
            } else {
                loading.value = true;
            }
            
            try {
                const data = await request('/api/v1/events');
                if (data.success) {
                    events.value = data.data;
                }
            } catch (error) {
                console.error('Erreur lors du chargement des événements:', error);
            } finally {
                loading.value = false;
                isRefreshing.value = false;
            }
        };
        
        const goToEvent = (id) => {
            router.push(`/event/${id}`);
        };
        
        const truncateText = (text, length) => {
            if (!text) return '';
            return text.length > length ? text.substring(0, length) + '...' : text;
        };
        
        const formatDay = (dateString) => {
            return new Date(dateString).getDate();
        };
        
        const formatMonth = (dateString) => {
            return new Date(dateString).toLocaleDateString('fr-FR', { month: 'short' });
        };
        
        const formatTime = (timeString) => {
            if (!timeString) return '';
            return new Date(timeString).toLocaleTimeString('fr-FR', {
                hour: '2-digit',
                minute: '2-digit'
            });
        };
        
        const getStatusClass = (status) => {
            const classes = {
                'active': 'status-active',
                'upcoming': 'status-upcoming',
                'completed': 'status-completed',
                'cancelled': 'status-cancelled'
            };
            return classes[status] || 'status-default';
        };
        
        const getStatusLabel = (status) => {
            const labels = {
                'active': 'Actif',
                'upcoming': 'À venir',
                'completed': 'Terminé',
                'cancelled': 'Annulé',
                'draft': 'Brouillon'
            };
            return labels[status] || 'Non défini';
        };
        
        onMounted(() => {
            loadEvents();
        });
        
        return {
            loading,
            isRefreshing,
            events,
            selectedStatus,
            statusFilters,
            filteredEvents,
            goToEvent,
            truncateText,
            formatDay,
            formatMonth,
            formatTime,
            getStatusClass,
            getStatusLabel
        };
    }
};