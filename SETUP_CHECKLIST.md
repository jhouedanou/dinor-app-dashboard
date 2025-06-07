# Checklist d'installation - Dinor Dashboard

## ✅ Fichiers créés/corrigés pour résoudre les erreurs Docker

### 🔧 Structure Laravel de base
- [x] `bootstrap/app.php` - Bootstrap de l'application Laravel
- [x] `app/Console/Kernel.php` - Kernel pour les commandes console
- [x] `app/Exceptions/Handler.php` - Gestionnaire d'exceptions

### 🔌 Providers Laravel
- [x] `app/Providers/AppServiceProvider.php` - Provider principal
- [x] `app/Providers/AuthServiceProvider.php` - Provider d'authentification
- [x] `app/Providers/BroadcastServiceProvider.php` - Provider de broadcast
- [x] `app/Providers/EventServiceProvider.php` - Provider d'événements
- [x] `app/Providers/RouteServiceProvider.php` - Provider de routes

### 🛣️ Routes
- [x] `routes/api.php` - Routes API (existait déjà, mis à jour)
- [x] `routes/web.php` - Routes web (existait déjà)
- [x] `routes/channels.php` - Canaux de broadcast
- [x] `routes/console.php` - Routes de console

### 🔒 Middlewares
- [x] `app/Http/Middleware/EnsureEmailIsVerified.php` - Vérification email

## 🎯 Système Likes et Commentaires

### 📊 Modèles
- [x] `app/Models/Like.php` - Modèle pour les likes
- [x] `app/Models/Comment.php` - Modèle pour les commentaires
- [x] `app/Models/User.php` - Modèle utilisateur standard

### 🔧 Traits
- [x] `app/Traits/Likeable.php` - Trait pour les contenus likables
- [x] `app/Traits/Commentable.php` - Trait pour les contenus commentables

### 🗄️ Migrations
- [x] `database/migrations/2024_01_01_000001_create_users_table.php`
- [x] `database/migrations/2024_01_15_000001_create_likes_table.php`
- [x] `database/migrations/2024_01_15_000002_create_comments_table.php`

### 🏭 Factories et Seeders
- [x] `database/factories/UserFactory.php`
- [x] `database/seeders/LikesAndCommentsSeeder.php`

### 🔌 API Controllers
- [x] `app/Http/Controllers/Api/LikeController.php`
- [x] `app/Http/Controllers/Api/CommentController.php`

### 🎨 Ressources Filament
- [x] `app/Filament/Resources/LikeResource.php`
- [x] `app/Filament/Resources/CommentResource.php`
- [x] Pages pour CommentResource (List, Create, View, Edit)
- [x] Pages pour LikeResource (List, View)

### 🔄 Intégration aux modèles existants
- [x] `app/Models/Recipe.php` - Ajout des traits Likeable et Commentable
- [x] `app/Models/Event.php` - Ajout des traits Likeable et Commentable
- [x] `app/Models/DinorTv.php` - Ajout des traits Likeable et Commentable

## 🚀 Commandes de déploiement

### 1. Construction Docker
```bash
docker compose up -d --build
```

### 2. Installation des dépendances (si conteneur lance)
```bash
docker exec -it dinor-app composer install
```

### 3. Configuration Laravel
```bash
docker exec -it dinor-app php artisan key:generate
docker exec -it dinor-app php artisan migrate
docker exec -it dinor-app php artisan storage:link
```

### 4. Données de test (optionnel)
```bash
docker exec -it dinor-app php artisan db:seed --class=LikesAndCommentsSeeder
```

## 🔍 Tests d'API

### Endpoints à tester :
1. `POST /api/v1/likes/toggle` - Toggle like
2. `GET /api/v1/likes/check?type=recipe&id=1` - Vérifier like
3. `GET /api/v1/comments?type=recipe&id=1` - Lister commentaires
4. `POST /api/v1/comments` - Ajouter commentaire

### Interface Admin à vérifier :
1. Navigation vers "Interactions > Likes"
2. Navigation vers "Interactions > Commentaires"
3. Modération des commentaires en attente

## 📱 Intégration Flutter

Utilisez la documentation dans `docs/API_LIKES_COMMENTS.md` pour l'intégration Flutter.

## 🐛 Si problèmes persistent

1. Vérifier les logs Docker : `docker compose logs app`
2. Entrer dans le conteneur : `docker exec -it dinor-app bash`
3. Vérifier les permissions : `chmod -R 755 storage bootstrap/cache`
4. Nettoyer le cache : `php artisan config:clear && php artisan cache:clear`

## 📞 Support

En cas de problème, vérifier dans l'ordre :
1. Les logs Docker
2. Les fichiers de configuration Laravel
3. Les permissions des dossiers
4. La version de PHP et des dépendances 