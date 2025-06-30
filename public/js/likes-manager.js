/**
 * Gestionnaire des likes avec authentification
 */
class LikesManager {
    constructor() {
        this.apiBaseUrl = '/api/v1';
    }

    /**
     * Toggle like pour un contenu
     */
    async toggleLike(type, id) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/likes/toggle`, {
                method: 'POST',
                headers: authManager.getHeaders(),
                body: JSON.stringify({ type, id })
            });

            const data = await response.json();

            if (response.status === 401 && data.requires_auth) {
                // L'utilisateur n'est pas connecté
                authManager.showAuthModal(data.message);
                return { success: false, requires_auth: true };
            }

            if (data.success) {
                // Mettre à jour l'interface utilisateur
                this.updateLikeButton(type, id, data.action === 'liked', data.likes_count);
                return { success: true, action: data.action, likes_count: data.likes_count };
            } else {
                console.error('Erreur lors du toggle like:', data.message);
                this.showNotification(data.message, 'error');
                return { success: false, message: data.message };
            }
        } catch (error) {
            console.error('Erreur lors du toggle like:', error);
            
            // Vérifier si la réponse est du HTML (page d'erreur)
            if (error.message.includes('Unexpected token') || error.message.includes('<!DOCTYPE')) {
                authManager.showAuthModal('Vous devez vous connecter pour aimer ce contenu');
                return { success: false, requires_auth: true };
            }
            
            this.showNotification('Erreur de connexion', 'error');
            return { success: false, message: 'Erreur de connexion' };
        }
    }

    /**
     * Vérifier si un contenu est liké
     */
    async checkLike(type, id) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/likes/check?type=${type}&id=${id}`, {
                headers: authManager.getHeaders()
            });

            const data = await response.json();

            if (data.success) {
                this.updateLikeButton(type, id, data.is_liked, data.likes_count);
                return data;
            }
        } catch (error) {
            console.error('Erreur lors de la vérification du like:', error);
        }
    }

    /**
     * Mettre à jour le bouton de like dans l'interface
     */
    updateLikeButton(type, id, isLiked, likesCount) {
        const likeButton = document.querySelector(`[data-like-type="${type}"][data-like-id="${id}"]`);
        const countElement = document.querySelector(`[data-like-count-type="${type}"][data-like-count-id="${id}"]`);

        if (likeButton) {
            if (isLiked) {
                likeButton.classList.add('liked');
                likeButton.classList.remove('not-liked');
            } else {
                likeButton.classList.add('not-liked');
                likeButton.classList.remove('liked');
            }
        }

        if (countElement) {
            countElement.textContent = likesCount;
        }
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
        
        // Supprimer la notification après 3 secondes
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
     * Initialiser les événements de like sur la page
     */
    initializeLikeButtons() {
        document.addEventListener('click', (event) => {
            const likeButton = event.target.closest('[data-like-type]');
            if (likeButton) {
                event.preventDefault();
                const type = likeButton.dataset.likeType;
                const id = likeButton.dataset.likeId;
                this.toggleLike(type, id);
            }
        });

        // Vérifier l'état des likes au chargement de la page
        document.querySelectorAll('[data-like-type]').forEach(button => {
            const type = button.dataset.likeType;
            const id = button.dataset.likeId;
            this.checkLike(type, id);
        });
    }
}

// Initialiser le gestionnaire de likes
const likesManager = new LikesManager();

// Initialiser les boutons de like quand le DOM est prêt
document.addEventListener('DOMContentLoaded', () => {
    likesManager.initializeLikeButtons();
});

// Fonction globale pour Alpine.js
window.toggleLike = async function(type, id) {
    return await likesManager.toggleLike(type, id);
};