<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => [
        'api/*',
        'sanctum/csrf-cookie',
        'storage/*',
        'public/storage/*',
        'pwa/*',
    ],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:3000',  // BrowserSync
        'http://localhost:3001',  // BrowserSync proxy
        'http://localhost:8000',  // Laravel dev
        'http://localhost:5173',  // Vite dev server
        'https://localhost:3000',
        'https://localhost:3001',
        'https://localhost:8000',
        'https://localhost:5173',
    ],

    'allowed_origins_patterns' => [
        '/^https?:\/\/.*\.local$/',
        '/^https?:\/\/.*\.test$/',
        '/^https?:\/\/.*\.dev$/',
        '/^https?:\/\/localhost(:\d+)?$/',
        '/^https?:\/\/127\.0\.0\.1(:\d+)?$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [
        'X-Pagination-Current-Page',
        'X-Pagination-Per-Page',
        'X-Pagination-Total',
        'X-Pagination-Total-Pages',
    ],

    'max_age' => 86400, // 24 heures

    'supports_credentials' => true,

];