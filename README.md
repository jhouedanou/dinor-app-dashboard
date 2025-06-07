# Dinor Dashboard

Dashboard Filament pour la gestion de contenu de l'application mobile Dinor avec API REST complète.

## 🚀 Fonctionnalités

### Dashboard Admin (Filament)
- **Recettes de cuisine** : Gestion complète avec ingrédients, instructions, temps de préparation
- **Astuces** : Conseils et techniques culinaires
- **Événements Dinor** : Gestion d'événements avec géolocalisation et inscriptions
- **Dinor TV** : Gestion de contenus vidéo avec live streaming
- **Pages web** : Système de pages personnalisables
- **Catégories** : Organisation du contenu par catégories

### API REST pour Flutter
- Endpoints complets pour tous les types de contenu
- Pagination automatique
- Filtres et recherche
- Support pour les contenus featured/vedettes
- Gestion des vues et likes pour les vidéos

## 📱 Structure API pour Flutter

### Endpoints principaux
```
GET /api/v1/recipes - Liste des recettes
GET /api/v1/recipes/{id} - Détail d'une recette
GET /api/v1/events - Liste des événements
GET /api/v1/events/{id} - Détail d'un événement
GET /api/v1/dinor-tv - Liste des vidéos
GET /api/v1/pages - Pages web
GET /api/v1/dashboard - Dashboard global pour l'app
```

### 4 onglets Flutter supportés
1. **Recettes** : `/api/v1/recipes`
2. **Événements** : `/api/v1/events`
3. **Carte** : Utilise les coordonnées des événements (`latitude`, `longitude`)
4. **Page Web** : `/api/v1/pages/{slug}`

## 🐳 Installation avec Docker

### Prérequis
- Docker
- Docker Compose

### Démarrage rapide

1. **Cloner et démarrer les services**
```bash
# Construire et démarrer les conteneurs
docker-compose up -d --build

# Attendre que les services soient prêts
sleep 30
```

2. **Configuration initiale**
```bash
# Entrer dans le conteneur de l'application
docker exec -it dinor-app bash

# Installer les dépendances
composer install

# Copier le fichier d'environnement
cp .env.example .env

# Générer la clé d'application
php artisan key:generate

# Exécuter les migrations
php artisan migrate

# Installer Filament
php artisan filament:install --panels

# Créer un utilisateur admin
php artisan make:filament-user

# Créer le lien symbolique pour le storage
php artisan storage:link

# Peupler la base de données (optionnel)
php artisan db:seed
```

### 🌐 Accès aux services

- **Dashboard Admin** : http://localhost:8000/admin
- **API** : http://localhost:8000/api/v1/
- **PhpMyAdmin** : http://localhost:8080
- **Application** : http://localhost:8000

### 📊 Base de données

**MySQL** :
- Host: localhost:3306
- Database: dinor_dashboard
- Username: dinor
- Password: password

## 🔧 Configuration pour la production

### Variables d'environnement importantes
```env
APP_NAME="Dinor Dashboard"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com

DB_CONNECTION=mysql
DB_HOST=db
DB_DATABASE=dinor_dashboard
DB_USERNAME=dinor
DB_PASSWORD=password

CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
```

### Sécurité
- Changer les mots de passe par défaut
- Configurer HTTPS
- Mettre à jour les clés d'API
- Configurer les CORS pour Flutter

## 📱 Intégration Flutter

### Exemple d'utilisation de l'API

```dart
// Configuration de base
const String baseUrl = 'http://votre-domaine.com/api/v1';

// Récupérer les recettes
Future<List<Recipe>> getRecipes() async {
  final response = await http.get(Uri.parse('$baseUrl/recipes'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((recipe) => Recipe.fromJson(recipe))
        .toList();
  }
  throw Exception('Erreur lors du chargement des recettes');
}

// Récupérer les événements avec géolocalisation
Future<List<Event>> getEvents() async {
  final response = await http.get(Uri.parse('$baseUrl/events'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((event) => Event.fromJson(event))
        .toList();
  }
  throw Exception('Erreur lors du chargement des événements');
}
```

### Structure des 4 onglets Flutter
1. **Recettes** : GridView avec cartes de recettes
2. **Événements** : ListView avec détails et localisation
3. **Carte** : Google Maps avec marqueurs des événements
4. **Page Web** : WebView pour afficher le contenu HTML

## 🛠️ Développement

### Commandes utiles
```bash
# Voir les logs
docker-compose logs -f app

# Redémarrer les services
docker-compose restart

# Arrêter les services
docker-compose down

# Nettoyer complètement
docker-compose down -v
docker system prune -a
```

### Structure des modèles
- **Recipe** : Recettes avec ingrédients et instructions
- **Category** : Catégories pour organiser le contenu
- **Event** : Événements avec géolocalisation
- **Tip** : Astuces culinaires
- **DinorTv** : Contenus vidéo
- **Page** : Pages web personnalisables

## 📞 Support

Pour toute question technique ou problème d'installation, consultez la documentation Laravel/Filament ou contactez l'équipe de développement.

## 📄 Licence

Ce projet est sous licence MIT. 