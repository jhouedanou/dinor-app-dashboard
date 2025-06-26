const TipsList = {
    template: `
        <div class="tips-page recipe-page">
            <!-- Top App Bar Material Design 3 -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <div class="md3-app-bar-title">
                        <i class="material-icons dinor-text-primary">lightbulb</i>
                        <span class="dinor-text-primary">Astuces</span>
                    </div>
                </div>
            </nav>

            <!-- Enhanced Search and Filters -->
            <div class="enhanced-filters">
                <!-- Search Bar -->
                <div class="search-container">
                    <div class="search-input-wrapper">
                        <i class="material-icons search-icon dinor-text-secondary">search</i>
                        <input 
                            v-model="searchQuery"
                            @input="debouncedSearch"
                            type="text" 
                            placeholder="Rechercher une astuce..."
                            class="search-input">
                        <button 
                            v-if="searchQuery" 
                            @click="clearSearch"
                            class="clear-search-btn">
                            <i class="material-icons">clear</i>
                        </button>
                    </div>
                </div>

                <!-- Categories Filter -->
                <div v-if="categories?.length" class="filter-section">
                    <div class="filter-header">
                        <i class="material-icons">category</i>
                        <span>Catégories</span>
                    </div>
                    <div class="filter-chips">
                        <button 
                            @click="selectedCategory = null"
                            :class="['filter-chip', { 'active': selectedCategory === null }]">
                            Toutes
                        </button>
                        <button 
                            v-for="category in categories"
                            :key="category.id"
                            @click="selectedCategory = category.id"
                            :class="['filter-chip', { 'active': selectedCategory === category.id }]">
                            {{ category.name }}
                        </button>
                    </div>
                </div>

                <!-- Difficulty Filter -->
                <div class="filter-section">
                    <div class="filter-header">
                        <i class="material-icons">psychology</i>
                        <span>Niveau de difficulté</span>
                    </div>
                    <div class="filter-chips">
                        <button 
                            @click="selectedDifficulty = null"
                            :class="['filter-chip', { 'active': selectedDifficulty === null }]">
                            Tous
                        </button>
                        <button 
                            v-for="difficulty in difficulties"
                            :key="difficulty.value"
                            @click="selectedDifficulty = difficulty.value"
                            :class="['filter-chip', { 'active': selectedDifficulty === difficulty.value }]">
                            {{ difficulty.label }}
                        </button>
                    </div>
                </div>

                <!-- Results Count -->
                <div v-if="filteredTips.length !== tips.length || searchQuery" class="results-info">
                    {{ filteredTips.length }} astuce{{ filteredTips.length > 1 ? 's' : '' }}
                    <span v-if="searchQuery"> pour "{{ searchQuery }}"</span>
                </div>
            </div>

            <!-- Main Content -->
            <main class="md3-main-content">
                <!-- Loading -->
                <div v-if="loading" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement des astuces...</p>
                </div>

                <!-- Liste des astuces Material Design 3 -->
                <div v-else-if="filteredTips.length > 0" class="md3-recipes-grid">
                    <div 
                        v-for="tip in filteredTips" 
                        :key="tip.id"
                        @click="selectTip(tip)"
                        class="md3-card md3-card-elevated recipe-card-md3">
                        <div class="recipe-image-container">
                            <img 
                                :src="tip.image || '/images/tip-placeholder.jpg'" 
                                :alt="tip.title"
                                class="recipe-image"
                                loading="lazy"
                                @error="handleImageError">
                            <div class="recipe-overlay dinor-gradient-primary">
                                <div class="recipe-badges">
                                    <div v-if="tip.difficulty_level" class="md3-chip recipe-difficulty" :class="getDifficultyClass(tip.difficulty_level)">
                                        <i class="material-icons">lightbulb</i>
                                        <span>{{ getDifficultyLabel(tip.difficulty_level) }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="recipe-content">
                            <h3 class="md3-title-large recipe-title dinor-text-primary">{{ tip.title }}</h3>
                            <p class="md3-body-medium recipe-description dinor-text-gray">{{ truncateText(tip.content, 80) }}</p>
                            <div class="recipe-stats">
                                <div class="stat-item">
                                    <i class="material-icons dinor-text-secondary">schedule</i>
                                    <span class="md3-body-small">{{ tip.estimated_time }}min</span>
                                </div>
                                <div class="stat-item" v-if="tip.category">
                                    <i class="material-icons dinor-text-secondary">tag</i>
                                    <span class="md3-body-small">{{ tip.category.name }}</span>
                                </div>
                                <div class="stat-item">
                                    <i class="material-icons dinor-text-secondary">favorite</i>
                                    <span class="md3-body-small">{{ tip.likes_count || 0 }}</span>
                                </div>
                            </div>
                            <div v-if="tip.tags && tip.tags.length > 0" class="recipe-category">
                                <span v-for="tag in tip.tags.slice(0, 2)" :key="tag" class="md3-chip">{{ tag }}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- État vide -->
                <div v-else class="empty-state">
                    <div class="empty-icon">
                        <i class="material-icons">lightbulb_outline</i>
                    </div>
                    <h3 class="empty-title">{{ searchQuery ? "Aucune astuce trouvée" : "Aucune astuce disponible" }}</h3>
                    <p class="empty-description">
                        {{ searchQuery ? "Essayez avec d'autres mots-clés" : "Les astuces seront ajoutées prochainement" }}
                    </p>
                    <button v-if="searchQuery" @click="clearSearch" class="btn-primary">
                        Voir toutes les astuces
                    </button>
                </div>

                <!-- Pull to refresh indicator -->
                <div v-if="isRefreshing" class="refresh-indicator">
                    <div class="spinner"></div>
                    <span>Actualisation...</span>
                </div>
            </main>
        </div>
    `,
    
    setup() {
        const { ref, computed, onMounted } = Vue;
        const router = VueRouter.useRouter();
        
        const tips = ref([]);
        const categories = ref([]);
        const loading = ref(true);
        const isRefreshing = ref(false);
        const searchQuery = ref('');
        const selectedDifficulty = ref(null);
        const selectedCategory = ref(null);
        
        const { request } = useApi();
        
        const difficulties = [
            { value: 'beginner', label: 'Débutant' },
            { value: 'intermediate', label: 'Intermédiaire' },
            { value: 'advanced', label: 'Avancé' }
        ];

        const filteredTips = computed(() => {
            let filtered = tips.value;
            
            // Filtre par recherche
            if (searchQuery.value.trim()) {
                const query = searchQuery.value.toLowerCase();
                filtered = filtered.filter(tip => 
                    tip.title.toLowerCase().includes(query) ||
                    tip.content.toLowerCase().includes(query) ||
                    (tip.category && tip.category.name.toLowerCase().includes(query)) ||
                    (tip.tags && tip.tags.some(tag => tag.toLowerCase().includes(query)))
                );
            }
            
            // Filtre par catégorie
            if (selectedCategory.value) {
                filtered = filtered.filter(tip => tip.category_id === selectedCategory.value);
            }
            
            // Filtre par difficulté
            if (selectedDifficulty.value) {
                filtered = filtered.filter(tip => tip.difficulty_level === selectedDifficulty.value);
            }
            
            return filtered;
        });

        const debouncedSearch = debounce(() => {
            // La recherche est automatique grâce au computed
        }, 300);
        
        const loadTips = async (refresh = false) => {
            if (refresh) {
                isRefreshing.value = true;
            } else {
                loading.value = true;
            }
            
            try {
                const data = await request('/api/v1/tips');
                if (data.success) {
                    tips.value = data.data;
                }
            } catch (error) {
                console.error('Erreur lors du chargement des astuces:', error);
            } finally {
                loading.value = false;
                isRefreshing.value = false;
            }
        };

        const loadCategories = async () => {
            try {
                const data = await request('/api/v1/categories');
                if (data.success) {
                    categories.value = data.data;
                }
            } catch (error) {
                console.warn('Erreur lors du chargement des catégories:', error);
            }
        };

        const selectTip = (tip) => {
            router.push(`/tip/${tip.id}`);
        };

        const clearSearch = () => {
            searchQuery.value = '';
            selectedCategory.value = null;
            selectedDifficulty.value = null;
        };

        const truncateText = (text, length) => {
            if (!text) return '';
            const plainText = text.replace(/<[^>]*>/g, '');
            return plainText.length > length ? plainText.substring(0, length) + '...' : plainText;
        };

        const getDifficultyClass = (difficulty) => {
            const classes = {
                'beginner': 'difficulty-beginner',
                'intermediate': 'difficulty-intermediate',
                'advanced': 'difficulty-advanced'
            };
            return classes[difficulty] || 'difficulty-beginner';
        };

        const getDifficultyLabel = (difficulty) => {
            const labels = {
                'beginner': 'Débutant',
                'intermediate': 'Intermédiaire',
                'advanced': 'Avancé'
            };
            return labels[difficulty] || 'Débutant';
        };

        const handleImageError = (event) => {
            event.target.src = '/images/default-recipe.jpg';
        };

        onMounted(() => {
            loadTips();
            loadCategories();
        });

        return {
            tips,
            categories,
            loading,
            isRefreshing,
            searchQuery,
            selectedDifficulty,
            selectedCategory,
            difficulties,
            filteredTips,
            debouncedSearch,
            selectTip,
            clearSearch,
            truncateText,
            getDifficultyClass,
            getDifficultyLabel,
            handleImageError
        };
    }
}; 