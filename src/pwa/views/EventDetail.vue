<template>
  <div class="event-detail">
    <!-- Navigation Header -->
    <AppHeader 
      :title="event?.title || 'Événement'"
      :show-like="true"
      :show-share="true"
      :is-liked="userLiked"
      back-path="/events"
      @like="toggleLike"
      @share="shareEvent"
      @back="goBack"
    />

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
import AppHeader from '@/components/common/AppHeader.vue'

export default {
  name: 'EventDetail',
  components: {
    AppHeader
  },
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
/* Styles globaux */
.event-detail {
  min-height: 100vh;
  background: #FFFFFF; /* Fond blanc pour tous les écrans */
  font-family: 'Roboto', sans-serif;
}

/* Typographie globale */
h1, h2, h3, h4, h5, h6 {
  font-family: 'Open Sans', sans-serif; /* Open Sans pour les titres */
  font-weight: 600;
  color: #000000; /* Noir pour les titres - contraste 21:1 */
  line-height: 1.3;
}

p, span, div {
  font-family: 'Roboto', sans-serif; /* Roboto pour les textes */
  color: #2D3748; /* Couleur foncée pour contraste 12.6:1 */
  line-height: 1.5;
}

/* Styles spécifiques au composant EventDetail (sans l'en-tête qui est maintenant externalisé) */

/* Contenu principal */
.md3-main-content {
  padding: 16px;
}

.event-hero {
  position: relative;
  height: 250px;
  overflow: hidden;
  border-radius: 16px;
  margin-bottom: 24px;
}

.event-hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: brightness(1.1) contrast(1.1); /* Améliorer la luminosité des images */
}

.event-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  padding: 16px;
  border-radius: 0 0 16px 16px;
}

.event-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.md3-chip {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 8px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.event-location {
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
}

.event-category {
  background: #F4D03F; /* Doré */
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
}

.event-info {
  max-width: 1200px;
  margin: 0 auto;
}

.event-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 24px;
  padding: 16px;
  background: #F4D03F; /* Fond doré */
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-item i {
  font-size: 24px;
  color: #E53E3E; /* Rouge Dinor sur doré */
}

.stat-item span {
  font-size: 14px;
  font-weight: 600;
  color: #2D3748; /* Couleur foncée sur doré - contraste 3.8:1 */
}

.event-details {
  margin-bottom: 24px;
}

.detail-item {
  margin-bottom: 16px;
  padding: 16px;
  background: #FFFFFF; /* Fond blanc */
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.detail-item h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 700;
  color: #000000; /* Noir - contraste 21:1 */
}

.detail-item p {
  margin: 0;
  font-size: 14px;
  color: #2D3748; /* Couleur foncée - contraste 12.6:1 */
}

.event-description,
.event-registration,
.comments-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #FFFFFF; /* Fond blanc */
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.event-description h2,
.comments-section h2 {
  margin: 0 0 16px 0;
  font-size: 24px;
  font-weight: 700;
  color: #000000; /* Noir - contraste 21:1 */
}

.event-registration {
  background: #F7FAFC; /* Fond très clair */
  border-color: #E53E3E; /* Bordure rouge */
}

.event-registration h3 {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 700;
  color: #E53E3E; /* Rouge Dinor */
}

.event-registration p {
  margin: 0;
  font-size: 14px;
  color: #2D3748; /* Couleur foncée - contraste 12.6:1 */
}

.registration-info {
  margin-top: 8px;
}

.registration-info p {
  font-size: 12px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
}

.add-comment-form {
  margin-bottom: 24px;
}

.md3-textarea {
  width: 100%;
  min-height: 80px;
  padding: 12px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  margin-bottom: 12px;
  resize: vertical;
  font-family: 'Roboto', sans-serif;
  font-size: 14px;
  color: #2D3748; /* Couleur foncée */
  background: #FFFFFF; /* Fond blanc */
}

.md3-textarea:focus {
  outline: none;
  border-color: #E53E3E; /* Rouge Dinor */
  box-shadow: 0 0 0 2px rgba(229, 62, 62, 0.2);
}

.btn-primary {
  padding: 12px 24px;
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge - contraste 4.5:1 */
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary:hover:not(:disabled) {
  background: #C53030; /* Rouge plus foncé */
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
}

.btn-primary:disabled {
  background: #CBD5E0; /* Gris clair */
  color: #A0AEC0; /* Gris moyen */
  cursor: not-allowed;
}

.btn-secondary {
  padding: 12px 24px;
  background: #FFFFFF; /* Fond blanc */
  color: #E53E3E; /* Rouge Dinor */
  border: 1px solid #E53E3E;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: #E53E3E; /* Rouge Dinor */
  color: #FFFFFF; /* Blanc sur rouge */
  transform: translateY(-1px);
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-item {
  padding: 16px;
  background: #F7FAFC; /* Fond très clair */
  border-radius: 8px;
  border: 1px solid #E2E8F0;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.comment-author {
  font-weight: 700;
  color: #2D3748; /* Couleur foncée */
}

.comment-date {
  font-size: 12px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
}

.comment-content {
  margin: 0;
  font-size: 14px;
  color: #2D3748; /* Couleur foncée */
  line-height: 1.5;
}

.empty-comments {
  text-align: center;
  padding: 24px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
}

.loading-container,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  padding: 32px;
  text-align: center;
}

.loading-container .md3-circular-progress {
  width: 48px;
  height: 48px;
  border: 4px solid #E2E8F0;
  border-top: 4px solid #E53E3E;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-state .error-icon {
  margin-bottom: 16px;
}

.error-state .error-icon i {
  font-size: 64px;
  color: #E53E3E; /* Rouge Dinor */
}

.error-state h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 700;
  color: #000000; /* Noir - contraste 21:1 */
}

.error-state p {
  margin: 0 0 24px 0;
  font-size: 16px;
  color: #4A5568; /* Gris foncé - contraste 7.5:1 */
}

.error-actions {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

/* Responsive */
@media (max-width: 768px) {
  .event-stats {
    flex-direction: column;
    gap: 16px;
  }
  
  .stat-item {
    flex-direction: row;
    justify-content: center;
  }
  
  .error-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .error-actions button {
    width: 100%;
    max-width: 200px;
  }
}
</style> 