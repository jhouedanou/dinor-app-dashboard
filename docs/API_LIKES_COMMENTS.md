# API Likes et Commentaires - Dinor Dashboard

## 🎯 Vue d'ensemble

Le système de likes et commentaires permet aux utilisateurs de l'application mobile Dinor d'interagir avec le contenu (recettes, événements, vidéos Dinor TV).

## 🔧 Fonctionnalités

### Likes
- ✅ Like/Unlike pour tous les types de contenu
- ✅ Support utilisateurs connectés et anonymes (par IP)
- ✅ Comptage automatique des likes
- ✅ Vérification du statut de like
- ✅ Gestion admin dans Filament

### Commentaires
- ✅ Commentaires avec réponses (système hiérarchique)
- ✅ Support utilisateurs connectés et anonymes
- ✅ Modération des commentaires (approbation)
- ✅ Modification/suppression par l'auteur
- ✅ Gestion admin complète dans Filament

## 📡 Endpoints API

### Likes

#### Toggle Like
```http
POST /api/v1/likes/toggle
Content-Type: application/json

{
    "type": "recipe|event|dinor_tv",
    "id": 1
}
```

**Réponse :**
```json
{
    "success": true,
    "action": "liked|unliked",
    "likes_count": 15,
    "message": "Contenu aimé"
}
```

#### Vérifier le statut de like
```http
GET /api/v1/likes/check?type=recipe&id=1
```

**Réponse :**
```json
{
    "success": true,
    "is_liked": true,
    "likes_count": 15
}
```

#### Lister les likes d'un contenu
```http
GET /api/v1/likes?type=recipe&id=1
```

**Réponse :**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "user": {
                "id": 1,
                "name": "John Doe"
            },
            "created_at": "2024-01-15T10:30:00Z"
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 15
    }
}
```

### Commentaires

#### Lister les commentaires
```http
GET /api/v1/comments?type=recipe&id=1&per_page=10
```

**Réponse :**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "content": "Excellente recette !",
            "author_name": "John Doe",
            "user": {
                "id": 1,
                "name": "John Doe"
            },
            "created_at": "2024-01-15T10:30:00Z",
            "replies": [
                {
                    "id": 2,
                    "content": "Je suis d'accord !",
                    "author_name": "Jane Smith",
                    "created_at": "2024-01-15T11:00:00Z"
                }
            ]
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 2,
        "per_page": 10,
        "total": 25
    }
}
```

#### Ajouter un commentaire
```http
POST /api/v1/comments
Content-Type: application/json

{
    "type": "recipe",
    "id": 1,
    "content": "Merci pour cette recette !",
    "author_name": "John Doe",
    "author_email": "john@example.com",
    "parent_id": null
}
```

**Réponse :**
```json
{
    "success": true,
    "data": {
        "id": 3,
        "content": "Merci pour cette recette !",
        "author_name": "John Doe",
        "created_at": "2024-01-15T12:00:00Z"
    },
    "message": "Commentaire ajouté avec succès"
}
```

#### Modifier un commentaire (authentifié)
```http
PUT /api/v1/comments/3
Authorization: Bearer {token}
Content-Type: application/json

{
    "content": "Merci pour cette excellente recette !"
}
```

#### Supprimer un commentaire (authentifié)
```http
DELETE /api/v1/comments/3
Authorization: Bearer {token}
```

#### Lister les réponses d'un commentaire
```http
GET /api/v1/comments/1/replies
```

## 🔐 Authentification

- **Likes** : Aucune authentification requise (support anonyme par IP)
- **Commentaires** : 
  - Lecture : Aucune authentification requise
  - Création : Aucune authentification requise (support anonyme)
  - Modification/Suppression : Authentification requise (Sanctum)

## 🎨 Intégration Flutter

### Exemple d'utilisation des likes

```dart
class LikeService {
  static const String baseUrl = 'http://votre-domaine.com/api/v1';

  // Toggle like
  static Future<Map<String, dynamic>> toggleLike(String type, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/likes/toggle'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'type': type,
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Erreur lors du toggle like');
  }

  // Vérifier le statut de like
  static Future<bool> checkLikeStatus(String type, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/likes/check?type=$type&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_liked'];
    }
    return false;
  }
}
```

### Exemple d'utilisation des commentaires

```dart
class CommentService {
  static const String baseUrl = 'http://votre-domaine.com/api/v1';

  // Récupérer les commentaires
  static Future<List<Comment>> getComments(String type, int id, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments?type=$type&id=$id&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList();
    }
    throw Exception('Erreur lors du chargement des commentaires');
  }

  // Ajouter un commentaire
  static Future<Comment> addComment(String type, int id, String content, 
      {String? authorName, String? authorEmail, int? parentId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'type': type,
        'id': id,
        'content': content,
        'author_name': authorName,
        'author_email': authorEmail,
        'parent_id': parentId,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Comment.fromJson(data['data']);
    }
    throw Exception('Erreur lors de l\'ajout du commentaire');
  }
}
```

### Widget Flutter pour les likes

```dart
class LikeButton extends StatefulWidget {
  final String contentType;
  final int contentId;
  final int initialLikesCount;

  const LikeButton({
    Key? key,
    required this.contentType,
    required this.contentId,
    required this.initialLikesCount,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;
  int likesCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    likesCount = widget.initialLikesCount;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    try {
      isLiked = await LikeService.checkLikeStatus(widget.contentType, widget.contentId);
      setState(() {});
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await LikeService.toggleLike(widget.contentType, widget.contentId);
      setState(() {
        isLiked = result['action'] == 'liked';
        likesCount = result['likes_count'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du like')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: isLoading ? null : _toggleLike,
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
        ),
        Text('$likesCount'),
      ],
    );
  }
}
```

## 🛠️ Administration Filament

### Gestion des commentaires
- **Navigation** : Interactions > Commentaires
- **Fonctionnalités** :
  - Approbation/rejet en masse
  - Filtrage par type de contenu
  - Modération des commentaires en attente
  - Badge de notification pour les commentaires en attente

### Gestion des likes
- **Navigation** : Interactions > Likes
- **Fonctionnalités** :
  - Vue d'ensemble de tous les likes
  - Filtrage par type de contenu
  - Statistiques en temps réel
  - Suppression si nécessaire

## 📊 Statistiques

Les modèles Recipe, Event et DinorTv incluent automatiquement :
- `likes_count` : Nombre total de likes
- `comments_count` : Nombre total de commentaires approuvés
- Méthodes pour récupérer les contenus les plus aimés/commentés

## 🔧 Configuration

### Variables d'environnement
Aucune configuration spéciale requise. Le système utilise la configuration Laravel standard.

### Modération automatique
Par défaut, les commentaires sont auto-approuvés. Pour activer la modération :

```php
// Dans CommentController@store
'is_approved' => false, // Changer à false pour modération manuelle
```

## 🚀 Déploiement

1. Exécuter les migrations :
```bash
php artisan migrate
```

2. (Optionnel) Peupler avec des données de test :
```bash
php artisan db:seed --class=LikesAndCommentsSeeder
```

3. Vérifier les routes API :
```bash
php artisan route:list --path=api/v1
```

## 🐛 Dépannage

### Erreurs courantes

1. **Erreur 404 sur les routes** : Vérifier que les routes sont bien définies dans `routes/api.php`

2. **Erreur de validation** : S'assurer que les paramètres `type` et `id` sont corrects

3. **Problème de permissions** : Vérifier l'authentification Sanctum pour les routes protégées

4. **Likes dupliqués** : Le système empêche automatiquement les likes multiples par utilisateur/IP

### Logs utiles
```bash
# Voir les logs Laravel
tail -f storage/logs/laravel.log

# Voir les requêtes SQL
# Activer DB::enableQueryLog() dans AppServiceProvider
``` 