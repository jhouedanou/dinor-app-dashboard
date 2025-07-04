<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Configuration Dinor Dashboard
    |--------------------------------------------------------------------------
    |
    | Configuration spécifique pour l'application Dinor Dashboard
    |
    */

    'cache' => [
        // Durée de vie du cache pour différents types de contenu (en secondes)
        'ttl' => [
            'recipes' => env('CACHE_TTL_RECIPES', 300), // 5 minutes
            'tips' => env('CACHE_TTL_TIPS', 300), // 5 minutes
            'events' => env('CACHE_TTL_EVENTS', 180), // 3 minutes
            'dinor_tv' => env('CACHE_TTL_VIDEOS', 600), // 10 minutes
            'banners' => env('CACHE_TTL_BANNERS', 1800), // 30 minutes
            'categories' => env('CACHE_TTL_CATEGORIES', 3600), // 1 heure
        ],

        // Préfixes pour les clés de cache
        'prefixes' => [
            'recipes' => 'recipes',
            'tips' => 'tips', 
            'events' => 'events',
            'dinor_tv' => 'videos',
            'banners' => 'banners',
            'categories' => 'categories',
            'api' => 'api',
            'pwa' => 'pwa',
        ],

        // Configuration pour l'invalidation automatique
        'auto_invalidate' => [
            'enabled' => env('CACHE_AUTO_INVALIDATE', true),
            'triggers' => [
                'model_updated' => true,
                'model_created' => true,
                'model_deleted' => true,
            ]
        ]
    ],

    'pwa' => [
        // Configuration PWA
        'cache_version' => env('PWA_CACHE_VERSION', 'v2'),
        'offline_support' => env('PWA_OFFLINE_SUPPORT', true),
        'background_sync' => env('PWA_BACKGROUND_SYNC', true),
        
        // Configuration du service worker
        'sw' => [
            'update_interval' => env('SW_UPDATE_INTERVAL', 300), // 5 minutes
            'cache_strategy' => env('SW_CACHE_STRATEGY', 'network_first'), // network_first, cache_first, stale_while_revalidate
        ]
    ],

    'api' => [
        // Configuration API
        'rate_limit' => env('API_RATE_LIMIT', 60), // Requêtes par minute
        'timeout' => env('API_TIMEOUT', 30), // Secondes
        'retry_attempts' => env('API_RETRY_ATTEMPTS', 3),
        
        // Configuration de cache API
        'cache_enabled' => env('API_CACHE_ENABLED', true),
        'cache_ttl' => env('API_CACHE_TTL', 300), // 5 minutes
    ],

    'performance' => [
        // Configuration pour la performance
        'lazy_loading' => env('PERFORMANCE_LAZY_LOADING', true),
        'image_optimization' => env('PERFORMANCE_IMAGE_OPTIMIZATION', true),
        'cdn_enabled' => env('PERFORMANCE_CDN_ENABLED', false),
        'compression' => env('PERFORMANCE_COMPRESSION', true),
    ],

    'debug' => [
        // Configuration debug/monitoring
        'log_cache_operations' => env('DEBUG_LOG_CACHE', false),
        'log_api_requests' => env('DEBUG_LOG_API', false),
        'performance_monitoring' => env('DEBUG_PERFORMANCE', false),
    ]
];