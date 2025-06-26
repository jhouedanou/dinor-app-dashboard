<template>
  <div class="event-detail">
    <!-- Navigation Header -->
    <nav class="md3-top-app-bar">
      <div class="md3-app-bar-container">
        <button @click="goBack" class="md3-icon-button">
          <i class="material-icons">arrow_back</i>
        </button>
        <div class="md3-app-bar-title">
          <h1 class="md3-title-large dinor-text-primary">{{ event?.title || 'Événement' }}</h1>
        </div>
        <div class="md3-app-bar-actions">
          <button @click="toggleLike" class="md3-icon-button" :class="{ 'liked': userLiked }">
            <i class="material-icons">{{ userLiked ? 'favorite' : 'favorite_border' }}</i>
          </button>
          <button @click="shareEvent" class="md3-icon-button">
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
        <p class="md3-body-large">Chargement de l'événement...</p>
      </div>

      <!-- Event Content -->
      <div v-else-if="event" class="event-content">
        <!-- Hero Image -->
        <div v-if="event.image" class="event-hero">
          <img 
            :src="event.image || '/images/default-recipe.jpg'" 
            :alt="event.title"
            class="event-hero-image"
            @error="handleImageError">
          <div class="event-overlay dinor-gradient-primary">
            <div class="event-badges">
              <div v-if="event.location" class="md3-chip event-location">
                <i class="material-icons">location_on</i>
                <span>{{ event.location }}</span>
              </div>
              <div v-if="event.category" class="md3-chip event-category">
                <i class="material-icons">tag</i>
                <span>{{ event.category.name }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Event Info -->
        <div class="event-info">
          <div class="event-stats">
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">event</i>
              <span class="md3-body-medium">{{ formatEventDate(event.start_date) }}</span>
            </div>
            <div class="stat-item" v-if="event.start_time">
              <i class="material-icons dinor-text-secondary">schedule</i>
              <span class="md3-body-medium">{{ event.start_time }}</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">favorite</i>
              <span class="md3-body-medium">{{ event.likes_count || 0 }}</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">comment</i>
              <span class="md3-body-medium">{{ event.comments_count || 0 }}</span>
            </div>
          </div>

          <!-- Date and Location Info -->
          <div class="event-details">
            <div class="detail-item">
              <h3 class="md3-title-small dinor-text-primary">Date et Heure</h3>
              <p class="md3-body-medium">
                {{ formatEventDate(event.start_date) }}
                <span v-if="event.start_time"> à {{ event.start_time }}</span>
                <span v-if="event.end_date && event.end_date !== event.start_date">
                  - {{ formatEventDate(event.end_date) }}
                  <span v-if="event.end_time"> à {{ event.end_time }}</span>
                </span>
              </p>
            </div>

            <div v-if="event.location" class="detail-item">
              <h3 class="md3-title-small dinor-text-primary">Lieu</h3>
              <p class="md3-body-medium">{{ event.location }}</p>
            </div>
          </div>

          <!-- Description -->
          <div v-if="event.content" class="event-description">
            <h2 class="md3-title-medium dinor-text-primary">Description</h2>
            <div class="md3-body-large dinor-text-gray" v-html="formatContent(event.content)"></div>
          </div>

          <!-- Registration Info -->
          <div v-if="event.registration_required" class="event-registration">
            <h3 class="md3-title-small dinor-text-primary">Inscription</h3>
            <p class="md3-body-medium">
              <i class="material-icons dinor-text-secondary">info</i>
              Inscription requise pour cet événement
            </p>
            <div v-if="event.max_attendees" class="registration-info">
              <p class="md3-body-small dinor-text-gray">
                Places limitées: {{ event.max_attendees }} personnes maximum
              </p>
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
        <h2 class="md3-title-large">Événement introuvable</h2>
        <p class="md3-body-large dinor-text-gray">L'événement demandé n'existe pas ou a été supprimé.</p>
        <div class="error-actions">
          <button @click="goBack" class="btn-secondary">Retour aux événements</button>
          <button @click="goHome" class="btn-primary">Accueil</button>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApiStore } from '@/stores/api'

export default {
  name: 'EventDetail',
  props: {
    id: {
      type: String,
      required: true
    }
  },
  setup(props) {
    const router = useRouter()
    const route = useRoute()
    const apiStore = useApiStore()
    
    const event = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const newComment = ref('')

    const loadEvent = async () => {
      try {
        const data = await apiStore.get(`/events/${props.id}`)
        if (data.success) {
          event.value = data.data
          await loadComments()
          await checkUserLike()
        }
      } catch (error) {
        console.error('Erreur lors du chargement de l\'événement:', error)
      } finally {
        loading.value = false
      }
    }

    const loadComments = async () => {
      try {
        const data = await apiStore.get(`/comments`, { type: 'event', id: props.id })
        if (data.success) {
          comments.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des commentaires:', error)
      }
    }

    const checkUserLike = async () => {
      try {
        const data = await apiStore.get(`/likes/check`, { type: 'event', id: props.id })
        userLiked.value = data.success && data.data.liked
      } catch (error) {
        console.error('Erreur lors de la vérification du like:', error)
      }
    }

    const toggleLike = async () => {
      try {
        const data = await apiStore.post('/likes/toggle', {
          likeable_type: 'event',
          likeable_id: props.id
        })
        if (data.success) {
          userLiked.value = !userLiked.value
          if (event.value) {
            event.value.likes_count = data.data.total_likes
          }
        }
      } catch (error) {
        console.error('Erreur lors du toggle like:', error)
      }
    }

    const addComment = async () => {
      if (!newComment.value.trim()) return
      
      try {
        const data = await apiStore.post('/comments', {
          type: 'event',
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

    const shareEvent = () => {
      if (navigator.share && event.value) {
        navigator.share({
          title: event.value.title,
          text: event.value.content,
          url: window.location.href
        })
      } else {
        navigator.clipboard.writeText(window.location.href)
        alert('Lien copié dans le presse-papiers!')
      }
    }

    const goBack = () => {
      router.push('/events')
    }

    const goHome = () => {
      router.push('/')
    }

    const formatEventDate = (date) => {
      return new Date(date).toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
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
      loadEvent()
    })

    return {
      event,
      comments,
      loading,
      userLiked,
      newComment,
      toggleLike,
      addComment,
      shareEvent,
      goBack,
      goHome,
      formatEventDate,
      formatDate,
      handleImageError,
      formatContent
    }
  }
}
</script>

<style scoped>
.event-detail {
  min-height: 100vh;
  background: var(--md-sys-color-surface);
}

.event-hero {
  position: relative;
  height: 250px;
  overflow: hidden;
}

.event-hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.event-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  padding: 1rem;
}

.event-badges {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.event-info {
  padding: 1rem;
}

.event-stats {
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

.event-details {
  margin-bottom: 2rem;
}

.detail-item {
  margin-bottom: 1rem;
  padding: 1rem;
  background: var(--md-sys-color-surface-variant);
  border-radius: 8px;
}

.event-description,
.event-registration,
.comments-section {
  margin-bottom: 2rem;
}

.event-registration {
  padding: 1rem;
  background: var(--md-sys-color-primary-container);
  border-radius: 8px;
}

.registration-info {
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