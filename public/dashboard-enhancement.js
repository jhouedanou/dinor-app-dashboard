// Script d'amélioration du dashboard avec système de likes et liens vers pages détaillées

// Fonction pour ajouter les boutons de like aux cartes
function addLikeButtons() {
    // Sélectionner toutes les cartes de contenu
    const contentCards = document.querySelectorAll('[data-content-type]');
    
    contentCards.forEach(card => {
        const contentType = card.getAttribute('data-content-type');
        const contentId = card.getAttribute('data-content-id');
        
        if (contentType && contentId && !card.querySelector('.like-button')) {
            // Créer le bouton de like
            const likeButton = createLikeButton(contentType, contentId);
            
            // Trouver où insérer le bouton (dans le footer de la carte)
            const cardFooter = card.querySelector('.card-footer') || card.querySelector('.p-4:last-child') || card.lastElementChild;
            
            if (cardFooter) {
                // Créer un conteneur pour les actions si il n'existe pas
                let actionsContainer = cardFooter.querySelector('.card-actions');
                if (!actionsContainer) {
                    actionsContainer = document.createElement('div');
                    actionsContainer.className = 'card-actions flex items-center justify-between mt-3 pt-3 border-t border-gray-200';
                    cardFooter.appendChild(actionsContainer);
                }
                
                // Ajouter le bouton de like
                actionsContainer.appendChild(likeButton);
                
                // Ajouter le lien "Voir plus"
                const viewMoreLink = createViewMoreLink(contentType, contentId, card);
                actionsContainer.appendChild(viewMoreLink);
            }
        }
    });
}

// Fonction pour créer un bouton de like
function createLikeButton(contentType, contentId) {
    const button = document.createElement('button');
    button.className = 'like-button flex items-center space-x-2 px-3 py-1 rounded-lg bg-gray-50 hover:bg-red-50 border border-gray-200 hover:border-red-200 transition-all duration-200';
    button.setAttribute('data-content-type', contentType);
    button.setAttribute('data-content-id', contentId);
    
    const icon = document.createElement('i');
    icon.className = 'fas fa-heart text-gray-400';
    
    const count = document.createElement('span');
    count.className = 'text-sm text-gray-600';
    count.textContent = '0';
    
    button.appendChild(icon);
    button.appendChild(count);
    
    // Ajouter l'événement de clic
    button.addEventListener('click', () => toggleLike(contentType, contentId, button));
    
    // Charger l'état initial du like
    loadLikeState(contentType, contentId, button);
    
    return button;
}

// Fonction pour créer un lien "Voir plus"
function createViewMoreLink(contentType, contentId, card) {
    const link = document.createElement('a');
    
    // Déterminer la page de destination
    const pageMap = {
        'recipe': 'recipe.html',
        'event': 'event.html',
        'tip': 'tip.html'
    };
    
    const page = pageMap[contentType];
    if (page) {
        link.href = `${page}?id=${contentId}`;
        link.className = 'inline-flex items-center text-sm text-yellow-600 hover:text-yellow-700 font-medium';
        link.innerHTML = '<span>Voir détails</span><i class="fas fa-arrow-right ml-1"></i>';
    }
    
    return link;
}

// Fonction pour basculer l'état du like
async function toggleLike(contentType, contentId, button) {
    try {
        const response = await fetch('/api/v1/likes/toggle', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                likeable_type: contentType,
                likeable_id: contentId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            updateLikeButton(button, data.data.liked, data.data.likes_count);
        }
    } catch (error) {
        console.error('Erreur lors du toggle like:', error);
    }
}

// Fonction pour charger l'état initial du like
async function loadLikeState(contentType, contentId, button) {
    try {
        const response = await fetch(`/api/v1/likes/check?type=${contentType}&id=${contentId}`);
        const data = await response.json();
        
        if (data.success) {
            updateLikeButton(button, data.data.liked, data.data.likes_count);
        }
    } catch (error) {
        console.error('Erreur lors du chargement de l\'état du like:', error);
    }
}

// Fonction pour mettre à jour l'apparence du bouton de like
function updateLikeButton(button, isLiked, likesCount) {
    const icon = button.querySelector('i');
    const count = button.querySelector('span');
    
    if (isLiked) {
        button.className = button.className.replace('bg-gray-50 hover:bg-red-50 border-gray-200 hover:border-red-200', 'bg-red-50 border-red-200');
        icon.className = 'fas fa-heart text-red-500';
        count.className = 'text-sm text-red-600';
    } else {
        button.className = button.className.replace('bg-red-50 border-red-200', 'bg-gray-50 hover:bg-red-50 border-gray-200 hover:border-red-200');
        icon.className = 'fas fa-heart text-gray-400';
        count.className = 'text-sm text-gray-600';
    }
    
    count.textContent = likesCount || 0;
}

// Fonction pour ajouter les statistiques de likes au dashboard
async function addLikesStats() {
    try {
        const response = await fetch('/api/v1/likes/stats');
        const data = await response.json();
        
        if (data.success) {
            // Trouver le conteneur des statistiques
            const statsContainer = document.querySelector('.stats-grid') || document.querySelector('[data-stats-container]');
            
            if (statsContainer) {
                // Créer la carte des statistiques de likes
                const likesStatsCard = createLikesStatsCard(data.data);
                statsContainer.appendChild(likesStatsCard);
            }
        }
    } catch (error) {
        console.error('Erreur lors du chargement des statistiques de likes:', error);
    }
}

// Fonction pour créer la carte des statistiques de likes
function createLikesStatsCard(likesData) {
    const card = document.createElement('div');
    card.className = 'bg-white rounded-lg shadow-lg p-6 border border-gray-200';
    
    card.innerHTML = `
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">Likes par catégorie</h3>
            <div class="p-2 bg-red-100 rounded-lg">
                <i class="fas fa-heart text-red-600"></i>
            </div>
        </div>
        <div class="space-y-3">
            <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Recettes</span>
                <span class="font-medium text-red-600">${likesData.likes_by_category.recipes || 0}</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Événements</span>
                <span class="font-medium text-blue-600">${likesData.likes_by_category.events || 0}</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Astuces</span>
                <span class="font-medium text-green-600">${likesData.likes_by_category.tips || 0}</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Vidéos</span>
                <span class="font-medium text-purple-600">${likesData.likes_by_category.videos || 0}</span>
            </div>
            <div class="pt-3 border-t border-gray-200">
                <div class="flex justify-between items-center font-semibold">
                    <span class="text-gray-900">Total</span>
                    <span class="text-lg text-yellow-600">${likesData.total_likes || 0}</span>
                </div>
            </div>
        </div>
    `;
    
    return card;
}

// Fonction pour marquer les cartes avec les attributs nécessaires
function markContentCards() {
    // Marquer les cartes de recettes
    const recipeCards = document.querySelectorAll('[data-recipe-id]');
    recipeCards.forEach(card => {
        const recipeId = card.getAttribute('data-recipe-id');
        card.setAttribute('data-content-type', 'recipe');
        card.setAttribute('data-content-id', recipeId);
    });
    
    // Marquer les cartes d'événements
    const eventCards = document.querySelectorAll('[data-event-id]');
    eventCards.forEach(card => {
        const eventId = card.getAttribute('data-event-id');
        card.setAttribute('data-content-type', 'event');
        card.setAttribute('data-content-id', eventId);
    });
    
    // Marquer les cartes d'astuces
    const tipCards = document.querySelectorAll('[data-tip-id]');
    tipCards.forEach(card => {
        const tipId = card.getAttribute('data-tip-id');
        card.setAttribute('data-content-type', 'tip');
        card.setAttribute('data-content-id', tipId);
    });
}

// Fonction principale d'initialisation
function initDashboardEnhancements() {
    // Attendre que le DOM soit complètement chargé
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            setTimeout(enhanceDashboard, 1000); // Attendre que les données soient chargées
        });
    } else {
        setTimeout(enhanceDashboard, 1000);
    }
}

// Fonction pour améliorer le dashboard
function enhanceDashboard() {
    console.log('Amélioration du dashboard en cours...');
    
    // Marquer les cartes avec les attributs de contenu
    markContentCards();
    
    // Ajouter les boutons de like
    addLikeButtons();
    
    // Ajouter les statistiques de likes
    addLikesStats();
    
    // Observer les changements dans le DOM pour les nouvelles cartes
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.type === 'childList') {
                // Vérifier si de nouvelles cartes ont été ajoutées
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === Node.ELEMENT_NODE && node.querySelector) {
                        markContentCards();
                        addLikeButtons();
                    }
                });
            }
        });
    });
    
    // Observer les changements dans le conteneur principal
    const container = document.querySelector('.container') || document.body;
    observer.observe(container, { childList: true, subtree: true });
    
    console.log('Dashboard amélioré avec succès!');
}

// Initialiser les améliorations
initDashboardEnhancements();