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

    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    'allowed_origins' => [
        'https://new.dinorapp.com',
        'https://dinorapp.com',
        'http://localhost:3000',
        'http://localhost:8000',
        'http://localhost:5173',
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['Content-Type', 'X-Requested-With', 'Authorization', 'Accept', 'Origin'],

    'exposed_headers' => [
        'X-Pagination-Current-Page',
        'X-Pagination-Per-Page',
        'X-Pagination-Total',
        'X-Pagination-Total-Pages',
    ],

    'max_age' => 86400, // 24 heures

    'supports_credentials' => true,

];