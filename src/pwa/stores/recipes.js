import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import apiService from '@/services/api'

export const useRecipesStore = defineStore('recipes', () => {
  // State
  const recipes = ref([])
  const currentRecipe = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const searchQuery = ref('')
  const selectedCategory = ref(null)
  const pagination = ref({
    current_page: 1,
    last_page: 1,
    per_page: 12,
    total: 0
  })

  // Getters
  const filteredRecipes = computed(() => {
    let filtered = recipes.value

    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(recipe =>
        recipe.title.toLowerCase().includes(query) ||
        recipe.short_description?.toLowerCase().includes(query) ||
        recipe.tags?.some(tag => tag.toLowerCase().includes(query))
      )
    }

    if (selectedCategory.value) {
      filtered = filtered.filter(recipe => recipe.category_id === selectedCategory.value)
    }

    return filtered
  })

  const featuredRecipes = computed(() => {
    return recipes.value.filter(recipe => recipe.is_featured)
  })

  // Actions
  async function fetchRecipes(params = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await apiService.getRecipes(params)
      
      if (response.success) {
        recipes.value = response.data
        if (response.meta) {
          pagination.value = response.meta
        }
      } else {
        throw new Error(response.message || 'Failed to fetch recipes')
      }
    } catch (err) {
      error.value = err.message
      console.error('Error fetching recipes:', err)
    } finally {
      loading.value = false
    }
  }

  // Nouvelle méthode pour forcer le rafraîchissement
  async function fetchRecipesFresh(params = {}) {
    loading.value = true
    error.value = null

    try {
      console.log('🔄 [RecipesStore] Rafraîchissement forcé des recettes')
      const response = await apiService.getRecipesFresh(params)
      
      if (response.success) {
        recipes.value = response.data
        if (response.meta) {
          pagination.value = response.meta
        }
        console.log('✅ [RecipesStore] Recettes rafraîchies:', response.data.length)
      } else {
        throw new Error(response.message || 'Failed to fetch recipes')
      }
    } catch (err) {
      error.value = err.message
      console.error('Error fetching recipes:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchRecipe(id) {
    loading.value = true
    error.value = null

    try {
      const response = await apiService.getRecipe(id)
      
      if (response.success) {
        currentRecipe.value = response.data
      } else {
        throw new Error(response.message || 'Failed to fetch recipe')
      }
    } catch (err) {
      error.value = err.message
      console.error('Error fetching recipe:', err)
    } finally {
      loading.value = false
    }
  }

  // Nouvelle méthode pour forcer le rafraîchissement d'une recette
  async function fetchRecipeFresh(id) {
    loading.value = true
    error.value = null

    try {
      console.log('🔄 [RecipesStore] Rafraîchissement forcé de la recette:', id)
      const response = await apiService.getRecipeFresh(id)
      
      if (response.success) {
        currentRecipe.value = response.data
        console.log('✅ [RecipesStore] Recette rafraîchie:', response.data.title)
      } else {
        throw new Error(response.message || 'Failed to fetch recipe')
      }
    } catch (err) {
      error.value = err.message
      console.error('Error fetching recipe:', err)
    } finally {
      loading.value = false
    }
  }

  async function toggleLike(id) {
    try {
      const response = await apiService.toggleLike('recipes', id)
      
      if (response.success) {
        // Update recipe in list
        const recipe = recipes.value.find(r => r.id === id)
        if (recipe) {
          recipe.is_liked = response.data.is_liked
          recipe.likes_count = response.data.likes_count
        }
        
        // Update current recipe if it's the same
        if (currentRecipe.value && currentRecipe.value.id === id) {
          currentRecipe.value.is_liked = response.data.is_liked
          currentRecipe.value.likes_count = response.data.likes_count
        }
        
        return response.data
      }
    } catch (err) {
      console.error('Error toggling like:', err)
      return { success: false }
    }
  }

  function setSearchQuery(query) {
    searchQuery.value = query
  }

  function setSelectedCategory(categoryId) {
    selectedCategory.value = categoryId
  }

  function clearFilters() {
    searchQuery.value = ''
    selectedCategory.value = null
  }

  function clearCurrentRecipe() {
    currentRecipe.value = null
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    recipes,
    currentRecipe,
    loading,
    error,
    searchQuery,
    selectedCategory,
    pagination,
    
    // Getters
    filteredRecipes,
    featuredRecipes,
    
    // Actions
    fetchRecipes,
    fetchRecipesFresh,
    fetchRecipe,
    fetchRecipeFresh,
    toggleLike,
    setSearchQuery,
    setSelectedCategory,
    clearFilters,
    clearCurrentRecipe,
    clearError
  }
})