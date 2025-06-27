<template>
  <div class="recipes-list">
    <!-- Bannières pour les recettes -->
    <BannerSection 
      type="recipes" 
      section="hero" 
      :banners="bannersByType"
    />

    <!-- Header -->
    <header class="page-header">
      <div class="header-content">
        <h1>Recettes</h1>
        <p class="subtitle">Découvrez nos délicieuses recettes</p>
      </div>
    </header>

    <!-- Search and Filters -->
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

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des recettes...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
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
                <span v-if="recipe.preparation_time" class="time">
                  <span class="material-symbols-outlined">schedule</span>
                  {{ recipe.preparation_time }}min
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
                <span class="material-symbols-outlined">favorite</span>
                <span>{{ recipe.likes_count || 0 }}</span>
              </div>
              <div v-if="recipe.servings" class="stat">
                <span class="material-symbols-outlined">group</span>
                <span>{{ recipe.servings }}</span>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipesStore } from '@/stores/recipes'
import { useAppStore } from '@/stores/app'
import { useBanners } from '@/composables/useBanners'
import BannerSection from '@/components/common/BannerSection.vue'
import SearchAndFilters from '@/components/common/SearchAndFilters.vue'

export default {
  name: 'RecipesList',
  components: {
    BannerSection,
    SearchAndFilters
  },
  setup() {
    const router = useRouter()
    const recipesStore = useRecipesStore()
    const appStore = useAppStore()
    
    // Banner management
    const { loadBannersByType } = useBanners()
    const bannersByType = ref([])
    
    const loadBanners = async () => {
      try {
        const banners = await loadBannersByType('recipes')
        bannersByType.value = banners
      } catch (error) {
        console.error('Error loading banners:', error)
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
    const filteredRecipes = computed(() => recipesStore.filteredRecipes)
    const categories = computed(() => []) // TODO: Add categories store
    
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
    
    const loadRecipes = async () => {
      await recipesStore.fetchRecipes()
    }
    
    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'easy': 'Facile',
        'medium': 'Moyen',
        'hard': 'Difficile'
      }
      return labels[difficulty] || difficulty
    }
    
    // Lifecycle
    onMounted(() => {
      loadRecipes()
      loadBanners()
      appStore.initializePWAListeners()
      appStore.initializeNetworkListeners()
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
      goToRecipe,
      clearSearch,
      setSelectedCategory,
      updateAdditionalFilter,
      clearAllFilters,
      retry,
      getDifficultyLabel
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

.page-header {
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-bottom: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  padding: 24px 16px;
}

.header-content h1 {
  margin: 0 0 16px 0;
  font-size: 28px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
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
  background: rgba(0, 0, 0, 0.5);
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