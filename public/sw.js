// Service Worker pour PWA Dinor
const CACHE_NAME = 'dinor-pwa-v1.0.0';
const STATIC_CACHE = 'dinor-static-v1';
const DYNAMIC_CACHE = 'dinor-dynamic-v1';

// Fichiers à mettre en cache lors de l'installation
const STATIC_FILES = [
  '/',
  '/pwa/',
  '/pwa/style.css',
  '/pwa/app.js',
  '/images/default-recipe.jpg',
  '/images/default-event.jpg',
  '/images/default-video-thumbnail.jpg',
  '/pwa/icons/icon-192x192.png',
  '/pwa/icons/icon-512x512.png'
];

// Fichiers API à mettre en cache
const API_ROUTES = [
  '/api/v1/recipes',
  '/api/v1/tips',
  '/api/v1/events',
  '/api/v1/categories',
  '/api/v1/videos'
];

// Installation du Service Worker
self.addEventListener('install', event => {
  console.log('🔧 Service Worker: Installation en cours...');
  
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => {
        console.log('📦 Service Worker: Mise en cache des fichiers statiques');
        return cache.addAll(STATIC_FILES.filter(url => url)); // Filtrer les URLs valides
      })
      .catch(error => {
        console.warn('⚠️ Service Worker: Erreur lors de la mise en cache initiale:', error);
      })
  );
  
  // Force l'activation immédiate
  self.skipWaiting();
});

// Activation du Service Worker
self.addEventListener('activate', event => {
  console.log('✅ Service Worker: Activation');
  
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          // Supprimer les anciens caches
          if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
            console.log('🗑️ Service Worker: Suppression cache obsolète:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  
  // Prendre le contrôle immédiatement
  self.clients.claim();
});

// Interception des requêtes
self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  
  // Ignorer les requêtes non-HTTP
  if (!request.url.startsWith('http')) {
    return;
  }
  
  // Stratégie Cache First pour les fichiers statiques
  if (isStaticFile(request.url)) {
    event.respondWith(cacheFirst(request));
  }
  // Stratégie Network First pour les API
  else if (isApiRequest(request.url)) {
    event.respondWith(networkFirst(request));
  }
  // Stratégie par défaut
  else {
    event.respondWith(networkFirst(request));
  }
});

// Vérifier si c'est un fichier statique
function isStaticFile(url) {
  return url.includes('/pwa/') || 
         url.includes('/images/') || 
         url.includes('/css/') || 
         url.includes('/js/') ||
         url.endsWith('.css') ||
         url.endsWith('.js') ||
         url.endsWith('.png') ||
         url.endsWith('.jpg') ||
         url.endsWith('.jpeg') ||
         url.endsWith('.svg') ||
         url.endsWith('.ico');
}

// Vérifier si c'est une requête API
function isApiRequest(url) {
  return url.includes('/api/');
}

// Stratégie Cache First
async function cacheFirst(request) {
  try {
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }
    
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.error('Service Worker Cache First error:', error);
    return new Response('Contenu non disponible hors ligne', {
      status: 503,
      statusText: 'Service Unavailable'
    });
  }
}

// Stratégie Network First
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    
    if (response.ok && isApiRequest(request.url)) {
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    console.warn('Network request failed, trying cache:', request.url);
    
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }
    
    // Retourner une réponse par défaut pour les API
    if (isApiRequest(request.url)) {
      return new Response(JSON.stringify({
        success: false,
        data: [],
        message: 'Données non disponibles hors ligne'
      }), {
        status: 503,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    return new Response('Contenu non disponible hors ligne', {
      status: 503,
      statusText: 'Service Unavailable'
    });
  }
}

// Gestion des messages depuis l'application
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
});

console.log('🚀 Service Worker Dinor initialisé'); 