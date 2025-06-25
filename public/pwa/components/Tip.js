// Composant Tip optimisé pour PWA
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
                    <span class="ml-2 text-gray-500">/ Astuce</span>
                </div>
            </nav>

            <!-- Contenu -->
            <main class="max-w-4xl mx-auto px-4 py-6">
                <div v-if="loading" class="text-center py-12">
                    <div class="spinner mx-auto"></div>
                    <p class="mt-4 text-gray-600">Chargement de l'astuce...</p>
                </div>

                <div v-else-if="tip" class="space-y-6">
                    <!-- En-tête -->
                    <div class="bg-white rounded-lg shadow-lg overflow-hidden">
                        <div v-if="tip.image_url" class="relative h-64 md:h-96">
                            <img 
                                :src="tip.image_url" 
                                :alt="tip.title"
                                class="w-full h-full object-cover"
                                loading="eager">
                            <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                            <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
                                <h1 class="text-2xl md:text-4xl font-bold">{{ tip.title }}</h1>
                            </div>
                        </div>
                        <div v-else class="p-8 text-center">
                            <div class="inline-flex items-center justify-center w-20 h-20 bg-yellow-100 rounded-full mb-4">
                                <i class="fas fa-lightbulb text-3xl text-yellow-600"></i>
                            </div>
                            <h1 class="text-2xl md:text-4xl font-bold text-gray-900">{{ tip.title }}</h1>
                        </div>
                    </div>

                    <!-- Informations et contenu -->
                    <div class="bg-white rounded-lg shadow-lg p-6">
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div class="flex items-center space-x-6">
                                <div v-if="tip.estimated_time" class="text-center">
                                    <div class="text-xl font-bold text-yellow-600">{{ tip.estimated_time }}min</div>
                                    <div class="text-sm text-gray-500">Temps estimé</div>
                                </div>
                                <div v-if="tip.difficulty_level">
                                    <div class="text-sm text-gray-500 mb-1">Difficulté</div>
                                    <span :class="getDifficultyClass(tip.difficulty_level)" class="px-3 py-1 rounded-full text-sm font-medium">
                                        {{ getDifficultyLabel(tip.difficulty_level) }}
                                    </span>
                                </div>
                                <div v-if="tip.category">
                                    <div class="text-sm text-gray-500 mb-1">Catégorie</div>
                                    <span class="bg-gray-100 text-gray-800 px-3 py-1 rounded-full text-sm font-medium">
                                        {{ tip.category.name }}
                                    </span>
                                </div>
                            </div>
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
                            </div>
                        </div>

                        <!-- Tags -->
                        <div v-if="tip.tags && tip.tags.length > 0" class="mb-6">
                            <div class="flex flex-wrap gap-2">
                                <span v-for="tag in tip.tags" :key="tag" class="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-sm">
                                    #{{ tag }}
                                </span>
                            </div>
                        </div>

                        <!-- Contenu -->
                        <div class="prose max-w-none mb-8" v-html="tip.content"></div>

                        <!-- Vidéo -->
                        <div v-if="tip.video_url" class="mt-8">
                            <h3 class="text-xl font-bold mb-4">Vidéo explicative</h3>
                            <div class="aspect-video">
                                <iframe 
                                    :src="tip.video_url" 
                                    frameborder="0" 
                                    allowfullscreen
                                    class="w-full h-full rounded-lg"
                                    loading="lazy"></iframe>
                            </div>
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
                                    placeholder="Partagez votre avis sur cette astuce..."
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
                        <h2 class="text-2xl font-bold mb-2">Astuce non trouvée</h2>
                        <p>L'astuce que vous recherchez n'existe pas.</p>
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
        const tip = ref(null);
        const comments = ref([]);
        const likesCount = ref(0);
        const userLiked = ref(false);
        const newComment = ref('');
        
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
        
        const checkUserLike = async () => {
            try {
                const data = await request(`/api/v1/likes/check?type=tip&id=${route.params.id}`);
                userLiked.value = data.success && data.data.liked;
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
        
        const getDifficultyClass = (level) => {
            const classes = {
                'easy': 'bg-green-100 text-green-800',
                'medium': 'bg-yellow-100 text-yellow-800',
                'hard': 'bg-red-100 text-red-800'
            };
            return classes[level] || 'bg-green-100 text-green-800';
        };
        
        const getDifficultyLabel = (level) => {
            const labels = {
                'easy': 'Facile',
                'medium': 'Moyen',
                'hard': 'Difficile'
            };
            return labels[level] || 'Non défini';
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
            router.push('/');
        };
        
        onMounted(() => {
            loadTip();
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
            toggleLike,
            submitComment,
            getDifficultyClass,
            getDifficultyLabel,
            formatDate,
            goBack
        };
    }
};