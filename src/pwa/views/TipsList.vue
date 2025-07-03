<template>
  <div class="tips-list">
    <!-- Bannières pour les astuces -->
    <BannerSection 
      type="tips" 
      section="hero" 
      :banners="bannersByType"
    />

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement des astuces...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <span class="material-symbols-outlined">error</span>
        <span class="emoji-fallback">⚠️</span>
      </div>
      <h2 class="md3-title-large">Erreur de chargement</h2>
      <p class="md3-body-large dinor-text-gray">{{ error }}</p>
      <button @click="retry" class="btn-secondary">Réessayer</button>
    </div>

    <!-- Empty State -->
    <div v-else-if="!loading && tips.length === 0" class="empty-state">
      <div class="empty-icon">
        <span class="material-symbols-outlined">lightbulb</span>
        <span class="emoji-fallback">💡</span>
      </div>
      <h2 class="md3-title-medium">Aucune astuce trouvée</h2>
      <p class="md3-body-medium dinor-text-gray">
        Aucune astuce n'est disponible pour le moment.
      </p>
    </div>

    <!-- Content -->
    <div v-else class="content">
      <!-- Tips Grid -->
      <div class="tips-grid">
        <div 
          v-for="tip in tips" 
          :key="tip.id" 
          class="tip-card md3-card md3-ripple"
          @click="goToTip(tip.id)"
        >
          <!-- Tip Icon -->
          <div class="tip-icon">
            <span class="material-symbols-outlined">lightbulb</span>
            <span class="emoji-fallback">💡</span>
          </div>

          <!-- Tip Content -->
          <div class="tip-content">
            <h3 class="tip-title md3-title-medium">{{ tip.title }}</h3>
            <p v-if="tip.content" class="tip-description md3-body-medium dinor-text-gray">
              {{ getShortDescription(tip.content) }}
            </p>
            
            <!-- Tip Meta -->
            <div class="tip-meta">
              <div class="time" v-if="tip.created_at">
                <span class="material-symbols-outlined">schedule</span>
                <span class="emoji-fallback">⏰</span>
                <span>{{ formatDate(tip.created_at) }}</span>
              </div>
            </div>

            <!-- Tip Stats -->
            <div class="tip-stats">
              <div class="stat">
                <LikeButton
                  type="tip"
                  :item-id="tip.id"
                  :initial-liked="tip.is_liked || false"
                  :initial-count="tip.likes_count || 0"
                  :show-count="true"
                  size="small"
                  variant="minimal"
                  @auth-required="showAuthModal = true"
                  @click.stop=""
                />
              </div>
              <div class="stat">
                <FavoriteButton
                  type="tip"
                  :item-id="tip.id"
                  :initial-favorited="false"
                  :initial-count="tip.favorites_count || 0"
                  :show-count="true"
                  size="small"
                  variant="minimal"
                  @auth-required="showAuthModal = true"
                  @click.stop=""
                />
              </div>
              <div class="stat" v-if="tip.category">
                <span class="material-symbols-outlined">category</span>
                <span class="emoji-fallback">🏷️</span>
                <span>{{ tip.category.name }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '@/services/api'
import { useBanners } from '@/composables/useBanners'
import FavoriteButton from '@/components/common/FavoriteButton.vue'
import LikeButton from '@/components/common/LikeButton.vue'
import AuthModal from '@/components/common/AuthModal.vue'
import BannerSection from '@/components/common/BannerSection.vue'

export default {
  name: 'TipsList',
  components: {
    FavoriteButton,
    LikeButton,
    AuthModal,
    BannerSection
  },
  setup() {
    const router = useRouter()
    
    // Banner management
    const { banners, loadBannersForContentType } = useBanners()
    const bannersByType = computed(() => banners.value)
    
    // State
    const tips = ref([])
    const loading = ref(false)
    const error = ref(null)
    const showAuthModal = ref(false)
    
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
    
    const formatDate = (date) => {
      const options = { year: 'numeric', month: 'long', day: 'numeric' }
      return new Date(date).toLocaleDateString(undefined, options)
    }
    
    // Écouter les mises à jour de likes
    const handleLikeUpdate = (event) => {
      const { type, id, liked, count } = event.detail
      if (type === 'tip') {
        const tip = tips.value.find(t => t.id == id)
        if (tip) {
          tip.is_liked = liked
          tip.likes_count = count
        }
      }
    }

    // Lifecycle
    onMounted(async () => {
      await loadBannersForContentType('tips', true) // Force refresh sans cache
      loadTips()
      window.addEventListener('like-updated', handleLikeUpdate)
    })
    
    onUnmounted(() => {
      window.removeEventListener('like-updated', handleLikeUpdate)
    })
    
    return {
      tips,
      loading,
      error,
      showAuthModal,
      bannersByType,
      goToTip,
      retry,
      getDifficultyLabel,
      getShortDescription,
      formatDate
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

.tip-icon .material-symbols-outlined {
  font-size: 32px;
  color: #F59E0B;
}

.tip-icon .emoji-fallback {
  font-size: 30px;
  color: #F59E0B;
}

.time .material-symbols-outlined {
  font-size: 16px;
  color: #6B7280;
  margin-right: 4px;
}

.time .emoji-fallback {
  font-size: 14px;
  color: #6B7280;
  margin-right: 4px;
}

.stat .material-symbols-outlined {
  font-size: 16px;
  margin-right: 4px;
}

.stat .emoji-fallback {
  font-size: 14px;
  margin-right: 4px;
}
</style>