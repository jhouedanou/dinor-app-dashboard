// Composant Recipe optimisé pour PWA
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
                    <span class="ml-2 text-gray-500">/ Recette</span>
                </div>
            </nav>

            <!-- Contenu -->
            <main class="max-w-4xl mx-auto px-4 py-6">
                <div v-if="loading" class="text-center py-12">
                    <div class="spinner mx-auto"></div>
                    <p class="mt-4 text-gray-600">Chargement de la recette...</p>
                </div>

                <div v-else-if="recipe" class="space-y-6">
                    <!-- Image principale -->
                    <div class="bg-white rounded-lg shadow-lg overflow-hidden">
                        <div class="relative h-64 md:h-96">
                            <img 
                                :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
                                :alt="recipe.title"
                                class="w-full h-full object-cover"
                                loading="eager">
                            <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                            <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
                                <h1 class="text-2xl md:text-4xl font-bold mb-2">{{ recipe.title }}</h1>
                                <p class="text-lg opacity-90">{{ recipe.short_description }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Informations et actions -->
                    <div class="bg-white rounded-lg shadow-lg p-6">
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div class="flex items-center space-x-6">
                                <div class="text-center">
                                    <div class="text-xl font-bold text-yellow-600">{{ recipe.preparation_time }}min</div>
                                    <div class="text-sm text-gray-500">Préparation</div>
                                </div>
                                <div class="text-center">
                                    <div class="text-xl font-bold text-yellow-600">{{ recipe.cooking_time }}min</div>
                                    <div class="text-sm text-gray-500">Cuisson</div>
                                </div>
                                <div class="text-center">
                                    <div class="text-xl font-bold text-yellow-600">{{ recipe.servings }}</div>
                                    <div class="text-sm text-gray-500">Portions</div>
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

                        <!-- Ingrédients -->
                        <div class="mb-8">
                            <h2 class="text-2xl font-bold mb-4">Ingrédients</h2>
                            <ul class="space-y-2">
                                <li v-for="ingredient in recipe.ingredients" :key="ingredient.id" class="flex items-center space-x-2">
                                    <i class="fas fa-check text-yellow-500"></i>
                                    <span>{{ formatIngredient(ingredient) }}</span>
                                </li>
                            </ul>
                        </div>

                        <!-- Instructions -->
                        <div class="mb-8">
                            <h2 class="text-2xl font-bold mb-4">Instructions</h2>
                            <ol class="space-y-4">
                                <li v-for="(instruction, index) in recipe.instructions" :key="index" class="flex space-x-4">
                                    <span class="flex-shrink-0 w-8 h-8 bg-yellow-500 text-white rounded-full flex items-center justify-center font-bold">
                                        {{ index + 1 }}
                                    </span>
                                    <div class="pt-1" v-html="formatInstruction(instruction)"></div>
                                </li>
                            </ol>
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
                                    placeholder="Partagez votre avis sur cette recette..."
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
                        <h2 class="text-2xl font-bold mb-2">Recette non trouvée</h2>
                        <p>La recette que vous recherchez n'existe pas.</p>
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
        const recipe = ref(null);
        const comments = ref([]);
        const likesCount = ref(0);
        const userLiked = ref(false);
        const newComment = ref('');
        
        const { request } = useApi();
        const { toggleLike: toggleLikeApi } = useLikes();
        const { submitComment: submitCommentApi } = useComments();
        
        const loadRecipe = async () => {
            try {
                const data = await request(`/api/v1/recipes/${route.params.id}`);
                if (data.success) {
                    recipe.value = data.data;
                    likesCount.value = data.data.likes_count || 0;
                    loadComments();
                    checkUserLike();
                }
            } catch (error) {
                console.error('Erreur lors du chargement de la recette:', error);
            } finally {
                loading.value = false;
            }
        };
        
        const loadComments = async () => {
            loadingComments.value = true;
            try {
                const data = await request(`/api/v1/comments?type=recipe&id=${route.params.id}`);
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
                const data = await request(`/api/v1/likes/check?type=recipe&id=${route.params.id}`);
                userLiked.value = data.success && data.is_liked;
            } catch (error) {
                console.error('Erreur lors de la vérification du like:', error);
            }
        };
        
        const toggleLike = async () => {
            const result = await toggleLikeApi('recipe', route.params.id);
            if (result.success) {
                userLiked.value = result.action === 'liked';
                likesCount.value = result.likes_count;
            }
        };
        
        const submitComment = async () => {
            if (!newComment.value.trim()) return;
            
            submittingComment.value = true;
            const result = await submitCommentApi('recipe', route.params.id, newComment.value);
            
            if (result.success) {
                comments.value.unshift(result.comment);
                newComment.value = '';
            }
            submittingComment.value = false;
        };
        
        const formatIngredient = (ingredient) => {
            if (typeof ingredient === 'object') {
                return ingredient.quantity && ingredient.unit 
                    ? `${ingredient.quantity} ${ingredient.unit} ${ingredient.name}`
                    : ingredient.name || ingredient;
            }
            return ingredient;
        };
        
        const formatInstruction = (instruction) => {
            return typeof instruction === 'object' ? instruction.step || instruction : instruction;
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
            router.push('/recipes');
        };
        
        onMounted(() => {
            loadRecipe();
        });
        
        return {
            loading,
            loadingComments,
            submittingComment,
            recipe,
            comments,
            likesCount,
            userLiked,
            newComment,
            toggleLike,
            submitComment,
            formatIngredient,
            formatInstruction,
            formatDate,
            goBack
        };
    }
};