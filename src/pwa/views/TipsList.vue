<template>
  <div class="tips-list">
    <!-- Header -->
    <header class="page-header">
      <div class="header-content">
        <h1>Astuces Culinaires</h1>
        <p class="subtitle">Découvrez nos conseils pour améliorer vos techniques culinaires</p>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des astuces...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
      </div>
      <p>{{ error }}</p>
      <button @click="retry" class="retry-btn">
        Réessayer
      </button>
    </div>

    <!-- Content -->
    <div v-else class="content">
      <!-- Empty State -->
      <div v-if="!tips.length && !loading" class="empty-state">
        <div class="empty-icon">
          <span class="material-symbols-outlined">lightbulb</span>
        </div>
        <h3>Aucune astuce disponible</h3>
        <p>Les astuces culinaires seront bientôt disponibles.</p>
      </div>

      <!-- Tips Grid -->
      <div v-else class="tips-grid">
        <article
          v-for="tip in tips"
          :key="tip.id"
          @click="goToTip(tip.id)"
          class="tip-card"
        >
          <div class="tip-header">
            <div class="tip-icon">
              <span class="material-symbols-outlined">lightbulb</span>
            </div>
            <div class="tip-meta">
              <span v-if="tip.difficulty_level" class="difficulty">
                {{ getDifficultyLabel(tip.difficulty_level) }}
              </span>
              <span v-if="tip.estimated_time" class="time">
                <span class="material-symbols-outlined">schedule</span>
                {{ tip.estimated_time }}min
              </span>
            </div>
          </div>
          
          <div class="tip-content">
            <h3 class="tip-title">{{ tip.title }}</h3>
            <p v-if="tip.content" class="tip-description">
              {{ getShortDescription(tip.content) }}
            </p>
            
            <div v-if="tip.tags?.length" class="tip-tags">
              <span
                v-for="tag in tip.tags.slice(0, 3)"
                :key="tag"
                class="tag"
              >
                {{ tag }}
              </span>
            </div>
            
            <div class="tip-stats">
              <div class="stat">
                <span class="material-symbols-outlined">favorite</span>
                <span>{{ tip.likes_count || 0 }}</span>
              </div>
              <div v-if="tip.category" class="stat">
                <span class="material-symbols-outlined">category</span>
                <span>{{ tip.category.name }}</span>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '@/services/api'

export default {
  name: 'TipsList',
  setup() {
    const router = useRouter()
    
    // State
    const tips = ref([])
    const loading = ref(false)
    const error = ref(null)
    
    // Methods
    const goToTip = (id) => {
      router.push(`/tip/${id}`)
    }
    
    const retry = () => {
      error.value = null
      loadTips()
    }
    
    const loadTips = async () => {
      loading.value = true
      error.value = null
      
      try {
        const response = await apiService.getTips()
        
        if (response.success) {
          tips.value = response.data
        } else {
          throw new Error(response.message || 'Failed to fetch tips')
        }
      } catch (err) {
        error.value = err.message
        console.error('Error fetching tips:', err)
      } finally {
        loading.value = false
      }
    }
    
    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'beginner': 'Débutant',
        'intermediate': 'Intermédiaire',
        'advanced': 'Avancé'
      }
      return labels[difficulty] || difficulty
    }
    
    const getShortDescription = (content) => {
      if (!content) return ''
      // Remove HTML tags and limit to 150 characters
      const text = content.replace(/<[^>]*>/g, '')
      return text.length > 150 ? text.substring(0, 150) + '...' : text
    }
    
    // Lifecycle
    onMounted(() => {
      loadTips()
    })
    
    return {
      tips,
      loading,
      error,
      goToTip,
      retry,
      getDifficultyLabel,
      getShortDescription
    }
  }
}
</script>

<style scoped>
.tips-list {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc comme Home */
  font-family: 'Roboto', sans-serif;
}

.page-header {
  background: linear-gradient(135deg, var(--md-sys-color-primary-container, #eaddff) 0%, var(--md-sys-color-tertiary-container, #ffd8e4) 100%);
  padding: 32px 16px;
  text-align: center;
}

.header-content h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: var(--md-sys-color-on-primary-container, #21005d);
}

.subtitle {
  margin: 0;
  font-size: 16px;
  color: var(--md-sys-color-on-primary-container, #21005d);
  opacity: 0.8;
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
  background: var(--md-sys-color-tertiary-container, #ffd8e4);
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

.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.tip-card {
  background: #FFFFFF; /* Fond blanc */
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #E2E8F0; /* Bordure gris clair */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tip-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(229, 62, 62, 0.15); /* Ombre rouge */
  border-color: #E53E3E; /* Bordure rouge au hover */
  background: #FFFFFF;
}

.tip-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.tip-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #F4D03F 0%, #FF6B35 100%); /* Dégradé doré vers orange */
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tip-icon .material-symbols-outlined {
  font-size: 24px;
  color: #FFFFFF; /* Icône blanche sur fond coloré */
}

.tip-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: flex-end;
}

.difficulty,
.time {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  padding: 4px 8px;
  border-radius: 12px;
  background: #F4D03F; /* Fond doré */
  color: #2D3748; /* Couleur foncée pour contraste 3.8:1 */
}

.time .material-symbols-outlined {
  font-size: 14px;
}

.tip-content {
  flex: 1;
}

.tip-title {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 600;
  font-family: 'Open Sans', sans-serif; /* Police Open Sans pour les titres */
  color: #2D3748; /* Couleur foncée pour bon contraste */
  line-height: 1.3;
}

.tip-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-family: 'Roboto', sans-serif; /* Police Roboto pour les textes */
  color: #4A5568; /* Couleur grise pour bon contraste */
  line-height: 1.5;
}

.tip-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 16px;
}

.tag {
  font-size: 12px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  padding: 4px 8px;
  border-radius: 8px;
  background: #FF6B35; /* Orange accent */
  color: #FFFFFF; /* Blanc pour contraste 3.1:1 */
}

.tip-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.stat .material-symbols-outlined {
  font-size: 18px;
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
@media (max-width: 768px) {
  .tips-grid {
    grid-template-columns: 1fr;
  }
  
  .tip-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .tip-meta {
    flex-direction: row;
    align-items: center;
  }
}
</style>