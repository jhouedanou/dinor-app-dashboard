// Bouton flottant pour nettoyer les Service Workers
(function() {
    'use strict';
    
    // Ne pas créer le bouton si on est déjà sur la page de nettoyage
    if (window.location.pathname.includes('clear-sw.html')) {
        return;
    }
    
    // Créer le bouton flottant
    const cleanButton = document.createElement('div');
    cleanButton.id = 'sw-clean-button';
    cleanButton.innerHTML = '🧹 SW';
    cleanButton.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        z-index: 9999;
        background: #e74c3c;
        color: white;
        border: none;
        border-radius: 50px;
        width: 60px;
        height: 60px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        font-family: system-ui, -apple-system, sans-serif;
    `;
    
    // Effets hover
    cleanButton.addEventListener('mouseenter', function() {
        this.style.transform = 'scale(1.1)';
        this.style.background = '#c0392b';
        this.title = 'Nettoyer les Service Workers';
    });
    
    cleanButton.addEventListener('mouseleave', function() {
        this.style.transform = 'scale(1)';
        this.style.background = '#e74c3c';
    });
    
    // Action de nettoyage
    cleanButton.addEventListener('click', async function() {
        this.innerHTML = '⏳';
        this.style.background = '#f39c12';
        
        try {
            let cleaned = 0;
            
            // Nettoyer les Service Workers
            if ('serviceWorker' in navigator) {
                const registrations = await navigator.serviceWorker.getRegistrations();
                for (let registration of registrations) {
                    await registration.unregister();
                    cleaned++;
                    console.log('🗑️ Service Worker désinscrit:', registration.scope);
                }
            }
            
            // Nettoyer les caches
            if ('caches' in window) {
                const cacheNames = await caches.keys();
                await Promise.all(
                    cacheNames.map(cacheName => {
                        console.log('🗑️ Cache supprimé:', cacheName);
                        return caches.delete(cacheName);
                    })
                );
            }
            
            // Succès
            this.innerHTML = '✅';
            this.style.background = '#27ae60';
            
            // Notification
            const notification = document.createElement('div');
            notification.innerHTML = `
                🧹 Nettoyage terminé !<br>
                🗑️ ${cleaned} Service Worker(s)<br>
                🔄 Rechargement recommandé
            `;
            notification.style.cssText = `
                position: fixed;
                bottom: 90px;
                right: 20px;
                z-index: 10000;
                background: #2ecc71;
                color: white;
                padding: 15px;
                border-radius: 8px;
                font-size: 14px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                max-width: 200px;
                text-align: center;
                line-height: 1.4;
            `;
            
            document.body.appendChild(notification);
            
            // Supprimer la notification après 5 secondes
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 5000);
            
            // Remettre le bouton normal après 3 secondes
            setTimeout(() => {
                this.innerHTML = '🧹 SW';
                this.style.background = '#e74c3c';
            }, 3000);
            
        } catch (error) {
            console.error('Erreur lors du nettoyage:', error);
            this.innerHTML = '❌';
            this.style.background = '#e74c3c';
            
            setTimeout(() => {
                this.innerHTML = '🧹 SW';
            }, 2000);
        }
    });
    
    // Ajouter le bouton au DOM quand la page est prête
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            document.body.appendChild(cleanButton);
        });
    } else {
        document.body.appendChild(cleanButton);
    }
    
    console.log('🧹 Bouton de nettoyage Service Workers ajouté');
})(); 