<template>
  <div class="recipe-detail">
    <!-- Navigation Header -->
    <nav class="md3-top-app-bar">
      <div class="md3-app-bar-container">
        <button @click="goBack" class="md3-icon-button">
          <i class="material-icons">arrow_back</i>
        </button>
        <div class="md3-app-bar-title">
          <h1 class="md3-title-large dinor-text-primary">{{ recipe?.title || 'Recette' }}</h1>
        </div>
        <div class="md3-app-bar-actions">
          <button @click="toggleLike" class="md3-icon-button" :class="{ 'liked': userLiked }">
            <i class="material-icons">{{ userLiked ? 'favorite' : 'favorite_border' }}</i>
          </button>
          <button @click="shareRecipe" class="md3-icon-button">
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
              <div v-if="recipe.difficulty_level" class="md3-chip recipe-difficulty">
                <i class="material-icons">restaurant</i>
                <span>{{ getDifficultyLabel(recipe.difficulty_level) }}</span>
              </div>
              <div v-if="recipe.category" class="md3-chip recipe-category">
                <i class="material-icons">tag</i>
                <span>{{ recipe.category.name }}</span>
              </div>
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
        <h2 class="md3-title-large">Recette introuvable</h2>
        <p class="md3-body-large dinor-text-gray">La recette demandée n'existe pas ou a été supprimée.</p>
        <button @click="goBack" class="btn-primary">Retour</button>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useApiStore } from '@/stores/api'

export default {
  name: 'RecipeDetail',
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
    
    const recipe = ref(null)
    const comments = ref([])
    const loading = ref(true)
    const userLiked = ref(false)
    const newComment = ref('')

    const loadRecipe = async () => {
      try {
        const data = await apiStore.get(`/recipes/${props.id}`)
        if (data.success) {
          recipe.value = data.data
          await loadComments()
          await checkUserLike()
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
            likeable_type: 'recipe',
            likeable_id: props.id
          }
        })
        if (data.success) {
          userLiked.value = !userLiked.value
          if (recipe.value) {
            recipe.value.likes_count = data.data.total_likes
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
            type: 'recipe',
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

    const shareRecipe = () => {
      if (navigator.share && recipe.value) {
        navigator.share({
          title: recipe.value.title,
          text: recipe.value.description,
          url: window.location.href
        })
      } else {
        // Fallback pour les navigateurs sans support de Web Share API
        navigator.clipboard.writeText(window.location.href)
        alert('Lien copié dans le presse-papiers!')
      }
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

    return {
      recipe,
      comments,
      loading,
      userLiked,
      newComment,
      toggleLike,
      addComment,
      shareRecipe,
      goBack,
      getDifficultyLabel,
      formatDate,
      handleImageError,
      formatInstructions
    }
  }
}
</script>

<style scoped>
.recipe-detail {
  min-height: 100vh;
  background: var(--md-sys-color-surface);
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
  background: var(--md-sys-color-surface-variant);
  border-radius: 12px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
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