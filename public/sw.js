// Service Worker pour PWA Dinor avec OneSignal
console.log('Service Worker: Initialisation');

const CACHE_NAME = 'dinor-pwa-v1';
const urlsToCache = [
  '/',
  '/pwa/',
  '/pwa/index.html'
];

// Installation du service worker
self.addEventListener('install', (event) => {
  console.log('Service Worker: Installation');
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Cache ouvert');
        return cache.addAll(urlsToCache);
      })
      .catch((error) => {
        console.log('Service Worker: Erreur lors de la mise en cache:', error);
      })
  );
});

// Activation du service worker
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activation');
  self.clients.claim();
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Suppression cache obsolète', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Interception des requêtes
self.addEventListener('fetch', (event) => {
  // Ne pas intercepter les requêtes API
  if (event.request.url.includes('/api/')) {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Retourner la réponse en cache si elle existe
        if (response) {
          return response;
        }
        // Sinon, faire la requête réseau
        return fetch(event.request);
      })
      .catch(() => {
        // En cas d'erreur, retourner une page d'erreur ou une page par défaut
        if (event.request.destination === 'document') {
          return caches.match('/pwa/index.html');
        }
      })
  );
});

// Configuration OneSignal pour le développement local
// Pour éviter les erreurs de restriction d'origine en développement
try {
  // Importation du SDK OneSignal seulement si on n'est pas en localhost
  if (location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
    importScripts('https://cdn.onesignal.com/sdks/web/v16/OneSignalSDKWorker.js');
    console.log('Service Worker: OneSignal SDK chargé');
  } else {
    console.log('Service Worker: OneSignal désactivé en développement local');
  }
} catch (error) {
  console.log('Service Worker: OneSignal SDK non disponible:', error);
}

// Gestionnaire pour les notifications push (OneSignal)
self.addEventListener('push', (event) => {
  console.log('Service Worker: Notification push reçue', event);
  
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body || 'Nouvelle notification de Dinor',
      icon: '/pwa/icons/icon-192x192.png',
      badge: '/pwa/icons/icon-96x96.png',
      vibrate: [200, 100, 200],
      data: {
        url: data.url || '/pwa/'
      }
    };
    
    event.waitUntil(
      self.registration.showNotification(data.title || 'Dinor', options)
    );
  }
});

// Gestionnaire pour le clic sur notification
self.addEventListener('notificationclick', (event) => {
  console.log('Service Worker: Clic sur notification', event);
  
  event.notification.close();
  
  const url = event.notification.data?.url || '/pwa/';
  
  event.waitUntil(
    clients.openWindow(url)
  );
});

console.log('Service Worker: Configuration terminée');
