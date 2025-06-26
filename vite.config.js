import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'resources/css/filament/admin/theme.css',
                // PWA assets
                'public/pwa/app.js',
                'public/pwa/style.css',
            ],
            refresh: true,
        }),
    ],
    server: {
        host: '0.0.0.0',
        port: 5173,
        hmr: {
            host: 'localhost',
            port: 5173,
        },
        watch: {
            usePolling: true,
            // Watch PWA files
            include: [
                'public/pwa/**/*',
                'resources/**/*'
            ]
        },
        // Proxy configuration pour l'API
        proxy: {
            '/api': {
                target: 'http://localhost:8000',
                changeOrigin: true,
                secure: false
            }
        }
    },
    // Configuration pour le build
    build: {
        rollupOptions: {
            input: {
                // Laravel assets
                app: 'resources/js/app.js',
                'filament-admin': 'resources/css/filament/admin/theme.css',
                // PWA assets
                main: 'public/pwa/index.html',
                'pwa-app': 'public/pwa/app.js'
            }
        }
    }
}); 