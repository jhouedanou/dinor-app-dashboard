# Guide d'Authentification - Dinor App

## 🚀 Fonctionnalités Implémentées

Ce guide explique le système d'authentification et d'interaction (likes/commentaires) mis en place pour l'application Dinor.

### ✅ Scripts Inclus

1. **`/js/auth-manager.js`** - Gestionnaire d'authentification principal
2. **`/js/likes-manager.js`** - Gestionnaire des likes avec authentification
3. **`/js/comments-manager.js`** - Gestionnaire des commentaires avec authentification
4. **`/css/auth-components.css`** - Styles pour les composants d'authentification

### ✅ Pages Corrigées

- **`/public/recipe.html`** - Page de détails des recettes
- **`/public/tip.html`** - Page de détails des astuces

## 🔧 Corrections Apportées

### 1. **Erreurs Alpine.js corrigées**
- Remplacement de `recipe.property` par `recipe?.property || defaultValue`
- Remplacement de `tip.property` par `tip?.property || defaultValue`
- Correction des clés dans les boucles `x-for` avec des index

### 2. **API d'authentification**
- Messages d'erreur améliorés dans `LikeController` et `CommentController`
- Méthode `hasLiked` ajoutée au modèle `Like`
- Méthodes `toggleLike` ajoutées aux modèles `Recipe`, `Tip`, et `Event`

### 3. **Système d'authentification frontend**
- Modal de connexion/inscription automatique
- Gestion des tokens JWT
- Stockage local des sessions
- Interface utilisateur responsive

## 📱 Comment Utiliser

### 1. **Inclusion des Scripts**

Ajoutez ces scripts dans vos pages HTML :

```html
<link rel="stylesheet" href="/css/auth-components.css">
<script src="/js/auth-manager.js"></script>
<script src="/js/likes-manager.js"></script>
<script src="/js/comments-manager.js"></script>
```

### 2. **Boutons de Like**

Pour ajouter un bouton de like :

```html
<!-- Bouton de like -->
<button data-like-type="recipe" 
        data-like-id="3" 
        class="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-lg hover:bg-gray-200">
    <span class="text-xl">🤍</span>
    <span data-like-count-type="recipe" data-like-count-id="3">0</span>
    <span>J'aime</span>
</button>
```

### 3. **Formulaire de Commentaires**

Pour ajouter un formulaire de commentaires :

```html
<!-- Formulaire de commentaire -->
<form class="comment-form" data-type="recipe" data-id="3">
    <textarea name="content" 
              placeholder="Votre commentaire..." 
              class="w-full p-4 border rounded-lg"
              rows="3"></textarea>
    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">
        Commenter
    </button>
</form>

<!-- Zone d'affichage des commentaires -->
<div data-comments-type="recipe" data-comments-id="3"></div>
```

### 4. **Navigation avec Authentification**

Pour ajouter des boutons de connexion/inscription :

```html
<div id="authStatus" class="flex items-center space-x-2">
    <!-- Sera mis à jour automatiquement -->
</div>

<script>
// Mettre à jour le statut d'authentification
function updateAuthStatus() {
    const authStatusDiv = document.getElementById('authStatus');
    
    if (authManager.isAuthenticated()) {
        authStatusDiv.innerHTML = `
            <span>Bonjour, ${authManager.user.name}!</span>
            <button onclick="logout()">Déconnexion</button>
        `;
    } else {
        authStatusDiv.innerHTML = `
            <button onclick="showLogin()">Connexion</button>
            <button onclick="showRegister()">Inscription</button>
        `;
    }
}

function showLogin() {
    authManager.showAuthModal();
    authManager.switchTab('login');
}

function showRegister() {
    authManager.showAuthModal();
    authManager.switchTab('register');
}

async function logout() {
    await authManager.logout();
    updateAuthStatus();
}

// Initialiser au chargement
document.addEventListener('DOMContentLoaded', updateAuthStatus);
</script>
```

## 🎯 Comportement du Système

### **Utilisateur Non Connecté**
1. Clic sur "J'aime" → Modal de connexion/inscription s'affiche
2. Tentative de commentaire → Modal de connexion/inscription s'affiche
3. Peut voir les likes et commentaires existants

### **Utilisateur Connecté**
1. Peut liker/unliker du contenu
2. Peut poster des commentaires
3. Peut répondre aux commentaires
4. Ses actions sont sauvegardées avec son compte

### **Gestion des Erreurs**
- Connexion réseau → Notifications d'erreur
- Token expiré → Redirection vers connexion
- Erreurs API → Messages d'erreur détaillés

## 🔐 Sécurité

- **Authentification JWT** avec tokens stockés localement
- **Validation côté serveur** pour tous les endpoints
- **Protection CSRF** avec middleware Laravel
- **Sanitisation** des données utilisateur

## 🚀 API Endpoints

### Authentification
- `POST /api/v1/auth/login` - Connexion
- `POST /api/v1/auth/register` - Inscription  
- `POST /api/v1/auth/logout` - Déconnexion

### Likes
- `POST /api/v1/likes/toggle` - Toggle like (authentifié)
- `GET /api/v1/likes/check` - Vérifier like (public)

### Commentaires
- `POST /api/v1/comments` - Ajouter commentaire (authentifié)
- `GET /api/v1/comments` - Lister commentaires (public)

## 🎨 Styles CSS

Le fichier `auth-components.css` inclut :
- Styles pour les modals d'authentification
- Animations pour les boutons de like
- États de chargement
- Design responsive
- Notifications

## 📱 Compatibilité

- **Navigateurs** : Chrome, Firefox, Safari, Edge (modernes)
- **Mobile** : Responsive design avec Tailwind CSS
- **JavaScript** : ES6+ avec support Alpine.js
- **Framework** : Laravel 10+ avec Filament 3+

## 🐛 Debugging

Pour déboguer les problèmes :

1. **Console du navigateur** pour les erreurs JavaScript
2. **Network tab** pour les erreurs API
3. **Laravel logs** pour les erreurs serveur
4. **Vérifier l'authentification** avec `authManager.isAuthenticated()`

## ✨ Exemple Complet

Voir `/public/example-recipe-page.html` pour un exemple complet d'intégration.