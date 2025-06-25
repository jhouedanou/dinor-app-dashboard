// Composant Liste des Recettes optimisé
const RecipesList = {
    template: `
        <div class="recipes-page recipe-page">
            <!-- Top App Bar Material Design 3 -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <div class="md3-app-bar-title">
                        <i class="material-icons dinor-text-primary">restaurant</i>
                        <span class="dinor-text-primary">Recettes</span>
                    </div>
                    <div class="md3-app-bar-actions">
                        <button @click="toggleSearch" class="md3-icon-button">
                            <i class="material-icons">search</i>
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Search Bar -->
            <div v-if="showSearch" class="md3-search-container">
                <div class="md3-search-bar">
                    <i class="material-icons search-icon dinor-text-secondary">search</i>
                    <input 
                        v-model="searchQuery"
                        @input="debouncedSearch"
                        type="text" 
                        placeholder="Rechercher une recette..."
                        class="md3-search-input">
                    <button 
                        v-if="searchQuery" 
                        @click="clearSearch"
                        class="md3-icon-button">
                        <i class="material-icons">clear</i>
                    </button>
                </div>
            </div>

            <!-- Filtres rapides -->
            <div class="md3-filter-container" v-if="categories.length > 0">
                <div class="md3-filter-scroll">
                    <button 
                        @click="selectedCategory = null"
                        :class="['md3-chip', { 'md3-chip-selected': !selectedCategory }]">
                        Toutes
                    </button>
                    <button 
                        v-for="category in categories"
                        :key="category.id"
                        @click="selectedCategory = category.id"
                        :class="['md3-chip', { 'md3-chip-selected': selectedCategory === category.id }]">
                        {{ category.name }}
                    </button>
                </div>
            </div>

            <!-- Main Content -->
            <main class="md3-main-content">
                <!-- Loading -->
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement des recettes...</p>
                </div>

            <!-- Liste des recettes -->
            <div v-else-if="filteredRecipes.length > 0" class="recipes-grid">
                <div 
                    v-for="recipe in filteredRecipes" 
                    :key="recipe.id"
                    @click="goToRecipe(recipe.id)"
                    class="recipe-card card-hover">
                    <div class="recipe-image-container">
                        <img 
                            :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
                            :alt="recipe.title"
                            class="recipe-image"
                            loading="lazy"
                            @error="handleImageError">
                        <div class="recipe-overlay">
                            <div class="recipe-info">
                                <h3 class="recipe-title">{{ recipe.title }}</h3>
                                <p class="recipe-description">{{ truncateText(recipe.short_description, 80) }}</p>
                            </div>
                        </div>
                        <div class="recipe-badges">
                            <span v-if="recipe.difficulty" class="difficulty-badge" :class="getDifficultyClass(recipe.difficulty)">
                                {{ getDifficultyLabel(recipe.difficulty) }}
                            </span>
                        </div>
                    </div>
                    <div class="recipe-details">
                        <div class="recipe-stats">
                            <span class="stat">
                                <i class="fas fa-clock"></i>
                                {{ recipe.preparation_time }}min
                            </span>
                            <span class="stat">
                                <i class="fas fa-users"></i>
                                {{ recipe.servings }}
                            </span>
                            <span class="stat">
                                <i class="fas fa-heart"></i>
                                {{ recipe.likes_count || 0 }}
                            </span>
                        </div>
                        <div v-if="recipe.category" class="recipe-category">
                            {{ recipe.category.name }}
                        </div>
                    </div>
                </div>
            </div>

            <!-- État vide -->
            <div v-else class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-utensils"></i>
                </div>
                <h3 class="empty-title">{{ searchQuery ? 'Aucune recette trouvée' : 'Aucune recette disponible' }}</h3>
                <p class="empty-description">
                    {{ searchQuery ? 
                        "Essayez avec d'autres mots-clés" : 
                        "Les recettes apparaîtront ici bientôt" 
                    }}
                </p>
                <button v-if="searchQuery" @click="clearSearch" class="btn-primary">
                    Voir toutes les recettes
                </button>
            </div>

            <!-- Pull to refresh indicator -->
            <div v-if="isRefreshing" class="refresh-indicator">
                <div class="spinner"></div>
                <span>Actualisation...</span>
            </div>
        </div>
    `,
    setup() {
        const { ref, computed, onMounted, watch } = Vue;
        const router = VueRouter.useRouter();
        
        const loading = ref(true);
        const isRefreshing = ref(false);
        const recipes = ref([]);
        const categories = ref([]);
        const searchQuery = ref('');
        const selectedCategory = ref(null);
        
        const { request } = useApi();
        
        const filteredRecipes = computed(() => {
            let filtered = recipes.value;
            
            // Filtrer par catégorie
            if (selectedCategory.value) {
                filtered = filtered.filter(recipe => 
                    recipe.category && recipe.category.id === selectedCategory.value
                );
            }
            
            // Filtrer par recherche
            if (searchQuery.value) {
                const query = searchQuery.value.toLowerCase();
                filtered = filtered.filter(recipe => 
                    recipe.title.toLowerCase().includes(query) ||
                    recipe.short_description.toLowerCase().includes(query) ||
                    (recipe.category && recipe.category.name.toLowerCase().includes(query))
                );
            }
            
            return filtered;
        });
        
        const debouncedSearch = debounce(() => {
            // La recherche est automatique grâce au computed
        }, 300);
        
        const loadRecipes = async (refresh = false) => {
            if (refresh) {
                isRefreshing.value = true;
            } else {
                loading.value = true;
            }
            
            try {
                const [recipesData, categoriesData] = await Promise.all([
                    request('/api/v1/recipes'),
                    request('/api/v1/categories?type=recipe')
                ]);
                
                if (recipesData.success) {
                    recipes.value = recipesData.data;
                }
                
                if (categoriesData.success) {
                    categories.value = categoriesData.data;
                }
            } catch (error) {
                console.error('Erreur lors du chargement des recettes:', error);
            } finally {
                loading.value = false;
                isRefreshing.value = false;
            }
        };
        
        const goToRecipe = (id) => {
            router.push(`/recipe/${id}`);
        };
        
        const clearSearch = () => {
            searchQuery.value = '';
        };
        
        const truncateText = (text, length) => {
            if (!text) return '';
            return text.length > length ? text.substring(0, length) + '...' : text;
        };
        
        const getDifficultyClass = (difficulty) => {
            const classes = {
                'easy': 'difficulty-easy',
                'medium': 'difficulty-medium',
                'hard': 'difficulty-hard'
            };
            return classes[difficulty] || 'difficulty-easy';
        };
        
        const getDifficultyLabel = (difficulty) => {
            const labels = {
                'easy': 'Facile',
                'medium': 'Moyen',
                'hard': 'Difficile'
            };
            return labels[difficulty] || 'Facile';
        };
        
        const handleImageError = (event) => {
            event.target.src = '/images/default-recipe.jpg';
        };
        
        // Pull to refresh
        let startY = 0;
        let isScrolling = false;
        
        const handleTouchStart = (e) => {
            if (window.scrollY === 0) {
                startY = e.touches[0].clientY;
                isScrolling = true;
            }
        };
        
        const handleTouchMove = (e) => {
            if (!isScrolling) return;
            
            const currentY = e.touches[0].clientY;
            const diff = currentY - startY;
            
            if (diff > 100 && !isRefreshing.value) {
                loadRecipes(true);
                isScrolling = false;
            }
        };
        
        onMounted(() => {
            loadRecipes();
            
            // Ajouter les listeners pour pull to refresh
            document.addEventListener('touchstart', handleTouchStart, { passive: true });
            document.addEventListener('touchmove', handleTouchMove, { passive: true });
        });
        
        return {
            loading,
            isRefreshing,
            recipes,
            categories,
            searchQuery,
            selectedCategory,
            filteredRecipes,
            debouncedSearch,
            goToRecipe,
            clearSearch,
            truncateText,
            getDifficultyClass,
            getDifficultyLabel,
            handleImageError
        };
    }
};