<template>
  <div class="pages-list">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des pages...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <LucideAlertTriangle :size="48" />
      </div>
      <h2 class="md3-title-large">Erreur de chargement</h2>
      <p class="md3-body-large dinor-text-gray">{{ error }}</p>
      <button @click="retry" class="btn-secondary">Réessayer</button>
    </div>

    <!-- Empty State -->
    <div v-else-if="!loading && pages.length === 0" class="empty-state">
      <div class="empty-icon">
        <LucideBookOpen :size="48" />
      </div>
      <h2 class="md3-title-medium">Aucune page trouvée</h2>
      <p class="md3-body-medium dinor-text-gray">
        Aucune page n'est disponible pour le moment.
      </p>
    </div>

    <!-- Pages List -->
    <div v-else class="pages-grid">
      <article
        v-for="page in pages"
        :key="page.id"
        @click="goToPage(page)"
        class="page-card"
      >
        <div class="page-icon">
          <component :is="getPageIconComponent(page.template)" :size="24" />
        </div>
        
        <div class="page-content">
          <h3 class="page-title">{{ page.title }}</h3>
          <p v-if="page.excerpt" class="page-excerpt">
            {{ page.excerpt }}
          </p>
          
          <div class="page-meta">
            <span v-if="page.template" class="template-badge">
              {{ getTemplateLabel(page.template) }}
            </span>
            <span v-if="page.updated_at" class="last-updated">
              Mis à jour {{ formatDate(page.updated_at) }}
            </span>
          </div>
        </div>
        
        <div class="page-arrow">
          <LucideChevronRight :size="20" />
        </div>
      </article>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '@/services/api'

export default {
  name: 'PagesList',
  setup() {
    const router = useRouter()
    
    // State
    const pages = ref([])
    const loading = ref(false)
    const error = ref(null)
    
    // Methods
    const goToPage = (page) => {
      // Rediriger directement vers WebEmbed avec l'URL de la page
      if (page.url) {
        const encodedUrl = encodeURIComponent(page.url)
        router.push(`/web-embed?url=${encodedUrl}`)
      }
    }
    
    const retry = () => {
      error.value = null
      loadPages()
    }
    
    const loadPages = async () => {
      loading.value = true
      error.value = null
      
      try {
        const response = await apiService.getPages()
        
        if (response.success) {
          pages.value = response.data
        } else {
          throw new Error(response.message || 'Failed to fetch pages')
        }
      } catch (err) {
        error.value = err.message
        console.error('Error fetching pages:', err)
      } finally {
        loading.value = false
      }
    }
    
    const getPageIconComponent = (template) => {
      const icons = {
        'about': 'LucideInfo',
        'contact': 'LucideMail',
        'privacy': 'LucideShieldCheck',
        'terms': 'LucideGavel',
        'faq': 'LucideHelpCircle',
        'default': 'LucideFileText'
      }
      return icons[template] || icons.default
    }
    
    const getTemplateLabel = (template) => {
      const labels = {
        'about': 'À propos',
        'contact': 'Contact',
        'privacy': 'Confidentialité',
        'terms': 'Conditions',
        'faq': 'FAQ',
        'default': 'Page'
      }
      return labels[template] || labels.default
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }
    
    // Lifecycle
    onMounted(() => {
      loadPages()
    })
    
    return {
      pages,
      loading,
      error,
      goToPage,
      retry,
      getPageIconComponent,
      getTemplateLabel,
      formatDate
    }
  }
}
</script>

<style scoped>
.pages-list {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

.loading-state,
.error-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--md-sys-color-surface-variant, #e7e0ec);
  border-top: 4px solid var(--md-sys-color-primary, #6750a4);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon,
.empty-icon {
  width: 64px;
  height: 64px;
  background: var(--md-sys-color-error-container, #fce8e6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.empty-icon {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
}

.error-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.empty-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

.content {
  padding: 16px;
}

.pages-grid {
  display: grid;
  gap: 12px;
  max-width: 600px;
  margin: 0 auto;
}

.page-card {
  display: flex;
  align-items: center;
  background: var(--md-sys-color-surface-container, #f7f2fa);
  border-radius: 16px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  gap: 16px;
}

.page-card:hover {
  background: var(--md-sys-color-surface-container-high, #f1ecf4);
  transform: translateX(4px);
}

.page-icon {
  width: 48px;
  height: 48px;
  background: var(--md-sys-color-primary-container, #eaddff);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.page-icon .material-symbols-outlined {
  font-size: 24px;
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.page-content {
  flex: 1;
  min-width: 0;
}

.page-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
  line-height: 1.3;
}

.page-excerpt {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.page-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.template-badge {
  font-size: 12px;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: 8px;
  background: var(--md-sys-color-secondary-container, #e8def8);
  color: var(--md-sys-color-on-secondary-container, #1d192b);
}

.last-updated {
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.page-arrow {
  flex-shrink: 0;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  transition: transform 0.2s ease;
}

.page-card:hover .page-arrow {
  transform: translateX(4px);
}

.page-arrow .material-symbols-outlined {
  font-size: 20px;
}

.retry-btn {
  padding: 12px 24px;
  background: var(--md-sys-color-primary, #6750a4);
  color: var(--md-sys-color-on-primary, #ffffff);
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.retry-btn:hover {
  background: var(--md-sys-color-primary-container, #eaddff);
  color: var(--md-sys-color-on-primary-container, #21005d);
}

/* Responsive */
@media (min-width: 768px) {
  .pages-grid {
    max-width: 800px;
  }
  
  .page-card {
    padding: 20px;
  }
  
  .page-title {
    font-size: 18px;
  }
  
  .page-excerpt {
    font-size: 15px;
  }
}

/* Système de fallback pour les icônes - logique simplifiée */
.emoji-fallback {
  display: none; /* Masqué par défaut */
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

/* UNIQUEMENT quand .force-emoji est présent sur html, afficher les emoji */
html.force-emoji .material-symbols-outlined {
  display: none !important;
}

html.force-emoji .emoji-fallback {
  display: inline-block !important;
}

.error-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.error-icon .emoji-fallback {
  font-size: 32px;
  color: var(--md-sys-color-on-error-container, #5f1411);
}

.empty-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

.empty-icon .emoji-fallback {
  font-size: 32px;
  color: var(--md-sys-color-on-tertiary-container, #31111d);
}

.page-icon .material-symbols-outlined {
  font-size: 32px;
  color: var(--md-sys-color-primary, #6750a4);
}

.page-icon .emoji-fallback {
  font-size: 30px;
  color: var(--md-sys-color-primary, #6750a4);
}

.page-arrow .material-symbols-outlined {
  font-size: 20px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.page-arrow .emoji-fallback {
  font-size: 16px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}
</style>