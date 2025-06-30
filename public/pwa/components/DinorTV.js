// Composant Dinor TV avec Player Intégré
const DinorTV = {
    template: `
        <div class="dinortv-page">
            <!-- Header -->
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fas fa-play-circle mr-2"></i>
                    Dinor TV
                    <span class="new-badge">NEW</span>
                </h1>
                <div class="header-actions">
                    <button @click="refreshVideos" class="refresh-btn" :disabled="loading">
                        <i class="fas fa-refresh" :class="{ 'fa-spin': loading }"></i>
                    </button>
                    <button @click="openYouTubeChannel" class="youtube-btn">
                        <i class="fab fa-youtube"></i>
                        Chaîne
                    </button>
                </div>
            </div>

            <!-- Player principal -->
            <div v-if="currentVideo" class="main-player">
                <div class="video-container">
                    <!-- Player Vidéo Intégré avec Overlay -->
                    <div class="video-player-container" @click="togglePlayer">
                        <div v-if="!playerActive" class="video-poster">
                            <img 
                                :src="currentVideo.thumbnail || getThumbnail(currentVideo.video_url)" 
                                :alt="currentVideo.title"
                                class="poster-image">
                            <div class="play-button-overlay">
                                <div class="play-button">
                                    <i class="fas fa-play"></i>
                                </div>
                                <div class="play-text">Cliquer pour regarder</div>
                            </div>
                        </div>
                        <iframe 
                            v-if="playerActive"
                            :src="getEmbedUrl(currentVideo.video_url)"
                            class="video-iframe"
                            frameborder="0"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                        </iframe>
                    </div>
                </div>
                <div class="video-info">
                    <h2 class="video-title">{{ currentVideo.title }}</h2>
                    <p v-if="currentVideo.description" class="video-description">
                        {{ currentVideo.description }}
                    </p>
                    <div class="video-actions">
                        <button @click="likeVideo" class="action-btn" :class="{ 'liked': currentVideo.liked }">
                            <i class="fas fa-heart"></i>
                            <span>{{ currentVideo.likes_count || 0 }}</span>
                        </button>
                        <button @click="shareVideo" class="action-btn">
                            <i class="fas fa-share"></i>
                            Partager
                        </button>
                        <button @click="openInYouTube" class="action-btn">
                            <i class="fab fa-youtube"></i>
                            YouTube
                        </button>
                    </div>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="loading && !currentVideo" class="loading-container">
                <div class="spinner"></div>
                <p class="loading-text">Chargement des vidéos...</p>
            </div>

            <!-- Liste des vidéos -->
            <div v-else-if="videos.length > 0" class="videos-section">
                <h3 class="section-title">
                    {{ currentVideo ? 'Autres vidéos' : 'Toutes les vidéos' }}
                </h3>
                
                <div class="videos-grid">
                    <div 
                        v-for="video in filteredVideos" 
                        :key="video.id"
                        @click="playVideo(video)"
                        class="video-card card-hover"
                        :class="{ 'video-active': currentVideo && currentVideo.id === video.id }">
                        <div class="video-thumbnail">
                            <img 
                                :src="video.thumbnail || getThumbnail(video.video_url)" 
                                :alt="video.title"
                                class="thumbnail-image"
                                loading="lazy"
                                @error="handleThumbnailError">
                            <div class="play-overlay">
                                <i class="fas fa-play"></i>
                            </div>
                            <div v-if="video.duration" class="video-duration">
                                {{ formatDuration(video.duration) }}
                            </div>
                        </div>
                        <div class="video-details">
                            <h4 class="video-title">{{ truncateText(video.title, 60) }}</h4>
                            <div class="video-meta">
                                <span v-if="video.views" class="views">
                                    <i class="fas fa-eye"></i>
                                    {{ formatViews(video.views) }}
                                </span>
                                <span v-if="video.created_at" class="date">
                                    {{ formatDate(video.created_at) }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- État vide -->
            <div v-else class="empty-state">
                <div class="empty-icon">
                    <i class="fab fa-youtube"></i>
                </div>
                <h3 class="empty-title">Aucune vidéo disponible</h3>
                <p class="empty-description">
                    Les vidéos Dinor TV apparaîtront ici bientôt
                </p>
                <button @click="openYouTubeChannel" class="btn-primary">
                    <i class="fab fa-youtube mr-2"></i>
                    Voir la chaîne YouTube
                </button>
            </div>

            <!-- Modal de partage -->
            <div v-if="showShareModal" class="share-modal" @click="closeShareModal">
                <div class="modal-content" @click.stop>
                    <div class="modal-header">
                        <h3>Partager la vidéo</h3>
                        <button @click="closeShareModal" class="close-btn">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="share-options">
                        <button @click="shareOn('whatsapp')" class="share-btn whatsapp">
                            <i class="fab fa-whatsapp"></i>
                            WhatsApp
                        </button>
                        <button @click="shareOn('facebook')" class="share-btn facebook">
                            <i class="fab fa-facebook"></i>
                            Facebook
                        </button>
                        <button @click="shareOn('twitter')" class="share-btn twitter">
                            <i class="fab fa-twitter"></i>
                            Twitter
                        </button>
                        <button @click="copyLink" class="share-btn copy">
                            <i class="fas fa-link"></i>
                            Copier le lien
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `,
    setup() {
        const { ref, computed, onMounted } = Vue;
        
        const loading = ref(true);
        const videos = ref([]);
        const currentVideo = ref(null);
        const showShareModal = ref(false);
        const playerActive = ref(false);
        
        const { request } = useApi();
        const { toggleLike } = useLikes();
        
        const filteredVideos = computed(() => {
            if (!currentVideo.value) return videos.value;
            return videos.value.filter(video => video.id !== currentVideo.value.id);
        });
        
        const loadVideos = async () => {
            loading.value = true;
            try {
                const data = await request('/api/v1/dinor-tv');
                if (data.success) {
                    videos.value = data.data;
                    // Sélectionner la première vidéo automatiquement
                    if (videos.value.length > 0) {
                        currentVideo.value = videos.value[0];
                    }
                }
            } catch (error) {
                console.error('Erreur lors du chargement des vidéos:', error);
                // Fallback avec des vidéos par défaut
                loadDefaultVideos();
            } finally {
                loading.value = false;
            }
        };
        
        const loadDefaultVideos = () => {
            // Vidéos de démonstration en cas d'échec de l'API
            videos.value = [
                {
                    id: 1,
                    title: 'Recette du jour - Tarte aux pommes',
                    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                    description: 'Découvrez notre délicieuse recette de tarte aux pommes',
                    views: 1250,
                    likes_count: 45,
                    created_at: new Date().toISOString()
                }
            ];
            if (videos.value.length > 0) {
                currentVideo.value = videos.value[0];
            }
        };
        
        const refreshVideos = () => {
            loadVideos();
        };
        
        const playVideo = (video) => {
            currentVideo.value = video;
            playerActive.value = false; // Reset player pour nouvelle vidéo
            
            // Scroll vers le player
            const player = document.querySelector('.main-player');
            if (player) {
                player.scrollIntoView({ behavior: 'smooth' });
            }
        };
        
        const togglePlayer = () => {
            playerActive.value = !playerActive.value;
        };
        
        const getEmbedUrl = (youtubeUrl) => {
            try {
                const url = new URL(youtubeUrl);
                let videoId;
                
                if (url.hostname === 'youtu.be') {
                    videoId = url.pathname.slice(1);
                } else if (url.hostname.includes('youtube.com')) {
                    videoId = url.searchParams.get('v');
                }
                
                if (videoId) {
                    return `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0`;
                }
            } catch (e) {
                console.error('URL YouTube invalide:', youtubeUrl);
            }
            
            return youtubeUrl;
        };
        
        const getThumbnail = (youtubeUrl) => {
            try {
                const url = new URL(youtubeUrl);
                let videoId;
                
                if (url.hostname === 'youtu.be') {
                    videoId = url.pathname.slice(1);
                } else if (url.hostname.includes('youtube.com')) {
                    videoId = url.searchParams.get('v');
                }
                
                if (videoId) {
                    return `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;
                }
            } catch (e) {
                console.error('Impossible de générer la miniature:', youtubeUrl);
            }
            
            return '/images/default-video-thumbnail.jpg';
        };
        
        const likeVideo = async () => {
            if (!currentVideo.value) return;
            
            const result = await toggleLike('dinor_tv', currentVideo.value.id);
            if (result.success) {
                currentVideo.value.liked = result.action === 'liked';
                currentVideo.value.likes_count = result.likes_count;
            }
        };
        
        const shareVideo = () => {
            showShareModal.value = true;
        };
        
        const closeShareModal = () => {
            showShareModal.value = false;
        };
        
        const shareOn = (platform) => {
            if (!currentVideo.value) return;
            
            const url = encodeURIComponent(currentVideo.value.url);
            const text = encodeURIComponent(currentVideo.value.title);
            
            let shareUrl;
            
            switch (platform) {
                case 'whatsapp':
                    shareUrl = `https://wa.me/?text=${text} ${url}`;
                    break;
                case 'facebook':
                    shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${url}`;
                    break;
                case 'twitter':
                    shareUrl = `https://twitter.com/intent/tweet?text=${text}&url=${url}`;
                    break;
            }
            
            if (shareUrl) {
                window.open(shareUrl, '_blank');
            }
            
            closeShareModal();
        };
        
        const copyLink = async () => {
            if (!currentVideo.value) return;
            
            try {
                await navigator.clipboard.writeText(currentVideo.value.url);
                // Feedback visuel
                const btn = document.querySelector('.share-btn.copy');
                if (btn) {
                    const originalText = btn.innerHTML;
                    btn.innerHTML = '<i class="fas fa-check"></i> Copié !';
                    setTimeout(() => {
                        btn.innerHTML = originalText;
                    }, 2000);
                }
            } catch (e) {
                console.error('Impossible de copier le lien');
            }
            
            setTimeout(() => closeShareModal(), 2000);
        };
        
        const openInYouTube = () => {
            if (currentVideo.value) {
                window.open(currentVideo.value.url, '_blank');
            }
        };
        
        const openYouTubeChannel = () => {
            // URL de la chaîne YouTube Dinor (à adapter)
            window.open('https://www.youtube.com/@dinorcuisine', '_blank');
        };
        
        const truncateText = (text, length) => {
            if (!text) return '';
            return text.length > length ? text.substring(0, length) + '...' : text;
        };
        
        const formatDuration = (seconds) => {
            const mins = Math.floor(seconds / 60);
            const secs = seconds % 60;
            return `${mins}:${secs.toString().padStart(2, '0')}`;
        };
        
        const formatViews = (views) => {
            if (views >= 1000000) {
                return (views / 1000000).toFixed(1) + 'M';
            } else if (views >= 1000) {
                return (views / 1000).toFixed(1) + 'K';
            }
            return views.toString();
        };
        
        const formatDate = (dateString) => {
            return new Date(dateString).toLocaleDateString('fr-FR', {
                day: 'numeric',
                month: 'short'
            });
        };
        
        const handleThumbnailError = (event) => {
            event.target.src = '/images/default-video-thumbnail.jpg';
        };
        
        onMounted(() => {
            loadVideos();
        });
        
        return {
            loading,
            videos,
            currentVideo,
            showShareModal,
            playerActive,
            filteredVideos,
            refreshVideos,
            playVideo,
            togglePlayer,
            getEmbedUrl,
            getThumbnail,
            likeVideo,
            shareVideo,
            closeShareModal,
            shareOn,
            copyLink,
            openInYouTube,
            openYouTubeChannel,
            truncateText,
            formatDuration,
            formatViews,
            formatDate,
            handleThumbnailError
        };
    }
};