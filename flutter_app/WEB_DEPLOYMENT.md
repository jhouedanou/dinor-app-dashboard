# 🚀 Guide de Déploiement Web - Dinor App Flutter

## 📋 Vue d'ensemble

Ce guide explique comment construire et déployer la version web de l'application Flutter Dinor App.

## 🛠️ Prérequis

- Flutter SDK installé (version 3.32.8 ou plus récente)
- Support web activé dans Flutter
- Python 3 (pour servir localement)

## 🔧 Construction de la version web

### Méthode 1: Script automatisé (recommandé)

```bash
# Construction simple
./build-web.sh

# Construction et serveur local
./build-web.sh serve

# Construction pour déploiement
./build-web.sh deploy
```

### Méthode 2: Commandes manuelles

```bash
# Nettoyer les builds précédents
flutter clean

# Installer les dépendances
flutter pub get

# Construire la version web
flutter build web --release
```

## 🌐 Test local

Après construction, vous pouvez tester l'application localement :

```bash
cd build/web
python3 -m http.server 8080
```

Puis ouvrez votre navigateur sur : http://localhost:8080

## 🚀 Déploiement

### Option 1: Netlify (Recommandé pour les débutants)

1. Allez sur [netlify.com](https://netlify.com)
2. Créez un compte ou connectez-vous
3. Glissez-déposez le dossier `build/web/` dans la zone de déploiement
4. Votre site sera automatiquement déployé

### Option 2: Vercel

1. Allez sur [vercel.com](https://vercel.com)
2. Importez votre projet GitHub
3. Configurez le dossier de build : `flutter_app/build/web`
4. Déployez

### Option 3: GitHub Pages

1. Créez une branche `gh-pages`
2. Copiez le contenu de `build/web/` dans cette branche
3. Activez GitHub Pages dans les paramètres du repository

### Option 4: Serveur web traditionnel

1. Copiez le contenu de `build/web/` vers votre répertoire web public
2. Configurez votre serveur web (Apache/Nginx) pour servir les fichiers statiques

## 📁 Structure des fichiers générés

```
build/web/
├── index.html              # Page principale
├── main.dart.js           # Code JavaScript compilé
├── flutter.js             # Runtime Flutter
├── flutter_bootstrap.js   # Bootstrap Flutter
├── manifest.json          # Manifeste PWA
├── favicon.png           # Icône du site
├── icons/                # Icônes PWA
├── assets/               # Assets de l'application
└── canvaskit/           # Runtime CanvasKit
```

## 🔧 Configuration avancée

### Personnalisation du titre et de la description

Modifiez `web/index.html` :

```html
<title>Dinor App - Votre chef de poche</title>
<meta name="description" content="Application culinaire mobile - Recettes, pronostics et plus">
```

### Configuration PWA

Modifiez `web/manifest.json` pour personnaliser l'application PWA :

```json
{
  "name": "Dinor App",
  "short_name": "Dinor",
  "description": "Votre chef de poche",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000"
}
```

### Optimisation des performances

Pour optimiser les performances :

```bash
# Construction avec optimisations avancées
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

# Construction avec tree-shaking des icônes désactivé (si nécessaire)
flutter build web --release --no-tree-shake-icons
```

## 🐛 Dépannage

### Problème: L'application ne se charge pas

1. Vérifiez que tous les fichiers sont présents dans `build/web/`
2. Vérifiez les erreurs dans la console du navigateur
3. Assurez-vous que le serveur web sert les fichiers correctement

### Problème: Les assets ne se chargent pas

1. Vérifiez que le dossier `assets/` est copié dans `build/web/`
2. Vérifiez les chemins dans `pubspec.yaml`

### Problème: Erreurs de CORS

1. Configurez votre serveur web pour servir les bons headers
2. Utilisez un serveur local pour les tests

## 📱 Fonctionnalités PWA

L'application web inclut les fonctionnalités PWA suivantes :

- ✅ Installation sur l'écran d'accueil
- ✅ Mode hors ligne (avec limitations)
- ✅ Notifications push (si configurées)
- ✅ Interface adaptative

## 🔄 Mise à jour

Pour mettre à jour l'application web :

1. Modifiez le code Flutter
2. Relancez la construction : `./build-web.sh`
3. Redéployez les nouveaux fichiers

## 📞 Support

Pour toute question ou problème :

1. Vérifiez les logs de construction
2. Consultez la documentation Flutter Web
3. Vérifiez la compatibilité des dépendances

---

**Note:** Cette version web est optimisée pour les navigateurs modernes. Pour une compatibilité maximale, testez sur Chrome, Firefox, Safari et Edge. 