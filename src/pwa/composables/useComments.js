import { ref } from 'vue'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'

export function useComments() {
  const apiStore = useApiStore()
  const authStore = useAuthStore()
  
  const comments = ref([])
  const loading = ref(false)
  const error = ref(null)

  /**
   * Charger les commentaires pour un contenu donné
   */
  const loadComments = async (type, id) => {
    loading.value = true
    error.value = null
    
    try {
      console.log(`💬 [Comments] Chargement des commentaires pour ${type}:${id}`)
      
      const data = await apiStore.get('/comments', { 
        commentable_type: `App\\Models\\${type}`,
        commentable_id: id 
      })
      
      if (data.success) {
        comments.value = data.data || []
        console.log(`✅ [Comments] ${comments.value.length} commentaires chargés`)
      } else {
        comments.value = []
      }
    } catch (err) {
      console.error('❌ [Comments] Erreur lors du chargement:', err)
      error.value = err.message
      comments.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * Ajouter un nouveau commentaire
   */
  const addComment = async (type, id, content) => {
    if (!content?.trim()) {
      throw new Error('Le contenu du commentaire ne peut pas être vide')
    }

    if (!authStore.isAuthenticated) {
      throw new Error('Vous devez être connecté pour commenter')
    }

    try {
      console.log(`💬 [Comments] Ajout d'un commentaire pour ${type}:${id}`)
      
      const commentData = {
        commentable_type: `App\\Models\\${type}`,
        commentable_id: parseInt(id),
        content: content.trim()
      }

      const data = await apiStore.post('/comments', commentData)
      
      if (data.success) {
        console.log('✅ [Comments] Commentaire ajouté avec succès')
        
        // Ajouter le nouveau commentaire à la liste locale
        const newComment = {
          id: data.data?.id || Date.now(),
          content: content.trim(),
          author_name: authStore.userName || 'Utilisateur',
          created_at: new Date().toISOString(),
          ...data.data
        }
        
        comments.value.unshift(newComment)
        return newComment
      } else {
        throw new Error(data.message || 'Erreur lors de l\'ajout du commentaire')
      }
    } catch (err) {
      console.error('❌ [Comments] Erreur lors de l\'ajout:', err)
      
      // Si erreur d'authentification, informer l'utilisateur
      if (err.message.includes('401') || err.message.includes('Unauthorized')) {
        throw new Error('Votre session a expiré. Veuillez vous reconnecter.')
      }
      
      throw err
    }
  }

  /**
   * Supprimer un commentaire (si autorisé)
   */
  const deleteComment = async (commentId) => {
    if (!authStore.isAuthenticated) {
      throw new Error('Vous devez être connecté pour supprimer un commentaire')
    }

    try {
      console.log(`💬 [Comments] Suppression du commentaire ${commentId}`)
      
      const data = await apiStore.del(`/comments/${commentId}`)
      
      if (data.success) {
        console.log('✅ [Comments] Commentaire supprimé avec succès')
        
        // Retirer le commentaire de la liste locale
        const index = comments.value.findIndex(c => c.id === commentId)
        if (index > -1) {
          comments.value.splice(index, 1)
        }
        
        return true
      } else {
        throw new Error(data.message || 'Erreur lors de la suppression du commentaire')
      }
    } catch (err) {
      console.error('❌ [Comments] Erreur lors de la suppression:', err)
      throw err
    }
  }

  /**
   * Formater la date d'un commentaire
   */
  const formatCommentDate = (date) => {
    if (!date) return ''
    
    try {
      const commentDate = new Date(date)
      const now = new Date()
      const diffInMinutes = Math.floor((now - commentDate) / (1000 * 60))
      
      if (diffInMinutes < 1) return 'À l\'instant'
      if (diffInMinutes < 60) return `Il y a ${diffInMinutes}mn`
      
      const diffInHours = Math.floor(diffInMinutes / 60)
      if (diffInHours < 24) return `Il y a ${diffInHours}h`
      
      const diffInDays = Math.floor(diffInHours / 24)
      if (diffInDays < 7) return `Il y a ${diffInDays}j`
      
      // Pour les dates plus anciennes, afficher la date complète
      return commentDate.toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short',
        year: commentDate.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
      })
    } catch {
      return 'Date invalide'
    }
  }

  /**
   * Vérifier si l'utilisateur peut modifier/supprimer un commentaire
   */
  const canEditComment = (comment) => {
    if (!authStore.isAuthenticated || !comment) return false
    
    // L'utilisateur peut modifier son propre commentaire
    // ou si c'est un admin (à implémenter selon vos besoins)
    return comment.user_id === authStore.user?.id || authStore.user?.role === 'admin'
  }

  return {
    // État
    comments,
    loading,
    error,
    
    // Actions
    loadComments,
    addComment,
    deleteComment,
    
    // Utilitaires
    formatCommentDate,
    canEditComment
  }
} 