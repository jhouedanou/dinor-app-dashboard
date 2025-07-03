/**
 * Service OneSignal pour la gestion des notifications push
 */
class OneSignalService {
    constructor() {
        this.isInitialized = false;
        
        // Configuration conditionnelle selon l'environnement
        if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
            // Mode développement local - OneSignal désactivé
            this.appId = null;
            this.devMode = true;
            console.log('🔧 OneSignal: Mode développement - notifications désactivées');
        } else {
            // Mode production
            this.appId = "7703701f-3c33-408d-99e0-db5c4da8918a";
            this.devMode = false;
            this.init();
        }
    }

    /**
     * Initialise OneSignal
     */
    async init() {
        if (this.devMode) {
            console.log('🔧 OneSignal: Initialisation ignorée en mode développement');
            return;
        }
        
        try {
            window.OneSignalDeferred = window.OneSignalDeferred || [];
            
            OneSignalDeferred.push(async (OneSignal) => {
                await OneSignal.init({
                    appId: this.appId,
                    allowLocalhostAsSecureOrigin: true, // Pour le développement
                });

                this.isInitialized = true;
                console.log('✅ OneSignal initialisé avec succès');

                // Écouter les événements de notification
                this.setupEventListeners();
                
                // Demander la permission si pas déjà accordée
                await this.requestPermission();
            });
        } catch (error) {
            console.error('❌ Erreur lors de l\'initialisation OneSignal:', error);
        }
    }

    /**
     * Configure les écouteurs d'événements
     */
    setupEventListeners() {
        if (this.devMode) {
            return;
        }
        
        window.OneSignalDeferred.push((OneSignal) => {
            // Notification reçue
            OneSignal.Notifications.addEventListener('receive', (event) => {
                console.log('📱 Notification reçue:', event);
                this.onNotificationReceived(event);
            });

            // Notification cliquée
            OneSignal.Notifications.addEventListener('click', (event) => {
                console.log('👆 Notification cliquée:', event);
                this.onNotificationClicked(event);
            });

            // Permission accordée
            OneSignal.Notifications.addEventListener('permissionChange', (event) => {
                console.log('🔔 Permission changée:', event);
                this.onPermissionChanged(event);
            });
        });
    }

    /**
     * Demande la permission pour les notifications
     */
    async requestPermission() {
        if (this.devMode) {
            console.log('🔧 OneSignal: Permission ignorée en mode développement');
            return false;
        }
        
        return new Promise((resolve) => {
            window.OneSignalDeferred.push(async (OneSignal) => {
                try {
                    const permission = await OneSignal.Notifications.requestPermission();
                    console.log('🔔 Permission notifications:', permission);
                    resolve(permission);
                } catch (error) {
                    console.error('❌ Erreur permission:', error);
                    resolve(false);
                }
            });
        });
    }

    /**
     * Obtient l'ID de l'utilisateur OneSignal
     */
    async getUserId() {
        return new Promise((resolve) => {
            window.OneSignalDeferred.push(async (OneSignal) => {
                try {
                    const userId = await OneSignal.User.PushSubscription.id;
                    resolve(userId);
                } catch (error) {
                    console.error('❌ Erreur getUserId:', error);
                    resolve(null);
                }
            });
        });
    }

    /**
     * Vérifie si l'utilisateur est abonné
     */
    async isSubscribed() {
        return new Promise((resolve) => {
            window.OneSignalDeferred.push(async (OneSignal) => {
                try {
                    const isSubscribed = await OneSignal.User.PushSubscription.optedIn;
                    resolve(isSubscribed);
                } catch (error) {
                    console.error('❌ Erreur isSubscribed:', error);
                    resolve(false);
                }
            });
        });
    }

    /**
     * Ajoute des tags à l'utilisateur
     */
    async addTags(tags) {
        return new Promise((resolve) => {
            window.OneSignalDeferred.push(async (OneSignal) => {
                try {
                    await OneSignal.User.addTags(tags);
                    console.log('🏷️ Tags ajoutés:', tags);
                    resolve(true);
                } catch (error) {
                    console.error('❌ Erreur addTags:', error);
                    resolve(false);
                }
            });
        });
    }

    /**
     * Gestionnaire pour notification reçue
     */
    onNotificationReceived(event) {
        // Vous pouvez personnaliser le comportement ici
        const notification = event.notification;
        
        // Exemple : afficher une alerte personnalisée
        if (notification.additionalData?.showAlert) {
            this.showCustomAlert(notification);
        }
    }

    /**
     * Gestionnaire pour notification cliquée
     */
    onNotificationClicked(event) {
        const notification = event.notification;
        
        // Si une URL est spécifiée, rediriger
        if (notification.launchURL) {
            window.location.href = notification.launchURL;
        } else if (notification.additionalData?.url) {
            window.location.href = notification.additionalData.url;
        }
    }

    /**
     * Gestionnaire pour changement de permission
     */
    onPermissionChanged(event) {
        if (event) {
            console.log('🔔 Notifications activées');
            // Optionnel : informer l'utilisateur
            this.showPermissionGrantedMessage();
        } else {
            console.log('🔕 Notifications désactivées');
        }
    }

    /**
     * Affiche une alerte personnalisée
     */
    showCustomAlert(notification) {
        // Créer une notification toast personnalisée
        const toast = document.createElement('div');
        toast.className = 'custom-notification-toast';
        toast.innerHTML = `
            <div class="toast-content">
                <h4>${notification.title}</h4>
                <p>${notification.body}</p>
            </div>
        `;
        
        // Ajouter du style
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #333;
            color: white;
            padding: 15px;
            border-radius: 8px;
            max-width: 300px;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        `;
        
        document.body.appendChild(toast);
        
        // Supprimer après 5 secondes
        setTimeout(() => {
            toast.remove();
        }, 5000);
    }

    /**
     * Affiche un message de confirmation de permission
     */
    showPermissionGrantedMessage() {
        console.log('✅ Vous recevrez maintenant les notifications Dinor !');
    }
}

// Export par défaut
export default OneSignalService;

// Créer une instance globale
export const oneSignalService = new OneSignalService();