# 🚀 Générateur d'Application Flutter Dinor Dashboard

Ce script génère automatiquement une application Flutter complète basée sur la page dashboard HTML existante de l'application Dinor.

## 📋 Prérequis

Avant d'exécuter le script, assurez-vous d'avoir :

- ✅ **Flutter** installé (version 3.0.0 ou supérieure)
- ✅ **Dart** installé avec Flutter
- ✅ **Android Studio** ou **VS Code** avec les extensions Flutter/Dart
- ✅ Un **émulateur Android/iOS** ou un **appareil physique** connecté
- ✅ Le **serveur Laravel Dinor** en fonctionnement sur `http://localhost:8000`

## 🔧 Installation et Utilisation

### 1. Rendre le script exécutable
```bash
chmod +x generate_flutter_app.sh
```

### 2. Exécuter le script
```bash
./generate_flutter_app.sh
```

### 3. Initialiser l'application Flutter
```bash
cd dinor_dashboard_flutter
flutter pub get
```

### 4. Lancer l'application
```bash
flutter run
```

## 📱 Fonctionnalités de l'App

L'application Flutter générée inclut :

### 🏠 Dashboard Principal
- **Header avec gradient** - Design identique au web
- **Cartes de statistiques** - Recettes, Événements, Pages, Astuces, Interactions
- **Navigation par onglets** - Interface utilisateur intuitive

### 🍽️ Section Recettes
- **Liste en grille** - Affichage optimisé pour mobile
- **Recherche en temps réel** - Filtrage instantané
- **Filtres par catégorie** - Navigation facile
- **Indicateurs de difficulté** - Visuel et coloré
- **Informations détaillées** - Temps de préparation, portions, etc.

### 📅 Section Événements
- **Liste verticale** - Design adapté aux événements
- **Recherche et filtres** - Par type (à venir, en vedette)
- **Informations complètes** - Date, lieu, prix, catégorie
- **Format de date français** - Affichage localisé

### 🔄 Gestion d'État
- **Provider Pattern** - Architecture Flutter recommandée
- **États de chargement** - Shimmer effects et spinners
- **Gestion d'erreurs** - Fallbacks et valeurs par défaut
- **Cache intelligent** - Optimisation des performances

### 🎨 Design System
- **Material Design 3** - Interface moderne et cohérente
- **Couleurs Dinor** - Palette jaune/orange fidèle à la marque
- **Animations fluides** - Transitions et micro-interactions
- **Responsive design** - Adaptation automatique aux écrans

## 🌐 Connexion API

L'application se connecte automatiquement aux endpoints Laravel :

```
GET /api/v1/recipes           # Liste des recettes
GET /api/v1/events            # Liste des événements  
GET /api/v1/pages             # Liste des pages
GET /api/v1/tips              # Liste des astuces
GET /api/v1/recipes/categories/list  # Catégories
```

### Configuration de l'URL de base
Pour modifier l'URL de l'API, éditez le fichier `lib/services/api_service.dart` :

```dart
class ApiService {
  static const String baseUrl = 'http://votre-url:8000/api/v1';
  // ...
}
```

## 📁 Structure du Projet Généré

```
dinor_dashboard_flutter/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── models/                      # Modèles de données
│   │   ├── recipe.dart
│   │   └── event.dart
│   ├── services/                    # Services API
│   │   └── api_service.dart
│   ├── providers/                   # Gestion d'état
│   │   └── dashboard_provider.dart
│   ├── screens/                     # Écrans principaux
│   │   └── dashboard_screen.dart
│   └── widgets/                     # Composants réutilisables
│       ├── stats_cards.dart
│       ├── recipe_tab.dart
│       └── event_tab.dart
├── pubspec.yaml                     # Dépendances
└── README.md
```

## 🔧 Dépendances Utilisées

- **http** - Requêtes API REST
- **provider** - Gestion d'état
- **shared_preferences** - Stockage local
- **cached_network_image** - Cache d'images
- **flutter_staggered_animations** - Animations avancées
- **pull_to_refresh** - Rafraîchissement par glisser
- **shimmer** - Effets de chargement
- **intl** - Internationalisation et formatage

## 🚀 Développement Avancé

### Ajouter de nouvelles fonctionnalités

1. **Nouveau modèle** : Créez un fichier dans `lib/models/`
2. **Nouveau service** : Ajoutez des méthodes dans `api_service.dart`
3. **Nouveau provider** : Étendez `dashboard_provider.dart`
4. **Nouveau widget** : Créez un fichier dans `lib/widgets/`

### Personnaliser le thème

Modifiez les couleurs dans `lib/main.dart` :

```dart
theme: ThemeData(
  primarySwatch: MaterialColor(0xFFVOTRE_COULEUR, {
    // Palette de couleurs personnalisée
  }),
),
```

## 🐛 Dépannage

### Problèmes courants

1. **Erreur de connexion API**
   - Vérifiez que le serveur Laravel fonctionne
   - Confirmez l'URL dans `api_service.dart`

2. **Erreurs de compilation**
   - Exécutez `flutter clean` puis `flutter pub get`
   - Vérifiez la version de Flutter : `flutter --version`

3. **Problèmes d'affichage**
   - Redémarrez l'application : `r` dans le terminal
   - Hot reload : `R` pour un restart complet

### Logs et debug

```bash
# Voir les logs en temps réel
flutter logs

# Activer le mode debug verbose
flutter run --verbose
```

## 📱 Tests et Déploiement

### Tests
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

### Build pour production
```bash
# Android APK
flutter build apk --release

# iOS (sur macOS uniquement)
flutter build ios --release
```

## 🤝 Contribution

Pour contribuer au développement :

1. Fork le projet
2. Créez une branche feature : `git checkout -b feature/nouvelle-fonctionnalite`
3. Committez vos changements : `git commit -m 'Ajout nouvelle fonctionnalité'`
4. Push vers la branche : `git push origin feature/nouvelle-fonctionnalite`
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**🎉 Félicitations !** Vous avez maintenant une application Flutter moderne et fonctionnelle pour votre dashboard Dinor !

Pour toute question ou assistance, n'hésitez pas à ouvrir une issue sur le repository GitHub. 