<template>
  <div class="recipes-list">
    <!-- Bannières pour les recettes -->
    <BannerSection 
      type="recipes" 
      section="hero" 
      :banners="bannersByType"
    />



    <!-- Toggle Filters Button -->
    <div class="filters-toggle">
      <button @click="showFilters = !showFilters" class="toggle-btn">
        <span class="material-symbols-outlined">{{ showFilters ? 'expand_less' : 'expand_more' }}</span>
        <span>{{ showFilters ? 'Masquer les filtres' : 'Afficher les filtres' }}</span>
      </button>
      <button @click="forceRefresh" class="refresh-btn" title="Actualiser les données" :disabled="loading">
        <span class="material-symbols-outlined" :class="{ 'spinning': loading }">refresh</span>
        <span>Actualiser</span>
      </button>
    </div>

    <!-- Search and Filters -->
    <div v-show="showFilters" class="filters-container">
      <SearchAndFilters
        v-model:searchQuery="searchQuery"
        v-model:selectedCategory="selectedCategory"
        search-placeholder="Rechercher une recette..."
        :categories="categories"
        :additional-filters="recipeFilters"
        :selected-filters="selectedFilters"
        :results-count="filteredRecipes.length"
        item-type="recette"
        @update:additionalFilter="updateAdditionalFilter"
      />
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des recettes...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
        <span class="emoji-fallback">❌</span>
      </div>
      <p>{{ error }}</p>
      <button @click="retry" class="retry-btn">
        Réessayer
      </button>
    </div>

    <!-- Content -->
    <div v-else class="content">

      <!-- Results count -->
      <div v-if="filteredRecipes.length" class="results-info">
        {{ filteredRecipes.length }} recette{{ filteredRecipes.length > 1 ? 's' : '' }}
        <span v-if="searchQuery"> pour "{{ searchQuery }}"</span>
      </div>

      <!-- Empty State -->
      <div v-if="!filteredRecipes.length && !loading" class="empty-state">
        <div class="empty-icon">
          <span class="material-symbols-outlined">restaurant</span>
          <span class="emoji-fallback">🍽️</span>
        </div>
        <h3>{{ searchQuery || selectedCategory || hasActiveFilters ? 'Aucune recette trouvée' : 'Aucune recette disponible' }}</h3>
        <p v-if="searchQuery || selectedCategory || hasActiveFilters">
          Essayez de modifier vos critères de recherche.
        </p>
        <p v-else>
          Les recettes seront bientôt disponibles.
        </p>
        <button v-if="searchQuery || selectedCategory || hasActiveFilters" @click="clearAllFilters" class="clear-filters-btn">
          Effacer tous les filtres
        </button>
      </div>

      <!-- Recipes Grid -->
      <div v-else class="recipes-grid">
        <article
          v-for="recipe in filteredRecipes"
          :key="recipe.id"
          @click="goToRecipe(recipe.id)"
          class="recipe-card"
        >
          <div class="recipe-image">
            <img
              :src="recipe.featured_image_url || '/images/default-recipe.jpg'"
              :alt="recipe.title"
              loading="lazy"
            />
            <div class="recipe-overlay">
              <div class="recipe-meta">
                <span v-if="getTotalTime(recipe)" class="time">
                  <span class="material-symbols-outlined">schedule</span>
                  <span class="emoji-fallback">⏱️</span>
                  {{ getTotalTime(recipe) }}min
                </span>
                <span v-if="recipe.difficulty" class="difficulty">
                  {{ getDifficultyLabel(recipe.difficulty) }}
                </span>
              </div>
            </div>
          </div>
          
          <div class="recipe-content">
            <h3 class="recipe-title">{{ recipe.title }}</h3>
            <p v-if="recipe.short_description" class="recipe-description">
              {{ recipe.short_description }}
            </p>
            
            <div class="recipe-stats">
              <div class="stat">
                <LikeButton
                  type="recipe"
                  :item-id="recipe.id"
                  :initial-liked="recipe.is_liked || false"
                  :initial-count="recipe.likes_count || 0"
                  :show-count="true"
                  size="small"
                  variant="minimal"
                  @auth-required="showAuthModal = true"
                  @click.stop=""
                />
              </div>
              <div class="stat">
                <span class="material-symbols-outlined">comment</span>
                <span class="emoji-fallback">💬</span>
                <span>{{ recipe.comments_count || 0 }}</span>
              </div>
              <div v-if="recipe.servings" class="stat">
                <span class="material-symbols-outlined">group</span>
                <span class="emoji-fallback">👥</span>
                <span>{{ recipe.servings }}</span>
              </div>
              <div v-if="recipe.required_equipment?.length" class="stat equipment">
                <span class="material-symbols-outlined">kitchen</span>
                <span class="emoji-fallback">🍳</span>
                <span>{{ recipe.required_equipment.length }} équipement{{ recipe.required_equipment.length > 1 ? 's' : '' }}</span>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
    
    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" />
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipesStore } from '@/stores/recipes'
import { useAppStore } from '@/stores/app'
import { useBanners } from '@/composables/useBanners'
import apiService from '@/services/api'
import BannerSection from '@/components/common/BannerSection.vue'
import SearchAndFilters from '@/components/common/SearchAndFilters.vue'
import LikeButton from '@/components/common/LikeButton.vue'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'RecipesList',
  components: {
    BannerSection,
    SearchAndFilters,
    LikeButton,
    AuthModal
  },
  setup() {
    const router = useRouter()
    const recipesStore = useRecipesStore()
    const appStore = useAppStore()
    
    // Banner management
    const { banners, loadBannersForContentType } = useBanners()
    const bannersByType = computed(() => banners.value)
    
    const loadBanners = async () => {
      try {
        console.log('🍳 [RecipesList] Chargement bannières pour type: recipes')
        await loadBannersForContentType('recipes', true) // Force refresh sans cache
      } catch (error) {
        console.error('Error loading banners:', error)
      }
    }
    
    // Filters visibility toggle - masquer par défaut
    const showFilters = ref(false)
    
    // Auth modal
    const showAuthModal = ref(false)
    
    // Categories management
    const categories = ref([])
    
    const loadCategories = async () => {
      try {
        const response = await apiService.getRecipeCategories()
        if (response.success) {
          categories.value = response.data
        }
      } catch (error) {
        console.error('Error loading categories:', error)
      }
    }
    
    // Computed properties
    const searchQuery = computed({
      get: () => recipesStore.searchQuery,
      set: (value) => recipesStore.setSearchQuery(value)
    })
    
    const selectedCategory = computed({
      get: () => recipesStore.selectedCategory,
      set: (value) => recipesStore.setSelectedCategory(value)
    })
    
    const loading = computed(() => recipesStore.loading)
    const error = computed(() => recipesStore.error)
    
    // Additional filters for recipes
    const selectedFilters = ref({})
    const recipeFilters = [
      {
        key: 'difficulty',
        label: 'Difficulté',
        icon: 'star',
        allLabel: 'Tous niveaux',
        options: [
          { value: 'easy', label: 'Facile' },
          { value: 'medium', label: 'Moyen' },
          { value: 'hard', label: 'Difficile' }
        ]
      },
      {
        key: 'prep_time',
        label: 'Temps de préparation',
        icon: 'schedule',
        allLabel: 'Tous temps',
        options: [
          { value: 'quick', label: '< 30 min' },
          { value: 'medium', label: '30-60 min' },
          { value: 'long', label: '> 60 min' }
        ]
      }
    ]
    
    // Computed avec tous les filtres
    const filteredRecipes = computed(() => {
      let filtered = recipesStore.recipes

      // Filtre par recherche textuelle
      if (searchQuery.value?.trim()) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(recipe =>
          recipe.title?.toLowerCase().includes(query) ||
          recipe.short_description?.toLowerCase().includes(query) ||
          recipe.tags?.some(tag => tag.toLowerCase().includes(query))
        )
      }

      // Filtre par catégorie
      if (selectedCategory.value) {
        filtered = filtered.filter(recipe => recipe.category_id === selectedCategory.value)
      }

      // Filtres additionnels
      if (selectedFilters.value.difficulty) {
        filtered = filtered.filter(recipe => recipe.difficulty === selectedFilters.value.difficulty)
      }

      if (selectedFilters.value.prep_time) {
        const prepTime = selectedFilters.value.prep_time
        filtered = filtered.filter(recipe => {
          const time = recipe.preparation_time || 0
          if (prepTime === 'quick') return time < 30
          if (prepTime === 'medium') return time >= 30 && time <= 60
          if (prepTime === 'long') return time > 60
          return true
        })
      }

      return filtered
    })
    
    const hasActiveFilters = computed(() => {
      return Object.values(selectedFilters.value).some(filter => filter !== null)
    })
    
    // Methods
    const goToRecipe = (id) => {
      router.push(`/recipe/${id}`)
    }
    
    const clearSearch = () => {
      searchQuery.value = ''
    }
    
    const setSelectedCategory = (categoryId) => {
      selectedCategory.value = categoryId
    }
    
    const updateAdditionalFilter = ({ key, value }) => {
      selectedFilters.value[key] = value
    }
    
    const clearAllFilters = () => {
      searchQuery.value = ''
      selectedCategory.value = null
      selectedFilters.value = {}
    }
    
    const retry = () => {
      recipesStore.clearError()
      loadRecipes()
    }
    
    const loadRecipes = async (forceRefresh = false) => {
      if (forceRefresh) {
        console.log('🔄 [RecipesList] Rechargement forcé des recettes')
        recipesStore.clearCache()
        // Aussi vider le cache du service API
        await apiService.clearCache()
      }
      await recipesStore.fetchRecipesFresh()
    }

    const forceRefresh = async () => {
      console.log('🔄 [RecipesList] Rechargement forcé demandé')
      try {
        // Invalider tous les caches
        await apiService.clearCache()
        recipesStore.clearCache()
        
        // Recharger avec les données fraîches
        await recipesStore.fetchRecipesFresh()
        console.log('✅ [RecipesList] Rechargement forcé terminé')
      } catch (error) {
        console.error('❌ [RecipesList] Erreur lors du rechargement forcé:', error)
      }
    }
    
    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'easy': 'Facile',
        'medium': 'Moyen',
        'hard': 'Difficile'
      }
      return labels[difficulty] || difficulty
    }
    
    // Corriger pour afficher le temps de préparation spécifiquement
    const getPreparationTime = (recipe) => {
      return recipe.preparation_time || 0
    }
    
    const getTotalTime = (recipe) => {
      const prepTime = recipe.preparation_time || 0
      const cookTime = recipe.cooking_time || 0
      const restTime = recipe.resting_time || 0
      return prepTime + cookTime + restTime
    }
    
    // Écouter les mises à jour de likes
    const handleLikeUpdate = (event) => {
      const { type, id, liked, count } = event.detail
      if (type === 'recipe') {
        const recipe = filteredRecipes.value.find(r => r.id == id)
        if (recipe) {
          recipe.is_liked = liked
          recipe.likes_count = count
        }
      }
    }

    // Lifecycle
    onMounted(() => {
      loadRecipes()
      loadBanners()
      loadCategories()
      appStore.initializePWAListeners()
      appStore.initializeNetworkListeners()
      window.addEventListener('like-updated', handleLikeUpdate)
    })
    
    onUnmounted(() => {
      window.removeEventListener('like-updated', handleLikeUpdate)
    })
    
    // Watchers
    watch(searchQuery, (newQuery) => {
      // Debounced search could be implemented here
    })
    
    return {
      searchQuery,
      selectedCategory,
      loading,
      error,
      filteredRecipes,
      categories,
      bannersByType,
      selectedFilters,
      recipeFilters,
      hasActiveFilters,
      showFilters,
      goToRecipe,
      clearSearch,
      setSelectedCategory,
      updateAdditionalFilter,
      clearAllFilters,
      retry,
      forceRefresh,
      getDifficultyLabel,
      getPreparationTime,
      getTotalTime,
      showAuthModal
    }
  }
}
</script>

<style scoped>
.recipes-list {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc comme Home */
  font-family: 'Roboto', sans-serif;
}

/* Toggle Filters Button */
.filters-toggle {
  padding: 16px;
  border-bottom: 1px solid #E2E8F0;
  display: flex;
  gap: 12px;
  justify-content: space-between;
  align-items: center;
}

.toggle-btn,
.refresh-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  color: #2D3748;
}

.toggle-btn {
  flex: 1;
}

.refresh-btn {
  background: #4A5568;
  color: #FFFFFF;
  border-color: #4A5568;
}

.toggle-btn:hover {
  background: #F7FAFC;
  border-color: #CBD5E0;
}

.refresh-btn:hover {
  background: #2D3748;
  border-color: #2D3748;
}

.refresh-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.toggle-btn i,
.refresh-btn i {
  font-size: 20px;
  color: #E53E3E;
}

.refresh-btn i {
  color: #FFFFFF;
}

/* Animation de rotation pour le bouton refresh */
.spinning {
  animation: spin-refresh 1s linear infinite;
}

@keyframes spin-refresh {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.filters-container {
  transition: all 0.3s ease;
}



.search-container {
  max-width: 400px;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 16px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  z-index: 1;
}

.search-input {
  width: 100%;
  padding: 16px 48px 16px 48px;
  border: 1px solid var(--md-sys-color-outline, #79747e);
  border-radius: 28px;
  font-size: 16px;
  background: var(--md-sys-color-surface, #fefbff);
  color: var(--md-sys-color-on-surface, #1c1b1f);
  transition: all 0.2s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--md-sys-color-primary, #6750a4);
  box-shadow: 0 0 0 2px var(--md-sys-color-primary-container, #eaddff);
}

.clear-search {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  padding: 4px;
  cursor: pointer;
  border-radius: 50%;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.loading-state,
.error-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 4px solid var(--md-sys-color-primary, #6750a4);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon,
.empty-icon {
  width: 64px;
  height: 64px;
  background: var(--md-sys-color-error-container, #fce8e6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.empty-icon {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
}

.error-icon .material-symbols-outlined,
.empty-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.empty-icon .material-symbols-outlined {
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.content {
  padding: 16px;
}

.filters {
  margin-bottom: 24px;
}

.filter-chips {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 8px;
}

.filter-chip {
  padding: 8px 16px;
  border: 1px solid #E2E8F0;
  border-radius: 20px;
  background: #FFFFFF;
  color: #4A5568; /* Couleur avec bon contraste */
  font-size: 14px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.filter-chip:hover {
  background: #F7FAFC;
  border-color: #E53E3E;
  color: #2D3748;
}

.filter-chip.active {
  background: #F4D03F; /* Fond doré */
  color: #2D3748; /* Couleur foncée pour contraste */
  border-color: #FF6B35; /* Bordure orange */
  font-weight: 600;
}

.results-info {
  margin-bottom: 16px;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.recipes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
  margin-bottom: 2em; /* Ajouter margin-bottom de 2em */
}

.recipe-card {
  background: #FFFFFF; /* Fond blanc */
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #E2E8F0; /* Bordure gris clair */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.recipe-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(229, 62, 62, 0.15); /* Ombre rouge */
  border-color: #E53E3E; /* Bordure rouge au hover */
}

.recipe-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.recipe-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.recipe-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 0%, rgba(0, 0, 0, 0.7) 100%);
  display: flex;
  align-items: flex-end;
  padding: 16px;
}

.recipe-meta {
  display: flex;
  gap: 12px;
  color: white;
  font-size: 14px;
}

.recipe-meta .time,
.recipe-meta .difficulty {
  display: flex;
  align-items: center;
  gap: 4px;
  background: rgba(255, 255, 255, 0.9); /* Fond blanc semi-transparent */
  color: #2D3748; /* Texte foncé pour contraste */
  padding: 4px 8px;
  border-radius: 12px;
}

.recipe-content {
  padding: 16px;
}

.recipe-title {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  font-family: 'Open Sans', sans-serif; /* Police Open Sans pour les titres */
  color: #2D3748; /* Couleur foncée pour bon contraste */
  line-height: 1.3;
}

.recipe-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-family: 'Roboto', sans-serif; /* Police Roboto pour les textes */
  color: #4A5568; /* Couleur grise pour bon contraste */
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.recipe-stats {
  display: flex;
  gap: 16px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.stat .material-symbols-outlined {
  font-size: 18px;
  margin-right: 6px;
  color: #8B7000; /* Couleur dorée pour les icônes */
  font-weight: 500;
  vertical-align: middle;
}

.stat.equipment .material-symbols-outlined {
  color: #FF6B35; /* Orange pour les équipements */
}

.recipe-meta .material-symbols-outlined {
  font-size: 18px;
  margin-right: 4px;
  color: #FFFFFF; /* Blanc pour contraster sur l'overlay */
  font-weight: 600;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
}

/* Système de fallback pour les icônes - logique simplifiée */
.emoji-fallback {
  display: none; /* Masqué par défaut */
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

/* UNIQUEMENT quand .force-emoji est présent sur html, afficher les emoji */
html.force-emoji .material-symbols-outlined {
  display: none !important;
}

html.force-emoji .emoji-fallback {
  display: inline-block !important;
}

.retry-btn,
.clear-search-btn {
  padding: 12px 24px;
  background: #E53E3E; /* Rouge principal */
  color: #FFFFFF; /* Blanc pour bon contraste */
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover,
.clear-search-btn:hover {
  background: #C53030; /* Rouge plus foncé */
  color: #FFFFFF;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .recipes-grid {
    grid-template-columns: 1fr;
  }
}
</style>