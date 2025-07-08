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

// Interception des requêtes - cache désactivé pour communication directe avec l'API
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Ignorer les requêtes non-http (ex: chrome-extension://)
  if (!url.protocol.startsWith('http')) {
    return;
  }
  
  // Ignorer le manifest.json et les ressources de dev Vite
  if (url.pathname === '/manifest.json' || 
      url.pathname.startsWith('/@vite') || 
      url.pathname.startsWith('/@fs') ||
      url.pathname.includes('/resources/css/filament/') ||
      url.hostname === 'localhost' && url.port === '5173') {
    return; // Laisser le navigateur gérer ces requêtes
  }

  // Communication directe avec l'API - pas de cache
  if (url.pathname.includes('/api/')) {
    console.log('🌐 [SW] Communication directe avec l\'API (cache désactivé):', url.pathname);
    // Laisser le navigateur gérer la requête directement
    return;
  }

  // Stratégie "Network First" pour les autres requêtes (assets statiques, etc.)
  event.respondWith(
    fetch(request).then((networkResponse) => {
      console.log('🌐 [SW] Requête réseau pour asset:', url.pathname);
      
      // IMPORTANT: Cloner la réponse AVANT toute utilisation pour éviter "Response body is already used"
      const responseClone = networkResponse.clone();
      
      // Optionnel: mettre en cache les nouvelles ressources statiques seulement
      if (networkResponse.ok && !url.pathname.includes('/api/')) {
        caches.open(STATIC_CACHE_NAME).then((cache) => {
          cache.put(request, responseClone);
        }).catch(error => {
          console.warn('⚠️ [SW] Erreur lors de la mise en cache:', error);
        });
      }
      
      return networkResponse;
    }).catch(() => {
      // Fallback: chercher dans le cache seulement si le réseau échoue
      return caches.match(request).then((response) => {
        if (response) {
          console.log('⚡ [SW] Fallback cache pour asset:', url.pathname);
          return response;
        }
        
        // Fallback pour la navigation hors ligne
        if (request.destination === 'document') {
          return caches.match('/pwa/index.html');
        }
        
        // Sinon, laisser l'erreur se propager
        throw new Error('Réseau indisponible et pas de cache disponible');
      });
    })
  );
});

// Écouter les messages de l'application pour invalider le cache
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'INVALIDATE_CACHE') {
    console.log('🔄 [SW] Invalidation du cache demandée');
    invalidateCache(event.data.pattern || '');
  } else if (event.data && event.data.type === 'FORCE_REFRESH') {
    console.log('🔄 [SW] Rechargement forcé demandé');
    forceRefresh();
  } else if (event.data && event.data.type === 'CLEAR_ALL_CACHE') {
    console.log('🗑️ [SW] Suppression de tout le cache demandée');
    clearAllCache();
  }
});

// Fonction pour invalider le cache - désactivé car plus de cache API
async function invalidateCache(pattern = '') {
  try {
    console.log('🗑️ [SW] Invalidation du cache demandée:', pattern, '- Cache API désactivé');
    
    // Seulement nettoyer le cache statique si nécessaire
    if (pattern && !pattern.includes('/api/')) {
      const staticCache = await caches.open(STATIC_CACHE_NAME);
      const keys = await staticCache.keys();
      
      for (const request of keys) {
        const url = new URL(request.url);
        if (!pattern || url.pathname.includes(pattern)) {
          await staticCache.delete(request);
          console.log('🗑️ [SW] Cache statique supprimé:', url.pathname);
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
    console.error('❌ [SW] Erreur lors de l\'invalidation du cache:', error);
  }
}

// Fonction pour forcer le rechargement
async function forceRefresh() {
  try {
    // Vider tous les caches
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
    
    console.log('🔄 [SW] Rechargement forcé effectué');
  } catch (error) {
    console.error('❌ [SW] Erreur lors du rechargement forcé:', error);
  }
}

// Fonction pour supprimer tout le cache
async function clearAllCache() {
  try {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames.map(cacheName => {
        console.log('🗑️ [SW] Suppression du cache:', cacheName);
        return caches.delete(cacheName);
      })
    );
    
    console.log('✅ [SW] Tous les caches supprimés');
  } catch (error) {
    console.error('❌ [SW] Erreur lors de la suppression du cache:', error);
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
