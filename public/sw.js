const CACHE_NAME = 'dinor-pwa-v4';
const urlsToCache = [
  '/pwa/',
  '/pwa/index.html',
  '/pwa/app.js',
  // Nouveaux fichiers CSS
  '/pwa/styles/dinor-color-palette.css',
  '/pwa/styles/md3-single-pages.css',
  '/pwa/styles/main.css',
  '/pwa/styles/bottom-navigation.css',
  '/pwa/styles/components.css',
  '/pwa/styles/dinor-tv-player.css',
  // Composants JavaScript
  '/pwa/components/navigation/BottomNavigation.js',
  '/pwa/components/DinorTV.js',
  '/pwa/components/Recipe.js',
  '/pwa/components/Event.js',
  '/pwa/components/RecipesList.js',
  '/pwa/components/EventsList.js',
  '/pwa/components/PagesList.js',
  '/pwa/components/Tip.js',
  '/manifest.json',
  // Assets statiques
  '/css/auth-components.css',
  '/js/auth-manager.js',
  '/js/likes-manager.js',
  '/js/comments-manager.js',
  // CDN resources (mise en cache pour l'offline)
  'https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js',
  'https://unpkg.com/vue-router@4/dist/vue-router.global.prod.js',
  'https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap',
  'https://fonts.googleapis.com/icon?family=Material+Icons',
  'https://cdn.tailwindcss.com',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'
];

// Fonction pour vérifier si une requête peut être mise en cache
function canCache(request) {
  try {
    const url = new URL(request.url);
    
    // Exclure les extensions Chrome et autres schémas non-supportés
    if (url.protocol !== 'http:' && url.protocol !== 'https:') {
      console.log(`SW: Schéma non supporté: ${url.protocol}`);
      return false;
    }
    
    // Seules les requêtes GET peuvent être mises en cache
    if (request.method !== 'GET') {
      console.log(`SW: Méthode non supportée: ${request.method}`);
      return false;
    }
    
    // Exclure les requêtes vers des extensions
    if (url.href.includes('chrome-extension') || 
        url.href.includes('moz-extension') || 
        url.href.includes('safari-extension') ||
        url.protocol === 'chrome-extension:' ||
        url.protocol === 'moz-extension:' ||
        url.protocol === 'safari-extension:') {
      console.log(`SW: Requête extension détectée: ${url.href}`);
      return false;
    }
    
    return true;
  } catch (error) {
    console.log(`SW: Erreur analyse URL: ${error.message}`);
    return false;
  }
}

// Installation du service worker
self.addEventListener('install', event => {
  // Force la mise à jour immédiate
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Cache ouvert');
        return cache.addAll(urlsToCache);
      })
      .catch(err => {
        console.error('Erreur lors de la mise en cache:', err);
      })
  );
});

// Activation du service worker
self.addEventListener('activate', event => {
  // Prendre le contrôle immédiatement
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all([
        // Supprimer les anciens caches
        ...cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Suppression du cache obsolète:', cacheName);
            return caches.delete(cacheName);
          }
        }),
        // Prendre le contrôle de tous les clients
        self.clients.claim()
      ]);
    })
  );
});

// Stratégie de cache : Network First pour les APIs, Cache First pour les assets
self.addEventListener('fetch', event => {
  const { request } = event;
  
  // Vérifier si la requête peut être mise en cache
  if (!canCache(request)) {
    console.log(`SW: Requête ignorée: ${request.url}`);
    // Laisser passer la requête sans l'intercepter
    return;
  }
  
  console.log(`SW: Traitement de la requête: ${request.url}`);
  
  const url = new URL(request.url);

  // Stratégie pour les API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(request)
        .then(response => {
          // Vérifier si la réponse peut être mise en cache
          if (response.status === 200 && canCache(request)) {
            // Clone la réponse pour la mettre en cache
            const responseClone = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(request, responseClone);
              })
              .catch(err => console.log('Erreur mise en cache API:', err));
          }
          return response;
        })
        .catch(() => {
          // Fallback vers le cache si réseau indisponible
          return caches.match(request);
        })
    );
    return;
  }

  // Stratégie Cache First pour les assets statiques
  event.respondWith(
    caches.match(request)
      .then(response => {
        // Retourne la version en cache si disponible
        if (response) {
          return response;
        }
        
        // Sinon, récupère depuis le réseau
        return fetch(request)
          .then(response => {
            // Vérifie si la réponse est valide et peut être mise en cache
            if (!response || response.status !== 200 || response.type !== 'basic' || !canCache(request)) {
              return response;
            }

            // Clone la réponse pour la mettre en cache
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(request, responseToCache);
              })
              .catch(err => console.log('Erreur mise en cache asset:', err));

            return response;
          });
      })
      .catch(err => {
        console.log('Erreur fetch:', err);
        // Retourner une réponse par défaut ou une page offline
        return new Response('Contenu non disponible hors ligne', {
          status: 503,
          statusText: 'Service Unavailable'
        });
      })
  );
});

// Gestion des notifications push (optionnel)
self.addEventListener('push', event => {
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body,
      icon: '/pwa/icons/icon-192x192.png',
      badge: '/pwa/icons/icon-72x72.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: data.primaryKey
      },
      actions: [
        {
          action: 'explore',
          title: 'Voir',
          icon: '/pwa/icons/icon-192x192.png'
        },
        {
          action: 'close',
          title: 'Fermer',
          icon: '/pwa/icons/icon-192x192.png'
        }
      ]
    };

    event.waitUntil(
      self.registration.showNotification(data.title, options)
    );
  }
});

// Gestion des clics sur les notifications
self.addEventListener('notificationclick', event => {
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/pwa/')
    );
  }
});