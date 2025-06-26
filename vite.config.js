import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/css/dinor-optimized.css',
                'resources/js/app.js',
                'resources/css/filament/admin/theme.css',
                // PWA assets
                'public/pwa/app.js',
                'public/pwa/style.css',
            ],
            refresh: true,
        }),
    ],
    css: {
        postcss: './postcss.config.js',
    },
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
                'src/pwa/**/*',
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
            output: {
                // Optimiser le chunking pour de meilleures performances
                manualChunks: {
                    vendor: ['alpinejs'],
                    filament: ['@filament/forms', '@filament/tables']
                }
            }
        },
        // Optimisations pour la production
        minify: 'terser',
        terserOptions: {
            compress: {
                drop_console: true, // Supprimer les console.log en production
                drop_debugger: true,
            },
        },
        cssMinify: true,
        sourcemap: false, // Désactiver les sourcemaps en production
    },
    define: {
        // Optimisations pour la performance
        __VUE_OPTIONS_API__: false,
        __VUE_PROD_DEVTOOLS__: false,
    }
}); 