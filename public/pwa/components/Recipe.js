// Composant Recipe avec Material Design Dinor
const Recipe = {
    template: `
        <div class="recipe-page">
            <!-- Navigation Material Design -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <button @click="goBack" class="md3-icon-button">
                        <i class="material-icons">arrow_back</i>
                    </button>
                    <div class="md3-app-bar-title">
                        <span class="dinor-text-primary">Dinor</span>
                        <span class="md3-breadcrumb">/ Recette</span>
                    </div>
                    <div class="md3-app-bar-actions">
                        <button @click="shareRecipe" class="md3-icon-button">
                            <i class="material-icons">share</i>
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Contenu Material Design -->
            <main class="md3-main-content">
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement de la recette...</p>
                </div>

                <div v-else-if="recipe" class="recipe-content">
                    <!-- Hero Image Card -->
                    <div class="md3-card md3-card-filled recipe-hero">
                        <div class="recipe-hero-image">
                            <img 
                                :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
                                :alt="recipe.title"
                                class="hero-image"
                                loading="eager">
                            <div class="hero-overlay dinor-gradient-primary"></div>
                            <div class="hero-content">
                                <h1 class="md3-display-small hero-title">{{ recipe.title }}</h1>
                                <p class="md3-body-large hero-subtitle">{{ recipe.short_description }}</p>
                                <div class="hero-badges">
                                    <div v-if="recipe.difficulty" class="md3-chip recipe-difficulty" :class="getDifficultyClass(recipe.difficulty)">
                                        <i class="material-icons">local_fire_department</i>
                                        <span>{{ getDifficultyLabel(recipe.difficulty) }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Stats Section -->
                    <div class="md3-card md3-card-filled recipe-stats">
                        <div class="stat-item">
                            <i class="material-icons stat-icon">schedule</i>
                            <div class="stat-value">{{ recipe.preparation_time }}min</div>
                            <div class="stat-label">Préparation</div>
                        </div>
                        <div class="stat-item">
                            <i class="material-icons stat-icon">local_fire_department</i>
                            <div class="stat-value">{{ recipe.cooking_time }}min</div>
                            <div class="stat-label">Cuisson</div>
                        </div>
                        <div class="stat-item">
                            <i class="material-icons stat-icon">people</i>
                            <div class="stat-value">{{ recipe.servings }}</div>
                            <div class="stat-label">Portions</div>
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

                    <!-- Ingrédients -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">shopping_cart</i>
                            Ingrédients
                        </h2>
                        <ul class="md3-list">
                            <li v-for="ingredient in recipe.ingredients" :key="ingredient.id" class="md3-list-item">
                                <i class="material-icons dinor-text-secondary">check_circle</i>
                                <span class="md3-body-large">{{ formatIngredient(ingredient) }}</span>
                            </li>
                        </ul>
                    </div>

                    <!-- Instructions -->
                    <div class="content-section">
                        <h2 class="section-title">
                            <i class="material-icons">receipt</i>
                            Instructions
                        </h2>
                        <ol class="instruction-list">
                            <li v-for="(instruction, index) in recipe.instructions" :key="index" class="instruction-item">
                                <div class="instruction-number">{{ index + 1 }}</div>
                                <div class="instruction-content md3-body-large" v-html="formatInstruction(instruction)"></div>
                            </li>
                        </ol>
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
                                    placeholder="Partagez votre avis sur cette recette..."
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
        
        const shareRecipe = () => {
            if (navigator.share && recipe.value) {
                navigator.share({
                    title: recipe.value.title,
                    text: recipe.value.short_description,
                    url: window.location.href
                });
            }
        };
        
        const getDifficultyClass = (difficulty) => {
            const level = typeof difficulty === 'string' ? difficulty.toLowerCase() : 'medium';
            return `difficulty-${level}`;
        };
        
        const getDifficultyLabel = (difficulty) => {
            const labels = {
                'easy': 'Facile',
                'medium': 'Moyen',
                'hard': 'Difficile'
            };
            const level = typeof difficulty === 'string' ? difficulty.toLowerCase() : 'medium';
            return labels[level] || 'Moyen';
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
            goBack,
            shareRecipe,
            getDifficultyClass,
            getDifficultyLabel
        };
    }
};