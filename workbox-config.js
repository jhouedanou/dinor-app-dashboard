module.exports = {
  globDirectory: 'public/',
  globPatterns: [
    'pwa/**/*.{js,css,html}',
    'js/**/*.js',
    'css/**/*.css',
    'images/**/*.{png,jpg,jpeg,gif,svg}',
    'manifest.json'
  ],
  swDest: 'public/sw.js',
  skipWaiting: true,
  clientsClaim: true,
  
  // Configuration des stratégies de cache
  runtimeCaching: [
    {
      // API Routes - Network First avec fallback cache
      urlPattern: new RegExp('^https?://.*\\/api\\/.*$'),
      handler: 'NetworkFirst',
      options: {
        cacheName: 'api-cache',
        expiration: {
          maxEntries: 100,
          maxAgeSeconds: 60 * 60 * 24, // 24 heures
        },
        networkTimeoutSeconds: 10,
        cacheKeyWillBeUsed: async ({ request }) => {
          // Cache les requêtes GET uniquement
          return request.method === 'GET' ? request.url : null;
        }
      }
    },
    {
      // Images - Stale While Revalidate
      urlPattern: new RegExp('\\.(?:png|jpg|jpeg|svg|gif|webp)$'),
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'images-cache',
        expiration: {
          maxEntries: 200,
          maxAgeSeconds: 60 * 60 * 24 * 30, // 30 jours
        }
      }
    },
    {
      // CDN Resources (Vue, Tailwind, etc.) - Cache First
      urlPattern: new RegExp('^https://(cdn\\.jsdelivr\\.net|unpkg\\.com|cdnjs\\.cloudflare\\.com)'),
      handler: 'CacheFirst',
      options: {
        cacheName: 'cdn-cache',
        expiration: {
          maxEntries: 50,
          maxAgeSeconds: 60 * 60 * 24 * 365, // 1 an
        }
      }
    },
    {
      // Fonts - Cache First
      urlPattern: new RegExp('\\.(?:woff|woff2|ttf|eot)$'),
      handler: 'CacheFirst',
      options: {
        cacheName: 'fonts-cache',
        expiration: {
          maxEntries: 20,
          maxAgeSeconds: 60 * 60 * 24 * 365, // 1 an
        }
      }
    },
    {
      // Pages HTML - Network First
      urlPattern: new RegExp('\\.html$'),
      handler: 'NetworkFirst',
      options: {
        cacheName: 'pages-cache',
        expiration: {
          maxEntries: 50,
          maxAgeSeconds: 60 * 60 * 24 * 7, // 7 jours
        }
      }
    }
  ],
  
  // Messages de mise à jour
  mode: 'production'
};