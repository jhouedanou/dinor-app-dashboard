import { precacheAndRoute, cleanupOutdatedCaches } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { NetworkFirst, CacheFirst, StaleWhileRevalidate } from 'workbox-strategies';
import { BackgroundSync } from 'workbox-background-sync';
import { Queue } from 'workbox-background-sync';

// Précache et nettoyage
precacheAndRoute(self.__WB_MANIFEST);
cleanupOutdatedCaches();

// Configuration des caches
const API_CACHE = 'dinor-api-v1';
const IMAGES_CACHE = 'dinor-images-v1';
const STATIC_CACHE = 'dinor-static-v1';

// Queue pour les données en mode offline
const bgSyncQueue = new Queue('api-queue', {
  onSync: async ({ queue }) => {
    let entry;
    while ((entry = await queue.shiftRequest())) {
      try {
        await fetch(entry.request);
        console.log('Sync réussi pour:', entry.request.url);
      } catch (error) {
        console.error('Erreur sync:', error);
        // Remettre en queue en cas d'échec
        await queue.unshiftRequest(entry);
        throw error;
      }
    }
  }
});

// Stratégie pour les APIs - Network First avec Background Sync
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  async ({ request, event }) => {
    try {
      // Tentative réseau d'abord
      const response = await fetch(request);
      
      // Cache la réponse si succès
      if (response.status === 200) {
        const cache = await caches.open(API_CACHE);
        cache.put(request, response.clone());
      }
      
      return response;
    } catch (error) {
      // Si POST/PUT/DELETE en échec, ajouter à la queue Background Sync
      if (['POST', 'PUT', 'DELETE'].includes(request.method)) {
        await bgSyncQueue.pushRequest({ request });
      }
      
      // Fallback vers le cache pour les GET
      if (request.method === 'GET') {
        const cache = await caches.open(API_CACHE);
        const cachedResponse = await cache.match(request);
        
        if (cachedResponse) {
          return cachedResponse;
        }
      }
      
      // Réponse offline par défaut
      return new Response(
        JSON.stringify({
          success: false,
          message: 'Données non disponibles hors ligne',
          offline: true
        }),
        {
          status: 503,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
  }
);

// Images - Stale While Revalidate
registerRoute(
  ({ request }) => request.destination === 'image',
  new StaleWhileRevalidate({
    cacheName: IMAGES_CACHE,
    plugins: [
      {
        cacheWillUpdate: async ({ response }) => {
          return response.status === 200 ? response : null;
        }
      }
    ]
  })
);

// Assets statiques - Cache First
registerRoute(
  ({ request }) => 
    request.destination === 'style' ||
    request.destination === 'script' ||
    request.destination === 'font',
  new CacheFirst({
    cacheName: STATIC_CACHE,
    plugins: [
      {
        cacheWillUpdate: async ({ response }) => {
          return response.status === 200 ? response : null;
        }
      }
    ]
  })
);

// CDN Resources - Cache First long terme
registerRoute(
  ({ url }) => 
    url.origin === 'https://cdn.jsdelivr.net' ||
    url.origin === 'https://unpkg.com' ||
    url.origin === 'https://cdnjs.cloudflare.com',
  new CacheFirst({
    cacheName: 'cdn-cache',
    plugins: [
      {
        cacheWillUpdate: async ({ response }) => {
          return response.status === 200 ? response : null;
        }
      }
    ]
  })
);

// Gestion des notifications push
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
        primaryKey: data.primaryKey || 1
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
      ],
      requireInteraction: true,
      silent: false
    };

    event.waitUntil(
      self.registration.showNotification(data.title || 'Dinor', options)
    );
  }
});

// Gestion des clics sur notifications
self.addEventListener('notificationclick', event => {
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/pwa/')
    );
  } else if (event.action === 'close') {
    // Ne rien faire, juste fermer
  } else {
    // Clic sur la notification principale
    event.waitUntil(
      clients.openWindow('/pwa/')
    );
  }
});

// Synchronisation en arrière-plan
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

async function doBackgroundSync() {
  try {
    // Synchroniser les données en attente
    const cache = await caches.open(API_CACHE);
    const requests = await cache.keys();
    
    for (const request of requests) {
      if (request.url.includes('/api/') && request.method !== 'GET') {
        try {
          await fetch(request);
          await cache.delete(request);
        } catch (error) {
          console.log('Sync échouée pour:', request.url);
        }
      }
    }
  } catch (error) {
    console.error('Erreur background sync:', error);
  }
}

// Nettoyage périodique du cache
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'CLEAN_CACHE') {
    event.waitUntil(cleanOldCaches());
  }
});

async function cleanOldCaches() {
  const cacheNames = await caches.keys();
  const oldCaches = cacheNames.filter(name => 
    !name.includes('dinor-') || 
    name.includes('v0') // Supprimer les anciennes versions
  );
  
  await Promise.all(
    oldCaches.map(cacheName => caches.delete(cacheName))
  );
}

// Installation et activation
self.addEventListener('install', event => {
  console.log('Service Worker: Install');
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  console.log('Service Worker: Activate');
  event.waitUntil(
    Promise.all([
      self.clients.claim(),
      cleanOldCaches()
    ])
  );
});