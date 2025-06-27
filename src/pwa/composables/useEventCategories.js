import { computed } from 'vue'
import { useApiCall, useApiMutation } from './useApi'

export function useEventCategories(options = {}) {
  const {
    data: categories,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/event-categories', {}, {
    cacheTTL: 10 * 60 * 1000, // 10 minutes
    ...options
  })

  const activeCategories = computed(() => {
    return categories.value?.data?.filter(category => category.is_active !== false) || []
  })

  const getCategoryById = (id) => {
    return categories.value?.data?.find(category => category.id === id)
  }

  const getCategoryBySlug = (slug) => {
    return categories.value?.data?.find(category => category.slug === slug)
  }

  return {
    categories,
    activeCategories,
    error,
    loading,
    execute,
    refresh,
    getCategoryById,
    getCategoryBySlug
  }
}

export function useEventCategory(id, options = {}) {
  const {
    data: category,
    error,
    loading,
    execute,
    refresh
  } = useApiCall(
    () => `/event-categories/${id.value || id}`,
    {},
    {
      cacheTTL: 10 * 60 * 1000, // 10 minutes
      autoFetch: !!id,
      ...options
    }
  )

  return {
    category,
    error,
    loading,
    execute,
    refresh
  }
}

export function useEventCategoryMutation() {
  const {
    data: categoryData,
    error,
    loading,
    post
  } = useApiMutation('/event-categories', {
    invalidatePattern: '/event-categories'
  })

  const createCategory = async (categoryData) => {
    return post(categoryData)
  }

  const checkExists = async (name) => {
    return post({ name }, { endpoint: '/event-categories/check-exists' })
  }

  return {
    categoryData,
    error,
    loading,
    createCategory,
    checkExists
  }
} 