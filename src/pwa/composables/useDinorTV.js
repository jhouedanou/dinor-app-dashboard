import { computed, ref } from 'vue'
import { useApiCall, useApiPagination, useApiMutation } from './useApi'

export function useDinorTV(params = {}, options = {}) {
  const {
    data: videos,
    error,
    loading,
    execute,
    refresh
  } = useApiCall('/dinor-tv', params, {
    cacheTTL: 10 * 60 * 1000, // 10 minutes
    ...options
  })

  const featuredVideos = computed(() => {
    return videos.value?.data?.filter(video => video.is_featured) || []
  })

  const latestVideos = computed(() => {
    return videos.value?.data?.sort((a, b) => 
      new Date(b.created_at) - new Date(a.created_at)
    ) || []
  })

  const videosByCategory = computed(() => {
    const grouped = {}
    if (videos.value?.data) {
      videos.value.data.forEach(video => {
        const category = video.category?.name || 'Autres'
        if (!grouped[category]) grouped[category] = []
        grouped[category].push(video)
      })
    }
    return grouped
  })

  return {
    videos,
    featuredVideos,
    latestVideos,
    videosByCategory,
    error,
    loading,
    execute,
    refresh
  }
}

export function useDinorTVPagination(initialParams = {}) {
  const {
    data: videos,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    updateParams
  } = useApiPagination('/dinor-tv', {
    per_page: 12,
    ...initialParams
  })

  const searchVideos = (query) => {
    return updateParams({ search: query, page: 1 })
  }

  const filterByCategory = (categoryId) => {
    return updateParams({ category_id: categoryId, page: 1 })
  }

  const filterByDuration = (duration) => {
    return updateParams({ duration, page: 1 })
  }

  const sortBy = (sortField, sortOrder = 'desc') => {
    return updateParams({ 
      sort_by: sortField, 
      sort_order: sortOrder, 
      page: 1 
    })
  }

  return {
    videos,
    meta,
    params,
    error,
    loading,
    hasMore,
    loadPage,
    loadMore,
    refresh,
    searchVideos,
    filterByCategory,
    filterByDuration,
    sortBy
  }
}

export function useVideo(id, options = {}) {
  const {
    data: video,
    error,
    loading,
    execute,
    refresh
  } = useApiCall(
    () => `/dinor-tv/${id.value || id}`,
    {},
    {
      cacheTTL: 15 * 60 * 1000, // 15 minutes
      autoFetch: !!id,
      ...options
    }
  )

  return {
    video,
    error,
    loading,
    execute,
    refresh
  }
}

export function useVideoPlayer(videoId) {
  const isPlaying = ref(false)
  const currentTime = ref(0)
  const duration = ref(0)
  const volume = ref(1)
  const isFullscreen = ref(false)

  const {
    data: viewData,
    post: recordView
  } = useApiMutation('/dinor-tv/{id}/view')

  const play = () => {
    isPlaying.value = true
  }

  const pause = () => {
    isPlaying.value = false
  }

  const togglePlayPause = () => {
    isPlaying.value ? pause() : play()
  }

  const seek = (time) => {
    currentTime.value = time
  }

  const setVolume = (vol) => {
    volume.value = Math.max(0, Math.min(1, vol))
  }

  const toggleFullscreen = () => {
    isFullscreen.value = !isFullscreen.value
  }

  const recordVideoView = async () => {
    if (videoId) {
      try {
        await recordView({}, { endpoint: `/dinor-tv/${videoId}/view` })
      } catch (error) {
        console.error('Erreur lors de l\'enregistrement de la vue:', error)
      }
    }
  }

  return {
    isPlaying,
    currentTime,
    duration,
    volume,
    isFullscreen,
    viewData,
    play,
    pause,
    togglePlayPause,
    seek,
    setVolume,
    toggleFullscreen,
    recordVideoView
  }
}

export function useVideoLike() {
  const {
    data: likeData,
    error,
    loading,
    post
  } = useApiMutation('/dinor-tv/{id}/like', {
    invalidatePattern: '/dinor-tv'
  })

  const toggleLike = async (videoId) => {
    return post({}, { endpoint: `/dinor-tv/${videoId}/like` })
  }

  return {
    likeData,
    error,
    loading,
    toggleLike
  }
}