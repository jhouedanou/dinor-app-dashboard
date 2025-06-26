<template>
  <div class="tip-detail">
    <!-- Navigation Header -->
    <nav class="md3-top-app-bar">
      <div class="md3-app-bar-container">
        <button @click="goBack" class="md3-icon-button">
          <i class="material-icons">arrow_back</i>
        </button>
        <div class="md3-app-bar-title">
          <h1 class="md3-title-large dinor-text-primary">{{ tip?.title || 'Astuce' }}</h1>
        </div>
        <div class="md3-app-bar-actions">
          <button @click="toggleLike" class="md3-icon-button" :class="{ 'liked': userLiked }">
            <i class="material-icons">{{ userLiked ? 'favorite' : 'favorite_border' }}</i>
          </button>
          <button @click="shareTip" class="md3-icon-button">
            <i class="material-icons">share</i>
          </button>
        </div>
      </div>
    </nav>

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
              <div v-if="tip.difficulty_level" class="md3-chip tip-difficulty">
                <i class="material-icons">lightbulb</i>
                <span>{{ getDifficultyLabel(tip.difficulty_level) }}</span>
              </div>
              <div v-if="tip.category" class="md3-chip tip-category">
                <i class="material-icons">tag</i>
                <span>{{ tip.category.name }}</span>
              </div>
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
            <div class="md3-body-large dinor-text-gray" v-html="tip.content"></div>
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
        <button @click="goBack" class="btn-primary">Retour</button>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApi } from '@/composables/useApi'

export default {
  name: 'TipDetail',
  props: {
    id: {
      type: String,
      required: true
    }
  },
  setup(props) {
    const router = useRouter()
    const route = useRoute()
    const { request } = useApi()
    
    const tip = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const newComment = ref('')

    const loadTip = async () => {
      try {
        const data = await request(`/api/v1/tips/${props.id}`)
        if (data.success) {
          tip.value = data.data
          await loadComments()
          await checkUserLike()
        }
      } catch (error) {
        console.error('Erreur lors du chargement de l\'astuce:', error)
      } finally {
        loading.value = false
      }
    }

    const loadComments = async () => {
      try {
        const data = await request(`/api/v1/comments?type=tip&id=${props.id}`)
        if (data.success) {
          comments.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des commentaires:', error)
      }
    }

    const checkUserLike = async () => {
      try {
        const data = await request(`/api/v1/likes/check?type=tip&id=${props.id}`)
        userLiked.value = data.success && data.data.liked
      } catch (error) {
        console.error('Erreur lors de la vérification du like:', error)
      }
    }

    const toggleLike = async () => {
      try {
        const data = await request('/api/v1/likes/toggle', {
          method: 'POST',
          body: {
            likeable_type: 'tip',
            likeable_id: props.id
          }
        })
        if (data.success) {
          userLiked.value = !userLiked.value
          if (tip.value) {
            tip.value.likes_count = data.data.total_likes
          }
        }
      } catch (error) {
        console.error('Erreur lors du toggle like:', error)
      }
    }

    const addComment = async () => {
      if (!newComment.value.trim()) return
      
      try {
        const data = await request('/api/v1/comments', {
          method: 'POST',
          body: {
            type: 'tip',
            id: props.id,
            content: newComment.value,
            author_name: 'Utilisateur'
          }
        })
        if (data.success) {
          await loadComments()
          newComment.value = ''
        }
      } catch (error) {
        console.error('Erreur lors de l\'ajout du commentaire:', error)
      }
    }

    const shareTip = () => {
      if (navigator.share && tip.value) {
        navigator.share({
          title: tip.value.title,
          text: tip.value.content,
          url: window.location.href
        })
      } else {
        navigator.clipboard.writeText(window.location.href)
        alert('Lien copié dans le presse-papiers!')
      }
    }

    const goBack = () => {
      router.push('/tips')
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

    onMounted(() => {
      loadTip()
    })

    return {
      tip,
      comments,
      loading,
      userLiked,
      newComment,
      toggleLike,
      addComment,
      shareTip,
      goBack,
      getDifficultyLabel,
      formatDate,
      handleImageError
    }
  }
}
</script>

<style scoped>
.tip-detail {
  min-height: 100vh;
  background: var(--md-sys-color-surface);
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
  background: var(--md-sys-color-surface-variant);
  border-radius: 12px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
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
  background: var(--md-sys-color-surface-variant);
  border-radius: 8px;
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