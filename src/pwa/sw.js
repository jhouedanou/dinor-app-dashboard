// Service Worker pour PWA Dinor avec OneSignal
console.log('Service Worker: Initialisation');

const CACHE_NAME = 'dinor-pwa-v3'; // Incrémenté pour forcer la mise à jour
const API_CACHE_NAME = 'dinor-api-v3';
const STATIC_CACHE_NAME = 'dinor-static-v3';

const urlsToCache = [
  '/',
  '/pwa/',
  '/pwa/index.html'
];

// URLs API à mettre en cache
const apiUrlsToCache = [
  '/api/v1/recipes',
  '/api/v1/tips',
  '/api/v1/events',
  '/api/v1/dinor-tv'
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
          if (cacheName !== CACHE_NAME && cacheName !== API_CACHE_NAME && cacheName !== STATIC_CACHE_NAME) {
            console.log('Service Worker: Suppression cache obsolète', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Interception SELECTIVE - seulement pour les assets statiques
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // RÈGLE #1: Ignorer les requêtes non-http
  if (!url.protocol.startsWith('http')) {
    return;
  }
  
  // RÈGLE #2: JAMAIS intercepter les pages de navigation PWA
  if (request.destination === 'document' || 
      request.mode === 'navigate' ||
      (url.pathname.startsWith('/pwa/') && !url.pathname.includes('.'))) {
    return; // Laisser le navigateur gérer la navigation
  }
  
  // RÈGLE #3: JAMAIS intercepter les APIs
  if (url.pathname.includes('/api/')) {
    return; // Laisser l'API tranquille
  }
  
  // RÈGLE #4: Ignorer les ressources de développement
  if (url.pathname.startsWith('/@vite') || 
      url.pathname.startsWith('/@fs') ||
      url.pathname.includes('/resources/css/filament/') ||
      (url.hostname === 'localhost' && url.port === '5173')) {
    return;
  }

  // RÈGLE #5: SEULEMENT intercepter les assets statiques (CSS, JS, images, etc.)
  const isStaticAsset = /\.(js|css|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot)$/i.test(url.pathname) ||
                       url.pathname.includes('/assets/') ||
                       url.pathname.includes('/icons/') ||
                       url.pathname.includes('/images/');

  if (!isStaticAsset) {
    return; // Laisser le navigateur gérer tout le reste
  }

  // SEULEMENT pour les assets statiques : Cache First avec fallback réseau
  event.respondWith(
    caches.match(request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse; // Utiliser le cache si disponible
      }
      
      // Sinon, aller chercher sur le réseau et mettre en cache
      return fetch(request).then((networkResponse) => {
        if (networkResponse.ok) {
          const responseClone = networkResponse.clone();
          caches.open(STATIC_CACHE_NAME).then((cache) => {
            cache.put(request, responseClone);
          });
        }
        return networkResponse;
      });
    })
  );
});

// Écouter les messages de l'application pour invalider le cache
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'INVALIDATE_CACHE') {
    invalidateCache(event.data.pattern || '');
  } else if (event.data && event.data.type === 'FORCE_REFRESH') {
    forceRefresh();
  } else if (event.data && event.data.type === 'CLEAR_ALL_CACHE') {
    clearAllCache();
  }
});

// Fonction pour invalider le cache statique
async function invalidateCache(pattern = '') {
  try {
    if (pattern && !pattern.includes('/api/')) {
      const staticCache = await caches.open(STATIC_CACHE_NAME);
      const keys = await staticCache.keys();
      
      for (const request of keys) {
        const url = new URL(request.url);
        if (!pattern || url.pathname.includes(pattern)) {
          await staticCache.delete(request);
        }
      }
    }
    
    // Notifier les clients de l'invalidation
    self.clients.matchAll().then(clients => {
      clients.forEach(client => {
        client.postMessage({
          type: 'CACHE_INVALIDATED',
          pattern: pattern,
          timestamp: Date.now()
        });
      });
    });
    
  } catch (error) {
    console.error('❌ [SW] Erreur invalidation cache:', error);
  }
}

// Fonction pour forcer le rechargement
async function forceRefresh() {
  try {
    await clearAllCache();
    
    // Notifier les clients de forcer le rechargement
    self.clients.matchAll().then(clients => {
      clients.forEach(client => {
        client.postMessage({
          type: 'FORCE_RELOAD',
          timestamp: Date.now()
        });
      });
    });
  } catch (error) {
    console.error('❌ [SW] Erreur rechargement forcé:', error);
  }
}

// Fonction pour supprimer tout le cache
async function clearAllCache() {
  try {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames.map(cacheName => caches.delete(cacheName))
    );
  } catch (error) {
    console.error('❌ [SW] Erreur suppression cache:', error);
  }
}

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
