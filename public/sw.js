const CACHE_NAME = 'dinor-pwa-v1';
const urlsToCache = [
  '/pwa/',
  '/pwa/index.html',
  '/pwa/app.js',
  '/pwa/style.css',
  '/manifest.json',
  // Assets statiques
  '/css/auth-components.css',
  '/js/auth-manager.js',
  '/js/likes-manager.js',
  '/js/comments-manager.js',
  // CDN resources (mise en cache pour l'offline)
  'https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js',
  'https://unpkg.com/vue-router@4/dist/vue-router.global.prod.js',
  'https://cdn.tailwindcss.com',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'
];

// Installation du service worker
self.addEventListener('install', event => {
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
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Suppression du cache obsolète:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Stratégie de cache : Network First pour les APIs, Cache First pour les assets
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Stratégie pour les API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(request)
        .then(response => {
          // Clone la réponse pour la mettre en cache
          const responseClone = response.clone();
          caches.open(CACHE_NAME)
            .then(cache => {
              cache.put(request, responseClone);
            });
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
            // Vérifie si la réponse est valide
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clone la réponse pour la mettre en cache
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(request, responseToCache);
              });

            return response;
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