<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test d'authentification - Dinor</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background: #d4edda; border-color: #c3e6cb; color: #155724; }
        .error { background: #f8d7da; border-color: #f5c6cb; color: #721c24; }
        .info { background: #d1ecf1; border-color: #bee5eb; color: #0c5460; }
        button { padding: 10px 20px; margin: 5px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background: #0056b3; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-size: 12px; }
        input { padding: 8px; margin: 5px; border: 1px solid #ddd; border-radius: 4px; width: 200px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Test d'authentification - Dinor</h1>
        
        <div class="section info">
            <h3>📊 État actuel</h3>
            <div id="auth-status">Vérification...</div>
        </div>

        <div class="section info">
            <h3>🔧 Info Système</h3>
            <p><strong>Laravel Version:</strong> {{ app()->version() }}</p>
            <p><strong>PHP Version:</strong> {{ PHP_VERSION }}</p>
            <p><strong>Environment:</strong> {{ app()->environment() }}</p>
            <p><strong>Base URL:</strong> {{ url('/') }}</p>
            <p><strong>API Base URL:</strong> {{ url('/api/v1') }}</p>
        </div>

        <div class="section">
            <h3>🔑 Connexion</h3>
            <input type="email" id="email" placeholder="Email" value="fatima.traore@example.com">
            <input type="password" id="password" placeholder="Mot de passe" value="password">
            <button onclick="testLogin()">Se connecter</button>
            <button onclick="clearAuth()">Vider l'authentification</button>
        </div>

        <div class="section">
            <h3>🧪 Tests API</h3>
            <button onclick="testPredictions()">Test Prédictions</button>
            <button onclick="testLeaderboard()">Test Classement</button>
            <button onclick="testTournaments()">Test Tournois</button>
            <button onclick="testAllEndpoints()">Tester tous les endpoints</button>
        </div>

        <div class="section">
            <h3>📊 Test direct base de données</h3>
            <button onclick="testDatabaseInfo()">Infos base de données</button>
            <button onclick="testCreateToken()">Créer token de test</button>
        </div>

        <div class="section">
            <h3>📋 Résultats</h3>
            <div id="results"></div>
        </div>
    </div>

    <script>
        const BASE_URL = '{{ url("/api/v1") }}';
        const CSRF_TOKEN = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        
        function log(message, type = 'info') {
            const resultsDiv = document.getElementById('results');
            const timestamp = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.className = `section ${type}`;
            logEntry.innerHTML = `<strong>[${timestamp}]</strong> ${message}`;
            resultsDiv.appendChild(logEntry);
            console.log(`[${timestamp}] ${message}`);
        }

        function updateAuthStatus() {
            const token = localStorage.getItem('auth_token');
            const user = localStorage.getItem('auth_user');
            const statusDiv = document.getElementById('auth-status');
            
            if (token && user) {
                try {
                    const userData = JSON.parse(user);
                    statusDiv.innerHTML = `
                        <strong>✅ Connecté</strong><br>
                        Utilisateur: ${userData.name} (${userData.email})<br>
                        Token: ${token.substring(0, 20)}...<br>
                        <button onclick="console.log('Token complet:', '${token}')">Voir token complet</button>
                    `;
                } catch (e) {
                    statusDiv.innerHTML = '❌ Données utilisateur corrompues';
                }
            } else {
                statusDiv.innerHTML = '❌ Non connecté - Aucun token trouvé';
            }
        }

        async function makeAuthenticatedRequest(endpoint, options = {}) {
            const token = localStorage.getItem('auth_token');
            
            const config = {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': CSRF_TOKEN,
                    ...(token && { 'Authorization': `Bearer ${token}` })
                },
                ...options
            };

            log(`🚀 Requête vers ${endpoint}`);
            log(`🔐 Token envoyé: ${token ? 'OUI (' + token.substring(0, 20) + '...)' : 'NON'}`);
            
            if (config.body && typeof config.body === 'object') {
                config.body = JSON.stringify(config.body);
            }

            try {
                const response = await fetch(`${BASE_URL}${endpoint}`, config);
                const data = await response.json();
                
                log(`📡 Réponse ${response.status}: <pre>${JSON.stringify(data, null, 2)}</pre>`, 
                    response.ok ? 'success' : 'error');
                
                return { response, data };
            } catch (error) {
                log(`❌ Erreur: ${error.message}`, 'error');
                throw error;
            }
        }

        async function testLogin() {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            
            if (!email || !password) {
                log('❌ Veuillez saisir email et mot de passe', 'error');
                return;
            }

            try {
                log(`🔐 Tentative de connexion pour ${email}`);
                
                const response = await fetch(`${BASE_URL}/auth/login`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest',
                        'X-CSRF-TOKEN': CSRF_TOKEN
                    },
                    body: JSON.stringify({ email, password })
                });

                const data = await response.json();
                
                if (data.success) {
                    localStorage.setItem('auth_token', data.data.token);
                    localStorage.setItem('auth_user', JSON.stringify(data.data.user));
                    log(`✅ Connexion réussie pour ${data.data.user.name}`, 'success');
                    log(`🎫 Token reçu: ${data.data.token}`, 'info');
                    updateAuthStatus();
                } else {
                    log(`❌ Échec de connexion: <pre>${JSON.stringify(data, null, 2)}</pre>`, 'error');
                }
            } catch (error) {
                log(`❌ Erreur de connexion: ${error.message}`, 'error');
            }
        }

        function clearAuth() {
            localStorage.removeItem('auth_token');
            localStorage.removeItem('auth_user');
            log('🗑️ Authentification vidée', 'info');
            updateAuthStatus();
        }

        async function testPredictions() {
            await makeAuthenticatedRequest('/predictions/my-recent?limit=5');
        }

        async function testLeaderboard() {
            await makeAuthenticatedRequest('/leaderboard/my-stats');
        }

        async function testTournaments() {
            await makeAuthenticatedRequest('/tournaments/my-tournaments');
        }

        async function testAllEndpoints() {
            const endpoints = [
                '/predictions/my-recent?limit=5',
                '/leaderboard/my-stats',
                '/tournaments/my-tournaments',
                '/predictions',
                '/leaderboard/my-rank'
            ];

            for (const endpoint of endpoints) {
                await makeAuthenticatedRequest(endpoint);
                await new Promise(resolve => setTimeout(resolve, 500)); // Pause entre les requêtes
            }
        }

        async function testDatabaseInfo() {
            try {
                const response = await fetch('{{ url("/api/test/database-check") }}');
                const data = await response.json();
                log(`📊 Info base de données: <pre>${JSON.stringify(data, null, 2)}</pre>`, 'info');
            } catch (error) {
                log(`❌ Erreur base de données: ${error.message}`, 'error');
            }
        }

        async function testCreateToken() {
            try {
                const response = await fetch('{{ url("/test-create-token") }}', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': CSRF_TOKEN,
                        'Content-Type': 'application/json'
                    }
                });
                const data = await response.json();
                if (data.success) {
                    localStorage.setItem('auth_token', data.token);
                    localStorage.setItem('auth_user', JSON.stringify(data.user));
                    log(`✅ Token de test créé: ${data.token}`, 'success');
                    updateAuthStatus();
                } else {
                    log(`❌ Erreur création token: ${data.message}`, 'error');
                }
            } catch (error) {
                log(`❌ Erreur: ${error.message}`, 'error');
            }
        }

        // Initialisation
        updateAuthStatus();
        log('🚀 Page de test chargée');
        log(`🌐 API Base URL: ${BASE_URL}`);
    </script>
</body>
</html> 