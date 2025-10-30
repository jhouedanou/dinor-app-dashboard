import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

// Safe localStorage access with fallback
const getStoredLocale = () => {
  try {
    return localStorage.getItem('app-locale') || 'fr'
  } catch (error) {
    console.warn('Failed to access localStorage:', error)
    return 'fr'
  }
}

export const useLocaleStore = defineStore('locale', () => {
  // State
  const currentLocale = ref(getStoredLocale())
  const availableLocales = ref([
    { code: 'fr', name: 'Français', flag: '🇫🇷' },
    { code: 'en', name: 'English', flag: '🇬🇧' }
  ])

  // Watch for locale changes and persist to localStorage
  watch(currentLocale, (newLocale) => {
    try {
      localStorage.setItem('app-locale', newLocale)
    } catch (error) {
      console.warn('Failed to save locale to localStorage:', error)
    }
    // Update HTML lang attribute
    if (typeof document !== 'undefined') {
      document.documentElement.lang = newLocale
    }
  })

  // Actions
  function setLocale(locale) {
    if (availableLocales.value.find(l => l.code === locale)) {
      currentLocale.value = locale
    }
  }

  function toggleLocale() {
    currentLocale.value = currentLocale.value === 'fr' ? 'en' : 'fr'
  }

  function getLocaleName(code) {
    const locale = availableLocales.value.find(l => l.code === code)
    return locale ? locale.name : code
  }

  function getLocaleFlag(code) {
    const locale = availableLocales.value.find(l => l.code === code)
    return locale ? locale.flag : ''
  }

  return {
    // State
    currentLocale,
    availableLocales,
    
    // Actions
    setLocale,
    toggleLocale,
    getLocaleName,
    getLocaleFlag
  }
})
