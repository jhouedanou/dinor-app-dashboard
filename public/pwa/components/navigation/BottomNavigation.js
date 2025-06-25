// Composant Bottom Navigation pour PWA mobile
export default {
    template: `
        <nav class="bottom-nav">
            <div class="nav-container">
                <router-link 
                    v-for="tab in tabs" 
                    :key="tab.name"
                    :to="tab.path"
                    class="nav-item"
                    :class="{ 'nav-item-active': isActive(tab.path) }"
                    @click="handleTabClick(tab)">
                    <div class="nav-icon">
                        <i :class="tab.icon"></i>
                        <span v-if="tab.badge" class="nav-badge">{{ tab.badge }}</span>
                    </div>
                    <span class="nav-label">{{ tab.label }}</span>
                </router-link>
            </div>
        </nav>
    `,
    setup() {
        const { computed } = Vue;
        const route = VueRouter.useRoute();
        const router = VueRouter.useRouter();
        
        const tabs = [
            {
                name: 'recipes',
                label: 'Recettes',
                icon: 'fas fa-utensils',
                path: '/recipes',
                badge: null
            },
            {
                name: 'events',
                label: 'Événements',
                icon: 'fas fa-calendar-alt',
                path: '/events',
                badge: null
            },
            {
                name: 'pages',
                label: 'Pages',
                icon: 'fas fa-file-alt',
                path: '/pages',
                badge: null
            },
            {
                name: 'dinortv',
                label: 'Dinor TV',
                icon: 'fas fa-play-circle',
                path: '/dinor-tv',
                badge: 'NEW'
            }
        ];
        
        const isActive = (path) => {
            return route.path.startsWith(path);
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
        
        return {
            tabs,
            isActive,
            handleTabClick
        };
    }
};

// Styles CSS pour le bottom navigation (ajouté via JavaScript)
const bottomNavStyles = `
<style>
.bottom-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: white;
    border-top: 1px solid #e5e7eb;
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
    z-index: 50;
    padding-bottom: env(safe-area-inset-bottom, 0);
}

.nav-container {
    display: flex;
    max-width: 100%;
    margin: 0 auto;
}

.nav-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px 4px 12px;
    text-decoration: none;
    color: #6b7280;
    transition: all 0.2s ease;
    position: relative;
    min-height: 64px;
    justify-content: center;
}

.nav-item:hover {
    background-color: #f9fafb;
}

.nav-item-active {
    color: #f59e0b;
    background-color: #fef3c7;
}

.nav-icon {
    position: relative;
    font-size: 20px;
    margin-bottom: 4px;
    transition: transform 0.2s ease;
}

.nav-item-active .nav-icon {
    transform: scale(1.1);
}

.nav-label {
    font-size: 11px;
    font-weight: 500;
    line-height: 1;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
}

.nav-badge {
    position: absolute;
    top: -8px;
    right: -8px;
    background: #ef4444;
    color: white;
    font-size: 9px;
    font-weight: bold;
    padding: 2px 6px;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
    line-height: 1.2;
}

/* Responsive design */
@media (max-width: 320px) {
    .nav-label {
        font-size: 10px;
    }
    .nav-icon {
        font-size: 18px;
    }
}

@media (min-width: 768px) {
    .bottom-nav {
        display: none; /* Masquer sur desktop */
    }
}

/* iOS Safe Area */
@supports (padding: max(0px)) {
    .bottom-nav {
        padding-bottom: max(12px, env(safe-area-inset-bottom));
    }
}

/* Animation d'apparition */
.bottom-nav {
    animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
    from {
        transform: translateY(100%);
    }
    to {
        transform: translateY(0);
    }
}
</style>
`;

// Injecter les styles
if (typeof document !== 'undefined' && !document.getElementById('bottom-nav-styles')) {
    const styleElement = document.createElement('style');
    styleElement.id = 'bottom-nav-styles';
    styleElement.innerHTML = bottomNavStyles.replace(/<\/?style>/g, '');
    document.head.appendChild(styleElement);
}