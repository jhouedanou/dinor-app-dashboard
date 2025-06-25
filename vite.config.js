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
        // Proxy configuration pour BrowserSync
        proxy: {
            '/api': {
                target: 'http://localhost:8000',
                changeOrigin: true,
                secure: false
            }
        }
    },
    // Configuration pour le build PWA
    build: {
        rollupOptions: {
            input: {
                main: 'public/pwa/index.html',
                app: 'public/pwa/app.js'
            },
            output: {
                entryFileNames: 'pwa/[name]-[hash].js',
                chunkFileNames: 'pwa/[name]-[hash].js',
                assetFileNames: 'pwa/[name]-[hash].[ext]'
            }
        }
    }
}); 