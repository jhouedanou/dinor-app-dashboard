<template>
  <div class="language-switcher" :class="{ 'compact': compact }">
    <button 
      v-if="compact"
      @click="toggleLanguage"
      class="language-toggle-btn"
      :title="$t('language.switch')"
    >
      <span class="flag">{{ currentFlag }}</span>
      <span class="lang-code">{{ currentLocale.toUpperCase() }}</span>
    </button>
    
    <div v-else class="language-selector">
      <label class="selector-label">{{ $t('profile.language') }}</label>
      <div class="language-options">
        <button 
          v-for="locale in availableLocales" 
          :key="locale.code"
          @click="setLanguage(locale.code)"
          class="language-option"
          :class="{ 'active': currentLocale === locale.code }"
        >
          <span class="flag">{{ locale.flag }}</span>
          <span class="lang-name">{{ locale.name }}</span>
          <LucideCheck v-if="currentLocale === locale.code" :size="18" class="check-icon" />
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useLocaleStore } from '@/stores/locale'

export default {
  name: 'LanguageSwitcher',
  props: {
    compact: {
      type: Boolean,
      default: false
    }
  },
  setup() {
    const { locale } = useI18n()
    const localeStore = useLocaleStore()

    const currentLocale = computed(() => localeStore.currentLocale)
    const availableLocales = computed(() => localeStore.availableLocales)
    const currentFlag = computed(() => localeStore.getLocaleFlag(currentLocale.value))

    const setLanguage = (lang) => {
      localeStore.setLocale(lang)
      locale.value = lang
    }

    const toggleLanguage = () => {
      const newLocale = currentLocale.value === 'fr' ? 'en' : 'fr'
      setLanguage(newLocale)
    }

    return {
      currentLocale,
      availableLocales,
      currentFlag,
      setLanguage,
      toggleLanguage
    }
  }
}
</script>

<style scoped>
.language-switcher {
  width: 100%;
}

.language-switcher.compact {
  width: auto;
}

/* Compact mode - Toggle button */
.language-toggle-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.language-toggle-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.3);
}

.language-toggle-btn .flag {
  font-size: 18px;
  line-height: 1;
}

.language-toggle-btn .lang-code {
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

/* Full mode - Selector */
.language-selector {
  padding: 16px 0;
}

.selector-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 12px;
}

.language-options {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.language-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #F7FAFC;
  border: 2px solid transparent;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  width: 100%;
  text-align: left;
}

.language-option:hover {
  background: #EDF2F7;
  border-color: #E2E8F0;
}

.language-option.active {
  background: #FFF5F5;
  border-color: #E53E3E;
}

.language-option .flag {
  font-size: 24px;
  line-height: 1;
}

.language-option .lang-name {
  flex: 1;
  font-size: 16px;
  font-weight: 500;
  color: #2D3748;
}

.language-option.active .lang-name {
  color: #E53E3E;
  font-weight: 600;
}

.language-option .check-icon {
  color: #E53E3E;
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .selector-label {
    color: #E2E8F0;
  }

  .language-option {
    background: #2D3748;
    color: #E2E8F0;
  }

  .language-option:hover {
    background: #4A5568;
  }

  .language-option.active {
    background: #742A2A;
  }

  .language-option .lang-name {
    color: #E2E8F0;
  }

  .language-option.active .lang-name {
    color: #FEB2B2;
  }

  .language-option .check-icon {
    color: #FEB2B2;
  }
}
</style>
