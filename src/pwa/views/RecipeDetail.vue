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
            :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
            :alt="recipe.title"
            class="recipe-hero-image"
            @error="handleImageError">
          <div class="recipe-overlay dinor-gradient-primary">
            <div class="recipe-badges">
              <Badge 
                v-if="recipe.difficulty"
                :text="getDifficultyLabel(recipe.difficulty)"
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
              <DinorIcon name="schedule" :size="20" class="dinor-text-secondary" />
              <span class="md3-body-medium">{{ recipe.cooking_time }}min</span>
            </div>
            <div class="stat-item">
              <DinorIcon name="group" :size="20" class="dinor-text-secondary" />
              <span class="md3-body-medium">{{ recipe.servings }} pers.</span>
            </div>
            <div class="stat-item">
              <DinorIcon name="favorite" :size="20" class="dinor-text-secondary" />
              <span class="md3-body-medium">{{ recipe.likes_count || 0 }}</span>
            </div>
            <div class="stat-item">
              <DinorIcon name="comment" :size="20" class="dinor-text-secondary" />
              <span class="md3-body-medium">{{ recipe.comments_count || 0 }}</span>
            </div>
          </div>

          <!-- Description -->
          <div v-if="recipe.description" class="recipe-description">
            <h2 class="md3-title-medium dinor-text-primary">Description</h2>
            <p class="md3-body-large dinor-text-gray" v-html="recipe.description"></p>
          </div>

          <!-- Summary Video -->
          <div v-if="recipe.summary_video_url" class="recipe-summary-video">
            <h2 class="md3-title-medium dinor-text-primary">Résumé en vidéo</h2>
            <div class="video-container">
              <iframe
                :src="getEmbedUrl(recipe.summary_video_url)"
                :title="`Résumé vidéo : ${recipe.title}`"
                frameborder="0"
                allowfullscreen
                class="summary-video-iframe"
              ></iframe>
            </div>
          </div>

          <!-- Main Video -->
          <div v-if="recipe.video_url" class="recipe-main-video">
            <h2 class="md3-title-medium dinor-text-primary">Vidéo de la recette</h2>
            <div class="video-container">
              <iframe
                :src="getEmbedUrl(recipe.video_url)"
                :title="`Vidéo : ${recipe.title}`"
                frameborder="0"
                allowfullscreen
                class="video-iframe"
              ></iframe>
            </div>
          </div>

          <!-- Recipe Sections in Accordions -->
          <div class="recipe-sections">
            <!-- Ingredients Accordion -->
            <Accordion 
              v-if="recipe.ingredients && recipe.ingredients.length"
              title="Ingrédients"
              :initial-open="true"
              id="ingredients-accordion"
            >
              <ul class="ingredients-list">
                <li v-for="(ingredient, index) in recipe.ingredients" :key="index" class="ingredient-item">
                  <span class="md3-body-medium">
                    {{ formatIngredientDisplay(ingredient) }}
                  </span>
                </li>
              </ul>
            </Accordion>

            <!-- Dinor Ingredients Accordion -->
            <Accordion 
              v-if="recipe.dinor_ingredients && recipe.dinor_ingredients.length"
              title="Ingrédients Dinor"
              :initial-open="true"
              id="dinor-ingredients-accordion"
            >
              <div class="dinor-ingredients-section">
                <p class="dinor-ingredients-description md3-body-small">
                  <strong>Ingrédients recommandés par Dinor</strong> - Des produits sélectionnés pour leur qualité et leur saveur authentique.
                </p>
                <ul class="dinor-ingredients-list">
                  <li v-for="(ingredient, index) in recipe.dinor_ingredients" :key="index" class="dinor-ingredient-item">
                    <div class="dinor-ingredient-content">
                      <span class="dinor-ingredient-main md3-body-medium">
                        {{ formatDinorIngredientDisplay(ingredient) }}
                      </span>
                      <div v-if="ingredient.description" class="dinor-ingredient-description md3-body-small">
                        {{ ingredient.description }}
                      </div>
                      <div v-if="ingredient.brand || ingredient.supplier" class="dinor-ingredient-brand md3-body-small">
                        <DinorIcon name="verified" :size="14" class="dinor-brand-icon" />
                        {{ ingredient.brand || ingredient.supplier }}
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </Accordion>

            <!-- Instructions Accordion -->
            <Accordion 
              v-if="recipe.instructions"
              title="Instructions"
              :initial-open="true"
              id="instructions-accordion"
            >
              <div class="md3-body-large dinor-text-gray" v-html="formatInstructions(recipe.instructions)"></div>
            </Accordion>

            <!-- Gallery Accordion -->
            <Accordion 
              v-if="recipe.gallery_urls && recipe.gallery_urls.length"
              title="Galerie photos"
              :initial-open="false"
              id="gallery-accordion"
            >
              <div class="gallery-grid">
                <img 
                  v-for="(image, index) in recipe.gallery_urls" 
                  :key="index"
                  :src="image"
                  :alt="`${recipe.title} - Photo ${index + 1}`"
                  class="gallery-image"
                  @error="handleImageError"
                  @click="openGalleryModal(index)"
                >
              </div>
            </Accordion>

            <!-- Comments Accordion -->
            <Accordion 
              :title="`Commentaires (${comments.length})`"
              :initial-open="false"
              id="comments-accordion"
            >
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
                        <DinorIcon name="delete" :size="16" />
                      </button>
                    </div>
                  </div>
                  <p class="comment-content md3-body-medium">{{ comment.content }}</p>
                </div>
              </div>
              <div v-else class="empty-comments">
                <p class="md3-body-medium dinor-text-gray">Aucun commentaire pour le moment.</p>
              </div>
            </Accordion>
          </div> <!-- Close recipe-sections -->

          <!-- Recipe Header Actions -->
          <div class="recipe-header-actions">
            <!-- Like Button standardisé -->
            <LikeButton 
              :type="'recipe'"
              :item-id="recipe.id"
              :initial-liked="userLiked"
              :initial-count="recipe.likes_count || 0"
              :show-count="true"
              size="medium"
              @auth-required="showAuthModal = true"
              @update:liked="handleLikeUpdate"
              @update:count="handleLikeCountUpdate"
            />
            
            <!-- Refresh Button -->
            <button 
              @click="forceRefresh"
              class="refresh-button"
              title="Actualiser les données"
              :disabled="loading"
            >
              <DinorIcon name="refresh" :size="20" :class="{ 'spinning': loading }" />
            </button>
            
            <!-- Share Button -->
            <button 
              @click="callShare"
              class="share-button"
              title="Partager cette recette"
            >
              <DinorIcon name="share" :size="20" />
            </button>
          </div>
        </div>
      </div>

      <!-- Error State -->
      <div v-else class="error-state">
        <div class="error-icon">
          <DinorIcon name="error" :size="64" />
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
    
    <!-- Image Lightbox -->
    <ImageLightbox
      v-if="recipe && recipe.gallery_urls"
      :images="recipe.gallery_urls"
      :title="recipe.title"
      :initial-index="lightboxIndex"
      :is-open="showLightbox"
      @close="closeLightbox"
    />
  </div>
</template>

<script>
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'
import { useSocialShare } from '@/composables/useSocialShare'
import { useShare } from '@/composables/useShare'
import { useComments } from '@/composables/useComments'
import Badge from '@/components/common/Badge.vue'
import ShareModal from '@/components/common/ShareModal.vue'
import AuthModal from '@/components/common/AuthModal.vue'
import FavoriteButton from '@/components/common/FavoriteButton.vue'
import LikeButton from '@/components/common/LikeButton.vue'
import ImageLightbox from '@/components/common/ImageLightbox.vue'
import Accordion from '@/components/common/Accordion.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'RecipeDetail',
  emits: ['update-header'],
  components: {
    Badge,
    ShareModal,
    AuthModal,
    FavoriteButton,
    LikeButton,
    ImageLightbox,
    Accordion,
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
    const { share: shareSocial } = useShare()
    const { comments, loadComments, loadCommentsFresh, canDeleteComment, deleteComment, setContext, addComment: addCommentFromComposable } = useComments()
    
    const recipe = ref(null)
    const loading = ref(true)
    const userLiked = ref(false)
    const userFavorited = ref(false)
    const newComment = ref('')
    const showAuthModal = ref(false)
    const showLightbox = ref(false)
    const lightboxIndex = ref(0)

    const shareData = computed(() => {
      if (!recipe.value) return {}
      return {
        title: recipe.value.title,
        text: recipe.value.description || `Découvrez cette délicieuse recette : ${recipe.value.title}`,
        url: window.location.href,
        image: recipe.value.featured_image_url,
        type: 'recipe',
        id: recipe.value.id
      }
    })

    const loadRecipe = async (forceRefresh = false) => {
      try {
        console.log('🔄 [RecipeDetail] Chargement recette ID:', props.id, 'ForceRefresh:', forceRefresh)
        
        // Utiliser forceRefresh pour récupérer les données fraîches
        const data = forceRefresh 
          ? await apiStore.request(`/recipes/${props.id}`, { forceRefresh: true })
          : await apiStore.get(`/recipes/${props.id}`)
          
        if (data.success) {
          recipe.value = data.data
          // Définir le contexte pour les commentaires
          setContext('Recipe', props.id)
          await loadComments()
          await checkUserLike()
          await checkUserFavorite()
          
          // Mettre à jour les métadonnées Open Graph
          updateOpenGraphTags(shareData.value)
          
          // Mettre à jour le header avec le titre de la recette
          emit('update-header', {
            title: recipe.value.title || 'Recette',
            showShare: true,
            showFavorite: true,
            favoriteType: 'recipe',
            favoriteItemId: parseInt(props.id),
            isContentFavorited: userFavorited.value,
            backPath: '/recipes'
          })
        }
      } catch (error) {
        console.error('Erreur lors du chargement de la recette:', error)
      } finally {
        loading.value = false
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

    const checkUserFavorite = async () => {
      try {
        const data = await apiStore.get(`/favorites/check`, { type: 'recipe', id: props.id })
        userFavorited.value = data.success && data.is_favorited
      } catch (error) {
        console.error('Erreur lors de la vérification du favori:', error)
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

    const toggleFavorite = async () => {
      try {
        const data = await apiStore.post('/favorites/toggle', {
          favoritable_type: 'recipe',
          favoritable_id: props.id
        })
        if (data.success) {
          userFavorited.value = !userFavorited.value
          if (recipe.value) {
            recipe.value.favorites_count = data.data.total_favorites
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
      
      // Vérifier si l'utilisateur est connecté
      if (!authStore.isAuthenticated) {
        showAuthModal.value = true
        return
      }
      
      try {
        console.log('📝 [Comments] Envoi du commentaire pour Recipe:', props.id)
        
        // Utiliser la fonction du composable
        await addCommentFromComposable('Recipe', props.id, newComment.value)
        
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

    const handleAuthenticated = () => {
      // Utilisateur connecté, on peut maintenant essayer d'ajouter le commentaire
      showAuthModal.value = false
      if (newComment.value.trim()) {
        addComment()
      }
    }

    // Composable pour le partage social
    const callShare = () => {
      shareSocial(shareData.value)
    }
    
    const goBack = () => {
      router.push('/recipes')
    }

    const forceRefresh = async () => {
      console.log('🔄 [RecipeDetail] Rechargement forcé demandé')
      loading.value = true
      try {
        await loadRecipe(true) // Force refresh
        console.log('✅ [RecipeDetail] Rechargement forcé terminé')
      } catch (error) {
        console.error('❌ [RecipeDetail] Erreur lors du rechargement forcé:', error)
      }
    }

    const getDifficultyLabel = (difficulty) => {
      const labels = {
        'beginner': 'Débutant',
        'easy': 'Facile',
        'medium': 'Intermédiaire',
        'hard': 'Difficile',
        'expert': 'Expert'
      }
      return labels[difficulty] || difficulty
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

    const getEmbedUrl = (videoUrl) => {
      if (!videoUrl) return ''
      
      // Gérer les URLs YouTube
      const youtubeMatch = videoUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://www.youtube.com/embed/${youtubeMatch[1]}?rel=0&modestbranding=1`
      }
      
      // Gérer les URLs Vimeo
      const vimeoMatch = videoUrl.match(/vimeo\.com\/(\d+)/)
      if (vimeoMatch) {
        return `https://player.vimeo.com/video/${vimeoMatch[1]}`
      }
      
      // Retourner l'URL telle quelle si ce n'est pas YouTube ou Vimeo
      return videoUrl
    }

    // Gestion des likes via le composant LikeButton
    const handleLikeUpdate = (liked) => {
      userLiked.value = liked
      console.log('❤️ [RecipeDetail] Like mis à jour:', liked)
    }
    
    const handleLikeCountUpdate = (count) => {
      if (recipe.value) {
        recipe.value.likes_count = count
      }
      console.log('🔢 [RecipeDetail] Compteur likes mis à jour:', count)
    }

    onMounted(() => {
      loadRecipe()
    })

    // Fonctions manquantes
    const goHome = () => {
      router.push('/')
    }

    const formatIngredients = (ingredients) => {
      if (!ingredients) return ''
      
      if (typeof ingredients === 'string') return ingredients
      
      if (Array.isArray(ingredients)) {
        return ingredients.map((ingredient, index) => {
          if (typeof ingredient === 'object' && ingredient.name) {
            return `<div class="ingredient-item">
              <span class="md3-body-medium">${ingredient.quantity || ''} ${ingredient.unit || ''} ${ingredient.name}</span>
            </div>`
          } else if (typeof ingredient === 'string') {
            return `<div class="ingredient-item">
              <span class="md3-body-medium">${ingredient}</span>
            </div>`
          }
          return `<div class="ingredient-item"><span class="md3-body-medium">${ingredient}</span></div>`
        }).join('')
      }
      
      return ingredients.toString()
    }

    const getDifficultyColor = (level) => {
      const colors = {
        'beginner': '#4CAF50',
        'intermediate': '#FF9800', 
        'advanced': '#F44336'
      }
      return colors[level] || '#4CAF50'
    }

    const formatCookingTime = (time) => {
      if (!time) return 'N/A'
      return `${time} min`
    }

    const formatIngredientDisplay = (ingredient) => {
      if (!ingredient) return ''
      
      let result = ''
      
      // Ajouter la quantité si elle existe
      if (ingredient.quantity) {
        result += `${ingredient.quantity} `
      }
      
      // Ajouter l'unité si elle existe
      if (ingredient.unit) {
        result += `${ingredient.unit} `
      }
      
      // Ajouter le nom de l'ingrédient
      if (ingredient.name) {
        result += `de ${ingredient.name}`
      }
      
      // Ajouter les notes si elles existent
      if (ingredient.notes) {
        result += ` (${ingredient.notes})`
      }
      
      // Ajouter la marque recommandée si elle existe
      if (ingredient.recommended_brand) {
        result += ` [${ingredient.recommended_brand}]`
      }
      
      return result.trim()
    }

    const formatDinorIngredientDisplay = (ingredient) => {
      if (!ingredient) return ''
      
      let result = ''
      
      // Ajouter la quantité si elle existe
      if (ingredient.quantity) {
        result += `${ingredient.quantity} `
      }
      
      // Ajouter l'unité si elle existe
      if (ingredient.unit) {
        result += `${ingredient.unit} `
      }
      
      // Ajouter le nom de l'ingrédient
      if (ingredient.name) {
        result += `de ${ingredient.name}`
      } else if (ingredient.ingredient_name) {
        result += `de ${ingredient.ingredient_name}`
      }
      
      // Ajouter les notes si elles existent
      if (ingredient.notes) {
        result += ` (${ingredient.notes})`
      }
      
      return result.trim()
    }

    // Fonction pour ouvrir la galerie d'images
    const openGalleryModal = (index) => {
      if (recipe.value?.gallery_urls?.[index]) {
        lightboxIndex.value = index
        showLightbox.value = true
      }
    }
    
    const closeLightbox = () => {
      showLightbox.value = false
    }

    // Exposer les méthodes et les refs nécessaires au template et au parent
    return {
      recipe,
      loading,
      showAuthModal,
      comments,
      newComment,
      authStore,
      userLiked,
      userFavorited,
      shareData,
      goBack,
      goHome,
      forceRefresh,
      addComment,
      canDeleteComment,
      deleteComment,
      callShare,
      handleLikeUpdate,
      handleLikeCountUpdate,
      handleImageError,
      formatIngredients,
      formatInstructions,
      getDifficultyColor,
      formatDate,
      formatCookingTime,
      getDifficultyLabel,
      getEmbedUrl,
      showShareModal,
      handleAuthenticated,
      openGalleryModal,
      formatIngredientDisplay,
      formatDinorIngredientDisplay,
      showLightbox,
      lightboxIndex,
      closeLightbox
    }
  }
}
</script>

<style scoped>
@import '../assets/styles/comments.css';

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

.recipe-summary-video,
.recipe-description,
.recipe-ingredients,
.recipe-instructions,
.comments-section {
  margin-bottom: 2rem;
}

.recipe-summary-video {
  background: #F8F9FA;
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.video-container {
  position: relative;
  padding-bottom: 56.25%; /* 16:9 aspect ratio */
  height: 0;
  overflow: hidden;
  margin: 1rem 0;
  border-radius: 8px;
}

.video-container iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.recipe-gallery {
  margin: 2rem 0;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.gallery-image {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.gallery-image:hover {
  transform: scale(1.05);
}

.recipe-main-video {
  margin: 2rem 0;
}

.recipe-summary-video {
  margin: 2rem 0;
}

.ingredients-list {
  list-style: none;
  padding: 0;
}

.ingredient-item {
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--md-sys-color-outline-variant);
}

.ingredient-item:last-child {
  border-bottom: none;
}

/* Dinor Ingredients Styles */
.dinor-ingredients-section {
  background: linear-gradient(135deg, #FFF8E1 0%, #FFECB3 100%);
  border-radius: 12px;
  padding: 1.5rem;
  border: 2px solid #E1251B;
  margin-top: 0.5rem;
}

.dinor-ingredients-description {
  color: #E1251B;
  margin-bottom: 1rem;
  text-align: center;
  padding: 0.5rem;
  background: rgba(225, 37, 27, 0.1);
  border-radius: 8px;
  border: 1px solid rgba(225, 37, 27, 0.2);
}

.dinor-ingredients-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.dinor-ingredient-item {
  padding: 1rem 0;
  border-bottom: 1px solid rgba(225, 37, 27, 0.2);
  background: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.5rem;
  border-radius: 8px;
  padding: 1rem;
}

.dinor-ingredient-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.dinor-ingredient-content {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.dinor-ingredient-main {
  font-weight: 600;
  color: #2D3748;
  font-size: 1rem;
}

.dinor-ingredient-description {
  color: #4A5568;
  font-style: italic;
  line-height: 1.4;
}

.dinor-ingredient-brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #E1251B;
  font-weight: 500;
}

.dinor-brand-icon {
  color: #E1251B;
}

@media (max-width: 768px) {
  .dinor-ingredients-section {
    padding: 1rem;
  }
  
  .dinor-ingredient-item {
    padding: 0.75rem;
  }
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

.recipe-header-actions {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}

.refresh-button,
.share-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  cursor: pointer;
  border-radius: 50%;
  padding: 8px;
  transition: all 0.2s ease;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.refresh-button:hover,
.share-button:hover {
  background: var(--md-sys-color-surface-variant, #e7e0ec);
  transform: scale(1.05);
}

.refresh-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.refresh-button i,
.share-button i {
  font-size: 20px;
}

/* Animation de rotation pour le bouton refresh */
.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Recipe Sections Styles */
.recipe-sections {
  margin: 2rem 0;
}

.recipe-sections .ingredients-list {
  margin: 0;
  padding: 0;
}

.recipe-sections .gallery-grid {
  margin-top: 0;
}

.recipe-sections .add-comment-form {
  margin-bottom: 1.5rem;
}

.recipe-sections .comments-list {
  margin-top: 1rem;
}
</style> 