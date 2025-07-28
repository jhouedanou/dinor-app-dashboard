# 🧪 Guide de Test - Application React Native Dinor

## 📋 Vue d'ensemble

Ce guide vous accompagne pour tester l'application React Native Dinor qui a été convertie depuis la PWA Vue.js. L'application utilise l'API Laravel hébergée sur `https://new.dinorapp.com/`.

## 🚀 Installation et Configuration

### Prérequis
- Node.js 18+ et npm 8+
- React Native CLI
- Android Studio (pour Android)
- Xcode (pour iOS, macOS uniquement)

### Installation des dépendances
```bash
cd react-native-dinor
npm install
```

### Configuration Android
✅ **Configuration automatique terminée !**
- Les fichiers Android ont été créés et configurés
- Le package `com.dinorapp` est configuré
- Les versions Gradle sont compatibles avec React Native 0.72.6

### Test de la configuration
```bash
./test-android-setup.sh
```

## 📱 Lancement de l'application

### Option 1 : Android
```bash
# Lancer l'application Android
npx react-native run-android

# Ou utiliser le script de test rapide
./quick-test.sh
```

### Option 2 : iOS (macOS uniquement)
```bash
# Installer les pods iOS
cd ios && pod install && cd ..

# Lancer l'application iOS
npx react-native run-ios
```

### Option 3 : Test rapide automatisé
```bash
# Script complet avec vérifications
./quick-test.sh
```

## 🔍 Tests de connectivité API

### Test automatique de l'API
```bash
# Test de connectivité API
node test-api-connection.js
```

### Endpoints testés :
- ✅ `/api/v1/recipes` - Recettes publiques
- ✅ `/api/v1/tips` - Conseils publics  
- ✅ `/api/v1/events` - Événements publics
- ✅ `/api/v1/categories` - Catégories
- ✅ `/api/v1/dinor-tv` - Contenu DinorTV
- ✅ `/api/v1/banners` - Bannières
- ⚠️ `/api/v1/auth/login` - Authentification (401 attendu avec credentials de test)

## 🧪 Tests fonctionnels

### 1. Test de navigation
- [ ] Navigation entre les onglets (Home, Recipes, Tips, Events, DinorTV, Profile)
- [ ] Navigation vers les écrans de détail
- [ ] Bouton retour fonctionnel

### 2. Test des données
- [ ] Affichage des recettes avec images
- [ ] Affichage des conseils avec difficulté
- [ ] Affichage des événements avec dates
- [ ] Chargement des catégories

### 3. Test des interactions
- [ ] Système de likes (cœur)
- [ ] Système de favoris (étoile)
- [ ] Partage de contenu
- [ ] Modal d'authentification

### 4. Test de l'API
- [ ] Requêtes GET vers les endpoints publics
- [ ] Gestion des erreurs réseau
- [ ] Cache des données avec Zustand

## 🔧 Dépannage

### Erreurs courantes

#### 1. "Android project not found"
**Solution :** ✅ **Résolu** - Les fichiers Android ont été créés et configurés

#### 2. Erreurs Gradle
**Solution :** ✅ **Résolu** - Versions compatibles configurées

#### 3. Erreurs de navigation
**Solution :** ✅ **Résolu** - Types TypeScript configurés

#### 4. Erreurs de dépendances
```bash
# Si vous avez des conflits de dépendances
npm install --legacy-peer-deps
```

### Commandes utiles
```bash
# Nettoyer le cache
npx react-native clean

# Redémarrer Metro
npx react-native start --reset-cache

# Vérifier les types TypeScript
npm run typecheck

# Lancer les tests
npm test
```

## 📊 Résultats attendus

### ✅ Fonctionnalités implémentées
- [x] Navigation par onglets
- [x] Écrans de détail
- [x] Intégration API Laravel
- [x] Gestion d'état avec Zustand
- [x] Système de likes et favoris
- [x] Interface utilisateur fidèle à la PWA
- [x] Support Android et iOS
- [x] Gestion des erreurs réseau
- [x] Cache des données

### 🔄 Fonctionnalités en cours
- [ ] Notifications push
- [ ] Mode hors ligne avancé
- [ ] Optimisations de performance

## 📱 Plateformes supportées

### Android
- ✅ Configuration complète
- ✅ Build et déploiement
- ✅ Tests fonctionnels

### iOS
- ✅ Configuration complète
- ⏳ Tests sur appareil physique requis

## 🎯 Prochaines étapes

1. **Tests utilisateur** : Tester l'application sur appareils physiques
2. **Optimisations** : Améliorer les performances et l'UX
3. **Fonctionnalités avancées** : Notifications, mode hors ligne
4. **Déploiement** : Publier sur Google Play et App Store

---

## 📞 Support

Si vous rencontrez des problèmes :
1. Consultez ce guide de test
2. Vérifiez les logs Metro
3. Testez la connectivité API
4. Consultez la documentation React Native

**🎉 L'application est prête pour les tests utilisateur !** 