const { createApp, ref, reactive, computed, onMounted, watch, nextTick } = Vue;
const { createRouter, createWebHistory } = VueRouter;

// Utils pour la performance
const debounce = (func, wait) => {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
};

// Composables réutilisables
const useApi = () => {
    const loading = ref(false);
    const error = ref(null);
    
    const request = async (url, options = {}) => {
        loading.value = true;
        error.value = null;
        
        try {
            const response = await fetch(url, {
                headers: {
                    'Content-Type': 'application/json',
                    'Cache-Control': 'no-cache, no-store, must-revalidate',
                    'Pragma': 'no-cache',
                    'Expires': '0',
                    ...options.headers
                },
                cache: 'no-store',
                ...options
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const data = await response.json();
            return data;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };
    
    return { loading, error, request };
};

const useLikes = () => {
    const toggleLike = async (type, id) => {
        try {
            const result = await likesManager.toggleLike(type, id);
            return result;
        } catch (error) {
            console.error('Erreur lors du toggle like:', error);
            return { success: false };
        }
    };
    
    return { toggleLike };
};

const useComments = () => {
    const submitComment = async (type, id, content) => {
        try {
            const result = await commentsManager.addComment(type, id, content);
            return result;
        } catch (error) {
            console.error('Erreur lors de l\'envoi du commentaire:', error);
            return { success: false };
        }
    };
    
    return { submitComment };
};

// Composants Vue
const Dashboard = {
    template: `
        <div class="min-h-screen bg-gray-50">
            <!-- Header avec install button -->
            <header class="nav-bar px-4 py-3">
                <div class="max-w-7xl mx-auto flex justify-between items-center">
                    <h1 class="text-2xl font-bold text-yellow-600">Dinor</h1>
                    <div class="flex items-center space-x-4">
                        <button 
                            id="install-button"
                            @click="installPWA"
                            class="bg-yellow-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-yellow-600 transition-colors"
                            style="display: none;">
                            <i class="fas fa-download mr-2"></i>Installer l'app
                        </button>
                        <div id="authStatus" class="text-sm">
                            <!-- Sera mis à jour par le auth manager -->
                        </div>
                    </div>
                </div>
            </header>

            <!-- Navigation tabs -->
            <nav class="bg-white shadow-sm">
                <div class="max-w-7xl mx-auto px-4">
                    <div class="flex space-x-8">
                        <button 
                            v-for="tab in tabs" 
                            :key="tab.id"
                            @click="activeTab = tab.id"
                            :class="[
                                'py-4 px-2 border-b-2 font-medium text-sm transition-colors',
                                activeTab === tab.id 
                                    ? 'border-yellow-500 text-yellow-600' 
                                    : 'border-transparent text-gray-500 hover:text-gray-700'
                            ]">
                            <i :class="tab.icon + ' mr-2'"></i>{{ tab.label }}
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Content -->
            <main class="max-w-7xl mx-auto px-4 py-6">
                <!-- Recettes -->
                <div v-if="activeTab === 'recipes'" class="space-y-6">
                    <div class="flex justify-between items-center">
                        <h2 class="text-2xl font-bold text-gray-900">Recettes</h2>
                        <input 
                            v-model="searchQuery"
                            @input="debouncedSearch"
                            type="text" 
                            placeholder="Rechercher une recette..."
                            class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent">
                    </div>
                    
                    <div v-if="loading" class="text-center py-8">
                        <div class="spinner mx-auto"></div>
                        <p class="mt-2 text-gray-600">Chargement des recettes...</p>
                    </div>
                    
                    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <div 
                            v-for="recipe in filteredRecipes" 
                            :key="recipe.id"
                            @click="goToRecipe(recipe.id)"
                            class="bg-white rounded-lg shadow-md card-hover cursor-pointer overflow-hidden">
                            <div class="relative h-48">
                                <img 
                                    :src="recipe.featured_image_url || '/images/default-recipe.jpg'" 
                                    :alt="recipe.title"
                                    class="w-full h-full object-cover"
                                    loading="lazy">
                                <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                                <div class="absolute bottom-0 left-0 right-0 p-4">
                                    <h3 class="text-white font-bold text-lg mb-1">{{ recipe.title }}</h3>
                                    <p class="text-gray-200 text-sm">{{ recipe.short_description }}</p>
                                </div>
                            </div>
                            <div class="p-4">
                                <div class="flex items-center justify-between text-sm text-gray-600">
                                    <span><i class="fas fa-clock mr-1"></i>{{ recipe.preparation_time }}min</span>
                                    <span><i class="fas fa-heart mr-1"></i>{{ recipe.likes_count || 0 }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Astuces -->
                <div v-if="activeTab === 'tips'" class="space-y-6">
                    <h2 class="text-2xl font-bold text-gray-900">Astuces Culinaires</h2>
                    
                    <div v-if="loading" class="text-center py-8">
                        <div class="spinner mx-auto"></div>
                        <p class="mt-2 text-gray-600">Chargement des astuces...</p>
                    </div>
                    
                    <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div 
                            v-for="tip in tips" 
                            :key="tip.id"
                            @click="goToTip(tip.id)"
                            class="bg-white rounded-lg shadow-md card-hover cursor-pointer p-6">
                            <div class="flex items-start space-x-4">
                                <div class="flex-shrink-0">
                                    <div class="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
                                        <i class="fas fa-lightbulb text-yellow-600"></i>
                                    </div>
                                </div>
                                <div class="flex-1">
                                    <h3 class="font-bold text-lg text-gray-900 mb-2">{{ tip.title }}</h3>
                                    <p class="text-gray-600 text-sm mb-3" v-html="tip.short_description"></p>
                                    <div class="flex items-center justify-between text-sm text-gray-500">
                                        <span v-if="tip.estimated_time">
                                            <i class="fas fa-clock mr-1"></i>{{ tip.estimated_time }}min
                                        </span>
                                        <span><i class="fas fa-heart mr-1"></i>{{ tip.likes_count || 0 }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Événements -->
                <div v-if="activeTab === 'events'" class="space-y-6">
                    <h2 class="text-2xl font-bold text-gray-900">Événements</h2>
                    
                    <div v-if="loading" class="text-center py-8">
                        <div class="spinner mx-auto"></div>
                        <p class="mt-2 text-gray-600">Chargement des événements...</p>
                    </div>
                    
                    <div v-else class="space-y-4">
                        <div 
                            v-for="event in events" 
                            :key="event.id"
                            @click="goToEvent(event.id)"
                            class="bg-white rounded-lg shadow-md card-hover cursor-pointer overflow-hidden">
                            <div class="md:flex">
                                <div class="md:w-1/3">
                                    <img 
                                        :src="event.featured_image_url || '/images/default-event.jpg'" 
                                        :alt="event.title"
                                        class="w-full h-48 md:h-full object-cover"
                                        loading="lazy">
                                </div>
                                <div class="md:w-2/3 p-6">
                                    <div class="flex items-center justify-between mb-2">
                                        <h3 class="font-bold text-xl text-gray-900">{{ event.title }}</h3>
                                        <span :class="getEventStatusClass(event.status)" class="px-3 py-1 rounded-full text-sm font-medium">
                                            {{ getEventStatusLabel(event.status) }}
                                        </span>
                                    </div>
                                    <p class="text-gray-600 mb-4">{{ event.short_description }}</p>
                                    <div class="flex items-center space-x-6 text-sm text-gray-500">
                                        <span><i class="fas fa-calendar mr-1"></i>{{ formatDate(event.start_date) }}</span>
                                        <span><i class="fas fa-clock mr-1"></i>{{ formatTime(event.start_time) }}</span>
                                        <span v-if="event.location"><i class="fas fa-map-marker-alt mr-1"></i>{{ event.location }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    `,
    setup() {
        const router = VueRouter.useRouter();
        const activeTab = ref('recipes');
        const loading = ref(false);
        const searchQuery = ref('');
        
        const tabs = [
            { id: 'recipes', label: 'Recettes', icon: 'fas fa-utensils' },
            { id: 'tips', label: 'Astuces', icon: 'fas fa-lightbulb' },
            { id: 'events', label: 'Événements', icon: 'fas fa-calendar' }
        ];
        
        const recipes = ref([]);
        const tips = ref([]);
        const events = ref([]);
        
        const { request } = useApi();
        
        const filteredRecipes = computed(() => {
            if (!searchQuery.value) return recipes.value;
            return recipes.value.filter(recipe => 
                recipe.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                recipe.short_description.toLowerCase().includes(searchQuery.value.toLowerCase())
            );
        });
        
        const debouncedSearch = debounce(() => {
            // La recherche est automatique grâce au computed
        }, 300);
        
        const loadData = async (type) => {
            loading.value = true;
            try {
                const data = await request(`/api/v1/${type}`);
                if (data.success) {
                    if (type === 'recipes') recipes.value = data.data;
                    else if (type === 'tips') tips.value = data.data;
                    else if (type === 'events') events.value = data.data;
                }
            } catch (error) {
                console.error(`Erreur lors du chargement des ${type}:`, error);
            } finally {
                loading.value = false;
            }
        };
        
        const goToRecipe = (id) => {
            router.push(`/recipe/${id}`);
        };
        
        const goToTip = (id) => {
            router.push(`/tip/${id}`);
        };
        
        const goToEvent = (id) => {
            router.push(`/event/${id}`);
        };
        
        const getEventStatusClass = (status) => {
            const classes = {
                'active': 'bg-green-100 text-green-800',
                'cancelled': 'bg-red-100 text-red-800',
                'completed': 'bg-gray-100 text-gray-800'
            };
            return classes[status] || 'bg-gray-100 text-gray-800';
        };
        
        const getEventStatusLabel = (status) => {
            const labels = {
                'active': 'Actif',
                'cancelled': 'Annulé',
                'completed': 'Terminé'
            };
            return labels[status] || 'Non défini';
        };
        
        const formatDate = (dateString) => {
            return new Date(dateString).toLocaleDateString('fr-FR', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        };
        
        const formatTime = (timeString) => {
            if (!timeString) return '';
            return new Date(timeString).toLocaleTimeString('fr-FR', {
                hour: '2-digit',
                minute: '2-digit'
            });
        };
        
        const installPWA = () => {
            if (window.installPWA) {
                window.installPWA();
            }
        };
        
        watch(activeTab, (newTab) => {
            if (newTab === 'recipes' && recipes.value.length === 0) {
                loadData('recipes');
            } else if (newTab === 'tips' && tips.value.length === 0) {
                loadData('tips');
            } else if (newTab === 'events' && events.value.length === 0) {
                loadData('events');
            }
        });
        
        onMounted(() => {
            // Charger les recettes par défaut
            loadData('recipes');
            
            // Initialiser l'authentification
            if (window.authManager) {
                window.authManager.init();
            }
        });
        
        return {
            activeTab,
            loading,
            searchQuery,
            tabs,
            recipes,
            tips,
            events,
            filteredRecipes,
            debouncedSearch,
            goToRecipe,
            goToTip,
            goToEvent,
            getEventStatusClass,
            getEventStatusLabel,
            formatDate,
            formatTime,
            installPWA
        };
    }
};

// Fonction de chargement des composants - pas d'import dynamique
const lazyLoad = (componentName) => {
    // Les composants sont déjà chargés via les scripts dans index.html
    const components = {
        'RecipesList': RecipesList,
        'TipsList': TipsList,
        'EventsList': EventsList,
        'PagesList': PagesList,
        'DinorTV': DinorTV,
        'Recipe': Recipe,
        'Event': Event,
        'Tip': Tip
    };
    
    return components[componentName] || {
        template: `<div class="error-fallback">
            <h2>Composant non trouvé</h2>
            <p>Le composant ${componentName} n'existe pas</p>
            <button @click="$router.push('/')">Retour à l'accueil</button>
        </div>`
    };
};

// Router avec les nouvelles routes bottom navigation
const routes = [
    // Route par défaut redirige vers les recettes
    { path: '/', redirect: '/recipes' },
    
    // Routes principales (bottom navigation)
    { path: '/recipes', component: lazyLoad('RecipesList'), name: 'recipes' },
    { path: '/tips', component: lazyLoad('TipsList'), name: 'tips' },
    { path: '/events', component: lazyLoad('EventsList'), name: 'events' },
    { path: '/pages', component: lazyLoad('PagesList'), name: 'pages' },
    { path: '/pages/:id', component: lazyLoad('PagesList'), name: 'page-detail' },
    { path: '/dinor-tv', component: lazyLoad('DinorTV'), name: 'dinor-tv' },
    
    // Routes de détail
    { path: '/recipe/:id', component: lazyLoad('Recipe'), name: 'recipe' },
    { path: '/tip/:id', component: lazyLoad('Tip'), name: 'tip' },
    { path: '/event/:id', component: lazyLoad('Event'), name: 'event' },
    
    // Route 404
    { path: '/:pathMatch(.*)*', redirect: '/recipes' }
];

const router = createRouter({
    history: createWebHistory('/pwa/'),
    routes
});

// App principal avec navigation
const App = {
    template: `
        <div id="app-container">
            <!-- Contenu principal -->
            <main class="main-content" :class="{ 'with-bottom-nav': showBottomNav, 'md3-main-content': true }">
                <router-view></router-view>
            </main>
            
            <!-- Bottom Navigation Material Design 3 -->
            <BottomNavigation v-if="showBottomNav" />
        </div>
    `,
    setup() {
        const route = VueRouter.useRoute();
        const { computed } = Vue;
        
        // Afficher la bottom nav seulement sur les pages principales
        const showBottomNav = computed(() => {
            const mainRoutes = ['/recipes', '/tips', '/events', '/pages', '/dinor-tv'];
            return mainRoutes.some(route_path => route.path.startsWith(route_path));
        });
        
        return {
            showBottomNav
        };
    },
    components: {
        BottomNavigation
    }
};

const app = createApp(App);

app.use(router);
app.mount('#app');