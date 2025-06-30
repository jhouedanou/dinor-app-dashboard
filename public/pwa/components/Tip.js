// Composant Tip avec Material Design 3 Dinor
const Tip = {
    template: `
        <div class="recipe-page tip-page">
            <!-- Navigation Material Design -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <button @click="goBack" class="md3-icon-button">
                        <i class="material-icons">arrow_back</i>
                    </button>
                    <div class="md3-app-bar-title">
                        <span class="dinor-text-primary">Dinor</span>
                        <span class="md3-breadcrumb">/ Astuce</span>
                    </div>
                    <div class="md3-app-bar-actions">
                        <button @click="shareTip" class="md3-icon-button">
                            <i class="material-icons">share</i>
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Contenu Material Design -->
            <main class="md3-main-content">
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement de l'astuce...</p>
                </div>

                <div v-else-if="tip" class="recipe-content">
                    <!-- Hero Image Card -->
                    <div class="md3-card md3-card-filled recipe-hero">
                        <div class="recipe-hero-image">
                            <img 
                                :src="tip.image_url || '/images/default-recipe.jpg'" 
                                :alt="tip.title"
                                class="hero-image"
                                loading="eager">
                            <div class="hero-overlay dinor-gradient-primary"></div>
                            <div class="hero-content">
                                <h1 class="md3-display-small hero-title">{{ tip.title }}</h1>
                                <p v-if="tip.short_description" class="md3-body-large hero-subtitle">{{ tip.short_description }}</p>
                                <div class="hero-badges">
                                    <div v-if="tip.difficulty_level" class="md3-chip tip-difficulty" :class="getDifficultyClass(tip.difficulty_level)">
                                        <i class="material-icons">lightbulb</i>
                                        <span>{{ getDifficultyLabel(tip.difficulty_level) }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Stats Section -->
                    <div class="md3-card md3-card-filled recipe-stats">
                        <div v-if="tip.estimated_time" class="stat-item">
                            <i class="material-icons stat-icon">schedule</i>
                            <div class="stat-value">{{ tip.estimated_time }}min</div>
                            <div class="stat-label">Temps estimé</div>
                        </div>
                        <div v-if="tip.category" class="stat-item">
                            <i class="material-icons stat-icon">category</i>
                            <div class="stat-value">{{ tip.category.name }}</div>
                            <div class="stat-label">Catégorie</div>
                        </div>
                        <div v-if="tip.difficulty_level" class="stat-item">
                            <i class="material-icons stat-icon">trending_up</i>
                            <div class="stat-value">{{ getDifficultyLabel(tip.difficulty_level) }}</div>
                            <div class="stat-label">Difficulté</div>
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

                    <!-- Tags -->
                    <div v-if="tip.tags && tip.tags.length > 0" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">tag</i>
                            Tags
                        </h2>
                        <div class="tags-container">
                            <span v-for="tag in tip.tags" :key="tag" class="md3-chip tag-chip">
                                <span>#{{ tag }}</span>
                            </span>
                        </div>
                    </div>

                    <!-- Contenu principal -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">description</i>
                            Contenu de l'astuce
                        </h2>
                        <div class="tip-content md3-body-large" v-html="tip.content"></div>
                    </div>

                    <!-- Vidéo principale -->
                    <div v-if="tip.video_url" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">play_circle</i>
                            Vidéo explicative
                        </h2>
                        <div class="video-player-container">
                            <div v-if="!videoPlayerActive" class="video-poster" @click="toggleVideoPlayer">
                                <img 
                                    :src="getVideoThumbnail(tip.video_url)" 
                                    :alt="tip.title"
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
                                :src="getEmbedUrl(tip.video_url)"
                                class="video-iframe"
                                frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen>
                            </iframe>
                        </div>
                    </div>

                    <!-- Carousel d'autres vidéos similaires -->
                    <div v-if="relatedVideos.length > 0" class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">video_library</i>
                            Autres astuces vidéo
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
                                                :src="video.image_url || getVideoThumbnail(video.video_url)" 
                                                :alt="video.title"
                                                class="thumbnail-image">
                                            <div class="play-overlay">
                                                <i class="material-icons">play_arrow</i>
                                            </div>
                                        </div>
                                        <div class="video-details">
                                            <h4 class="video-title">{{ truncateText(video.title, 50) }}</h4>
                                            <p class="video-meta">{{ getDifficultyLabel(video.difficulty_level) }}</p>
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
                                    placeholder="Partagez votre avis sur cette astuce..."
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
                        <i class="material-icons">lightbulb</i>
                    </div>
                    <h2 class="empty-title">Astuce non trouvée</h2>
                    <p class="empty-description">L'astuce que vous recherchez n'existe pas.</p>
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
        const tip = ref(null);
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
        
        const loadTip = async () => {
            try {
                const data = await request(`/api/v1/tips/${route.params.id}`);
                if (data.success) {
                    tip.value = data.data;
                    likesCount.value = data.data.likes_count || 0;
                    loadComments();
                    checkUserLike();
                    loadRelatedVideos();
                }
            } catch (error) {
                console.error('Erreur lors du chargement de l\'astuce:', error);
            } finally {
                loading.value = false;
            }
        };
        
        const loadComments = async () => {
            loadingComments.value = true;
            try {
                const data = await request(`/api/v1/comments?type=tip&id=${route.params.id}`);
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
                const data = await request(`/api/v1/tips?has_video=1&limit=10`);
                if (data.success) {
                    // Exclure l'astuce actuelle
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
                const data = await request(`/api/v1/likes/check?type=tip&id=${route.params.id}`);
                userLiked.value = data.success && data.is_liked;
            } catch (error) {
                console.error('Erreur lors de la vérification du like:', error);
            }
        };
        
        const toggleLike = async () => {
            const result = await toggleLikeApi('tip', route.params.id);
            if (result.success) {
                userLiked.value = result.action === 'liked';
                likesCount.value = result.likes_count;
            }
        };
        
        const submitComment = async () => {
            if (!newComment.value.trim()) return;
            
            submittingComment.value = true;
            const result = await submitCommentApi('tip', route.params.id, newComment.value);
            
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
            router.push(`/tips/${video.id}`);
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
        
        const getDifficultyClass = (level) => {
            const classes = {
                'easy': 'difficulty-easy',
                'medium': 'difficulty-medium', 
                'hard': 'difficulty-hard'
            };
            return classes[level] || 'difficulty-medium';
        };
        
        const getDifficultyLabel = (level) => {
            const labels = {
                'easy': 'Facile',
                'medium': 'Moyen',
                'hard': 'Difficile'
            };
            return labels[level] || 'Moyen';
        };
        
        const formatDate = (dateString) => {
            return new Date(dateString).toLocaleDateString('fr-FR', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        };
        
        const goBack = () => {
            router.push('/tips');
        };
        
        const shareTip = () => {
            if (navigator.share && tip.value) {
                navigator.share({
                    title: tip.value.title,
                    text: tip.value.short_description || tip.value.title,
                    url: window.location.href
                });
            }
        };
        
        onMounted(() => {
            loadTip();
            
            // Écouter les événements de scroll pour les boutons carousel
            if (carouselTrack.value) {
                carouselTrack.value.addEventListener('scroll', updateCarouselButtons);
            }
        });
        
        return {
            loading,
            loadingComments,
            submittingComment,
            tip,
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
            getDifficultyClass,
            getDifficultyLabel,
            formatDate,
            goBack,
            shareTip
        };
    }
};