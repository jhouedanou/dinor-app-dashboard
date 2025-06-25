// Composant Event avec Material Design 3 Dinor
const Event = {
    template: `
        <div class="recipe-page event-page">
            <!-- Navigation Material Design -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <button @click="goBack" class="md3-icon-button">
                        <i class="material-icons">arrow_back</i>
                    </button>
                    <div class="md3-app-bar-title">
                        <span class="dinor-text-primary">Dinor</span>
                        <span class="md3-breadcrumb">/ Événement</span>
                    </div>
                    <div class="md3-app-bar-actions">
                        <button @click="shareEvent" class="md3-icon-button">
                            <i class="material-icons">share</i>
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Contenu Material Design -->
            <main class="md3-main-content">
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement de l'événement...</p>
                </div>

                <div v-else-if="event" class="recipe-content">
                    <!-- Hero Image Card -->
                    <div class="md3-card md3-card-filled recipe-hero">
                        <div class="recipe-hero-image">
                            <img 
                                :src="event.featured_image_url || '/images/default-event.jpg'" 
                                :alt="event.title"
                                class="hero-image"
                                loading="eager">
                            <div class="hero-overlay dinor-gradient-primary"></div>
                            <div class="hero-content">
                                <div class="hero-badges" style="position: absolute; top: 0; right: 0; margin: 16px;">
                                    <div class="md3-chip event-status" :class="getStatusClass(event.status)">
                                        <i class="material-icons">event</i>
                                        <span>{{ getStatusLabel(event.status) }}</span>
                                    </div>
                                </div>
                                <h1 class="md3-display-small hero-title">{{ event.title }}</h1>
                                <p class="md3-body-large hero-subtitle">{{ event.short_description }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Détails de l'événement -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">event</i>
                            Détails de l'événement
                        </h2>
                        <div class="event-details">
                            <div class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">calendar_today</i>
                                <span class="md3-body-large">{{ formatDate(event.start_date) }}</span>
                            </div>
                            <div class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">access_time</i>
                                <span class="md3-body-large">{{ formatTime(event.start_time) }} - {{ formatTime(event.end_time) }}</span>
                            </div>
                            <div v-if="event.location" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">location_on</i>
                                <span class="md3-body-large">{{ event.location }}</span>
                            </div>
                            <div v-if="event.is_online" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">computer</i>
                                <span class="md3-body-large">Événement en ligne</span>
                            </div>
                            <div v-if="event.price && !event.is_free" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">euro</i>
                                <span class="md3-body-large">{{ event.price }} €</span>
                            </div>
                            <div v-if="event.is_free" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">card_giftcard</i>
                                <span class="md3-body-large dinor-text-secondary">Gratuit</span>
                            </div>
                        </div>

                        
                        <!-- Organisateur -->
                        <div v-if="event.organizer_name" class="organizer-section">
                            <h3 class="md3-title-large dinor-text-primary">Organisateur</h3>
                            <div class="organizer-details">
                                <p class="md3-body-large font-medium">{{ event.organizer_name }}</p>
                                <div v-if="event.organizer_email" class="event-detail-item">
                                    <i class="material-icons dinor-text-secondary">email</i>
                                    <a :href="'mailto:' + event.organizer_email" class="md3-body-large dinor-text-primary hover:underline">
                                        {{ event.organizer_email }}
                                    </a>
                                </div>
                                <div v-if="event.organizer_phone" class="event-detail-item">
                                    <i class="material-icons dinor-text-secondary">phone</i>
                                    <span class="md3-body-large">{{ event.organizer_phone }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    
                    <!-- Actions et participation -->
                    <div class="content-section">
                        <div class="recipe-actions">
                            <button 
                                @click="toggleLike" 
                                :class="[
                                    'md3-button',
                                    userLiked ? 'md3-button-filled' : 'md3-button-outlined'
                                ]">
                                <i class="material-icons">{{ userLiked ? 'favorite' : 'favorite_border' }}</i>
                                <span>{{ likesCount }}</span>
                            </button>
                            <div class="md3-chip">
                                <i class="material-icons">comment</i>
                                <span>{{ comments.length }} commentaires</span>
                            </div>
                        </div>

                        <!-- Participation -->
                        <div v-if="event.max_participants" class="participation-section">
                            <h3 class="md3-title-large dinor-text-primary">Participation</h3>
                            <div class="participation-stats">
                                <div class="participation-info">
                                    <span class="md3-body-medium">Places disponibles:</span>
                                    <span class="md3-body-medium font-medium">{{ event.available_spots }}/{{ event.max_participants }}</span>
                                </div>
                                <div class="participation-progress">
                                    <div class="progress-bar">
                                        <div 
                                            class="progress-fill" 
                                            :style="'width: ' + ((event.current_participants / event.max_participants) * 100) + '%'">
                                        </div>
                                    </div>
                                </div>
                                <p class="md3-body-small dinor-text-gray">{{ event.current_participants }} participants inscrits</p>
                            </div>
                        </div>

                        <!-- Bouton d'inscription -->
                        <button 
                            v-if="event.is_registration_open && event.registration_url"
                            @click="openRegistration"
                            class="md3-button md3-button-filled registration-button">
                            <i class="material-icons">event_available</i>
                            S'inscrire à l'événement
                        </button>
                    </div>

                    
                    <!-- Description complète -->
                    <div v-if="event.description" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">description</i>
                            Description
                        </h2>
                        <div class="md3-body-large event-description" v-html="event.description"></div>
                    </div>

                    
                    <!-- Commentaires -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">comment</i>
                            Commentaires ({{ comments.length }})
                        </h2>
                        
                        <!-- Formulaire -->
                        <div class="comment-form">
                            <form @submit.prevent="submitComment">
                                <textarea 
                                    v-model="newComment"
                                    rows="3" 
                                    class="md3-text-field"
                                    placeholder="Partagez votre avis sur cet événement..."
                                    required></textarea>
                                <button 
                                    type="submit" 
                                    :disabled="submittingComment"
                                    class="md3-button md3-button-filled">
                                    <i class="material-icons">send</i>
                                    {{ submittingComment ? 'Publication...' : 'Publier' }}
                                </button>
                            </form>
                        </div>

                        <!-- Liste des commentaires -->
                        <div v-if="loadingComments" class="md3-loading-state">
                            <div class="md3-circular-progress"></div>
                        </div>
                        <div v-else class="comments-list">
                            <div v-for="comment in comments" :key="comment.id" class="comment-item">
                                <div class="comment-header">
                                    <h4 class="md3-title-medium">{{ comment.author_name || comment.user?.name }}</h4>
                                    <p class="md3-body-medium dinor-text-gray">{{ formatDate(comment.created_at) }}</p>
                                </div>
                                <p class="md3-body-large comment-content">{{ comment.content }}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else class="text-center py-12">
                    <div class="text-gray-500">
                        <i class="fas fa-exclamation-circle text-4xl mb-4"></i>
                        <h2 class="text-2xl font-bold mb-2">Événement non trouvé</h2>
                        <p>L'événement que vous recherchez n'existe pas.</p>
                        <button @click="goBack" class="inline-block mt-4 bg-yellow-500 text-white px-6 py-2 rounded-lg hover:bg-yellow-600">
                            Retour
                        </button>
                    </div>
                </div>
            </main>
        </div>
    `,
    setup() {
        const { ref, onMounted } = Vue;
        const route = VueRouter.useRoute();
        const router = VueRouter.useRouter();
        
        const loading = ref(true);
        const loadingComments = ref(false);
        const submittingComment = ref(false);
        const event = ref(null);
        const comments = ref([]);
        const likesCount = ref(0);
        const userLiked = ref(false);
        const newComment = ref('');
        
        const { request } = useApi();
        const { toggleLike: toggleLikeApi } = useLikes();
        const { submitComment: submitCommentApi } = useComments();
        
        const loadEvent = async () => {
            try {
                const data = await request(`/api/v1/events/${route.params.id}`);
                if (data.success) {
                    event.value = data.data;
                    likesCount.value = data.data.likes_count || 0;
                    loadComments();
                    checkUserLike();
                }
            } catch (error) {
                console.error('Erreur lors du chargement de l\'événement:', error);
            } finally {
                loading.value = false;
            }
        };
        
        const loadComments = async () => {
            loadingComments.value = true;
            try {
                const data = await request(`/api/v1/comments?type=event&id=${route.params.id}`);
                if (data.success) {
                    comments.value = data.data;
                }
            } catch (error) {
                console.error('Erreur lors du chargement des commentaires:', error);
            } finally {
                loadingComments.value = false;
            }
        };
        
        const checkUserLike = async () => {
            try {
                const data = await request(`/api/v1/likes/check?type=event&id=${route.params.id}`);
                userLiked.value = data.success && data.data.liked;
            } catch (error) {
                console.error('Erreur lors de la vérification du like:', error);
            }
        };
        
        const toggleLike = async () => {
            const result = await toggleLikeApi('event', route.params.id);
            if (result.success) {
                userLiked.value = result.action === 'liked';
                likesCount.value = result.likes_count;
            }
        };
        
        const submitComment = async () => {
            if (!newComment.value.trim()) return;
            
            submittingComment.value = true;
            const result = await submitCommentApi('event', route.params.id, newComment.value);
            
            if (result.success) {
                comments.value.unshift(result.comment);
                newComment.value = '';
            }
            submittingComment.value = false;
        };
        
        const getStatusClass = (status) => {
            const classes = {
                'active': 'event-status-active',
                'cancelled': 'event-status-cancelled', 
                'completed': 'event-status-completed',
                'draft': 'event-status-draft',
                'postponed': 'event-status-postponed'
            };
            return classes[status] || 'event-status-draft';
        };
        
        const getStatusLabel = (status) => {
            const labels = {
                'active': 'Actif',
                'cancelled': 'Annulé',
                'completed': 'Terminé',
                'draft': 'Brouillon',
                'postponed': 'Reporté'
            };
            return labels[status] || 'Non défini';
        };
        
        const formatDate = (dateString) => {
            return new Date(dateString).toLocaleDateString('fr-FR', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        };
        
        const formatTime = (timeString) => {
            if (!timeString) return '';
            return new Date(timeString).toLocaleTimeString('fr-FR', {
                hour: '2-digit',
                minute: '2-digit'
            });
        };
        
        const openRegistration = () => {
            if (event.value?.registration_url) {
                window.open(event.value.registration_url, '_blank');
            }
        };
        
        const goBack = () => {
            router.push('/events');
        };
        
        const shareEvent = () => {
            if (navigator.share && event.value) {
                navigator.share({
                    title: event.value.title,
                    text: event.value.short_description,
                    url: window.location.href
                });
            }
        };
        
        onMounted(() => {
            loadEvent();
        });
        
        return {
            loading,
            loadingComments,
            submittingComment,
            event,
            comments,
            likesCount,
            userLiked,
            newComment,
            toggleLike,
            submitComment,
            getStatusClass,
            getStatusLabel,
            formatDate,
            formatTime,
            openRegistration,
            goBack,
            shareEvent
        };
    }
};