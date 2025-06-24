/**
 * Gestionnaire d'authentification pour l'application
 */
class AuthManager {
    constructor() {
        this.token = localStorage.getItem('auth_token');
        this.user = JSON.parse(localStorage.getItem('user') || 'null');
        this.apiBaseUrl = '/api/v1';
    }

    /**
     * Vérifier si l'utilisateur est connecté
     */
    isAuthenticated() {
        return this.token && this.user;
    }

    /**
     * Obtenir les headers pour les requêtes API
     */
    getHeaders() {
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
        };

        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }

        return headers;
    }

    /**
     * Connexion utilisateur
     */
    async login(email, password) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/auth/login`, {
                method: 'POST',
                headers: this.getHeaders(),
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (data.success) {
                this.token = data.data.token;
                this.user = data.data.user;
                
                localStorage.setItem('auth_token', this.token);
                localStorage.setItem('user', JSON.stringify(this.user));
                
                return { success: true, user: this.user };
            } else {
                return { success: false, message: data.message };
            }
        } catch (error) {
            console.error('Erreur de connexion:', error);
            return { success: false, message: 'Erreur de connexion' };
        }
    }

    /**
     * Inscription utilisateur
     */
    async register(name, email, password, passwordConfirmation) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/auth/register`, {
                method: 'POST',
                headers: this.getHeaders(),
                body: JSON.stringify({ 
                    name, 
                    email, 
                    password, 
                    password_confirmation: passwordConfirmation 
                })
            });

            const data = await response.json();

            if (data.success) {
                this.token = data.data.token;
                this.user = data.data.user;
                
                localStorage.setItem('auth_token', this.token);
                localStorage.setItem('user', JSON.stringify(this.user));
                
                return { success: true, user: this.user };
            } else {
                return { success: false, message: data.message, errors: data.errors };
            }
        } catch (error) {
            console.error('Erreur d\'inscription:', error);
            return { success: false, message: 'Erreur d\'inscription' };
        }
    }

    /**
     * Déconnexion utilisateur
     */
    async logout() {
        try {
            if (this.token) {
                await fetch(`${this.apiBaseUrl}/auth/logout`, {
                    method: 'POST',
                    headers: this.getHeaders()
                });
            }
        } catch (error) {
            console.error('Erreur de déconnexion:', error);
        } finally {
            this.token = null;
            this.user = null;
            localStorage.removeItem('auth_token');
            localStorage.removeItem('user');
        }
    }

    /**
     * Afficher le modal de connexion/inscription
     */
    showAuthModal(message = null) {
        const modalHtml = `
            <div id="authModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
                    <div class="flex justify-between items-center mb-4">
                        <h2 class="text-xl font-bold">Connexion requise</h2>
                        <button onclick="authManager.closeAuthModal()" class="text-gray-500 hover:text-gray-700">
                            ✕
                        </button>
                    </div>
                    
                    ${message ? `<div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded mb-4">${message}</div>` : ''}
                    
                    <div id="authTabs" class="mb-4">
                        <button onclick="authManager.switchTab('login')" class="auth-tab active px-4 py-2 bg-blue-500 text-white rounded-l">
                            Connexion
                        </button>
                        <button onclick="authManager.switchTab('register')" class="auth-tab px-4 py-2 bg-gray-300 rounded-r">
                            Inscription
                        </button>
                    </div>

                    <!-- Formulaire de connexion -->
                    <div id="loginForm" class="auth-form">
                        <form onsubmit="authManager.handleLogin(event)">
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="loginEmail">
                                    Email
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="loginEmail" type="email" required>
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="loginPassword">
                                    Mot de passe
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="loginPassword" type="password" required>
                            </div>
                            <button class="w-full bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" 
                                    type="submit">
                                Se connecter
                            </button>
                        </form>
                    </div>

                    <!-- Formulaire d'inscription -->
                    <div id="registerForm" class="auth-form hidden">
                        <form onsubmit="authManager.handleRegister(event)">
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="registerName">
                                    Nom
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="registerName" type="text" required>
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="registerEmail">
                                    Email
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="registerEmail" type="email" required>
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="registerPassword">
                                    Mot de passe
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="registerPassword" type="password" required minlength="8">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2" for="registerPasswordConfirm">
                                    Confirmer le mot de passe
                                </label>
                                <input class="w-full px-3 py-2 border rounded focus:outline-none focus:border-blue-500" 
                                       id="registerPasswordConfirm" type="password" required minlength="8">
                            </div>
                            <button class="w-full bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded" 
                                    type="submit">
                                S'inscrire
                            </button>
                        </form>
                    </div>

                    <div id="authMessage" class="mt-4 hidden"></div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', modalHtml);
    }

    /**
     * Fermer le modal d'authentification
     */
    closeAuthModal() {
        const modal = document.getElementById('authModal');
        if (modal) {
            modal.remove();
        }
    }

    /**
     * Changer d'onglet dans le modal
     */
    switchTab(tab) {
        // Changer l'apparence des onglets
        document.querySelectorAll('.auth-tab').forEach(button => {
            button.classList.remove('active', 'bg-blue-500', 'text-white');
            button.classList.add('bg-gray-300');
        });
        
        const activeTab = document.querySelector(`[onclick="authManager.switchTab('${tab}')"]`);
        activeTab.classList.add('active', 'bg-blue-500', 'text-white');
        activeTab.classList.remove('bg-gray-300');

        // Afficher/masquer les formulaires
        document.querySelectorAll('.auth-form').forEach(form => {
            form.classList.add('hidden');
        });
        
        document.getElementById(tab + 'Form').classList.remove('hidden');
    }

    /**
     * Gérer la soumission du formulaire de connexion
     */
    async handleLogin(event) {
        event.preventDefault();
        
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;
        
        const result = await this.login(email, password);
        
        if (result.success) {
            this.closeAuthModal();
            // Recharger la page ou mettre à jour l'interface
            location.reload();
        } else {
            this.showAuthMessage(result.message, 'error');
        }
    }

    /**
     * Gérer la soumission du formulaire d'inscription
     */
    async handleRegister(event) {
        event.preventDefault();
        
        const name = document.getElementById('registerName').value;
        const email = document.getElementById('registerEmail').value;
        const password = document.getElementById('registerPassword').value;
        const passwordConfirm = document.getElementById('registerPasswordConfirm').value;
        
        if (password !== passwordConfirm) {
            this.showAuthMessage('Les mots de passe ne correspondent pas', 'error');
            return;
        }
        
        const result = await this.register(name, email, password, passwordConfirm);
        
        if (result.success) {
            this.closeAuthModal();
            // Recharger la page ou mettre à jour l'interface
            location.reload();
        } else {
            this.showAuthMessage(result.message, 'error');
        }
    }

    /**
     * Afficher un message dans le modal d'authentification
     */
    showAuthMessage(message, type = 'info') {
        const messageDiv = document.getElementById('authMessage');
        if (messageDiv) {
            const bgColor = type === 'error' ? 'bg-red-100 border-red-400 text-red-700' : 'bg-blue-100 border-blue-400 text-blue-700';
            messageDiv.innerHTML = `<div class="${bgColor} px-4 py-3 rounded border">${message}</div>`;
            messageDiv.classList.remove('hidden');
        }
    }
}

// Initialiser le gestionnaire d'authentification
const authManager = new AuthManager();