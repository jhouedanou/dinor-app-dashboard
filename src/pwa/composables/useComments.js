import { ref } from 'vue'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'

export function useComments() {
  const apiStore = useApiStore()
  const authStore = useAuthStore()
  
  const comments = ref([])
  const loading = ref(false)
  const error = ref(null)
  const currentType = ref(null)
  const currentId = ref(null)

  /**
   * Charger les commentaires pour un contenu donné
   */
  const loadComments = async (type = null, id = null) => {
    loading.value = true
    error.value = null
    
    // Si des paramètres sont fournis, les utiliser
    if (type && id) {
      currentType.value = type
      currentId.value = id
    }
    
    // Vérifier qu'on a les paramètres nécessaires
    if (!currentType.value || !currentId.value) {
      console.error('❌ [Comments] Type ou ID manquant pour charger les commentaires')
      error.value = 'Paramètres manquants pour charger les commentaires'
      loading.value = false
      return
    }
    
    try {
      console.log(`💬 [Comments] Chargement des commentaires pour ${currentType.value}:${currentId.value}`)
      
      const data = await apiStore.get('/comments', { 
        commentable_type: `App\\Models\\${currentType.value}`,
        commentable_id: currentId.value 
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
   * Charger les commentaires avec des données fraîches (sans cache)
   */
  const loadCommentsFresh = async (type = null, id = null) => {
    loading.value = true
    error.value = null
    
    // Si des paramètres sont fournis, les utiliser
    if (type && id) {
      currentType.value = type
      currentId.value = id
    }
    
    // Vérifier qu'on a les paramètres nécessaires
    if (!currentType.value || !currentId.value) {
      console.error('❌ [Comments] Type ou ID manquant pour charger les commentaires')
      error.value = 'Paramètres manquants pour charger les commentaires'
      loading.value = false
      return
    }
    
    try {
      console.log(`💬 [Comments] Chargement frais des commentaires pour ${currentType.value}:${currentId.value}`)
      
      const data = await apiStore.getFresh('/comments', { 
        commentable_type: `App\\Models\\${currentType.value}`,
        commentable_id: currentId.value 
      })
      
      if (data.success) {
        comments.value = data.data || []
        console.log(`✅ [Comments] ${comments.value.length} commentaires chargés (frais)`)
      } else {
        comments.value = []
      }
    } catch (err) {
      console.error('❌ [Comments] Erreur lors du chargement frais:', err)
      error.value = err.message
      comments.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * Définir le contexte pour les commentaires
   */
  const setContext = (type, id) => {
    currentType.value = type
    currentId.value = id
    console.log(`💬 [Comments] Contexte défini: ${type}:${id}`)
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
   * Répondre en tant qu'admin à un commentaire
   */
  const replyAsAdmin = async (commentId, replyContent) => {
    if (!replyContent?.trim()) {
      throw new Error('La réponse ne peut pas être vide')
    }

    if (!authStore.isAuthenticated) {
      throw new Error('Vous devez être connecté')
    }

    try {
      console.log(`🛡️ [Comments] Réponse admin au commentaire ${commentId}`)
      
      const data = await apiStore.post(`/comments/${commentId}/admin-reply`, {
        admin_reply: replyContent.trim()
      })
      
      if (data.success) {
        console.log('✅ [Comments] Réponse admin enregistrée')
        
        // Mettre à jour le commentaire localement
        const comment = comments.value.find(c => c.id === commentId)
        if (comment) {
          comment.admin_reply = replyContent.trim()
          comment.admin_reply_by_name = data.data?.admin_reply_by_name || authStore.userName
          comment.admin_replied_at = data.data?.admin_replied_at || new Date().toISOString()
        }
        
        return data.data
      } else {
        throw new Error(data.message || 'Erreur lors de l\'envoi de la réponse')
      }
    } catch (err) {
      console.error('❌ [Comments] Erreur réponse admin:', err)
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

  /**
   * Vérifier si l'utilisateur peut supprimer un commentaire
   */
  const canDeleteComment = (comment) => {
    if (!authStore.isAuthenticated || !comment) return false
    
    // L'utilisateur peut supprimer son propre commentaire
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
    loadCommentsFresh,
    addComment,
    deleteComment,
    replyAsAdmin,
    
    // Utilitaires
    formatCommentDate,
    canEditComment,
    canDeleteComment,
    setContext
  }
} 