# 🧪 GUIDE DE TEST - DINOR REACT NATIVE

## ✅ MODIFICATIONS EFFECTUÉES

### 1. Correction de l'URL de l'API
- **Avant :** `https://your-dinor-api.com/api/v1`
- **Après :** `https://new.dinorapp.com/api/v1`

### 2. Correction des erreurs TypeScript
- Ajout de l'interface `ApiResponse`
- Typage correct des méthodes d'API
- Correction des types de retour

## 🚀 LANCEMENT DE L'APPLICATION

### Prérequis
```bash
# Vérifier Node.js
node --version  # >= 18

# Vérifier React Native CLI
npx react-native --version
```

### Installation
```bash
# Aller dans le dossier React Native
cd react-native-dinor

# Installer les dépendances
npm install

# iOS uniquement - installer les pods
cd ios && pod install && cd ..
```

### Lancement
```bash
# Lancer Metro bundler
npm start

# Dans un autre terminal, lancer sur Android
npm run android

# Ou sur iOS
npm run ios
```

## 🧪 TESTS À EFFECTUER

### 1. Test de l'API (Avant le lancement)
```bash
# Tester la connexion à l'API
node test-api-connection.js
```

**Résultat attendu :**
```
🧪 Test de connexion à l'API Dinor...

📡 Test de /recipes...
✅ /recipes - Status: 200
   📊 Données reçues: X éléments

📡 Test de /tips...
✅ /tips - Status: 200
   📊 Données reçues: X éléments

📡 Test de /events...
✅ /events - Status: 200
   📊 Données reçues: X éléments
```

### 2. Test de l'Application

#### ✅ Écran d'accueil (Home)
- [ ] **Chargement des données** : Les carousels se chargent
- [ ] **Recettes** : 4 dernières recettes affichées
- [ ] **Astuces** : 4 dernières astuces affichées  
- [ ] **Événements** : 4 derniers événements affichés
- [ ] **Pull to refresh** : Actualisation fonctionne

#### ✅ Navigation
- [ ] **Bottom tabs** : 6 onglets fonctionnels
- [ ] **Home** : Écran d'accueil
- [ ] **Recipes** : Liste des recettes
- [ ] **Tips** : Liste des astuces
- [ ] **Events** : Liste des événements
- [ ] **DinorTV** : Écran placeholder
- [ ] **Profile** : Profil utilisateur

#### ✅ Authentification
- [ ] **Modal de connexion** : S'ouvre correctement
- [ ] **Champs email/password** : Saisie fonctionnelle
- [ ] **Bouton de connexion** : Action fonctionnelle
- [ ] **Gestion des erreurs** : Messages d'erreur affichés
- [ ] **Persistance** : Connexion sauvegardée

#### ✅ Interactions
- [ ] **Likes** : Bouton like fonctionne
- [ ] **Favoris** : Ajout/retrait des favoris
- [ ] **Partage** : Modal de partage
- [ ] **Recherche** : Barre de recherche

## 🔍 DEBUG ET LOGS

### Logs à surveiller dans la console :

```typescript
// Logs de connexion API
📡 [API] Requête vers: /recipes
✅ [API] Réponse JSON: { success: true, endpoint: '/recipes' }

// Logs d'authentification
🔐 [Auth] Tentative de connexion pour: user@example.com
✅ [Auth] Connexion réussie pour: User Name

// Logs de navigation
🏠 [Home] Chargement des données d'accueil
✅ [Home] Données d'accueil chargées

// Logs d'interactions
❤️ [Home] Toggle like: { type: 'recipes', id: 1 }
✅ [Home] Like result: true
```

### En cas de problème :

#### ❌ Erreur de connexion API
```bash
# Vérifier l'URL de l'API
curl https://new.dinorapp.com/api/v1/recipes

# Vérifier le réseau
ping new.dinorapp.com
```

#### ❌ Erreur Metro bundler
```bash
# Nettoyer le cache
npm start --reset-cache

# Ou nettoyer complètement
npm run clean
npm start
```

#### ❌ Erreur Android
```bash
cd android
./gradlew clean
cd ..
npm run android
```

#### ❌ Erreur iOS
```bash
cd ios
pod install
cd ..
npm run ios
```

## 📱 TEST SUR APPAREIL PHYSIQUE

### Configuration réseau pour développement :

1. **Trouver l'IP de votre machine :**
```bash
# Linux/Mac
ifconfig | grep "inet "

# Windows
ipconfig
```

2. **Modifier l'URL de développement :**
```typescript
// Dans src/services/api.ts
if (__DEV__) {
  return 'http://VOTRE-IP/api/v1'; // Remplacer par votre IP
}
```

3. **Vérifier la connectivité :**
```bash
# Sur votre téléphone, ouvrir un navigateur et tester :
http://VOTRE-IP/api/v1/recipes
```

## 🎯 CRITÈRES DE SUCCÈS

### ✅ Application fonctionnelle si :
- [ ] L'écran d'accueil se charge avec des données
- [ ] La navigation entre les onglets fonctionne
- [ ] L'authentification fonctionne
- [ ] Les interactions (likes, favoris) fonctionnent
- [ ] Aucune erreur dans la console Metro

### ❌ Problèmes à corriger :
- [ ] Écran blanc ou de chargement infini
- [ ] Erreurs de connexion API
- [ ] Crashes de l'application
- [ ] Navigation qui ne fonctionne pas

## 🚀 DÉPLOIEMENT

### Build de production :
```bash
# Android
cd android
./gradlew assembleRelease

# iOS
cd ios
xcodebuild -workspace DinorApp.xcworkspace -scheme DinorApp -configuration Release
```

## 📞 SUPPORT

En cas de problème :
1. Vérifier les logs Metro
2. Tester l'API directement
3. Vérifier la configuration réseau
4. Consulter la documentation React Native

---

**🎉 L'application est maintenant prête à être testée avec la bonne URL d'API !** 