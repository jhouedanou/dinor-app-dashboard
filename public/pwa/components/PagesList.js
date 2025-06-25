// Composant Pages (WebView intégré)
const PagesList = {
    template: `
        <div class="pages-page">
            <!-- Header -->
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fas fa-file-alt mr-2"></i>
                    Pages
                </h1>
                <button v-if="currentPage" @click="refreshPage" class="refresh-btn">
                    <i class="fas fa-refresh" :class="{ 'fa-spin': isRefreshing }"></i>
                </button>
            </div>

            <!-- Navigation breadcrumb -->
            <div v-if="currentPage" class="page-breadcrumb">
                <button @click="goBack" class="breadcrumb-back">
                    <i class="fas fa-arrow-left"></i>
                </button>
                <div class="breadcrumb-title">{{ currentPage.title }}</div>
            </div>

            <!-- Loading -->
            <div v-if="loading && !currentPage" class="loading-container">
                <div class="spinner"></div>
                <p class="loading-text">Chargement des pages...</p>
            </div>

            <!-- WebView iframe pour page unique -->
            <div v-else-if="currentPage" class="webview-container">
                <div v-if="isRefreshing" class="webview-loading">
                    <div class="spinner"></div>
                    <span>Actualisation de la page...</span>
                </div>
                
                <iframe 
                    ref="webviewFrame"
                    :src="currentPage.url"
                    class="webview-iframe"
                    :class="{ 'iframe-loading': isRefreshing }"
                    frameborder="0"
                    allowfullscreen
                    @load="onIframeLoad"
                    @error="onIframeError">
                </iframe>
                
                <!-- Contrôles WebView -->
                <div class="webview-controls">
                    <button @click="navigateBack" :disabled="!canGoBack" class="control-btn">
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <button @click="navigateForward" :disabled="!canGoForward" class="control-btn">
                        <i class="fas fa-chevron-right"></i>
                    </button>
                    <button @click="refreshPage" class="control-btn">
                        <i class="fas fa-refresh"></i>
                    </button>
                    <button @click="openExternal" class="control-btn">
                        <i class="fas fa-external-link-alt"></i>
                    </button>
                </div>
            </div>

            <!-- Liste des pages -->
            <div v-else-if="pages.length > 0" class="pages-list">
                <div 
                    v-for="page in pages" 
                    :key="page.id"
                    @click="openPage(page)"
                    class="page-card card-hover">
                    <div class="page-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <div class="page-content">
                        <h3 class="page-title">{{ page.title }}</h3>
                        <p v-if="page.description" class="page-description">
                            {{ truncateText(page.description, 120) }}
                        </p>
                        <div class="page-url">
                            <i class="fas fa-link"></i>
                            <span>{{ formatURL(page.url) }}</span>
                        </div>
                    </div>
                    <div class="page-arrow">
                        <i class="fas fa-chevron-right"></i>
                    </div>
                </div>
            </div>

            <!-- État vide -->
            <div v-else class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <h3 class="empty-title">Aucune page disponible</h3>
                <p class="empty-description">
                    Les pages apparaîtront ici bientôt
                </p>
            </div>

            <!-- Erreur iframe -->
            <div v-if="iframeError" class="iframe-error">
                <div class="error-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h3 class="error-title">Impossible de charger la page</h3>
                <p class="error-description">Vérifiez votre connexion internet</p>
                <button @click="refreshPage" class="btn-primary">
                    Réessayer
                </button>
            </div>
        </div>
    `,
    setup() {
        const { ref, onMounted, nextTick } = Vue;
        const router = VueRouter.useRouter();
        const route = VueRouter.useRoute();
        
        const loading = ref(true);
        const isRefreshing = ref(false);
        const iframeError = ref(false);
        const pages = ref([]);
        const currentPage = ref(null);
        const webviewFrame = ref(null);
        const canGoBack = ref(false);
        const canGoForward = ref(false);
        
        const { request } = useApi();
        
        const loadPages = async () => {
            loading.value = true;
            try {
                const data = await request('/api/v1/pages');
                if (data.success) {
                    pages.value = data.data;
                }
            } catch (error) {
                console.error('Erreur lors du chargement des pages:', error);
            } finally {
                loading.value = false;
            }
        };
        
        const openPage = (page) => {
            currentPage.value = page;
            // Ajouter à l'historique du navigateur
            router.push(`/pages/${page.id}`);
        };
        
        const goBack = () => {
            currentPage.value = null;
            router.push('/pages');
        };
        
        const refreshPage = () => {
            if (currentPage.value && webviewFrame.value) {
                isRefreshing.value = true;
                iframeError.value = false;
                webviewFrame.value.src = webviewFrame.value.src;
            }
        };
        
        const onIframeLoad = () => {
            isRefreshing.value = false;
            iframeError.value = false;
            
            // Tenter d'accéder à l'historique iframe (peut échouer à cause de CORS)
            try {
                const iframeWindow = webviewFrame.value.contentWindow;
                if (iframeWindow && iframeWindow.history) {
                    canGoBack.value = iframeWindow.history.length > 1;
                }
            } catch (e) {
                // Ignoré à cause des restrictions CORS
            }
        };
        
        const onIframeError = () => {
            isRefreshing.value = false;
            iframeError.value = true;
        };
        
        const navigateBack = () => {
            if (webviewFrame.value && webviewFrame.value.contentWindow) {
                try {
                    webviewFrame.value.contentWindow.history.back();
                } catch (e) {
                    console.log('Navigation back non autorisée');
                }
            }
        };
        
        const navigateForward = () => {
            if (webviewFrame.value && webviewFrame.value.contentWindow) {
                try {
                    webviewFrame.value.contentWindow.history.forward();
                } catch (e) {
                    console.log('Navigation forward non autorisée');
                }
            }
        };
        
        const openExternal = () => {
            if (currentPage.value) {
                window.open(currentPage.value.url, '_blank');
            }
        };
        
        const truncateText = (text, length) => {
            if (!text) return '';
            return text.length > length ? text.substring(0, length) + '...' : text;
        };
        
        const formatURL = (url) => {
            try {
                const urlObj = new URL(url);
                return urlObj.hostname;
            } catch (e) {
                return url;
            }
        };
        
        onMounted(async () => {
            await loadPages();
            
            // Vérifier si on doit ouvrir une page spécifique
            const pageId = route.params.id;
            if (pageId) {
                const page = pages.value.find(p => p.id === parseInt(pageId));
                if (page) {
                    currentPage.value = page;
                }
            }
        });
        
        return {
            loading,
            isRefreshing,
            iframeError,
            pages,
            currentPage,
            webviewFrame,
            canGoBack,
            canGoForward,
            openPage,
            goBack,
            refreshPage,
            onIframeLoad,
            onIframeError,
            navigateBack,
            navigateForward,
            openExternal,
            truncateText,
            formatURL
        };
    }
};