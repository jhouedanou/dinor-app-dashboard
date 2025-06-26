import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';
import typography from '@tailwindcss/typography';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './vendor/laravel/jetstream/**/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './vendor/filament/**/*.blade.php',
        // PWA files
        './src/pwa/**/*.vue',
        './src/pwa/**/*.js',
        './src/pwa/**/*.html',
        './public/pwa/**/*.js',
        './public/pwa/**/*.html',
        // Dashboard and standalone pages
        './public/**/*.html',
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ['Roboto', 'Inter', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                // Couleurs Dinor personnalisées
                'dinor': {
                    'red': '#E1251B',
                    'gray': '#818080',
                    'champagne': '#E6D9D0',
                    'gold': '#9E7C22',
                    'blood': '#690E08',
                },
                // Palette étendue pour Material Design 3
                'md3': {
                    'surface': 'var(--md-sys-color-surface, #fefbff)',
                    'on-surface': 'var(--md-sys-color-on-surface, #1c1b1f)',
                    'primary': 'var(--md-sys-color-primary, #9E7C22)',
                    'on-primary': 'var(--md-sys-color-on-primary, #ffffff)',
                    'secondary': 'var(--md-sys-color-secondary, #E1251B)',
                    'on-secondary': 'var(--md-sys-color-on-secondary, #ffffff)',
                }
            },
            spacing: {
                '18': '4.5rem',
                '88': '22rem',
                '100': '25rem',
                '112': '28rem',
                '128': '32rem',
            },
            animation: {
                'fade-in': 'fadeIn 0.3s ease-in-out',
                'slide-up': 'slideUp 0.3s ease-in-out',
                'bounce-subtle': 'bounceSubtle 0.6s ease-in-out',
            },
            keyframes: {
                fadeIn: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                slideUp: {
                    '0%': { opacity: '0', transform: 'translateY(20px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                bounceSubtle: {
                    '0%, 100%': { transform: 'translateY(0)' },
                    '50%': { transform: 'translateY(-5px)' },
                },
            },
            backgroundImage: {
                'dinor-gradient': 'linear-gradient(135deg, #E1251B 0%, #9E7C22 100%)',
                'dinor-gradient-soft': 'linear-gradient(135deg, #E6D9D0 0%, #818080 100%)',
            },
            boxShadow: {
                'md3': '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
                'md3-lg': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
            }
        },
    },

    plugins: [
        forms, 
        typography,
        // Plugin personnalisé pour les classes Material Design 3
        function({ addUtilities }) {
            const newUtilities = {
                '.dinor-text-primary': {
                    color: '#9E7C22',
                },
                '.dinor-text-secondary': {
                    color: '#E1251B',
                },
                '.dinor-text-gray': {
                    color: '#818080',
                },
                '.dinor-bg-primary': {
                    backgroundColor: '#9E7C22',
                },
                '.dinor-bg-secondary': {
                    backgroundColor: '#E1251B',
                },
                '.dinor-gradient-primary': {
                    background: 'linear-gradient(135deg, #E1251B 0%, #9E7C22 100%)',
                },
                '.md3-elevation-1': {
                    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.3), 0 1px 3px 1px rgba(0, 0, 0, 0.15)',
                },
                '.md3-elevation-2': {
                    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.3), 0 2px 6px 2px rgba(0, 0, 0, 0.15)',
                },
                '.md3-elevation-3': {
                    boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.3), 0 4px 8px 3px rgba(0, 0, 0, 0.15)',
                },
                '.md3-surface-tint': {
                    backgroundColor: 'color-mix(in srgb, var(--md-sys-color-surface-tint, #9E7C22) 5%, var(--md-sys-color-surface, #fefbff))',
                },
            }
            addUtilities(newUtilities)
        }
    ],

    // Optimisations pour la production
    corePlugins: {
        preflight: true,
    },
    
    // Purge agressif pour réduire la taille
    safelist: [
        // Classes dynamiques importantes
        'dinor-text-primary',
        'dinor-text-secondary',
        'dinor-text-gray',
        'md3-elevation-1',
        'md3-elevation-2',
        'md3-elevation-3',
        // Classes d'animation
        'animate-fade-in',
        'animate-slide-up',
        'animate-bounce-subtle',
    ]
}; 