<template>
  <div class="tip-detail">
    <!-- Main Content -->
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement de l'astuce...</p>
      </div>

      <!-- Tip Content -->
      <div v-else-if="tip" class="tip-content">
        <!-- Hero Image -->
        <div v-if="tip.image" class="tip-hero">
          <img 
            :src="tip.image || '/images/default-recipe.jpg'" 
            :alt="tip.title"
            class="tip-hero-image"
            @error="handleImageError">
          <div class="tip-overlay dinor-gradient-primary">
            <div class="tip-badges">
              <Badge 
                v-if="tip.difficulty_level"
                :text="getDifficultyLabel(tip.difficulty_level)"
                icon="lightbulb"
                variant="secondary"
                size="medium"
              />
              <Badge 
                v-if="tip.category"
                :text="tip.category.name"
                icon="tag"
                variant="neutral"
                size="medium"
              />
            </div>
          </div>
        </div>

        <!-- Tip Info -->
        <div class="tip-info">
          <div class="tip-stats">
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">schedule</i>
              <span class="md3-body-medium">{{ tip.estimated_time }}min</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">favorite</i>
              <span class="md3-body-medium">{{ tip.likes_count || 0 }}</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">comment</i>
              <span class="md3-body-medium">{{ tip.comments_count || 0 }}</span>
            </div>
          </div>

          <!-- Content -->
          <div class="tip-content-text">
            <h2 class="md3-title-medium dinor-text-primary">Astuce</h2>
            <div class="md3-body-large dinor-text-gray" v-html="formatContent(tip.content)"></div>
          </div>

          <!-- Tags -->
          <div v-if="tip.tags && tip.tags.length" class="tip-tags">
            <h3 class="md3-title-small dinor-text-primary">Tags</h3>
            <div class="tags-container">
              <span v-for="tag in tip.tags" :key="tag" class="md3-chip">{{ tag }}</span>
            </div>
          </div>

          <!-- Comments Section -->
          <div class="comments-section">
            <h2 class="md3-title-medium dinor-text-primary">Commentaires ({{ comments.length }})</h2>
            
            <!-- Add Comment Form -->
            <div class="add-comment-form">
              <textarea 
                v-model="newComment" 
                placeholder="Ajoutez votre commentaire..." 
                class="md3-textarea"
                rows="3">
              </textarea>
              <button @click="addComment" class="btn-primary" :disabled="!newComment.trim()">
                Publier
              </button>
            </div>

            <!-- Comments List -->
            <div v-if="comments.length" class="comments-list">
              <div v-for="comment in comments" :key="comment.id" class="comment-item">
                <div class="comment-header">
                  <span class="comment-author md3-body-medium">{{ comment.author_name }}</span>
                  <span class="comment-date md3-body-small dinor-text-gray">{{ formatDate(comment.created_at) }}</span>
                </div>
                <p class="comment-content md3-body-medium">{{ comment.content }}</p>
              </div>
            </div>
            <div v-else class="empty-comments">
              <p class="md3-body-medium dinor-text-gray">Aucun commentaire pour le moment.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Error State -->
      <div v-else class="error-state">
        <div class="error-icon">
          <i class="material-icons">error_outline</i>
        </div>
        <h2 class="md3-title-large">Astuce introuvable</h2>
        <p class="md3-body-large dinor-text-gray">L'astuce demandée n'existe pas ou a été supprimée.</p>
        <div class="error-actions">
          <button @click="goBack" class="btn-secondary">Retour aux astuces</button>
          <button @click="goHome" class="btn-primary">Accueil</button>
        </div>
      </div>
    </main>
    
    <!-- Share Modal -->
    <ShareModal 
      v-model="showShareModal" 
      :share-data="shareData"
    />
  </div>
</template>

<script>
import { ref, onMounted, computed, defineExpose } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'
import { useSocialShare } from '@/composables/useSocialShare'
import Badge from '@/components/common/Badge.vue'
import ShareModal from '@/components/common/ShareModal.vue'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'TipDetail',
  emits: ['update-header'],
  components: {
    Badge,
    ShareModal,
    AuthModal
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  setup(props, { emit }) {
    const router = useRouter()
    const route = useRoute()
    const apiStore = useApiStore()
    const { share, showShareModal, updateOpenGraphTags } = useSocialShare()
    
    const tip = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const newComment = ref('')

    const shareData = computed(() => {
      if (!tip.value) return {}
      return {
        title: tip.value.title,
        text: `Découvrez cette astuce pratique : ${tip.value.title}`,
        url: window.location.href,
        image: tip.value.image,
        type: 'tip',
        id: tip.value.id
      }
    })

    const loadTip = async () => {
      try {
        const data = await apiStore.get(`/tips/${props.id}`)
        if (data.success) {
          tip.value = data.data
          await loadComments()
          await checkUserLike()
          
          // Mettre à jour les métadonnées Open Graph
          updateOpenGraphTags(shareData.value)
          
          // Mettre à jour le header avec le titre de l'astuce
          emit('update-header', {
            title: tip.value.title || 'Astuce',
            showLike: true,
            showShare: true,
            isLiked: userLiked.value,
            backPath: '/tips'
          })
        }
      } catch (error) {
        console.error('Erreur lors du chargement de l\'astuce:', error)
      } finally {
        loading.value = false
      }
    }

    const loadComments = async () => {
      try {
        const data = await apiStore.get(`/comments`, { type: 'tip', id: props.id })
        if (data.success) {
          comments.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des commentaires:', error)
      }
    }

    const checkUserLike = async () => {
      try {
        const data = await apiStore.get(`/likes/check`, { type: 'tip', id: props.id })
        userLiked.value = data.success && data.is_liked
      } catch (error) {
        console.error('Erreur lors de la vérification du like:', error)
      }
    }

    const toggleLike = async () => {
      try {
        const data = await apiStore.post('/likes/toggle', {
          likeable_type: 'tip',
          likeable_id: props.id
        })
        if (data.success) {
          userLiked.value = !userLiked.value
          if (tip.value) {
            tip.value.likes_count = data.data.total_likes
          }
          
          // Mettre à jour le statut like dans le header
          emit('update-header', {
            isLiked: userLiked.value
          })
        }
      } catch (error) {
        console.error('Erreur lors du toggle like:', error)
      }
    }

    const addComment = async () => {
      if (!newComment.value.trim()) return
      
      try {
        const data = await apiStore.post('/comments', {
          type: 'tip',
          id: props.id,
          content: newComment.value,
          author_name: 'Utilisateur'
        })
        if (data.success) {
          await loadComments()
          newComment.value = ''
        }
      } catch (error) {
        console.error('Erreur lors de l\'ajout du commentaire:', error)
      }
    }

    // Composable pour le partage social
    const callShare = () => {
      share(shareData.value)
    }
    
    const goBack = () => {
      router.push('/tips')
    }

    const goHome = () => {
      router.push('/')
    }

    const getDifficultyLabel = (level) => {
      const labels = {
        'beginner': 'Débutant',
        'intermediate': 'Intermédiaire', 
        'advanced': 'Avancé'
      }
      return labels[level] || 'Débutant'
    }

    const formatDate = (date) => {
      return new Date(date).toLocaleDateString('fr-FR')
    }

    const handleImageError = (event) => {
      event.target.src = '/images/default-recipe.jpg'
    }

    const formatContent = (content) => {
      if (!content) return ''
      
      // Si c'est déjà une chaîne, la retourner
      if (typeof content === 'string') return content
      
      // Si c'est un array d'objets, les formater
      if (Array.isArray(content)) {
        return content.map((item, index) => {
          if (typeof item === 'object' && item.step) {
            return `<div class="content-step">
              <h4>Étape ${index + 1}</h4>
              <p>${item.step}</p>
            </div>`
          } else if (typeof item === 'string') {
            return `<div class="content-step">
              <p>${item}</p>
            </div>`
          }
          return `<div class="content-step"><p>${item}</p></div>`
        }).join('')
      }
      
      return content.toString()
    }

    onMounted(() => {
      loadTip()
    })

    // Exposer la fonction share pour le composant parent
    defineExpose({
      share: callShare,
      toggleLike
    })

    return {
      tip,
      comments,
      loading,
      userLiked,
      newComment,
      toggleLike,
      addComment,
      goBack,
      goHome,
      getDifficultyLabel,
      formatDate,
      handleImageError,
      formatContent,
      showShareModal,
      shareData
    }
  }
}
</script>

<style scoped>
.tip-detail {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc comme Home */
  font-family: 'Roboto', sans-serif;
}

/* Typographie globale */
h1, h2, h3, h4, h5, h6 {
  font-family: 'Open Sans', sans-serif; /* Open Sans pour les titres */
  font-weight: 600;
  color: #2D3748; /* Couleur foncée pour bon contraste */
  line-height: 1.3;
}

p, span, div {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  color: #4A5568; /* Couleur grise pour bon contraste */
  line-height: 1.5;
}

.tip-hero {
  position: relative;
  height: 250px;
  overflow: hidden;
}

.tip-hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.tip-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  padding: 1rem;
}

.tip-badges {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.tip-info {
  padding: 1rem;
}

.tip-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #F4D03F; /* Fond doré */
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

@media (max-width: 480px) {
  .tip-stats {
    flex-wrap: wrap;
    gap: 0.5rem;
    justify-content: center;
  }
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  color: #2D3748; /* Couleur foncée pour contraste sur fond doré */
  font-weight: 500;
  min-width: 80px;
}

@media (max-width: 480px) {
  .stat-item {
    min-width: 60px;
    font-size: 0.9rem;
  }
}

.tip-content-text,
.tip-tags,
.comments-section {
  margin-bottom: 2rem;
}

.tags-container {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin-top: 0.5rem;
}

.add-comment-form {
  margin-bottom: 1rem;
}

.md3-textarea {
  width: 100%;
  min-height: 80px;
  padding: 0.75rem;
  border: 1px solid var(--md-sys-color-outline);
  border-radius: 8px;
  margin-bottom: 0.5rem;
  resize: vertical;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.comment-item {
  padding: 1rem;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: box-shadow 0.2s ease;
}

.comment-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.loading-container,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  padding: 2rem;
  text-align: center;
}

.error-icon i {
  font-size: 4rem;
  color: var(--md-sys-color-error);
  margin-bottom: 1rem;
}

.md3-icon-button.liked {
  color: var(--md-sys-color-error);
}
</style> 