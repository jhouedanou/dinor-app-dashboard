/**
 * Service moderne de notifications push compatible avec iOS et toutes plateformes
 */

class NotificationService {
  constructor() {
    this.isInitialized = false
    this.isSupported = this.checkSupport()
    this.permission = 'default'
    this.swRegistration = null
  }

  /**
   * Vérifie le support des notifications
   */
  checkSupport() {
    return 'Notification' in window && 
           'serviceWorker' in navigator && 
           'PushManager' in window
  }

  /**
   * Initialise le service de notifications
   */
  async init() {
    if (this.isInitialized) {
      console.log('🔔 NotificationService: Déjà initialisé')
      return
    }

    if (!this.isSupported) {
      console.warn('🔔 NotificationService: Les notifications ne sont pas supportées')
      return
    }

    try {
      // Enregistrer le service worker
      await this.registerServiceWorker()
      
      // Vérifier la permission actuelle
      this.permission = Notification.permission
      
      this.isInitialized = true
      console.log('✅ NotificationService: Initialisé avec succès')
    } catch (error) {
      console.error('❌ NotificationService: Erreur d\'initialisation:', error)
    }
  }

  /**
   * Enregistre le service worker
   */
  async registerServiceWorker() {
    try {
      const registration = await navigator.serviceWorker.register('/pwa/sw.js')
      this.swRegistration = registration
      console.log('✅ Service Worker enregistré:', registration)
      return registration
    } catch (error) {
      console.error('❌ Erreur d\'enregistrement du Service Worker:', error)
      throw error
    }
  }

  /**
   * Demande la permission pour les notifications (optimisé pour iOS)
   */
  async requestPermission() {
    if (!this.isSupported) {
      console.warn('🔔 Les notifications ne sont pas supportées')
      return 'denied'
    }

    // Vérifier si déjà accordée
    if (Notification.permission === 'granted') {
      console.log('🔔 Permission déjà accordée')
      return 'granted'
    }

    try {
      // Pour iOS Safari, utiliser une interaction utilisateur
      const permission = await this.requestPermissionWithFallback()
      this.permission = permission
      
      console.log('🔔 Permission notifications:', permission)
      
      if (permission === 'granted') {
        // S'abonner aux notifications push
        await this.subscribeToPush()
      }
      
      return permission
    } catch (error) {
      console.error('❌ Erreur lors de la demande de permission:', error)
      return 'denied'
    }
  }

  /**
   * Demande de permission avec fallback pour iOS
   */
  async requestPermissionWithFallback() {
    // Méthode moderne (Promise-based)
    if (typeof Notification.requestPermission === 'function') {
      return await Notification.requestPermission()
    }
    
    // Fallback pour les anciens navigateurs (callback-based)
    return new Promise((resolve) => {
      Notification.requestPermission((permission) => {
        resolve(permission)
      })
    })
  }

  /**
   * S'abonne aux notifications push
   */
  async subscribeToPush() {
    if (!this.swRegistration) {
      throw new Error('Service Worker non disponible')
    }

    try {
      const subscription = await this.swRegistration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array('BEl62iUYgUivxIkv69yViEuiBIa6wFfIBmUMWiSAOXrCO72AcQQGOWGp3W_9QFH0H6lLjxFnMhqQOQAMuoVF_Lk')
      })

      console.log('✅ Abonnement push créé:', subscription)
      
      // Envoyer l'abonnement au serveur
      await this.sendSubscriptionToServer(subscription)
      
      return subscription
    } catch (error) {
      console.error('❌ Erreur d\'abonnement push:', error)
      throw error
    }
  }

  /**
   * Envoie l'abonnement au serveur
   */
  async sendSubscriptionToServer(subscription) {
    try {
      const response = await fetch('/api/push-subscription', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          subscription: subscription,
          user_agent: navigator.userAgent,
          platform: this.detectPlatform()
        })
      })

      if (response.ok) {
        console.log('✅ Abonnement envoyé au serveur')
      } else {
        console.warn('⚠️ Erreur envoi abonnement:', response.status)
      }
    } catch (error) {
      console.error('❌ Erreur envoi serveur:', error)
    }
  }

  /**
   * Détecte la plateforme
   */
  detectPlatform() {
    const userAgent = navigator.userAgent.toLowerCase()
    
    if (/iphone|ipad|ipod/.test(userAgent)) {
      return 'ios'
    } else if (/android/.test(userAgent)) {
      return 'android'
    } else if (/mac/.test(userAgent)) {
      return 'macos'
    } else if (/win/.test(userAgent)) {
      return 'windows'
    }
    
    return 'unknown'
  }

  /**
   * Convertit une clé VAPID base64 en Uint8Array
   */
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  /**
   * Affiche une notification locale (fallback)
   */
  async showLocalNotification(title, options = {}) {
    if (this.permission !== 'granted') {
      console.warn('🔔 Permission non accordée pour les notifications')
      return
    }

    try {
      const notification = new Notification(title, {
        icon: '/pwa/icons/icon-192x192.png',
        badge: '/pwa/icons/icon-96x96.png',
        vibrate: [200, 100, 200],
        ...options
      })

      // Auto-fermeture après 5 secondes
      setTimeout(() => {
        notification.close()
      }, 5000)

      return notification
    } catch (error) {
      console.error('❌ Erreur affichage notification:', error)
    }
  }

  /**
   * Vérifie le statut des notifications
   */
  getStatus() {
    return {
      isSupported: this.isSupported,
      permission: this.permission,
      isInitialized: this.isInitialized,
      hasServiceWorker: !!this.swRegistration
    }
  }

  /**
   * Désactive les notifications
   */
  async unsubscribe() {
    if (!this.swRegistration) {
      return
    }

    try {
      const subscription = await this.swRegistration.pushManager.getSubscription()
      if (subscription) {
        await subscription.unsubscribe()
        console.log('✅ Désabonnement réussi')
      }
    } catch (error) {
      console.error('❌ Erreur désabonnement:', error)
    }
  }

  /**
   * Interface pour demander la permission avec UI
   */
  async requestPermissionWithPrompt() {
    // Créer un prompt personnalisé pour iOS
    if (this.detectPlatform() === 'ios') {
      return this.showIOSPermissionPrompt()
    }
    
    return this.requestPermission()
  }

  /**
   * Prompt spécial pour iOS
   */
  async showIOSPermissionPrompt() {
    return new Promise((resolve) => {
      // Créer une modal personnalisée
      const modal = document.createElement('div')
      modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      `

      modal.innerHTML = `
        <div style="
          background: white;
          border-radius: 12px;
          padding: 24px;
          max-width: 320px;
          margin: 20px;
          text-align: center;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        ">
          <div style="font-size: 48px; margin-bottom: 16px;">🔔</div>
          <h3 style="margin: 0 0 12px 0; color: #333;">Activer les notifications</h3>
          <p style="margin: 0 0 24px 0; color: #666; font-size: 14px; line-height: 1.4;">
            Recevez les dernières actualités, événements et astuces culinaires directement sur votre appareil.
          </p>
          <div style="display: flex; gap: 12px;">
            <button id="notification-deny" style="
              flex: 1;
              padding: 12px;
              border: 1px solid #ddd;
              border-radius: 8px;
              background: white;
              color: #666;
              font-size: 16px;
              cursor: pointer;
            ">Plus tard</button>
            <button id="notification-allow" style="
              flex: 1;
              padding: 12px;
              border: none;
              border-radius: 8px;
              background: #E53E3E;
              color: white;
              font-size: 16px;
              cursor: pointer;
            ">Activer</button>
          </div>
        </div>
      `

      document.body.appendChild(modal)

      const allowBtn = modal.querySelector('#notification-allow')
      const denyBtn = modal.querySelector('#notification-deny')

      allowBtn.onclick = async () => {
        document.body.removeChild(modal)
        const permission = await this.requestPermission()
        resolve(permission)
      }

      denyBtn.onclick = () => {
        document.body.removeChild(modal)
        resolve('denied')
      }
    })
  }
}

// Export par défaut
export default NotificationService

// Instance globale
export const notificationService = new NotificationService()