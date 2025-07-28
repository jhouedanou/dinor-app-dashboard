# Dinor App - Votre chef de poche

Application mobile Flutter pour la plateforme Dinor - Votre chef de poche.

## 🚀 Description

Application mobile native développée en Flutter qui reproduit fidèlement les fonctionnalités de l'application web PWA Dinor. L'app propose des recettes, astuces culinaires, événements et vidéos DinorTV.

## 📱 Fonctionnalités

- **Recettes** : Parcourir et consulter des recettes détaillées
- **Astuces** : Découvrir des conseils culinaires pratiques
- **Événements** : Consulter les événements gastronomiques
- **DinorTV** : Regarder des vidéos culinaires
- **Profil** : Gestion du compte utilisateur
- **Favoris** : Système de likes et favoris
- **Commentaires** : Interaction sociale sur le contenu

## 🛠 Installation

### Prérequis
- Flutter 3.19.0 ou supérieur
- Dart 3.3.0 ou supérieur
- Android Studio / VS Code
- SDK Android 21+ (Android 5.0) ou iOS 12.0+

### Installation des dépendances
```bash
flutter pub get
```

### Lancement de l'application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk --release
```

## 🌐 API Documentation

L'application utilise l'API REST Dinor située à `https://new.dinorapp.com/api/v1/`

### Endpoints Principaux

#### 📚 Recettes
- `GET /recipes` - Liste des recettes
- `GET /recipes/{id}` - Détail d'une recette
- `GET /recipes/featured/list` - Recettes mises en avant
- `GET /recipes/categories/list` - Catégories de recettes

#### 🗓 Événements
- `GET /events` - Liste des événements
- `GET /events/{id}` - Détail d'un événement
- `GET /events/upcoming/list` - Événements à venir
- `GET /events/featured/list` - Événements mis en avant

#### 💡 Astuces
- `GET /tips` - Liste des astuces
- `GET /tips/{id}` - Détail d'une astuce
- `GET /tips/featured/list` - Astuces mises en avant

#### 📺 DinorTV
- `GET /dinor-tv` - Liste des vidéos
- `GET /dinor-tv/featured/list` - Vidéos mises en avant
- `GET /dinor-tv/live/list` - Vidéos en direct

#### 📄 Pages & Navigation
- `GET /pages` - Liste des pages
- `GET /pages/homepage` - Contenu de la page d'accueil
- `GET /pages/menu` - Menu de navigation

#### 📊 Catégories & Dashboard
- `GET /categories` - Liste des catégories
- `GET /categories/check` - Vérification des catégories
- `GET /dashboard` - Données du tableau de bord

#### 👥 Interactions Sociales
- `GET /likes` - Gestion des likes
- `GET /comments` - Gestion des commentaires

#### 🧪 Endpoints de Test
- `GET /test/recipes-all` - Toutes les recettes (test)
- `GET /test/events-all` - Tous les événements (test)
- `GET /test/categories-all` - Toutes les catégories (test)
- `GET /test/database-check` - Vérification de la base de données

### Format des Réponses

Toutes les réponses de l'API suivent le format standard :

```json
{
  "success": true,
  "data": {
    // Données de la réponse
  },
  "meta": {
    "total": 100,
    "per_page": 20,
    "current_page": 1,
    "last_page": 5
  },
  "message": "Success"
}
```

### Authentification

L'API utilise l'authentification Bearer Token :

```
Authorization: Bearer {token}
```

## 🏗 Architecture

### Structure du Projet
```
lib/
├── app.dart                    # App principale
├── main.dart                   # Point d'entrée
├── components/                 # Composants réutilisables
│   ├── common/                # Composants communs
│   └── navigation/            # Navigation
├── composables/               # Logique métier réutilisable
├── router/                    # Configuration des routes
├── screens/                   # Écrans de l'application
├── services/                  # Services (API, etc.)
└── stores/                    # Gestion d'état
```

### Technologies Utilisées
- **Flutter** - Framework mobile multiplateforme
- **Riverpod** - Gestion d'état réactive
- **Navigator** - Navigation classique avec GlobalKey
- **HTTP** - Client HTTP pour l'API
- **CachedNetworkImage** - Cache des images
- **SharedPreferences** - Stockage local

## 🎨 Design System

### Couleurs
- **Primary** : `#E53E3E` (Rouge Dinor)
- **Secondary** : `#F4D03F` (Jaune/Or)
- **Background** : `#F5F5F5` (Gris clair)
- **Surface** : `#FFFFFF` (Blanc)
- **Text Primary** : `#2D3748` (Gris foncé)
- **Text Secondary** : `#4A5568` (Gris moyen)

### Typographie
- **Titres** : OpenSans (600-700)
- **Corps de texte** : Roboto (400-500)

## 🔧 Configuration

### Variables d'Environnement
Les configurations sont définies dans `lib/services/api_service.dart` :

```dart
static const String baseUrl = 'https://new.dinorapp.com/api/v1';
static const Duration timeout = Duration(seconds: 30);
```

## 🚀 Déploiement

### Android
```bash
# Build APK de production
flutter build apk --release

# Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

## 🧪 Tests

```bash
# Lancer les tests
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📝 Développement

### Hot Reload
Flutter supporte le hot reload pour un développement rapide :
```bash
# Dans le terminal après flutter run
r  # Hot reload
R  # Hot restart
```

### Debug
```bash
# Lancer avec les DevTools
flutter run --debug
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou support :
- Email : support@dinorapp.com
- GitHub Issues : [Issues](https://github.com/dinor/dinor-app-flutter/issues)

---

**Dinor App - Votre chef de poche** - Développé avec ❤️ en Flutter
