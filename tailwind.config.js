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
                // Nouvelles polices demandées
                'title': ['Nunito Sans', 'sans-serif'], // Pour les titres
                'body': ['Open Sans', 'sans-serif'], // Pour les textes
                sans: ['Open Sans', 'Nunito Sans', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                // Couleurs Dinor mises à jour - palette plus claire
                'dinor': {
                    'red': '#E53E3E', // Rouge de l'image (plus vif)
                    'red-dark': '#C53030', // Rouge plus foncé pour les hovers
                    'gray': '#718096', // Gris plus clair
                    'gray-light': '#EDF2F7', // Gris très clair pour les fonds
                    'champagne': '#F7FAFC', // Champagne plus clair
                    'gold': '#D69E2E', // Or plus vif
                    'gold-light': '#F6E05E', // Or clair pour les accents
                    'white': '#FFFFFF', // Blanc pur
                },
                // Palette étendue pour Material Design 3 - version claire
                'md3': {
                    'surface': '#FFFFFF', // Fond blanc pur
                    'surface-variant': '#F7FAFC', // Fond variant très clair
                    'on-surface': '#2D3748', // Texte sombre sur fond clair
                    'on-surface-variant': '#4A5568', // Texte variant
                    'primary': '#E53E3E', // Rouge principal de l'image
                    'on-primary': '#FFFFFF', // Blanc sur rouge
                    'primary-container': '#FED7D7', // Container rouge clair
                    'on-primary-container': '#C53030', // Texte dans container rouge
                    'secondary': '#D69E2E', // Or secondaire
                    'on-secondary': '#FFFFFF', // Blanc sur or
                    'secondary-container': '#FAF089', // Container or clair
                    'on-secondary-container': '#B7791F', // Texte dans container or
                    'background': '#FFFFFF', // Fond principal blanc
                    'on-background': '#1A202C', // Texte sur fond
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
                'dinor-gradient': 'linear-gradient(135deg, #E53E3E 0%, #D69E2E 100%)',
                'dinor-gradient-soft': 'linear-gradient(135deg, #F7FAFC 0%, #EDF2F7 100%)',
                'dinor-light': 'linear-gradient(135deg, #FFFFFF 0%, #F7FAFC 100%)',
            },
            boxShadow: {
                'md3': '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
                'md3-lg': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
                'dinor-soft': '0 4px 20px rgba(229, 62, 62, 0.15)',
            }
        },
    },

    plugins: [
        forms, 
        typography,
        // Plugin personnalisé pour les classes Material Design 3 - version claire
        function({ addUtilities }) {
            const newUtilities = {
                '.dinor-text-primary': {
                    color: '#E53E3E',
                },
                '.dinor-text-secondary': {
                    color: '#D69E2E',
                },
                '.dinor-text-gray': {
                    color: '#718096',
                },
                '.dinor-bg-primary': {
                    backgroundColor: '#E53E3E',
                },
                '.dinor-bg-secondary': {
                    backgroundColor: '#D69E2E',
                },
                '.dinor-bg-white': {
                    backgroundColor: '#FFFFFF',
                },
                '.dinor-gradient-primary': {
                    background: 'linear-gradient(135deg, #E53E3E 0%, #C53030 100%)',
                },
                '.dinor-gradient-secondary': {
                    background: 'linear-gradient(135deg, #D69E2E 0%, #B7791F 100%)',
                },
                '.md3-elevation-1': {
                    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.1), 0 1px 3px 1px rgba(0, 0, 0, 0.05)',
                },
                '.md3-elevation-2': {
                    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.1), 0 2px 6px 2px rgba(0, 0, 0, 0.05)',
                },
                '.md3-elevation-3': {
                    boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 4px 8px 3px rgba(0, 0, 0, 0.05)',
                },
                '.md3-surface-tint': {
                    backgroundColor: '#FFFFFF',
                },
                // Classes pour les polices
                '.font-title': {
                    fontFamily: '"Nunito Sans", sans-serif',
                    fontWeight: '700',
                },
                '.font-body': {
                    fontFamily: '"Open Sans", sans-serif',
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
        'dinor-bg-primary',
        'dinor-bg-secondary',
        'dinor-bg-white',
        'font-title',
        'font-body',
        'md3-elevation-1',
        'md3-elevation-2',
        'md3-elevation-3',
        // Classes d'animation
        'animate-fade-in',
        'animate-slide-up',
        'animate-bounce-subtle',
    ]
}; 