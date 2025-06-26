import { computed } from 'vue'
import { useApiCall, useApiPagination, useApiMutation } from './useApi'

export function useRecipes(params = {}, options = {}) {
  const {
    data: recipes,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/recipes', params, {
    cacheTTL: 5 * 60 * 1000, // 5 minutes
    ...options
  })

  const featuredRecipes = computed(() => {
    return recipes.value?.data?.filter(recipe => recipe.is_featured) || []
  })

  const popularRecipes = computed(() => {
    return recipes.value?.data?.sort((a, b) => (b.likes_count || 0) - (a.likes_count || 0)) || []
  })

  return {
    recipes,
    featuredRecipes,
    popularRecipes,
    error,
    loading,
    execute,
    refresh
  }
}

export function useRecipesPagination(initialParams = {}) {
  const {
    data: recipes,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    updateParams
  } = useApiPagination('/recipes', {
    per_page: 12,
    ...initialParams
  })

  const searchRecipes = (query) => {
    return updateParams({ search: query, page: 1 })
  }

  const filterByCategory = (categoryId) => {
    return updateParams({ category_id: categoryId, page: 1 })
  }

  const filterByDifficulty = (difficulty) => {
    return updateParams({ difficulty, page: 1 })
  }

  return {
    recipes,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    searchRecipes,
    filterByCategory,
    filterByDifficulty
  }
}

export function useRecipe(id, options = {}) {
  const {
    data: recipe,
    error,
    loading,
    execute,
    refresh
  } = useApiCall(
    () => `/recipes/${id.value || id}`,
    {},
    {
      cacheTTL: 10 * 60 * 1000, // 10 minutes
      autoFetch: !!id,
      ...options
    }
  )

  return {
    recipe,
    error,
    loading,
    execute,
    refresh
  }
}

export function useRecipeLike() {
  const {
    data: likeData,
    error,
    loading,
    post
  } = useApiMutation('/recipes/{id}/like', {
    invalidatePattern: '/recipes'
  })

  const toggleLike = async (recipeId) => {
    return post({}, { endpoint: `/recipes/${recipeId}/like` })
  }

  return {
    likeData,
    error,
    loading,
    toggleLike
  }
}

export function useRecipeComments(recipeId) {
  const {
    data: comments,
    error: fetchError,
    loading: fetchLoading,
    refresh
  } = useApiCall(
    () => `/recipes/${recipeId.value || recipeId}/comments`,
    {},
    {
      cacheTTL: 2 * 60 * 1000, // 2 minutes
      autoFetch: !!recipeId
    }
  )

  const {
    data: newComment,
    error: postError,
    loading: postLoading,
    post
  } = useApiMutation(`/recipes/${recipeId}/comments`, {
    invalidatePattern: `/recipes/${recipeId}/comments`
  })

  const addComment = async (content) => {
    const result = await post({ content })
    refresh() // Rafraîchir la liste des commentaires
    return result
  }

  return {
    comments,
    newComment,
    error: fetchError || postError,
    loading: fetchLoading || postLoading,
    addComment,
    refresh
  }
}