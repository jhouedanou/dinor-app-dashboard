<template>
  <div class="event-detail">
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
        <div v-if="event.featured_image_url" class="event-hero">
          <img 
            :src="event.featured_image_url || '/images/default-recipe.jpg'" 
            :alt="event.title"
            class="event-hero-image"
            @error="handleImageError">
          <div class="event-overlay dinor-gradient-primary">
            <div class="event-badges">
              <div v-if="event.location" class="md3-chip event-location">
                <DinorIcon name="location_on" :size="16" />
                <span>{{ event.location }}</span>
              </div>
              <div v-if="event.category" class="md3-chip event-category">
                <DinorIcon name="tag" :size="16" />
                <span>{{ event.category.name }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Event Info -->
        <div class="event-info">
          <div class="event-stats">
            <div class="stat-item" v-if="event.start_date">
              <DinorIcon name="calendar_today" :size="16" />
              <span class="md3-body-medium">{{ formatEventDate(event.start_date) }}</span>
            </div>
            <div class="stat-item" v-if="event.start_time">
              <DinorIcon name="schedule" :size="16" />
              <span class="md3-body-medium">{{ formatTime(event.start_time) }}</span>
            </div>
            <div class="stat-item" v-if="event.location">
              <DinorIcon name="place" :size="16" />
              <span class="md3-body-medium">{{ event.location }}</span>
            </div>
            <div class="stat-item">
              <DinorIcon name="favorite" :size="16" />
              <span class="md3-body-medium">{{ event.likes_count || 0 }}</span>
            </div>
            <div class="stat-item">
              <DinorIcon name="comment" :size="16" />
              <span class="md3-body-medium">{{ event.comments_count || 0 }}</span>
            </div>
          </div>

          <!-- Date and Location Info -->
          <div class="event-details">
            <div class="detail-item">
              <h3 class="md3-title-small dinor-text-primary">Date et Heure</h3>
              <p class="md3-body-medium">
                {{ formatEventDateDetailed(event.start_date) }}
                <span v-if="event.start_time"> à {{ formatTime(event.start_time) }}</span>
                <span v-if="event.end_date && event.end_date !== event.start_date">
                  - {{ formatEventDateDetailed(event.end_date) }}
                  <span v-if="event.end_time"> à {{ formatTime(event.end_time) }}</span>
                </span>
              </p>
            </div>

            <div v-if="event.location" class="detail-item">
              <h3 class="md3-title-small dinor-text-primary">Lieu</h3>
              <p class="md3-body-medium">{{ event.location }}</p>
            </div>
          </div>

          <!-- Calendar Links -->
          <div class="calendar-links">
            <h3 class="md3-title-small dinor-text-primary">Ajouter à votre agenda</h3>
            <div class="calendar-buttons">
              <button @click="addToGoogleCalendar" class="calendar-button google-calendar">
                <span class="material-symbols-outlined">event</span>
                <span class="emoji-fallback">📅</span>
                Google Calendar
              </button>
              <button @click="addToIcal" class="calendar-button ical">
                <span class="material-symbols-outlined">calendar_month</span>
                <span class="emoji-fallback">🗓️</span>
                iCal / Outlook
              </button>
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
              <span class="material-symbols-outlined dinor-text-secondary">info</span>
              <span class="emoji-fallback dinor-text-secondary">ℹ️</span>
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
              <div v-if="!authStore.isAuthenticated" class="auth-prompt">
                <p class="auth-prompt-text">Connectez-vous pour laisser un commentaire</p>
                <button @click="showAuthModal = true" class="btn-primary">
                  Se connecter
                </button>
              </div>
              <div v-else>
                <div class="authenticated-user">
                  <span class="user-info">Connecté en tant que {{ authStore.userName }}</span>
                  <button @click="authStore.logout()" class="btn-logout">Déconnexion</button>
                </div>
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
            </div>

            <!-- Comments List -->
            <div v-if="comments.length" class="comments-list">
              <div v-for="comment in comments" :key="comment.id" class="comment-item">
                <div class="comment-header">
                  <div class="comment-meta">
                    <span class="comment-author md3-body-medium">{{ comment.author_name }}</span>
                    <span class="comment-date md3-body-small dinor-text-gray">{{ formatDate(comment.created_at) }}</span>
                  </div>
                  <div v-if="canDeleteComment(comment)" class="comment-actions">
                    <button @click="deleteComment(comment.id)" class="btn-delete" title="Supprimer le commentaire">
                      <span class="material-symbols-outlined">delete</span>
                      <span class="emoji-fallback">🗑️</span>
                    </button>
                  </div>
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
          <span class="material-symbols-outlined">error</span>
          <span class="emoji-fallback">⚠️</span>
        </div>
        <h2 class="md3-title-large">Événement introuvable</h2>
        <p class="md3-body-large dinor-text-gray">L'événement demandé n'existe pas ou a été supprimé.</p>
        <div class="error-actions">
          <button @click="goBack" class="btn-secondary">Retour aux événements</button>
          <button @click="goHome" class="btn-primary">Accueil</button>
        </div>
      </div>
    </main>
    
    <!-- Share Modal -->
    <ShareModal 
      v-model="showShareModal" 
      :share-data="shareData"
    />

    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" />
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'
import { useSocialShare } from '@/composables/useSocialShare'
import { useComments } from '@/composables/useComments'
import ShareModal from '@/components/common/ShareModal.vue'
import AuthModal from '@/components/common/AuthModal.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'EventDetail',
  emits: ['update-header'],
  components: {
    ShareModal,
    AuthModal,
    DinorIcon
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  setup(props, { emit }) {
    const router = useRouter()
    const apiStore = useApiStore()
    const authStore = useAuthStore()
    const { share, showShareModal, updateOpenGraphTags } = useSocialShare()
    const { comments, loadComments, loadCommentsFresh, canDeleteComment, deleteComment, setContext, addComment: addCommentFromComposable } = useComments()
    
    const event = ref(null)
    const loading = ref(true)
    const userLiked = ref(false)
    const userFavorited = ref(false)
    const newComment = ref('')
    const showAuthModal = ref(false)

    const shareData = computed(() => {
      if (!event.value) return {}
      return {
        title: event.value.title,
        text: `Ne manquez pas cet événement : ${event.value.title}`,
        url: window.location.href,
        image: event.value.image,
        type: 'event',
        id: event.value.id
      }
    })

    const loadEvent = async () => {
      try {
        const data = await apiStore.get(`/events/${props.id}`)
        if (data.success) {
          event.value = data.data
          // Définir le contexte pour les commentaires
          setContext('Event', props.id)
          await loadComments()
          await checkUserLike()
          await checkUserFavorite()
          
          // Mettre à jour les métadonnées Open Graph
          updateOpenGraphTags(shareData.value)
          
          // Mettre à jour le header avec le titre de l'événement
          emit('update-header', {
            title: event.value.title || 'Événement',
            showShare: true,
            showFavorite: true,
            favoriteType: 'event',
            favoriteItemId: parseInt(props.id),
            isContentFavorited: userFavorited.value,
            backPath: '/events'
          })
        }
      } catch (error) {
        console.error('Erreur lors du chargement de l\'événement:', error)
      } finally {
        loading.value = false
      }
    }



    const checkUserLike = async () => {
      try {
        const data = await apiStore.get(`/likes/check`, { type: 'event', id: props.id })
        userLiked.value = data.success && data.is_liked
      } catch (error) {
        console.error('Erreur lors de la vérification du like:', error)
      }
    }

    const checkUserFavorite = async () => {
      try {
        const data = await apiStore.get(`/favorites/check`, { type: 'event', id: props.id })
        userFavorited.value = data.success && data.is_favorited
      } catch (error) {
        console.error('Erreur lors de la vérification du favori:', error)
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
          
          // Mettre à jour le statut like dans le header
          emit('update-header', {
            isLiked: userLiked.value
          })
        }
      } catch (error) {
        console.error('Erreur lors du toggle like:', error)
      }
    }

    const toggleFavorite = async () => {
      try {
        const data = await apiStore.post('/favorites/toggle', {
          favoritable_type: 'event',
          favoritable_id: props.id
        })
        if (data.success) {
          userFavorited.value = !userFavorited.value
          if (event.value) {
            event.value.favorites_count = data.data.total_favorites
          }
          
          // Mettre à jour le statut favori dans le header
          emit('update-header', {
            isContentFavorited: userFavorited.value
          })
        }
      } catch (error) {
        console.error('Erreur lors du toggle favori:', error)
      }
    }

    const addComment = async () => {
      if (!newComment.value.trim()) return
      
      if (!authStore.isAuthenticated) {
        showAuthModal.value = true
        return
      }
      
      try {
        console.log('📝 [Comments] Envoi du commentaire pour Event:', props.id)
        
        // Utiliser la fonction du composable
        await addCommentFromComposable('Event', props.id, newComment.value)
        
        console.log('✅ [Comments] Commentaire ajouté avec succès')
        newComment.value = ''
      } catch (error) {
        console.error('❌ [Comments] Erreur lors de l\'ajout du commentaire:', error)
        
        // Si erreur 401, demander connexion
        if (error.message.includes('401') || error.message.includes('connecté')) {
          showAuthModal.value = true
        }
      }
    }



    // Composable pour le partage social
    const callShare = () => {
      share(shareData.value)
    }

    const goBack = () => {
      router.push('/events')
    }

    const goHome = () => {
      router.push('/')
    }

    const formatEventDate = (date) => {
      if (!date) return ''
      return new Date(date).toLocaleDateString('fr-FR', {
        weekday: 'short',
        day: 'numeric',
        month: 'short'
      })
    }

    const formatEventDateDetailed = (date) => {
      if (!date) return ''
      return new Date(date).toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }

    const formatTime = (time) => {
      if (!time) return ''
      // Si c'est déjà au format HH:MM, le retourner
      if (time.match(/^\d{2}:\d{2}$/)) {
        return time
      }
      // Si c'est un timestamp ou une date, extraire l'heure
      try {
        const date = new Date(time)
        return date.toLocaleTimeString('fr-FR', {
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch {
        return time
      }
    }

    const formatCommentDate = (date) => {
      if (!date) return ''
      const now = new Date()
      const commentDate = new Date(date)
      const diffTime = now - commentDate
      const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
      const diffHours = Math.floor(diffTime / (1000 * 60 * 60))
      const diffMinutes = Math.floor(diffTime / (1000 * 60))

      if (diffMinutes < 1) {
        return 'À l\'instant'
      } else if (diffMinutes < 60) {
        return `Il y a ${diffMinutes} min`
      } else if (diffHours < 24) {
        return `Il y a ${diffHours} h`
      } else if (diffDays < 7) {
        return `Il y a ${diffDays} jour${diffDays > 1 ? 's' : ''}`
      } else {
        return commentDate.toLocaleDateString('fr-FR', {
          day: 'numeric',
          month: 'short',
          year: commentDate.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
        })
      }
    }

    const formatDate = (date) => {
      if (!date) return ''
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

    const formatDateForCalendar = (date, time) => {
      if (!date) return ''
      const dateObj = new Date(date)
      if (time) {
        const [hours, minutes] = time.split(':')
        dateObj.setHours(parseInt(hours), parseInt(minutes))
      }
      return dateObj.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '')
    }

    const addToGoogleCalendar = () => {
      if (!event.value) return
      
      const title = encodeURIComponent(event.value.title)
      const description = encodeURIComponent(event.value.content ? event.value.content.replace(/<[^>]*>/g, '') : '')
      const location = encodeURIComponent(event.value.location || '')
      const startDate = formatDateForCalendar(event.value.start_date, event.value.start_time)
      const endDate = formatDateForCalendar(event.value.end_date || event.value.start_date, event.value.end_time || event.value.start_time)
      
      const url = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${title}&dates=${startDate}/${endDate}&details=${description}&location=${location}&sf=true&output=xml`
      
      window.open(url, '_blank')
    }

    const addToIcal = () => {
      if (!event.value) return
      
      const title = event.value.title
      const description = event.value.content ? event.value.content.replace(/<[^>]*>/g, '') : ''
      const location = event.value.location || ''
      const startDate = formatDateForCalendar(event.value.start_date, event.value.start_time)
      const endDate = formatDateForCalendar(event.value.end_date || event.value.start_date, event.value.end_time || event.value.start_time)
      
      const icalContent = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Dinor//Event//EN
BEGIN:VEVENT
UID:${event.value.id}@dinor.com
DTSTART:${startDate}
DTEND:${endDate}
SUMMARY:${title}
DESCRIPTION:${description}
LOCATION:${location}
END:VEVENT
END:VCALENDAR`
      
      const blob = new Blob([icalContent], { type: 'text/calendar;charset=utf-8' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `${title.replace(/[^a-zA-Z0-9]/g, '_')}.ics`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)
    }

    onMounted(() => {
      loadEvent()
    })

    return {
      event,
      comments,
      loading,
      userLiked,
      userFavorited,
      newComment,
      toggleLike,
      toggleFavorite,
      addComment,
      canDeleteComment,
      deleteComment,
      goBack,
      goHome,
      formatEventDate,
      formatEventDateDetailed,
      formatTime,
      formatCommentDate,
      formatDate,
      handleImageError,
      formatContent,
      showShareModal,
      shareData,
      authStore,
      showAuthModal,
      addToGoogleCalendar,
      addToIcal
    }
  }
}
</script>

<style scoped>
@import '../assets/styles/comments.css';

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
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
  padding: 16px;
  background: #F4D03F; /* Fond doré */
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
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

.error-state .error-icon span.material-symbols-outlined {
  font-size: 64px;
  color: #E53E3E; /* Rouge Dinor */
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 48;
}

.error-state .error-icon .emoji-fallback {
  font-size: 64px;
  color: #E53E3E; /* Rouge Dinor */
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

/* Styles spécifiques pour les icônes */
.event-stats .material-symbols-outlined {
  font-size: 20px;
  margin-right: 8px;
}

/* Styles pour les puces event-badges */
.md3-chip .material-symbols-outlined {
  font-size: 18px;
  margin-right: 6px;
}

.md3-chip .emoji-fallback {
  font-size: 16px;
  margin-right: 6px;
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
    flex-direction: row;
    gap: 12px;
    flex-wrap: wrap;
  }
  
  .stat-item {
    justify-content: flex-start;
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

/* Calendar Links Styles */
.calendar-links {
  margin: 2rem 0;
  padding: 1.5rem;
  background: #F8F9FA;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
}

.calendar-links h3 {
  margin-bottom: 1rem;
  color: #2D3748;
}

.calendar-buttons {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.calendar-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 8px;
  background: #FFFFFF;
  color: #2D3748;
  font-weight: 500;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.calendar-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.calendar-button.google-calendar {
  background: #4285F4;
  color: white;
}

.calendar-button.google-calendar:hover {
  background: #3367D6;
}

.calendar-button.ical {
  background: #FF6900;
  color: white;
}

.calendar-button.ical:hover {
  background: #E55A00;
}

.calendar-button .material-symbols-outlined {
  font-size: 1.1rem;
}

@media (max-width: 480px) {
  .calendar-buttons {
    flex-direction: column;
  }
  
  .calendar-button {
    width: 100%;
    justify-content: center;
  }
}
</style> 