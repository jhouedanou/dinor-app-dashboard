const TipsList = {
    template: `
        <div class="tips-container">
            <!-- Header avec titre et recherche -->
            <div class="tips-header">
                <div class="header-content">
                    <h1 class="tips-title">
                        <i class="material-icons">lightbulb</i>
                        Astuces Dinor
                    </h1>
                    <p class="tips-subtitle">Découvrez nos conseils et astuces culinaires</p>
                </div>
                
                <!-- Barre de recherche -->
                <div class="search-container">
                    <div class="search-bar">
                        <i class="material-icons search-icon">search</i>
                        <input 
                            type="text" 
                            v-model="searchQuery" 
                            placeholder="Rechercher une astuce..."
                            class="search-input"
                        >
                        <button v-if="searchQuery" @click="clearSearch" class="clear-search">
                            <i class="material-icons">close</i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Filtres par difficulté -->
            <div class="filter-chips">
                <button 
                    @click="selectedDifficulty = null"
                    :class="['filter-chip', { active: selectedDifficulty === null }]"
                >
                    Toutes
                </button>
                <button 
                    v-for="difficulty in difficulties"
                    :key="difficulty.value"
                    @click="selectedDifficulty = difficulty.value"
                    :class="['filter-chip', { active: selectedDifficulty === difficulty.value }]"
                >
                    {{ difficulty.label }}
                </button>
            </div>

            <!-- Loading state -->
            <div v-if="loading" class="loading-container">
                <div class="loading-spinner">
                    <div class="spinner"></div>
                    <p>Chargement des astuces...</p>
                </div>
            </div>

            <!-- Liste des astuces -->
            <div v-else-if="filteredTips.length > 0" class="tips-grid">
                <div 
                    v-for="tip in filteredTips" 
                    :key="tip.id"
                    class="tip-card"
                    @click="selectTip(tip)"
                >
                    <div class="tip-image-container">
                        <img 
                            :src="tip.image || '/images/tip-placeholder.jpg'" 
                            :alt="tip.title"
                            class="tip-image"
                            loading="lazy"
                        >
                        <div class="tip-difficulty-badge" :class="getDifficultyClass(tip.difficulty_level)">
                            {{ getDifficultyLabel(tip.difficulty_level) }}
                        </div>
                    </div>
                    
                    <div class="tip-content">
                        <h3 class="tip-title">{{ tip.title }}</h3>
                        <p class="tip-excerpt" v-if="tip.content">
                            {{ getExcerpt(tip.content) }}
                        </p>
                        
                        <div class="tip-meta">
                            <div class="tip-time" v-if="tip.estimated_time">
                                <i class="material-icons">schedule</i>
                                {{ tip.estimated_time }} min
                            </div>
                            <div class="tip-category" v-if="tip.category">
                                <i class="material-icons">tag</i>
                                {{ tip.category.name }}
                            </div>
                        </div>
                        
                        <div class="tip-tags" v-if="tip.tags && tip.tags.length > 0">
                            <span v-for="tag in tip.tags.slice(0, 3)" :key="tag" class="tip-tag">
                                {{ tag }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- État vide -->
            <div v-else class="empty-state">
                <div class="empty-icon">
                    <i class="material-icons">lightbulb_outline</i>
                </div>
                <h3>{{ searchQuery ? "Aucune astuce trouvée" : "Aucune astuce disponible" }}</h3>
                <p>{{ searchQuery ? "Essayez avec d'autres mots-clés" : "Les astuces seront ajoutées prochainement" }}</p>
                <button v-if="searchQuery" @click="clearSearch" class="retry-btn">
                    Voir toutes les astuces
                </button>
            </div>
        </div>
    `,
    
    setup() {
        const { ref, computed, onMounted } = Vue;
        
        const tips = ref([]);
        const loading = ref(true);
        const searchQuery = ref('');
        const selectedDifficulty = ref(null);
        
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
            
            // Filtre par difficulté
            if (selectedDifficulty.value) {
                filtered = filtered.filter(tip => tip.difficulty_level === selectedDifficulty.value);
            }
            
            return filtered;
        });

        const loadTips = async () => {
            try {
                loading.value = true;
                const response = await fetch('/api/v1/tips', {
                    headers: {
                        'Content-Type': 'application/json',
                        'Cache-Control': 'no-cache'
                    }
                });
                if (response.ok) {
                    const result = await response.json();
                    if (result.success && result.data) {
                        tips.value = result.data;
                    }
                } else {
                    console.error('Erreur lors du chargement des astuces');
                }
            } catch (error) {
                console.error('Erreur:', error);
            } finally {
                loading.value = false;
            }
        };

        const selectTip = (tip) => {
            // Navigation vers la page détail de l'astuce avec Vue Router
            VueRouter.useRouter().push(`/tip/${tip.id}`);
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

        const getExcerpt = (content) => {
            if (!content) return '';
            const plainText = content.replace(/<[^>]*>/g, '');
            return plainText.length > 120 ? plainText.substring(0, 120) + '...' : plainText;
        };

        const clearSearch = () => {
            searchQuery.value = '';
        };

        onMounted(() => {
            loadTips();
        });

        return {
            tips,
            loading,
            searchQuery,
            selectedDifficulty,
            difficulties,
            filteredTips,
            selectTip,
            getDifficultyClass,
            getDifficultyLabel,
            getExcerpt,
            clearSearch
        };
    }
}; 