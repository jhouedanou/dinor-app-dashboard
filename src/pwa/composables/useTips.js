import { computed } from 'vue'
import { useApiCall, useApiPagination, useApiMutation } from './useApi'
import { processItemsImages, processItemImages } from '@/utils/imageUtils'

export function useTips(params = {}, options = {}) {
  const {
    data: rawTips,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/tips', params, {
    cacheTTL: 5 * 60 * 1000, // 5 minutes
    ...options
  })

  // Traiter les données pour corriger les URLs d'images
  const tips = computed(() => {
    if (!rawTips.value) return rawTips.value
    
    const processed = { ...rawTips.value }
    if (processed.data && Array.isArray(processed.data)) {
      processed.data = processItemsImages(processed.data, 'tips')
    }
    return processed
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
    data: rawTips,
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

  // Traiter les données pour corriger les URLs d'images
  const tips = computed(() => {
    if (!rawTips.value || !Array.isArray(rawTips.value)) return rawTips.value
    return processItemsImages(rawTips.value, 'tips')
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
    data: rawTip,
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

  // Traiter les données pour corriger les URLs d'images
  const tip = computed(() => {
    if (!rawTip.value) return rawTip.value
    
    const processed = { ...rawTip.value }
    if (processed.data) {
      processed.data = processItemImages(processed.data, 'tips')
    }
    return processed
  })

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