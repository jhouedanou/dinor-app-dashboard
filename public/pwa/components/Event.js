// Composant Event optimisé pour PWA
export default {
    template: `
        <div class="min-h-screen bg-gray-50">
            <!-- Navigation -->
            <nav class="nav-bar px-4 py-3">
                <div class="max-w-7xl mx-auto flex items-center">
                    <button @click="goBack" class="text-yellow-600 hover:text-yellow-700 mr-4">
                        <i class="fas fa-arrow-left"></i>
                    </button>
                    <h1 class="text-xl font-bold text-yellow-600">Dinor</h1>
                    <span class="ml-2 text-gray-500">/ Événement</span>
                </div>
            </nav>

            <!-- Contenu -->
            <main class="max-w-4xl mx-auto px-4 py-6">
                <div v-if="loading" class="text-center py-12">
                    <div class="spinner mx-auto"></div>
                    <p class="mt-4 text-gray-600">Chargement de l'événement...</p>
                </div>

                <div v-else-if="event" class="space-y-6">
                    <!-- En-tête -->
                    <div class="bg-white rounded-lg shadow-lg overflow-hidden">
                        <div class="relative h-64 md:h-96">
                            <img 
                                :src="event.featured_image_url || '/images/default-event.jpg'" 
                                :alt="event.title"
                                class="w-full h-full object-cover"
                                loading="eager">
                            <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                            <div class="absolute top-4 right-4">
                                <span :class="getStatusClass(event.status)" class="px-3 py-1 rounded-full text-sm font-bold">
                                    {{ getStatusLabel(event.status) }}
                                </span>
                            </div>
                            <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
                                <h1 class="text-2xl md:text-4xl font-bold mb-2">{{ event.title }}</h1>
                                <p class="text-lg opacity-90">{{ event.short_description }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Informations -->
                    <div class="bg-white rounded-lg shadow-lg p-6">
                        <div class="grid md:grid-cols-2 gap-8">
                            <!-- Détails -->
                            <div class="space-y-6">
                                <div>
                                    <h2 class="text-2xl font-bold mb-4">Détails de l'événement</h2>
                                    <div class="space-y-3">
                                        <div class="flex items-center space-x-3">
                                            <i class="fas fa-calendar text-yellow-500"></i>
                                            <span>{{ formatDate(event.start_date) }}</span>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <i class="fas fa-clock text-yellow-500"></i>
                                            <span>{{ formatTime(event.start_time) }} - {{ formatTime(event.end_time) }}</span>
                                        </div>
                                        <div v-if="event.location" class="flex items-center space-x-3">
                                            <i class="fas fa-map-marker-alt text-yellow-500"></i>
                                            <span>{{ event.location }}</span>
                                        </div>
                                        <div v-if="event.is_online" class="flex items-center space-x-3">
                                            <i class="fas fa-laptop text-yellow-500"></i>
                                            <span>Événement en ligne</span>
                                        </div>
                                        <div v-if="event.price && !event.is_free" class="flex items-center space-x-3">
                                            <i class="fas fa-euro-sign text-yellow-500"></i>
                                            <span>{{ event.price }} €</span>
                                        </div>
                                        <div v-if="event.is_free" class="flex items-center space-x-3">
                                            <i class="fas fa-gift text-green-500"></i>
                                            <span class="text-green-600 font-medium">Gratuit</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Organisateur -->
                                <div v-if="event.organizer_name">
                                    <h3 class="text-lg font-semibold mb-2">Organisateur</h3>
                                    <div class="space-y-2">
                                        <p class="font-medium">{{ event.organizer_name }}</p>
                                        <div v-if="event.organizer_email" class="flex items-center space-x-2">
                                            <i class="fas fa-envelope text-gray-400"></i>
                                            <a :href="'mailto:' + event.organizer_email" class="text-yellow-600 hover:underline">
                                                {{ event.organizer_email }}
                                            </a>
                                        </div>
                                        <div v-if="event.organizer_phone" class="flex items-center space-x-2">
                                            <i class="fas fa-phone text-gray-400"></i>
                                            <span>{{ event.organizer_phone }}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Actions et participation -->
                            <div class="space-y-6">
                                <div class="flex items-center space-x-4">
                                    <button 
                                        @click="toggleLike" 
                                        :class="[
                                            'flex items-center space-x-2 px-4 py-2 rounded-lg border transition-all',
                                            userLiked ? 'bg-red-50 border-red-200 text-red-600' : 'bg-gray-50 border-gray-200 text-gray-600'
                                        ]">
                                        <i class="fas fa-heart"></i>
                                        <span>{{ likesCount }}</span>
                                    </button>
                                    <div class="flex items-center space-x-2 text-gray-600">
                                        <i class="fas fa-comment"></i>
                                        <span>{{ comments.length }} commentaires</span>
                                    </div>
                                </div>

                                <!-- Participation -->
                                <div v-if="event.max_participants" class="bg-gray-50 rounded-lg p-4">
                                    <h3 class="text-lg font-semibold mb-2">Participation</h3>
                                    <div class="space-y-2">
                                        <div class="flex justify-between">
                                            <span>Places disponibles:</span>
                                            <span class="font-medium">{{ event.available_spots }}/{{ event.max_participants }}</span>
                                        </div>
                                        <div class="w-full bg-gray-200 rounded-full h-2">
                                            <div 
                                                class="bg-yellow-500 h-2 rounded-full" 
                                                :style="'width: ' + ((event.current_participants / event.max_participants) * 100) + '%'">
                                            </div>
                                        </div>
                                        <p class="text-sm text-gray-600">{{ event.current_participants }} participants inscrits</p>
                                    </div>
                                </div>

                                <!-- Bouton d'inscription -->
                                <button 
                                    v-if="event.is_registration_open && event.registration_url"
                                    @click="openRegistration"
                                    class="w-full bg-yellow-500 text-white py-3 px-4 rounded-lg font-medium hover:bg-yellow-600 transition-colors">
                                    <i class="fas fa-ticket-alt mr-2"></i>S'inscrire à l'événement
                                </button>
                            </div>
                        </div>

                        <!-- Description complète -->
                        <div v-if="event.description" class="mt-8">
                            <h2 class="text-2xl font-bold mb-4">Description</h2>
                            <div class="prose max-w-none" v-html="event.description"></div>
                        </div>
                    </div>

                    <!-- Commentaires -->
                    <div class="bg-white rounded-lg shadow-lg p-6">
                        <h2 class="text-2xl font-bold mb-6">Commentaires ({{ comments.length }})</h2>
                        
                        <!-- Formulaire -->
                        <div class="border border-gray-200 rounded-lg p-4 bg-gray-50 mb-6">
                            <form @submit.prevent="submitComment">
                                <textarea 
                                    v-model="newComment"
                                    rows="3" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500 mb-3"
                                    placeholder="Partagez votre avis sur cet événement..."
                                    required></textarea>
                                <button 
                                    type="submit" 
                                    :disabled="submittingComment"
                                    class="bg-yellow-500 text-white px-6 py-2 rounded-lg hover:bg-yellow-600 transition-colors disabled:opacity-50">
                                    {{ submittingComment ? 'Publication...' : 'Publier' }}
                                </button>
                            </form>
                        </div>

                        <!-- Liste des commentaires -->
                        <div v-if="loadingComments" class="text-center py-4">
                            <div class="spinner mx-auto"></div>
                        </div>
                        <div v-else class="space-y-4">
                            <div v-for="comment in comments" :key="comment.id" class="border-l-3 border-yellow-400 pl-4">
                                <div class="flex items-start justify-between mb-2">
                                    <div>
                                        <h4 class="font-medium text-gray-900">{{ comment.author_name || comment.user?.name }}</h4>
                                        <p class="text-sm text-gray-500">{{ formatDate(comment.created_at) }}</p>
                                    </div>
                                </div>
                                <p class="text-gray-700">{{ comment.content }}</p>
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
                'active': 'bg-green-500 text-white',
                'cancelled': 'bg-red-500 text-white',
                'completed': 'bg-gray-500 text-white'
            };
            return classes[status] || 'bg-gray-500 text-white';
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
            router.push('/');
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
            goBack
        };
    }
};