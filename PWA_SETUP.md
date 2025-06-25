# 🚀 Configuration PWA Vue + Laravel API - Guide Complet

## ✅ Configuration Terminée

Votre projet PWA Dinor est maintenant **entièrement configuré** avec :

### 🏗️ Architecture
- **Frontend**: PWA Vue.js 3 avec routing et bottom navigation
- **Backend**: Laravel API avec Filament Admin simplifié  
- **Cache**: Service Worker avec stratégies Workbox avancées
- **Dev Environment**: Docker + BrowserSync pour hot reload

### 📱 Fonctionnalités PWA
- ✅ **Installation native** sur mobile/desktop
- ✅ **Mode offline** avec cache intelligent
- ✅ **Bottom navigation** 4 onglets (Recettes, Événements, Pages, Dinor TV)
- ✅ **Hot reload** automatique en développement
- ✅ **Service Worker** avec Background Sync
- ✅ **Responsive design** mobile-first

---

## 🚀 Démarrage Rapide

### Option 1: Docker (Recommandé)
```bash
# Démarrer tous les services
docker-compose up -d

# URLs disponibles:
# - Laravel: http://localhost:8000
# - PWA: http://localhost:8000/pwa/
# - BrowserSync (hot reload): http://localhost:3001
# - Admin: http://localhost:8000/admin
```

### Option 2: Développement Local
```bash
# Terminal 1 - Laravel
php artisan serve

# Terminal 2 - Hot reload PWA
npm run pwa:dev

# URLs:
# - PWA: http://localhost:8000/pwa/
# - Admin: http://localhost:8000/admin
```

---

## 📊 Pages et Navigation

### Bottom Navigation (4 onglets):

#### 1. 🍽️ Recettes (`/recipes`)
- Liste des recettes avec recherche et filtres
- Vue détail avec ingrédients et instructions
- API: `/api/v1/recipes`

#### 2. 📅 Événements (`/events`) 
- Liste des événements avec filtres de statut
- Vue détail avec informations complètes
- API: `/api/v1/events`

#### 3. 📄 Pages (`/pages`)
- WebView intégré pour afficher des pages externes
- Navigation avec contrôles (back, forward, refresh)
- Configuration via Admin: Pages → URL uniquement

#### 4. 🎬 Dinor TV (`/dinor-tv`)
- Player YouTube intégré
- Liste de vidéos avec miniatures
- Configuration via Admin: Dinor TV → URL YouTube uniquement

---

## ⚙️ Administration Filament

L'interface admin a été **simplifiée** pour la PWA :

### Pages Web (`/admin/pages`)
**Champs uniquement** :
- Titre de la page
- URL complète (ex: https://example.com)
- Description (optionnel)
- Visible dans l'app
- Ordre d'affichage

### Dinor TV (`/admin/dinor-tv`)
**Champs uniquement** :
- Titre de la vidéo  
- URL YouTube complète
- Description (optionnel)
- Visible dans l'app
- Vidéo mise en avant

---

## 🔧 Configuration Technique

### Hot Reload & BrowserSync
```bash
# Le BrowserSync surveille automatiquement:
# - public/pwa/**/*.js
# - public/pwa/**/*.html  
# - public/pwa/**/*.css

# Service configuré dans docker-compose.yml
# Port 3001 pour l'app avec hot reload
```

### Service Worker
```javascript
// Stratégies de cache configurées:
// - API: Network First + Background Sync
// - Images: Stale While Revalidate
// - Assets: Cache First
// - CDN: Cache First long terme

// Fichiers: /public/sw.js + workbox-config.js
```

### CORS Configuration
```php
// config/cors.php - Configuré pour:
// - localhost:3000, 3001 (BrowserSync)
// - localhost:8000 (Laravel)
// - localhost:5173 (Vite)
// - Storage et API paths
```

---

## 📁 Structure des Fichiers

```
public/pwa/
├── index.html                    # Point d'entrée PWA
├── app.js                       # App Vue principale + routing
├── manifest.json               # Configuration PWA
├── sw.js                      # Service Worker (généré)
├── components/
│   ├── navigation/
│   │   └── BottomNavigation.js # Navigation bottom tabs
│   ├── RecipesList.js         # Page recettes
│   ├── EventsList.js          # Page événements  
│   ├── PagesList.js           # Page WebView
│   ├── DinorTV.js             # Page Dinor TV
│   ├── Recipe.js              # Détail recette
│   ├── Event.js               # Détail événement
│   └── Tip.js                 # Détail astuce
└── icons/                     # Icônes PWA (à générer)
```

---

## 🎯 URLs Importantes

| Service | URL | Description |
|---------|-----|-------------|
| **PWA** | `http://localhost:8000/pwa/` | Application mobile |
| **Hot Reload** | `http://localhost:3001` | PWA avec rechargement auto |
| **Admin** | `http://localhost:8000/admin` | Interface Filament |
| **API** | `http://localhost:8000/api/v1/` | APIs REST |
| **Test** | `http://localhost:8000/pwa/test.html` | Page de test |
| **Icônes** | `http://localhost:8000/pwa/icons/generate-icons.html` | Générateur d'icônes |

---

## 🔨 Commandes Utiles

```bash
# Installation complète
./public/pwa/scripts/install.sh

# Configuration storage
./scripts/setup-storage.sh

# Build production PWA
npm run pwa:build

# Générer Service Worker
npm run sw:generate

# Hot reload seulement
npm run browsersync

# Docker services
docker-compose up -d          # Démarrer
docker-compose down           # Arrêter
docker-compose logs app       # Logs Laravel
docker-compose logs browsersync # Logs BrowserSync
```

---

## 🐛 Dépannage

### PWA ne s'installe pas
- ✅ Vérifier HTTPS (requis en production)
- ✅ Contrôler manifest.json
- ✅ Service Worker enregistré
- ✅ Icônes 192x192 et 512x512 présentes

### Hot reload ne fonctionne pas
- ✅ BrowserSync service démarré
- ✅ Port 3001 accessible  
- ✅ Fichiers surveillés dans docker-compose.yml

### Images ne s'affichent pas
- ✅ `php artisan storage:link` exécuté
- ✅ Permissions 775 sur storage/app/public
- ✅ CORS configuré pour /storage

### API errors
- ✅ Laravel démarré sur port 8000
- ✅ Base de données connectée
- ✅ Routes API définies dans routes/api.php

---

## 🎉 Prêt pour le Développement !

Votre PWA Vue + Laravel est maintenant **100% opérationnelle** avec :
- ✅ Architecture moderne et performante
- ✅ Hot reload pour un développement rapide  
- ✅ Interface admin simplifiée
- ✅ Fonctionnement offline
- ✅ Installation native

**Commencez par** : `docker-compose up -d` puis ouvrez `http://localhost:3001` 🚀