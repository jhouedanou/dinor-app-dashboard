import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useLocaleStore = defineStore('locale', () => {
  // State
  const currentLocale = ref(localStorage.getItem('app-locale') || 'fr')
  const availableLocales = ref([
    { code: 'fr', name: 'Français', flag: '🇫🇷' },
    { code: 'en', name: 'English', flag: '🇬🇧' }
  ])

  // Watch for locale changes and persist to localStorage
  watch(currentLocale, (newLocale) => {
    localStorage.setItem('app-locale', newLocale)
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
