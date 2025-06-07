<?php

return [
    'default_filesystem_disk' => env('FILAMENT_FILESYSTEM_DRIVER', 'public'),

    'auth' => [
        'guard' => env('FILAMENT_AUTH_GUARD', 'admin'),
        'pages' => [
            'login' => \App\Filament\Pages\Auth\Login::class,
        ],
    ],

    'pages' => [
        'namespace' => 'App\\Filament\\Pages',
        'path' => app_path('Filament/Pages'),
        'register' => [
            \App\Filament\Pages\Dashboard::class,
        ],
    ],

    'resources' => [
        'namespace' => 'App\\Filament\\Resources',
        'path' => app_path('Filament/Resources'),
    ],

    'widgets' => [
        'namespace' => 'App\\Filament\\Widgets',
        'path' => app_path('Filament/Widgets'),
    ],

    'livewire' => [
        'namespace' => 'App\\Filament',
        'path' => app_path('Filament'),
    ],

    'dark_mode' => false,

    'database_notifications' => [
        'enabled' => false,
    ],

    'broadcasting' => [
        'echo' => false,
    ],

    'default_avatar_provider' => \Filament\AvatarProviders\UiAvatarsProvider::class,

    'default_filesystem_disk' => env('FILAMENT_FILESYSTEM_DRIVER', 'public'),

    'assets_path' => null,

    'cache_path' => base_path('bootstrap/cache/filament'),

    'livewire_loading_delay' => 'default',

    'spa' => false,
]; 