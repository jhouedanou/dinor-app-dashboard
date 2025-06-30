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
                                <p v-if="event.short_description" class="md3-body-large hero-subtitle">{{ event.short_description }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Stats Section - Informations de l'événement -->
                    <div class="md3-card md3-card-filled recipe-stats event-stats">
                        <div class="stat-item">
                            <i class="material-icons stat-icon">calendar_today</i>
                            <div class="stat-value">{{ formatDate(event.start_date) }}</div>
                            <div class="stat-label">Date</div>
                        </div>
                        <div class="stat-item">
                            <i class="material-icons stat-icon">access_time</i>
                            <div class="stat-value">{{ formatTime(event.start_time) }}</div>
                            <div class="stat-label">Heure</div>
                        </div>
                        <div v-if="event.location" class="stat-item">
                            <i class="material-icons stat-icon">location_on</i>
                            <div class="stat-value">{{ truncateText(event.location, 20) }}</div>
                            <div class="stat-label">Lieu</div>
                        </div>
                        <div class="stat-item">
                            <button 
                                @click="toggleLike" 
                                :class="[
                                    'md3-button',
                                    userLiked ? 'md3-button-filled' : 'md3-button-outlined'
                                ]">
                                <i class="material-icons">{{ userLiked ? 'favorite' : 'favorite_border' }}</i>
                                <span>{{ likesCount }}</span>
                            </button>
                        </div>
                    </div>

                    <!-- Détails de l'événement -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">event</i>
                            Détails de l'événement
                        </h2>
                        <div class="event-details-grid">
                            <div class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">calendar_today</i>
                                <div class="detail-content">
                                    <span class="detail-label">Date</span>
                                    <span class="detail-value">{{ formatDate(event.start_date) }}</span>
                                </div>
                            </div>
                            <div class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">access_time</i>
                                <div class="detail-content">
                                    <span class="detail-label">Horaires</span>
                                    <span class="detail-value">{{ formatTime(event.start_time) }} - {{ formatTime(event.end_time) }}</span>
                                </div>
                            </div>
                            <div v-if="event.location" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">location_on</i>
                                <div class="detail-content">
                                    <span class="detail-label">Lieu</span>
                                    <span class="detail-value">{{ event.location }}</span>
                                </div>
                            </div>
                            <div v-if="event.is_online" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">computer</i>
                                <div class="detail-content">
                                    <span class="detail-label">Format</span>
                                    <span class="detail-value">Événement en ligne</span>
                                </div>
                            </div>
                            <div v-if="event.price && !event.is_free" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">euro</i>
                                <div class="detail-content">
                                    <span class="detail-label">Prix</span>
                                    <span class="detail-value">{{ event.price }} €</span>
                                </div>
                            </div>
                            <div v-if="event.is_free" class="event-detail-item">
                                <i class="material-icons dinor-text-secondary">card_giftcard</i>
                                <div class="detail-content">
                                    <span class="detail-label">Prix</span>
                                    <span class="detail-value dinor-text-secondary">Gratuit</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Organisateur -->
                    <div v-if="event.organizer_name" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">person</i>
                            Organisateur
                        </h2>
                        <div class="organizer-card">
                            <div class="organizer-info">
                                <h3 class="md3-title-large">{{ event.organizer_name }}</h3>
                                <div v-if="event.organizer_email" class="contact-item">
                                    <i class="material-icons dinor-text-secondary">email</i>
                                    <a :href="'mailto:' + event.organizer_email" class="md3-body-large dinor-text-primary">
                                        {{ event.organizer_email }}
                                    </a>
                                </div>
                                <div v-if="event.organizer_phone" class="contact-item">
                                    <i class="material-icons dinor-text-secondary">phone</i>
                                    <span class="md3-body-large">{{ event.organizer_phone }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Participation -->
                    <div v-if="event.max_participants" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">group</i>
                            Participation
                        </h2>
                        <div class="participation-card">
                            <div class="participation-stats">
                                <div class="participation-numbers">
                                    <div class="participation-stat">
                                        <span class="stat-number">{{ event.current_participants || 0 }}</span>
                                        <span class="stat-label">Inscrits</span>
                                    </div>
                                    <div class="participation-stat">
                                        <span class="stat-number">{{ event.available_spots || event.max_participants }}</span>
                                        <span class="stat-label">Places disponibles</span>
                                    </div>
                                    <div class="participation-stat">
                                        <span class="stat-number">{{ event.max_participants }}</span>
                                        <span class="stat-label">Maximum</span>
                                    </div>
                                </div>
                                <div class="participation-progress">
                                    <div class="progress-bar">
                                        <div 
                                            class="progress-fill" 
                                            :style="'width: ' + ((event.current_participants / event.max_participants) * 100) + '%'">
                                        </div>
                                    </div>
                                    <p class="progress-text">{{ Math.round((event.current_participants / event.max_participants) * 100) }}% complet</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Bouton d'inscription -->
                    <div v-if="event.is_registration_open && event.registration_url" class="content-section">
                        <div class="registration-section">
                            <button 
                                @click="openRegistration"
                                class="md3-button md3-button-filled registration-button">
                                <i class="material-icons">event_available</i>
                                S'inscrire à l'événement
                            </button>
                        </div>
                    </div>

                    <!-- Description complète -->
                    <div v-if="event.description" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">description</i>
                            Description
                        </h2>
                        <div class="event-description md3-body-large" v-html="event.description"></div>
                    </div>

                    <!-- Vidéo principale -->
                    <div v-if="event.video_url" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">play_circle</i>
                            Vidéo de présentation
                        </h2>
                        <div class="video-player-container">
                            <div v-if="!videoPlayerActive" class="video-poster" @click="toggleVideoPlayer">
                                <img 
                                    :src="getVideoThumbnail(event.video_url)" 
                                    :alt="event.title"
                                    class="poster-image">
                                <div class="play-button-overlay">
                                    <div class="play-button">
                                        <i class="material-icons">play_arrow</i>
                                    </div>
                                    <div class="play-text">Cliquer pour regarder</div>
                                </div>
                            </div>
                            <iframe 
                                v-if="videoPlayerActive"
                                :src="getEmbedUrl(event.video_url)"
                                class="video-iframe"
                                frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen>
                            </iframe>
                        </div>
                    </div>

                    <!-- Carousel d'autres événements vidéo -->
                    <div v-if="relatedVideos.length > 0" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">video_library</i>
                            Autres événements en vidéo
                        </h2>
                        <div class="video-carousel">
                            <div class="carousel-container">
                                <button @click="scrollCarousel('left')" class="carousel-nav left" :disabled="!canScrollLeft">
                                    <i class="material-icons">chevron_left</i>
                                </button>
                                <div class="carousel-track" ref="carouselTrack">
                                    <div 
                                        v-for="video in relatedVideos" 
                                        :key="video.id"
                                        @click="playRelatedVideo(video)"
                                        class="carousel-item">
                                        <div class="video-thumbnail">
                                            <img 
                                                :src="video.featured_image_url || getVideoThumbnail(video.video_url)" 
                                                :alt="video.title"
                                                class="thumbnail-image">
                                            <div class="play-overlay">
                                                <i class="material-icons">play_arrow</i>
                                            </div>
                                        </div>
                                        <div class="video-details">
                                            <h4 class="video-title">{{ truncateText(video.title, 50) }}</h4>
                                            <p class="video-meta">{{ formatDate(video.start_date) }}</p>
                                        </div>
                                    </div>
                                </div>
                                <button @click="scrollCarousel('right')" class="carousel-nav right" :disabled="!canScrollRight">
                                    <i class="material-icons">chevron_right</i>
                                </button>
                            </div>
                        </div>
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

                <div v-else class="empty-state">
                    <div class="empty-icon">
                        <i class="material-icons">event</i>
                    </div>
                    <h2 class="empty-title">Événement non trouvé</h2>
                    <p class="empty-description">L'événement que vous recherchez n'existe pas.</p>
                    <button @click="goBack" class="md3-button md3-button-filled">
                        <i class="material-icons">arrow_back</i>
                        Retour
                    </button>
                </div>
            </main>
        </div>
    `,
    setup() {
        const { ref, computed, onMounted, nextTick } = Vue;
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
        const videoPlayerActive = ref(false);
        const relatedVideos = ref([]);
        const carouselTrack = ref(null);
        const canScrollLeft = ref(false);
        const canScrollRight = ref(false);
        
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
                    loadRelatedVideos();
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

        const loadRelatedVideos = async () => {
            try {
                const data = await request(`/api/v1/events?has_video=1&limit=10`);
                if (data.success) {
                    // Exclure l'événement actuel
                    relatedVideos.value = data.data.filter(v => v.id !== parseInt(route.params.id));
                    await nextTick();
                    updateCarouselButtons();
                }
            } catch (error) {
                console.error('Erreur lors du chargement des vidéos liées:', error);
            }
        };
        
        const checkUserLike = async () => {
            try {
                const data = await request(`/api/v1/likes/check?type=event&id=${route.params.id}`);
                userLiked.value = data.success && data.is_liked;
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

        const toggleVideoPlayer = () => {
            videoPlayerActive.value = !videoPlayerActive.value;
        };

        const getEmbedUrl = (youtubeUrl) => {
            if (!youtubeUrl) return '';
            
            const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
            const match = youtubeUrl.match(regex);
            
            if (match && match[1]) {
                return `https://www.youtube.com/embed/${match[1]}?autoplay=1&rel=0`;
            }
            
            return youtubeUrl;
        };

        const getVideoThumbnail = (youtubeUrl) => {
            if (!youtubeUrl) return '/images/default-video-thumbnail.jpg';
            
            const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
            const match = youtubeUrl.match(regex);
            
            if (match && match[1]) {
                return `https://img.youtube.com/vi/${match[1]}/maxresdefault.jpg`;
            }
            
            return '/images/default-video-thumbnail.jpg';
        };

        const playRelatedVideo = (video) => {
            router.push(`/events/${video.id}`);
        };

        const scrollCarousel = (direction) => {
            if (!carouselTrack.value) return;
            
            const scrollAmount = 320; // Largeur d'un item + margin
            const currentScroll = carouselTrack.value.scrollLeft;
            
            if (direction === 'left') {
                carouselTrack.value.scrollTo({
                    left: currentScroll - scrollAmount,
                    behavior: 'smooth'
                });
            } else {
                carouselTrack.value.scrollTo({
                    left: currentScroll + scrollAmount,
                    behavior: 'smooth'
                });
            }
            
            setTimeout(updateCarouselButtons, 300);
        };

        const updateCarouselButtons = () => {
            if (!carouselTrack.value) return;
            
            const track = carouselTrack.value;
            canScrollLeft.value = track.scrollLeft > 0;
            canScrollRight.value = track.scrollLeft < track.scrollWidth - track.clientWidth;
        };

        const truncateText = (text, length) => {
            if (!text) return '';
            return text.length > length ? text.slice(0, length) + '...' : text;
        };
        
        const getStatusClass = (status) => {
            const classes = {
                'upcoming': 'status-upcoming',
                'ongoing': 'status-ongoing',
                'completed': 'status-completed',
                'cancelled': 'status-cancelled'
            };
            return classes[status] || 'status-upcoming';
        };
        
        const getStatusLabel = (status) => {
            const labels = {
                'upcoming': 'À venir',
                'ongoing': 'En cours',
                'completed': 'Terminé',
                'cancelled': 'Annulé'
            };
            return labels[status] || 'À venir';
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
            return timeString.slice(0, 5);
        };
        
        const openRegistration = () => {
            if (event.value && event.value.registration_url) {
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
                    text: event.value.short_description || event.value.title,
                    url: window.location.href
                });
            }
        };
        
        onMounted(() => {
            loadEvent();
            
            // Écouter les événements de scroll pour les boutons carousel
            if (carouselTrack.value) {
                carouselTrack.value.addEventListener('scroll', updateCarouselButtons);
            }
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
            videoPlayerActive,
            relatedVideos,
            carouselTrack,
            canScrollLeft,
            canScrollRight,
            toggleLike,
            submitComment,
            toggleVideoPlayer,
            getEmbedUrl,
            getVideoThumbnail,
            playRelatedVideo,
            scrollCarousel,
            truncateText,
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