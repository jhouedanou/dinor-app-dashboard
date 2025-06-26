import { computed } from 'vue'
import { useApiCall, useApiPagination, useApiMutation } from './useApi'

export function useTips(params = {}, options = {}) {
  const {
    data: tips,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/tips', params, {
    cacheTTL: 5 * 60 * 1000, // 5 minutes
    ...options
  })

  const featuredTips = computed(() => {
    return tips.value?.data?.filter(tip => tip.is_featured) || []
  })

  const tipsByDifficulty = computed(() => {
    const grouped = {}
    if (tips.value?.data) {
      tips.value.data.forEach(tip => {
        const difficulty = tip.difficulty_level || 'beginner'
        if (!grouped[difficulty]) grouped[difficulty] = []
        grouped[difficulty].push(tip)
      })
    }
    return grouped
  })

  return {
    tips,
    featuredTips,
    tipsByDifficulty,
    error,
    loading,
    execute,
    refresh
  }
}

export function useTipsPagination(initialParams = {}) {
  const {
    data: tips,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    updateParams
  } = useApiPagination('/tips', {
    per_page: 12,
    ...initialParams
  })

  const searchTips = (query) => {
    return updateParams({ search: query, page: 1 })
  }

  const filterByDifficulty = (difficulty) => {
    return updateParams({ difficulty_level: difficulty, page: 1 })
  }

  const filterByCategory = (categoryId) => {
    return updateParams({ category_id: categoryId, page: 1 })
  }

  return {
    tips,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    searchTips,
    filterByDifficulty,
    filterByCategory
  }
}

export function useTip(id, options = {}) {
  const {
    data: tip,
    error,
    loading,
    execute,
    refresh
  } = useApiCall(
    () => `/tips/${id.value || id}`,
    {},
    {
      cacheTTL: 10 * 60 * 1000, // 10 minutes
      autoFetch: !!id,
      ...options
    }
  )

  return {
    tip,
    error,
    loading,
    execute,
    refresh
  }
}

export function useTipLike() {
  const {
    data: likeData,
    error,
    loading,
    post
  } = useApiMutation('/tips/{id}/like', {
    invalidatePattern: '/tips'
  })

  const toggleLike = async (tipId) => {
    return post({}, { endpoint: `/tips/${tipId}/like` })
  }

  return {
    likeData,
    error,
    loading,
    toggleLike
  }
}