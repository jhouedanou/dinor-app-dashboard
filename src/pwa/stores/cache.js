import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useCacheStore = defineStore('cache', () => {
  // State
  const cache = ref(new Map())
  const cacheTimestamps = ref(new Map())
  const defaultTTL = ref(5 * 60 * 1000) // 5 minutes par défaut

  // Actions
  function set(key, data, ttl = defaultTTL.value) {
    cache.value.set(key, data)
    cacheTimestamps.value.set(key, Date.now() + ttl)
  }

  function get(key) {
    const timestamp = cacheTimestamps.value.get(key)
    
    if (!timestamp || Date.now() > timestamp) {
      // Cache expiré
      cache.value.delete(key)
      cacheTimestamps.value.delete(key)
      return null
    }
    
    return cache.value.get(key)
  }

  function has(key) {
    const data = get(key)
    return data !== null
  }

  function remove(key) {
    cache.value.delete(key)
    cacheTimestamps.value.delete(key)
  }

  function clear() {
    cache.value.clear()
    cacheTimestamps.value.clear()
  }

  function clearExpired() {
    const now = Date.now()
    for (const [key, timestamp] of cacheTimestamps.value.entries()) {
      if (now > timestamp) {
        cache.value.delete(key)
        cacheTimestamps.value.delete(key)
      }
    }
  }

  function getCacheInfo() {
    return {
      size: cache.value.size,
      keys: Array.from(cache.value.keys()),
      expired: Array.from(cacheTimestamps.value.entries())
        .filter(([, timestamp]) => Date.now() > timestamp)
        .map(([key]) => key)
    }
  }

  // Cleanup automatique toutes les 30 secondes
  setInterval(clearExpired, 30000)

  return {
    // State
    defaultTTL,
    
    // Actions
    set,
    get,
    has,
    remove,
    clear,
    clearExpired,
    getCacheInfo
  }
})