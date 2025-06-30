<template>
  <div class="recipe-detail">
    <!-- Main Content -->
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement de la recette...</p>
      </div>

      <!-- Recipe Content -->
      <div v-else-if="recipe" class="recipe-content">
        <!-- Hero Image -->
        <div class="recipe-hero">
          <img 
            :src="recipe.image || '/images/default-recipe.jpg'" 
            :alt="recipe.title"
            class="recipe-hero-image"
            @error="handleImageError">
          <div class="recipe-overlay dinor-gradient-primary">
            <div class="recipe-badges">
              <Badge 
                v-if="recipe.difficulty_level"
                :text="getDifficultyLabel(recipe.difficulty_level)"
                icon="restaurant"
                variant="secondary"
                size="medium"
              />
              <Badge 
                v-if="recipe.category"
                :text="recipe.category.name"
                icon="tag"
                variant="neutral"
                size="medium"
              />
            </div>
          </div>
        </div>

        <!-- Recipe Info -->
        <div class="recipe-info">
          <div class="recipe-stats">
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">schedule</i>
              <span class="md3-body-medium">{{ recipe.cooking_time }}min</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">people</i>
              <span class="md3-body-medium">{{ recipe.servings }} pers.</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">favorite</i>
              <span class="md3-body-medium">{{ recipe.likes_count || 0 }}</span>
            </div>
            <div class="stat-item">
              <i class="material-icons dinor-text-secondary">comment</i>
              <span class="md3-body-medium">{{ recipe.comments_count || 0 }}</span>
            </div>
          </div>

          <!-- Description -->
          <div v-if="recipe.description" class="recipe-description">
            <h2 class="md3-title-medium dinor-text-primary">Description</h2>
            <p class="md3-body-large dinor-text-gray" v-html="recipe.description"></p>
          </div>

          <!-- Ingredients -->
          <div v-if="recipe.ingredients && recipe.ingredients.length" class="recipe-ingredients">
            <h2 class="md3-title-medium dinor-text-primary">Ingrédients</h2>
            <ul class="ingredients-list">
              <li v-for="ingredient in recipe.ingredients" :key="ingredient.id" class="ingredient-item">
                <span class="md3-body-medium">{{ ingredient.quantity }} {{ ingredient.unit }} {{ ingredient.name }}</span>
              </li>
            </ul>
          </div>

          <!-- Instructions -->
          <div v-if="recipe.instructions" class="recipe-instructions">
            <h2 class="md3-title-medium dinor-text-primary">Instructions</h2>
            <div class="md3-body-large dinor-text-gray" v-html="formatInstructions(recipe.instructions)"></div>
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
        <h2 class="md3-title-large">Recette introuvable</h2>
        <p class="md3-body-large dinor-text-gray">La recette demandée n'existe pas ou a été supprimée.</p>
        <button @click="goBack" class="btn-primary">Retour</button>
      </div>
    </main>
    
    <!-- Share Modal -->
    <ShareModal 
      v-model="showShareModal" 
      :share-data="shareData"
    />
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal"
      @authenticated="handleAuthenticated"
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
  name: 'RecipeDetail',
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
    
    const recipe = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const newComment = ref('')
    const showAuthModal = ref(false)

    const shareData = computed(() => {
      if (!recipe.value) return {}
      return {
        title: recipe.value.title,
        text: recipe.value.description || `Découvrez cette délicieuse recette : ${recipe.value.title}`,
        url: window.location.href,
        image: recipe.value.image,
        type: 'recipe',
        id: recipe.value.id
      }
    })

    const loadRecipe = async () => {
      try {
        const data = await apiStore.get(`/recipes/${props.id}`)
        if (data.success) {
          recipe.value = data.data
          await loadComments()
          await checkUserLike()
          
          // Mettre à jour les métadonnées Open Graph
          updateOpenGraphTags(shareData.value)
          
          // Mettre à jour le header avec le titre de la recette
          emit('update-header', {
            title: recipe.value.title || 'Recette',
            showLike: true,
            showShare: true,
            isLiked: userLiked.value,
            backPath: '/recipes'
          })
        }
      } catch (error) {
        console.error('Erreur lors du chargement de la recette:', error)
      } finally {
        loading.value = false
      }
    }

    const loadComments = async () => {
      try {
        const data = await apiStore.get(`/comments`, { type: 'recipe', id: props.id })
        if (data.success) {
          comments.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des commentaires:', error)
      }
    }

    const checkUserLike = async () => {
      try {
        const data = await apiStore.get(`/likes/check`, { type: 'recipe', id: props.id })
        userLiked.value = data.success && data.is_liked
      } catch (error) {
        console.error('Erreur lors de la vérification du like:', error)
      }
    }

    const toggleLike = async () => {
      try {
        const data = await apiStore.request('/likes/toggle', {
          method: 'POST',
          body: {
            likeable_type: 'recipe',
            likeable_id: props.id
          }
        })
        if (data.success) {
          userLiked.value = !userLiked.value
          if (recipe.value) {
            recipe.value.likes_count = data.data.total_likes
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
      
      // Vérifier si l'utilisateur est connecté
      if (!authStore.isAuthenticated) {
        showAuthModal.value = true
        return
      }
      
      try {
        const commentData = {
          commentable_type: 'App\\Models\\Recipe',
          commentable_id: parseInt(props.id),
          content: newComment.value
        }
        
        console.log('📝 [Comments] Envoi du commentaire:', commentData)
        
        const data = await apiStore.post('/comments', commentData)
        
        if (data.success) {
          console.log('✅ [Comments] Commentaire ajouté avec succès')
          await loadComments()
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

    const handleAuthenticated = () => {
      // Utilisateur connecté, on peut maintenant essayer d'ajouter le commentaire
      showAuthModal.value = false
      if (newComment.value.trim()) {
        addComment()
      }
    }

    // Composable pour le partage social
    const callShare = () => {
      share(shareData.value)
    }
    
    const goBack = () => {
      router.push('/recipes')
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

    const formatInstructions = (instructions) => {
      if (!instructions) return ''
      
      // Si c'est déjà une chaîne, la retourner
      if (typeof instructions === 'string') return instructions
      
      // Si c'est un array d'objets, les formater
      if (Array.isArray(instructions)) {
        return instructions.map((instruction, index) => {
          if (typeof instruction === 'object' && instruction.step) {
            return `<div class="instruction-step">
              <h4>Étape ${index + 1}</h4>
              <p>${instruction.step}</p>
            </div>`
          } else if (typeof instruction === 'string') {
            return `<div class="instruction-step">
              <h4>Étape ${index + 1}</h4>
              <p>${instruction}</p>
            </div>`
          }
          return `<div class="instruction-step"><p>${instruction}</p></div>`
        }).join('')
      }
      
      return instructions.toString()
    }

    onMounted(() => {
      loadRecipe()
    })

    // Exposer la fonction share pour le composant parent
    defineExpose({
      share: callShare,
      toggleLike
    })

    // Exposer les méthodes et les refs nécessaires au template et au parent
    return {
      recipe,
      comments,
      loading,
      userLiked,
      newComment,
      authStore,
      showAuthModal,
      toggleLike,
      addComment,
      handleAuthenticated,
      goBack,
      getDifficultyLabel,
      formatDate,
      handleImageError,
      formatInstructions,
      showShareModal,
      shareData
    }
  }
}
</script>

<style scoped>
.recipe-detail {
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

.recipe-hero {
  position: relative;
  height: 300px;
  overflow: hidden;
}

.recipe-hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.recipe-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  padding: 1rem;
}

.recipe-badges {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.recipe-info {
  padding: 1rem;
}

.recipe-stats {
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
  .recipe-stats {
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

.recipe-description,
.recipe-ingredients,
.recipe-instructions,
.comments-section {
  margin-bottom: 2rem;
}

.ingredients-list {
  list-style: none;
  padding: 0;
}

.ingredient-item {
  padding: 0.5rem;
  border-bottom: 1px solid var(--md-sys-color-outline-variant);
}

.add-comment-form {
  margin-bottom: 1rem;
}

.auth-prompt {
  text-align: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e0e0e0;
}

.auth-prompt-text {
  margin: 0 0 1rem 0;
  color: #666;
  font-size: 0.95rem;
}

.authenticated-user {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  background: #e8f5e8;
  border-radius: 8px;
  font-size: 0.875rem;
}

.user-info {
  color: #2d5a2d;
  font-weight: 500;
}

.btn-logout {
  background: none;
  border: 1px solid #ddd;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  color: #666;
  transition: all 0.2s;
}

.btn-logout:hover {
  background: #f5f5f5;
  border-color: #ccc;
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