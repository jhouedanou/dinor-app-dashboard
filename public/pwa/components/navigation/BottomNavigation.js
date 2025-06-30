// Composant Bottom Navigation Material Design 3
const BottomNavigation = {
    template: `
        <nav class="md3-bottom-navigation" role="navigation" aria-label="Navigation principale">
            <div class="md3-nav-container">
                <router-link 
                    v-for="tab in dynamicTabs" 
                    :key="tab.name"
                    :to="tab.path"
                    class="md3-nav-item"
                    :class="{ 'md3-nav-item--active': isActive(tab.path) }"
                    :aria-label="tab.label"
                    @click="handleTabClick(tab)">
                    <div class="md3-nav-item__indicator" v-if="isActive(tab.path)"></div>
                    <div class="md3-nav-item__icon-container">
                        <div class="md3-nav-item__icon" :style="{ color: isActive(tab.path) ? tab.color : '' }">
                            <i :class="getIconClass(tab, isActive(tab.path))">{{ getIconContent(tab) }}</i>
                        </div>
                        <div v-if="tab.badge" class="md3-nav-item__badge">{{ tab.badge }}</div>
                    </div>
                    <span class="md3-nav-item__label">{{ tab.label }}</span>
                </router-link>
            </div>
        </nav>
    `,
    setup() {
        const { computed, ref, onMounted } = Vue;
        const route = VueRouter.useRoute();
        const router = VueRouter.useRouter();
        
        const apiTabs = ref([]);
        const loading = ref(false);
        
        // Éléments par défaut en fallback
        const defaultTabs = [
            {
                name: 'recipes',
                label: 'Recettes',
                icon: 'restaurant',
                iconFilled: 'restaurant',
                path: '/recipes',
                badge: null,
                color: '#9E7C22'
            },
            {
                name: 'tips',
                label: 'Astuces',
                icon: 'lightbulb',
                iconFilled: 'lightbulb',
                path: '/tips',
                badge: null,
                color: '#E6D9D0'
            },
            {
                name: 'events',
                label: 'Événements',
                icon: 'event',
                iconFilled: 'event',
                path: '/events',
                badge: null,
                color: '#818080'
            },
            {
                name: 'dinortv',
                label: 'Dinor TV',
                icon: 'play_circle',
                iconFilled: 'play_circle',
                path: '/dinor-tv',
                badge: null,
                color: '#690E08'
            },
            {
                name: 'pages',
                label: 'Pages',
                icon: 'description',
                iconFilled: 'description',
                path: '/pages',
                badge: null,
                color: '#E1251B'
            }
        ];
        
        const loadMenuItems = async () => {
            loading.value = true;
            try {
                const response = await fetch('/api/pwa-menu-items', {
                    headers: {
                        'Content-Type': 'application/json',
                        'Cache-Control': 'no-cache'
                    }
                });
                
                if (response.ok) {
                    const result = await response.json();
                    if (result.success && result.data && result.data.length > 0) {
                        // Transformer les données API en format attendu
                        apiTabs.value = result.data.map(item => ({
                            name: item.route,
                            label: item.label,
                            icon: item.icon,
                            iconFilled: item.icon,
                            path: `/${item.route}`,
                            badge: null,
                            color: item.color || '#E1251B'
                        }));
                    }
                } else {
                    console.warn('Impossible de charger les éléments du menu, utilisation du menu par défaut');
                }
            } catch (error) {
                console.error('Erreur lors du chargement du menu:', error);
            } finally {
                loading.value = false;
            }
        };
        
        // Tabs dynamiques : utilise l'API si disponible, sinon les éléments par défaut
        const dynamicTabs = computed(() => {
            return apiTabs.value.length > 0 ? apiTabs.value : defaultTabs;
        });
        
        const isActive = (path) => {
            return route.path.startsWith(path);
        };
        
        const getIconClass = (tab, isActive) => {
            // Détecter le type d'icône et retourner la classe appropriée
            if (tab.icon && (tab.icon.includes('fas ') || tab.icon.includes('far ') || tab.icon.includes('fab '))) {
                // Font Awesome icons - retourner la classe complète
                return tab.icon;
            } else {
                // Material Icons par défaut
                return 'material-icons';
            }
        };
        
        const getIconContent = (tab) => {
            // Pour Font Awesome, pas de contenu texte (l'icône est dans la classe)
            if (tab.icon && (tab.icon.includes('fas ') || tab.icon.includes('far ') || tab.icon.includes('fab '))) {
                return '';
            } else {
                // Pour Material Icons, retourner le nom de l'icône
                return tab.icon;
            }
        };
        
        const handleTabClick = (tab) => {
            // Haptic feedback sur mobile
            if ('vibrate' in navigator) {
                navigator.vibrate(50);
            }
            
            // Analytics tracking (optionnel)
            if (typeof gtag !== 'undefined') {
                gtag('event', 'tab_click', {
                    tab_name: tab.name,
                    custom_map: { metric1: 1 }
                });
            }
        };
        
        onMounted(() => {
            loadMenuItems();
        });
        
        return {
            dynamicTabs,
            loading,
            isActive,
            getIconClass,
            getIconContent,
            handleTabClick
        };
    }
};

// Styles Material Design 3 pour la navigation
const md3BottomNavStyles = `
<style>
/* Material Design 3 Bottom Navigation */
.md3-bottom-navigation {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 80px;
    background: var(--md-sys-color-surface-container);
    border-top: 1px solid var(--md-sys-color-outline-variant);
    z-index: 1000;
    padding-bottom: env(safe-area-inset-bottom, 0);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
}

.md3-nav-container {
    display: flex;
    height: 100%;
    max-width: 100%;
    align-items: center;
    justify-content: space-around;
}

.md3-nav-item {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 12px;
    text-decoration: none;
    color: var(--md-sys-color-on-surface-variant);
    transition: all 150ms cubic-bezier(0.2, 0, 0, 1);
    border-radius: 16px;
    min-width: 64px;
    min-height: 56px;
    flex: 1;
    max-width: 120px;
}

.md3-nav-item:hover {
    background-color: var(--md-sys-color-on-surface-variant, rgba(103, 80, 164, 0.08));
}

.md3-nav-item--active {
    color: var(--md-sys-color-on-secondary-container);
}

.md3-nav-item__indicator {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 64px;
    height: 32px;
    background: var(--md-sys-color-secondary-container);
    border-radius: 16px;
    z-index: -1;
    animation: md3-indicator-enter 150ms cubic-bezier(0.2, 0, 0, 1);
}

@keyframes md3-indicator-enter {
    0% {
        transform: translate(-50%, -50%) scale(0.8);
        opacity: 0;
    }
    100% {
        transform: translate(-50%, -50%) scale(1);
        opacity: 1;
    }
}

.md3-nav-item__icon-container {
    position: relative;
    margin-bottom: 4px;
}

.md3-nav-item__icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    font-size: 24px;
    transition: all 150ms cubic-bezier(0.2, 0, 0, 1);
}

.md3-nav-item--active .md3-nav-item__icon {
    transform: scale(1.1);
}

.md3-nav-item__badge {
    position: absolute;
    top: -4px;
    right: -4px;
    background: var(--md-sys-color-error);
    color: var(--md-sys-color-on-error);
    font-size: 10px;
    font-weight: 500;
    padding: 2px 6px;
    border-radius: 8px;
    min-width: 16px;
    height: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}

.md3-nav-item__label {
    font-size: 12px;
    font-weight: 500;
    line-height: 16px;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
    font-family: 'Roboto', system-ui, -apple-system, sans-serif;
}

/* Import de la palette Dinor - Les couleurs sont définies dans dinor-color-palette.css */

/* Material Icons */
.material-icons {
    font-family: 'Material Icons';
    font-weight: normal;
    font-style: normal;
    font-size: 24px;
    line-height: 1;
    letter-spacing: normal;
    text-transform: none;
    display: inline-block;
    white-space: nowrap;
    word-wrap: normal;
    direction: ltr;
    -webkit-font-feature-settings: 'liga';
    -webkit-font-smoothing: antialiased;
}

.material-icons-filled {
    font-variation-settings: 'FILL' 1;
}

/* Responsive */
@media (max-width: 320px) {
    .md3-nav-item__label {
        font-size: 11px;
    }
    .md3-nav-item__icon {
        font-size: 22px;
    }
}

@media (min-width: 768px) {
    .md3-bottom-navigation {
        display: none;
    }
}

/* Animation d'entrée */
.md3-bottom-navigation {
    animation: md3-nav-enter 300ms cubic-bezier(0.2, 0, 0, 1);
}

@keyframes md3-nav-enter {
    0% {
        transform: translateY(100%);
        opacity: 0;
    }
    100% {
        transform: translateY(0);
        opacity: 1;
    }
}

/* Support pour les écrans avec encoche */
@supports (padding: max(0px)) {
    .md3-bottom-navigation {
        padding-bottom: max(env(safe-area-inset-bottom, 0), 12px);
        height: calc(80px + env(safe-area-inset-bottom, 0));
    }
}
</style>
`;

// Injecter les styles Material Design 3
if (typeof document !== 'undefined' && !document.getElementById('md3-bottom-nav-styles')) {
    const styleElement = document.createElement('style');
    styleElement.id = 'md3-bottom-nav-styles';
    styleElement.innerHTML = md3BottomNavStyles.replace(/<\/?style>/g, '');
    document.head.appendChild(styleElement);
}