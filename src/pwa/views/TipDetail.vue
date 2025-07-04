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

          <!-- Summary Video -->
          <div v-if="tip.summary_video_url && tip.summary_video_url.trim()" class="tip-summary-video">
            <h2 class="md3-title-medium dinor-text-primary">Résumé en vidéo</h2>
            <div class="video-container">
              <iframe
                :src="getEmbedUrl(tip.summary_video_url)"
                :title="`Résumé vidéo : ${tip.title}`"
                frameborder="0"
                allowfullscreen
                class="summary-video-iframe"
              ></iframe>
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
                      <i class="material-icons">delete</i>
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

    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" />
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
    const authStore = useAuthStore()
    const { share, showShareModal, updateOpenGraphTags } = useSocialShare()
    
    const tip = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const userFavorited = ref(false)
    const newComment = ref('')
    const showAuthModal = ref(false)

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
          await checkUserFavorite()
          
          // Mettre à jour les métadonnées Open Graph
          updateOpenGraphTags(shareData.value)
          
          // Mettre à jour le header avec le titre de l'astuce
          emit('update-header', {
            title: tip.value.title || 'Astuce',
            showShare: true,
            showFavorite: true,
            favoriteType: 'tip',
            favoriteItemId: parseInt(props.id),
            isContentFavorited: userFavorited.value,
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
        console.log('🔄 [Comments] Chargement des commentaires pour tip ID:', props.id)
        const data = await apiStore.get(`/comments`, { 
          commentable_type: 'App\\Models\\Tip', 
          commentable_id: props.id 
        })
        console.log('📥 [Comments] Réponse reçue:', data)
        if (data.success) {
          comments.value = data.data
          console.log('✅ [Comments] Commentaires chargés:', comments.value.length, 'commentaires')
        }
      } catch (error) {
        console.error('❌ [Comments] Erreur lors du chargement des commentaires:', error)
      }
    }

    const loadCommentsFresh = async () => {
      try {
        console.log('🔄 [Comments] Rechargement FRAIS des commentaires pour tip ID:', props.id)
        const data = await apiStore.getFresh(`/comments`, { 
          commentable_type: 'App\\Models\\Tip', 
          commentable_id: props.id 
        })
        console.log('📥 [Comments] Réponse fraîche reçue:', data)
        if (data.success) {
          comments.value = data.data
          console.log('✅ [Comments] Commentaires frais chargés:', comments.value.length, 'commentaires')
        }
      } catch (error) {
        console.error('❌ [Comments] Erreur lors du rechargement frais des commentaires:', error)
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

    const checkUserFavorite = async () => {
      try {
        const data = await apiStore.get(`/favorites/check`, { type: 'tip', id: props.id })
        userFavorited.value = data.success && data.is_favorited
      } catch (error) {
        console.error('Erreur lors de la vérification du favori:', error)
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

    const toggleFavorite = async () => {
      try {
        const data = await apiStore.post('/favorites/toggle', {
          favoritable_type: 'tip',
          favoritable_id: props.id
        })
        if (data.success) {
          userFavorited.value = !userFavorited.value
          if (tip.value) {
            tip.value.favorites_count = data.data.total_favorites
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
        const commentData = {
          commentable_type: 'App\\Models\\Tip',
          commentable_id: parseInt(props.id),
          content: newComment.value
        }
        
        console.log('📝 [Comments] Envoi du commentaire:', commentData)
        
        const data = await apiStore.post('/comments', commentData)
        
        if (data.success) {
          console.log('✅ [Comments] Commentaire ajouté avec succès')
          // Recharger les commentaires avec des données fraîches
          await loadCommentsFresh()
          newComment.value = ''
        }
      } catch (error) {
        console.error('❌ [Comments] Erreur lors de l\'ajout du commentaire:', error)
        
        // Si erreur 401, demander connexion
        if (error.message.includes('401')) {
          showAuthModal.value = true
        }
      }
    }

    const canDeleteComment = (comment) => {
      if (!authStore.isAuthenticated) return false
      
      // L'utilisateur peut supprimer ses propres commentaires
      if (comment.user_id && comment.user_id === authStore.user?.id) return true
      
      // Si pas d'user_id, vérifier par l'IP/session (pour les commentaires anonymes)
      // Pour l'instant, on ne permet que la suppression des commentaires avec user_id
      return false
    }

    const deleteComment = async (commentId) => {
      if (!confirm('Êtes-vous sûr de vouloir supprimer ce commentaire ?')) {
        return
      }

      try {
        console.log('🗑️ [Comments] Suppression du commentaire ID:', commentId)
        
        const data = await apiStore.request(`/comments/${commentId}`, {
          method: 'DELETE'
        })
        
        if (data.success) {
          console.log('✅ [Comments] Commentaire supprimé avec succès')
          // Recharger les commentaires avec des données fraîches
          await loadCommentsFresh()
        }
      } catch (error) {
        console.error('❌ [Comments] Erreur lors de la suppression du commentaire:', error)
        alert('Erreur lors de la suppression du commentaire')
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

    const getEmbedUrl = (videoUrl) => {
      if (!videoUrl || !videoUrl.trim()) return ''
      
      const cleanUrl = videoUrl.trim()
      
      // Gérer les URLs YouTube
      const youtubeMatch = cleanUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://www.youtube.com/embed/${youtubeMatch[1]}?rel=0&modestbranding=1`
      }
      
      // Gérer les URLs Vimeo
      const vimeoMatch = cleanUrl.match(/vimeo\.com\/(\d+)/)
      if (vimeoMatch) {
        return `https://player.vimeo.com/video/${vimeoMatch[1]}`
      }
      
      // Retourner l'URL telle quelle si ce n'est pas YouTube ou Vimeo
      return cleanUrl
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
      userFavorited,
      newComment,
      toggleLike,
      toggleFavorite,
      addComment,
      canDeleteComment,
      deleteComment,
      goBack,
      goHome,
      getDifficultyLabel,
      formatDate,
      handleImageError,
      formatContent,
      getEmbedUrl,
      showShareModal,
      shareData,
      authStore,
      showAuthModal
    }
  }
}
</script>

<style scoped>
@import '../assets/styles/comments.css';

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

.tip-summary-video,
.tip-content-text,
.tip-tags,
.comments-section {
  margin-bottom: 2rem;
}

.tip-summary-video {
  background: #F8F9FA;
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.video-container {
  position: relative;
  padding-bottom: 56.25%; /* Ratio 16:9 */
  height: 0;
  overflow: hidden;
  border-radius: 8px;
  margin-top: 1rem;
}

.summary-video-iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
  border-radius: 8px;
}

.tags-container {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin-top: 0.5rem;
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