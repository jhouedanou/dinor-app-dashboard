<template>
  <div class="recipes-list">
    <!-- Header -->
    <header class="page-header">
      <div class="header-content">
        <h1>Recettes</h1>
        <div class="search-container">
          <div class="search-input-wrapper">
            <span class="material-symbols-outlined search-icon">search</span>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher une recette..."
              class="search-input"
            />
            <button 
              v-if="searchQuery"
              @click="clearSearch"
              class="clear-search"
              aria-label="Effacer la recherche"
            >
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
        </div>
      </div>
    </header>

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
      <!-- Filters (if needed) -->
      <div v-if="categories?.length" class="filters">
        <div class="filter-chips">
          <button
            @click="setSelectedCategory(null)"
            class="filter-chip"
            :class="{ active: !selectedCategory }"
          >
            Toutes
          </button>
          <button
            v-for="category in categories"
            :key="category.id"
            @click="setSelectedCategory(category.id)"
            class="filter-chip"
            :class="{ active: selectedCategory === category.id }"
          >
            {{ category.name }}
          </button>
        </div>
      </div>

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
        <h3>Aucune recette trouvée</h3>
        <p v-if="searchQuery">
          Essayez avec d'autres mots-clés ou parcourez toutes les recettes.
        </p>
        <p v-else>
          Les recettes seront bientôt disponibles.
        </p>
        <button v-if="searchQuery" @click="clearSearch" class="clear-search-btn">
          Voir toutes les recettes
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
import { computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipesStore } from '@/stores/recipes'
import { useAppStore } from '@/stores/app'

export default {
  name: 'RecipesList',
  setup() {
    const router = useRouter()
    const recipesStore = useRecipesStore()
    const appStore = useAppStore()
    
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
      goToRecipe,
      clearSearch,
      setSelectedCategory,
      retry,
      getDifficultyLabel
    }
  }
}
</script>

<style scoped>
.recipes-list {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
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
  border: 1px solid var(--md-sys-color-outline, #79747e);
  border-radius: 20px;
  background: var(--md-sys-color-surface, #fefbff);
  color: var(--md-sys-color-on-surface-variant, #49454f);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.filter-chip:hover {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
}

.filter-chip.active {
  background: var(--md-sys-color-secondary-container, #e8def8);
  color: var(--md-sys-color-on-secondary-container, #1d192b);
  border-color: var(--md-sys-color-secondary, #625b71);
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
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
}

.recipe-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
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
  color: var(--md-sys-color-on-surface, #1c1b1f);
  line-height: 1.3;
}

.recipe-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.4;
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
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover,
.clear-search-btn:hover {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

/* Responsive */
@media (max-width: 768px) {
  .recipes-grid {
    grid-template-columns: 1fr;
  }
}
</style>