// Composant Pages (WebView intégré)
const PagesList = {
    template: `
        <div class="pages-page recipe-page">
            <!-- Top App Bar Material Design 3 -->
            <nav class="md3-top-app-bar">
                <div class="md3-app-bar-container">
                    <div class="md3-app-bar-title">
                        <button v-if="currentPage" @click="goBack" class="md3-icon-button">
                            <i class="material-icons">arrow_back</i>
                        </button>
                        <i v-else class="material-icons dinor-text-primary">description</i>
                        <span class="dinor-text-primary">{{ currentPage ? currentPage.title : 'Pages' }}</span>
                    </div>
                    <div class="md3-app-bar-actions">
                        <button v-if="currentPage" @click="refreshPage" class="md3-icon-button" :disabled="isRefreshing">
                            <i class="material-icons" :class="{ 'rotating': isRefreshing }">refresh</i>
                        </button>
                        <button v-if="currentPage" @click="openExternal" class="md3-icon-button">
                            <i class="material-icons">open_in_new</i>
                        </button>
                    </div>
                </div>
            </nav>

            <!-- Main Content -->
            <main class="md3-main-content">
                <!-- Loading -->
                <div v-if="loading && !currentPage" class="md3-loading-state">
                    <div class="md3-circular-progress"></div>
                    <p class="md3-body-large dinor-text-gray">Chargement des pages...</p>
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

                <!-- Liste des pages Material Design 3 -->
                <div v-else-if="pages.length > 0" class="md3-pages-list">
                    <div 
                        v-for="page in pages" 
                        :key="page.id"
                        @click="openPage(page)"
                        class="md3-card md3-card-elevated page-card-md3">
                        <div class="page-icon-container">
                            <div class="page-icon dinor-bg-primary">
                                <i class="material-icons">description</i>
                            </div>
                        </div>
                        <div class="page-content">
                            <h3 class="md3-title-large page-title dinor-text-primary">{{ page.title }}</h3>
                            <p v-if="page.description" class="md3-body-medium page-description dinor-text-gray">
                                {{ truncateText(page.description, 120) }}
                            </p>
                            <div class="page-url-info">
                                <i class="material-icons dinor-text-secondary">link</i>
                                <span class="md3-body-small dinor-text-secondary">{{ formatURL(page.url) }}</span>
                            </div>
                        </div>
                        <div class="page-actions">
                            <i class="material-icons dinor-text-secondary">chevron_right</i>
                        </div>
                    </div>
                </div>

                <!-- État vide -->
                <div v-else class="empty-state">
                    <div class="empty-icon">
                        <i class="material-icons">description</i>
                    </div>
                    <h3 class="empty-title">Aucune page disponible</h3>
                    <p class="empty-description">
                        Les pages apparaîtront ici bientôt
                    </p>
                </div>

                <!-- Pull to refresh indicator -->
                <div v-if="isRefreshing && !currentPage" class="refresh-indicator">
                    <div class="spinner"></div>
                    <span>Actualisation...</span>
                </div>
            </main>

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
            } else if (pages.value.length > 0) {
                // Ouvrir automatiquement la première page si aucune page spécifique n'est demandée
                currentPage.value = pages.value[0];
                router.push(`/pages/${pages.value[0].id}`);
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