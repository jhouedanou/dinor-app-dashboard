// Composant Liste des Événements
const EventsList = {
    template: `
        <div class="events-page">
            <!-- Header -->
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fas fa-calendar-alt mr-2"></i>
                    Événements
                </h1>
            </div>

            <!-- Filtres de statut -->
            <div class="filters-container">
                <div class="filters-scroll">
                    <button 
                        @click="selectedStatus = null"
                        :class="['filter-chip', { 'filter-active': !selectedStatus }]">
                        Tous
                    </button>
                    <button 
                        v-for="status in statusFilters"
                        :key="status.value"
                        @click="selectedStatus = status.value"
                        :class="['filter-chip', { 'filter-active': selectedStatus === status.value }]">
                        {{ status.label }}
                    </button>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="loading" class="loading-container">
                <div class="spinner"></div>
                <p class="loading-text">Chargement des événements...</p>
            </div>

            <!-- Liste des événements -->
            <div v-else-if="filteredEvents.length > 0" class="events-list">
                <div 
                    v-for="event in filteredEvents" 
                    :key="event.id"
                    @click="goToEvent(event.id)"
                    class="event-card card-hover">
                    <div class="event-header">
                        <div class="event-date">
                            <div class="date-day">{{ formatDay(event.start_date) }}</div>
                            <div class="date-month">{{ formatMonth(event.start_date) }}</div>
                        </div>
                        <div class="event-status">
                            <span :class="getStatusClass(event.status)" class="status-badge">
                                {{ getStatusLabel(event.status) }}
                            </span>
                        </div>
                    </div>
                    
                    <div class="event-content">
                        <h3 class="event-title">{{ event.title }}</h3>
                        <p class="event-description">{{ truncateText(event.short_description, 100) }}</p>
                        
                        <div class="event-details">
                            <div class="event-time">
                                <i class="fas fa-clock"></i>
                                <span>{{ formatTime(event.start_time) }}</span>
                                <span v-if="event.end_time">- {{ formatTime(event.end_time) }}</span>
                            </div>
                            
                            <div v-if="event.location" class="event-location">
                                <i class="fas fa-map-marker-alt"></i>
                                <span>{{ event.location }}</span>
                            </div>
                            
                            <div v-if="event.is_online" class="event-online">
                                <i class="fas fa-laptop"></i>
                                <span>Événement en ligne</span>
                            </div>
                        </div>
                        
                        <div class="event-footer">
                            <div class="event-price">
                                <span v-if="event.is_free" class="price-free">Gratuit</span>
                                <span v-else-if="event.price" class="price">{{ event.price }}€</span>
                            </div>
                            
                            <div class="event-participants" v-if="event.max_participants">
                                <i class="fas fa-users"></i>
                                <span>{{ event.current_participants || 0 }}/{{ event.max_participants }}</span>
                            </div>
                            
                            <div class="event-likes">
                                <i class="fas fa-heart"></i>
                                <span>{{ event.likes_count || 0 }}</span>
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