import { createI18n } from 'vue-i18n'
import fr from './locales/fr.json'
import en from './locales/en.json'

// Get initial locale from localStorage or default to 'fr'
const getInitialLocale = () => {
  const savedLocale = localStorage.getItem('app-locale')
  if (savedLocale && ['fr', 'en'].includes(savedLocale)) {
    return savedLocale
  }
  return 'fr'
}

const i18n = createI18n({
  legacy: false, // Use Composition API mode
  locale: getInitialLocale(),
  fallbackLocale: 'fr',
  messages: {
    fr,
    en
  },
  globalInjection: true
})

export default i18n
