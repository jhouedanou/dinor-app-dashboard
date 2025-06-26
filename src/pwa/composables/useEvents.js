import { computed } from 'vue'
import { useApiCall, useApiPagination, useApiMutation } from './useApi'

export function useEvents(params = {}, options = {}) {
  const {
    data: events,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/events', params, {
    cacheTTL: 5 * 60 * 1000, // 5 minutes
    ...options
  })

  const activeEvents = computed(() => {
    return events.value?.data?.filter(event => event.status === 'active') || []
  })

  const upcomingEvents = computed(() => {
    return events.value?.data?.filter(event => {
      const eventDate = new Date(event.date)
      return eventDate > new Date()
    }).sort((a, b) => new Date(a.date) - new Date(b.date)) || []
  })

  const featuredEvents = computed(() => {
    return events.value?.data?.filter(event => event.is_featured) || []
  })

  return {
    events,
    activeEvents,
    upcomingEvents,
    featuredEvents,
    error,
    loading,
    execute,
    refresh
  }
}

export function useEventsPagination(initialParams = {}) {
  const {
    data: events,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    updateParams
  } = useApiPagination('/events', {
    per_page: 12,
    ...initialParams
  })

  const searchEvents = (query) => {
    return updateParams({ search: query, page: 1 })
  }

  const filterByStatus = (status) => {
    return updateParams({ status, page: 1 })
  }

  const filterByCategory = (categoryId) => {
    return updateParams({ category_id: categoryId, page: 1 })
  }

  const filterByDate = (dateRange) => {
    return updateParams({ 
      date_from: dateRange.from,
      date_to: dateRange.to,
      page: 1 
    })
  }

  return {
    events,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    searchEvents,
    filterByStatus,
    filterByCategory,
    filterByDate
  }
}

export function useEvent(id, options = {}) {
  const {
    data: event,
    error,
    loading,
    execute,
    refresh
  } = useApiCall(
    () => `/events/${id.value || id}`,
    {},
    {
      cacheTTL: 10 * 60 * 1000, // 10 minutes
      autoFetch: !!id,
      ...options
    }
  )

  return {
    event,
    error,
    loading,
    execute,
    refresh
  }
}

export function useEventRegistration() {
  const {
    data: registrationData,
    error,
    loading,
    post
  } = useApiMutation('/events/{id}/register', {
    invalidatePattern: '/events'
  })

  const register = async (eventId, participantData = {}) => {
    return post(participantData, { endpoint: `/events/${eventId}/register` })
  }

  return {
    registrationData,
    error,
    loading,
    register
  }
}