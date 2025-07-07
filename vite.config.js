import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        vue(),
        laravel({
            input: [
                'resources/scss/app.scss',
                'resources/css/dinor-optimized.css',
                'resources/js/app.js',
                'resources/css/filament/admin/theme.css',
            ],
            refresh: true,
        }),
    ],
    css: {
        preprocessorOptions: {
            scss: {
                additionalData: `@use "sass:color"; @import "resources/scss/variables.scss";`,
                charset: false
            }
        },
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
                    vendor: ['alpinejs']
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