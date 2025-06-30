/**
 * Gestionnaire des commentaires avec authentification
 */
class CommentsManager {
    constructor() {
        this.apiBaseUrl = '/api/v1';
    }

    /**
     * Ajouter un commentaire
     */
    async addComment(type, id, content, parentId = null) {
        if (!authManager.isAuthenticated()) {
            authManager.showAuthModal('Vous devez vous connecter pour laisser un commentaire');
            return { success: false, requires_auth: true };
        }

        try {
            const response = await fetch(`${this.apiBaseUrl}/comments`, {
                method: 'POST',
                headers: authManager.getHeaders(),
                body: JSON.stringify({ 
                    type, 
                    id, 
                    content, 
                    parent_id: parentId 
                })
            });

            const data = await response.json();

            if (response.status === 401 && data.requires_auth) {
                authManager.showAuthModal(data.message);
                return { success: false, requires_auth: true };
            }

            if (data.success) {
                this.showNotification('Commentaire ajouté avec succès', 'success');
                // Recharger les commentaires
                this.loadComments(type, id);
                return { success: true, comment: data.data };
            } else {
                this.showNotification(data.message, 'error');
                return { success: false, message: data.message };
            }
        } catch (error) {
            console.error('Erreur lors de l\'ajout du commentaire:', error);
            
            if (error.message.includes('Unexpected token') || error.message.includes('<!DOCTYPE')) {
                authManager.showAuthModal('Vous devez vous connecter pour commenter');
                return { success: false, requires_auth: true };
            }
            
            this.showNotification('Erreur de connexion', 'error');
            return { success: false, message: 'Erreur de connexion' };
        }
    }

    /**
     * Charger les commentaires
     */
    async loadComments(type, id, page = 1) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/comments?type=${type}&id=${id}&page=${page}`, {
                headers: authManager.getHeaders()
            });

            const data = await response.json();

            if (data.success) {
                this.displayComments(data.data, type, id);
                return data;
            } else {
                console.error('Erreur lors du chargement des commentaires:', data.message);
            }
        } catch (error) {
            console.error('Erreur lors du chargement des commentaires:', error);
        }
    }

    /**
     * Afficher les commentaires dans l'interface
     */
    displayComments(comments, type, id) {
        const commentsContainer = document.querySelector(`[data-comments-type="${type}"][data-comments-id="${id}"]`);
        
        if (!commentsContainer) return;

        let html = '';
        comments.forEach(comment => {
            html += this.renderComment(comment, type, id);
        });

        commentsContainer.innerHTML = html;
    }

    /**
     * Render un commentaire
     */
    renderComment(comment, type, id, isReply = false) {
        const marginClass = isReply ? 'ml-8' : '';
        let repliesHtml = '';
        
        if (comment.replies && comment.replies.length > 0) {
            comment.replies.forEach(reply => {
                repliesHtml += this.renderComment(reply, type, id, true);
            });
        }

        return `
            <div class="comment ${marginClass} border-l-2 border-gray-200 pl-4 mb-4" data-comment-id="${comment.id}">
                <div class="flex items-center mb-2">
                    <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white text-sm font-bold">
                        ${comment.user ? comment.user.name.charAt(0).toUpperCase() : '?'}
                    </div>
                    <div class="ml-3">
                        <span class="font-semibold text-gray-900">
                            ${comment.user ? comment.user.name : 'Utilisateur anonyme'}
                        </span>
                        <span class="text-gray-500 text-sm ml-2">
                            ${new Date(comment.created_at).toLocaleDateString('fr-FR')}
                        </span>
                    </div>
                </div>
                <div class="text-gray-700 mb-2">${comment.content}</div>
                ${!isReply ? `
                    <button onclick="commentsManager.showReplyForm(${comment.id}, '${type}', ${id})" 
                            class="text-blue-500 hover:text-blue-700 text-sm">
                        Répondre
                    </button>
                    <div id="replyForm${comment.id}" class="hidden mt-2">
                        <textarea id="replyContent${comment.id}" 
                                  class="w-full p-2 border rounded resize-none" 
                                  rows="2" 
                                  placeholder="Votre réponse..."></textarea>
                        <div class="mt-2">
                            <button onclick="commentsManager.submitReply(${comment.id}, '${type}', ${id})" 
                                    class="bg-blue-500 text-white px-4 py-1 rounded text-sm">
                                Répondre
                            </button>
                            <button onclick="commentsManager.hideReplyForm(${comment.id})" 
                                    class="bg-gray-300 text-gray-700 px-4 py-1 rounded text-sm ml-2">
                                Annuler
                            </button>
                        </div>
                    </div>
                ` : ''}
                ${repliesHtml}
            </div>
        `;
    }

    /**
     * Afficher le formulaire de réponse
     */
    showReplyForm(commentId, type, id) {
        if (!authManager.isAuthenticated()) {
            authManager.showAuthModal('Vous devez vous connecter pour répondre à un commentaire');
            return;
        }

        // Masquer tous les autres formulaires de réponse
        document.querySelectorAll('[id^="replyForm"]').forEach(form => {
            form.classList.add('hidden');
        });

        // Afficher le formulaire pour ce commentaire
        const replyForm = document.getElementById(`replyForm${commentId}`);
        if (replyForm) {
            replyForm.classList.remove('hidden');
            document.getElementById(`replyContent${commentId}`).focus();
        }
    }

    /**
     * Masquer le formulaire de réponse
     */
    hideReplyForm(commentId) {
        const replyForm = document.getElementById(`replyForm${commentId}`);
        if (replyForm) {
            replyForm.classList.add('hidden');
            document.getElementById(`replyContent${commentId}`).value = '';
        }
    }

    /**
     * Soumettre une réponse
     */
    async submitReply(parentId, type, id) {
        const content = document.getElementById(`replyContent${parentId}`).value.trim();
        
        if (!content) {
            this.showNotification('Veuillez saisir une réponse', 'error');
            return;
        }

        const result = await this.addComment(type, id, content, parentId);
        
        if (result.success) {
            this.hideReplyForm(parentId);
        }
    }

    /**
     * Initialiser le formulaire de commentaire principal
     */
    initializeCommentForm() {
        document.addEventListener('submit', async (event) => {
            if (event.target.classList.contains('comment-form')) {
                event.preventDefault();
                
                const form = event.target;
                const type = form.dataset.type;
                const id = form.dataset.id;
                const textarea = form.querySelector('textarea');
                const content = textarea.value.trim();
                
                if (!content) {
                    this.showNotification('Veuillez saisir un commentaire', 'error');
                    return;
                }

                const result = await this.addComment(type, id, content);
                
                if (result.success) {
                    textarea.value = '';
                }
            }
        });
    }

    /**
     * Afficher une notification
     */
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 z-50 p-4 rounded shadow-lg transition-opacity duration-500 ${
            type === 'error' ? 'bg-red-500 text-white' : 'bg-green-500 text-white'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 500);
        }, 3000);
    }

    /**
     * Initialiser les commentaires sur la page
     */
    initialize() {
        this.initializeCommentForm();
        
        // Charger les commentaires existants
        document.querySelectorAll('[data-comments-type]').forEach(container => {
            const type = container.dataset.commentsType;
            const id = container.dataset.commentsId;
            this.loadComments(type, id);
        });
    }
}

// Initialiser le gestionnaire de commentaires
const commentsManager = new CommentsManager();

// Initialiser quand le DOM est prêt
document.addEventListener('DOMContentLoaded', () => {
    commentsManager.initialize();
});

// Fonctions globales pour Alpine.js
window.addComment = async function(type, id, content) {
    return await commentsManager.addComment(type, id, content);
};

window.loadComments = async function(type, id) {
    return await commentsManager.loadComments(type, id);
};