# 📖 Guide API Flutter — Dinor App

> **Base URL :** `https://new.dinorapp.com/api/v1`  
> **Dernière mise à jour :** 3 avril 2026  
> **Version API :** v1

---

## Table des matières

1. [Authentification](#-authentification)
2. [Recettes & Guides Audio](#-recettes--guides-audio)
3. [Commentaires avec Réponses Admin](#-commentaires-avec-réponses-admin)
4. [Modèles Dart suggérés](#-modèles-dart-suggérés)
5. [Résumé des endpoints](#-résumé-des-endpoints)
6. [Gestion des erreurs](#-gestion-des-erreurs)

---

## 🔑 Authentification

L'API utilise **Laravel Sanctum** (Bearer Token).

### Endpoints publics (pas de token requis)
- Liste/détail des recettes, événements, astuces, Dinor TV
- Lecture des commentaires
- Création de commentaires (anonyme ou connecté)

### Endpoints protégés (token requis)
Ajouter le header :
```
Authorization: Bearer {token}
```

### Login

```
POST https://new.dinorapp.com/api/v1/auth/login
```

**Body :**
```json
{
  "email": "user@example.com",
  "password": "motdepasse"
}
```

**Réponse :**
```json
{
  "success": true,
  "data": {
    "user": { "id": 1, "name": "Aminata", "email": "...", "role": "user" },
    "token": "1|abc123xyz..."
  }
}
```

---

## 🎧 Recettes & Guides Audio

### Lister les recettes

```
GET https://new.dinorapp.com/api/v1/recipes
```

**Paramètres query (optionnels) :**

| Param | Type | Description |
|---|---|---|
| `category_id` | `int` | Filtrer par catégorie |
| `difficulty` | `string` | `beginner`, `easy`, `medium`, `hard`, `expert` |
| `featured` | `bool` | Recettes mises en avant uniquement |
| `search` | `string` | Recherche dans titre et description |
| `per_page` | `int` | Nombre par page (défaut : 15) |

**Réponse :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Attiéké poisson braisé",
      "description": "Un classique ivoirien...",
      "featured_image_url": "https://new.dinorapp.com/storage/recipes/images/attieke.jpg",
      "audio_guide_url": "https://new.dinorapp.com/storage/recipes/audio-guides/attieke-guide.mp3",
      "cooking_time": 45,
      "servings": 4,
      "difficulty": "medium",
      "is_featured": true,
      "likes_count": 23,
      "is_liked": false,
      "is_favorited": false,
      "category": { "id": 1, "name": "Plats principaux" }
    }
  ],
  "pagination": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 42
  }
}
```

---

### Détail d'une recette (avec guides audio)

```
GET https://new.dinorapp.com/api/v1/recipes/{id}
```

**Authentification :** optionnelle (si connecté, `is_liked` et `is_favorited` sont personnalisés)

**Réponse complète :**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Attiéké poisson braisé",
    "slug": "attieke-poisson-braise",
    "description": "Un classique de la cuisine ivoirienne...",
    "featured_image_url": "https://new.dinorapp.com/storage/recipes/images/attieke.jpg",
    "gallery_urls": [
      "https://new.dinorapp.com/storage/recipes/gallery/img1.jpg",
      "https://new.dinorapp.com/storage/recipes/gallery/img2.jpg"
    ],
    "video_url": "https://www.youtube.com/watch?v=...",
    "summary_video_url": "https://www.youtube.com/watch?v=...",
    "video_thumbnail_url": "https://new.dinorapp.com/storage/recipes/thumbnails/thumb.jpg",

    "audio_guide_url": "https://new.dinorapp.com/storage/recipes/audio-guides/guide-general.mp3",

    "cooking_time": 45,
    "preparation_time": 20,
    "resting_time": 0,
    "servings": 4,
    "difficulty": "medium",
    "is_published": true,
    "is_featured": true,

    "category": {
      "id": 1,
      "name": "Plats principaux",
      "slug": "plats-principaux"
    },

    "ingredients": [
      {
        "name": "Attiéké",
        "quantity": "500",
        "unit": "g",
        "notes": "bien séché",
        "ingredient_id": 12,
        "category": "féculents"
      }
    ],

    "dinor_ingredients": [
      {
        "name": "Huile Dinor",
        "quantity": "3",
        "unit": "cuillères à soupe",
        "description": "Huile végétale premium",
        "brand": "Dinor",
        "purchase_url": "https://shop.dinor.ci/huile-dinor"
      }
    ],

    "instructions": [
      {
        "step_number": 1,
        "title": "Préparation",
        "step": "<p>Laver et préparer le poisson...</p>",
        "audio_guide": "recipes/audio-guides/step1.wav",
        "audio_guide_url": "https://new.dinorapp.com/storage/recipes/audio-guides/step1.wav"
      },
      {
        "step_number": 2,
        "title": "Cuisson",
        "step": "<p>Faire chauffer l'huile Dinor dans une poêle...</p>",
        "audio_guide": null,
        "audio_guide_url": null
      },
      {
        "step_number": 3,
        "title": "Service",
        "step": "<p>Disposer l'attiéké dans une assiette...</p>",
        "audio_guide": "recipes/audio-guides/step3.mp3",
        "audio_guide_url": "https://new.dinorapp.com/storage/recipes/audio-guides/step3.mp3"
      }
    ],

    "likes_count": 23,
    "comments_count": 5,
    "favorites_count": 8,
    "is_liked": false,
    "is_favorited": false,

    "approved_comments": [
      {
        "id": 1,
        "author_name": "Aminata Koné",
        "content": "J'adore cette recette !",
        "created_at": "2026-04-03T10:30:00.000000Z",
        "admin_reply": "Merci Aminata !",
        "admin_reply_by_name": "Admin Dinor",
        "admin_replied_at": "2026-04-03T14:00:00.000000Z"
      }
    ]
  }
}
```

### 🎵 Champs audio importants

| Champ | Niveau | Type | Description |
|---|---|---|---|
| `audio_guide_url` | **Recette** | `String?` | Guide audio **global** de la recette |
| `instructions[].audio_guide_url` | **Étape** | `String?` | Guide audio **par étape** |
| `instructions[].audio_guide` | **Étape** | `String?` | Chemin relatif (usage interne, ne pas utiliser en Flutter) |
| `instructions[].step_number` | **Étape** | `int` | Numéro de l'étape (commence à 1) |
| `instructions[].step` | **Étape** | `String` | Contenu HTML de l'étape |
| `instructions[].title` | **Étape** | `String?` | Titre optionnel de l'étape |

**Formats audio supportés :** MP3, WAV, OGG, M4A, AAC, WebM, MP4 audio.

### Implémentation Flutter audio

```dart
// Dépendance recommandée : just_audio (ou audioplayers)
// pubspec.yaml :
// dependencies:
//   just_audio: ^0.9.36

import 'package:just_audio/just_audio.dart';

class AudioGuidePlayer {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  void dispose() => _player.dispose();
}

// Utilisation dans un widget RecipeDetail :
if (recipe.audioGuideUrl != null) {
  // Afficher le lecteur audio global
  AudioGuidePlayer().play(recipe.audioGuideUrl!);
}

for (final instruction in recipe.instructions) {
  if (instruction.audioGuideUrl != null) {
    // Afficher un mini-lecteur sur cette étape
  }
}
```

---

### Recettes mises en avant

```
GET https://new.dinorapp.com/api/v1/recipes/featured/list
```

**Réponse :** même structure que la liste, limitée à 10 recettes.

---

### Catégories de recettes

```
GET https://new.dinorapp.com/api/v1/recipes/categories/list
```

**Réponse :**
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Plats principaux", "recipes_count": 15 },
    { "id": 2, "name": "Desserts", "recipes_count": 8 }
  ]
}
```

---

## 💬 Commentaires avec Réponses Admin

### Lister les commentaires d'un contenu

```
GET https://new.dinorapp.com/api/v1/comments?type={type}&id={id}
```

**Authentification :** non requise

**Paramètres query :**

| Param | Type | Requis | Valeurs possibles |
|---|---|---|---|
| `type` | `String` | ✅ | `recipe`, `event`, `dinor_tv`, `tip` |
| `id` | `int` | ✅ | ID du contenu |

> **Format alternatif :** `?commentable_type=App\Models\Recipe&commentable_id=1`

**Réponse :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "author_name": "Aminata Koné",
      "author_email": "aminata@example.com",
      "content": "J'adore cette recette ! Le plat est délicieux 🍲👏",
      "is_approved": true,
      "created_at": "2026-04-03T10:30:00.000000Z",
      "user": {
        "id": 5,
        "name": "Aminata Koné"
      },

      "admin_reply": "Merci Aminata ! N'hésitez pas à partager vos photos de réalisation.",
      "admin_reply_by_name": "Admin Dinor",
      "admin_replied_at": "2026-04-03T14:00:00.000000Z",

      "replies": [
        {
          "id": 3,
          "author_name": "Kouamé Jean-Baptiste",
          "content": "Je confirme, c'est délicieux !",
          "created_at": "2026-04-03T12:00:00.000000Z",
          "admin_reply": null,
          "admin_reply_by_name": null,
          "admin_replied_at": null,
          "user": { "id": 8, "name": "Kouamé Jean-Baptiste" }
        }
      ]
    },
    {
      "id": 2,
      "author_name": "Kouamé Jean-Baptiste",
      "content": "Peut-on remplacer l'huile Dinor par de l'huile de coco ?",
      "is_approved": true,
      "created_at": "2026-04-03T11:00:00.000000Z",
      "user": null,
      "admin_reply": null,
      "admin_reply_by_name": null,
      "admin_replied_at": null,
      "replies": []
    }
  ],
  "total": 2
}
```

### 🛡️ Champs réponse admin

| Champ | Type | Description |
|---|---|---|
| `admin_reply` | `String?` | Texte de la réponse admin. `null` = pas encore de réponse |
| `admin_reply_by_name` | `String?` | Nom de l'admin (`"Admin Dinor"` par défaut) |
| `admin_replied_at` | `String?` | Date ISO 8601 de la réponse (`"2026-04-03T14:00:00.000000Z"`) |

> **Note :** Ces champs sont présents sur les commentaires **et** sur leurs réponses imbriquées (`replies[]`).

---

### Créer un commentaire

```
POST https://new.dinorapp.com/api/v1/comments
```

**Authentification :** optionnelle

#### Utilisateur connecté (avec token)

**Headers :**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body :**
```json
{
  "type": "recipe",
  "id": 1,
  "content": "Super recette, merci Dinor !"
}
```

> Le nom et l'email sont automatiquement remplis depuis le profil utilisateur.

#### Utilisateur anonyme (sans token)

**Body :**
```json
{
  "type": "recipe",
  "id": 1,
  "content": "Super recette !",
  "author_name": "Konan Yao",
  "author_email": "konan@email.com"
}
```

#### Répondre à un commentaire existant

Ajouter `parent_id` au body :
```json
{
  "type": "recipe",
  "id": 1,
  "content": "Tout à fait d'accord !",
  "parent_id": 1
}
```

**Réponse (201) :**
```json
{
  "success": true,
  "data": {
    "id": 4,
    "author_name": "Konan Yao",
    "content": "Super recette, merci Dinor !",
    "is_approved": true,
    "created_at": "2026-04-03T15:30:00.000000Z",
    "user": { "id": 10, "name": "Konan Yao" }
  },
  "message": "Commentaire ajouté avec succès"
}
```

---

### Répondre en tant qu'admin 🔒

```
POST https://new.dinorapp.com/api/v1/comments/{comment_id}/admin-reply
```

**Authentification :** requise — **admin uniquement**

**Headers :**
```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Body :**
```json
{
  "admin_reply": "Merci pour votre retour ! Nous sommes ravis que la recette vous plaise."
}
```

**Validation :**
- `admin_reply` : requis, string, min 3 caractères, max 2000 caractères

**Réponse (200) :**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "admin_reply": "Merci pour votre retour ! Nous sommes ravis que la recette vous plaise.",
    "admin_reply_by_name": "Admin Dinor",
    "admin_replied_at": "2026-04-03T16:00:00.000000Z"
  },
  "message": "Réponse admin enregistrée avec succès"
}
```

**Erreurs :**
| Code | Raison |
|---|---|
| `401` | Token manquant ou invalide |
| `403` | L'utilisateur n'est pas admin |
| `404` | Commentaire non trouvé |
| `422` | Validation : `admin_reply` requis, min 3, max 2000 |

---

### Récupérer les réponses d'un commentaire

```
GET https://new.dinorapp.com/api/v1/comments/{comment_id}/replies
```

**Réponse :**
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "author_name": "Kouamé",
      "content": "Je confirme !",
      "created_at": "2026-04-03T12:00:00.000000Z",
      "user": { "id": 8, "name": "Kouamé" }
    }
  ]
}
```

---

### Modifier un commentaire 🔒

```
PUT https://new.dinorapp.com/api/v1/comments/{comment_id}
```

**Authentification :** requise (auteur du commentaire uniquement)

**Body :**
```json
{
  "content": "Texte modifié du commentaire"
}
```

---

### Supprimer un commentaire 🔒

```
DELETE https://new.dinorapp.com/api/v1/comments/{comment_id}
```

**Authentification :** requise (auteur du commentaire uniquement)

---

## 📱 Modèles Dart suggérés

```dart
// ===== Comment Model =====
class Comment {
  final int id;
  final String authorName;
  final String? authorEmail;
  final String content;
  final bool isApproved;
  final DateTime createdAt;
  final CommentUser? user;

  // Réponse admin
  final String? adminReply;
  final String? adminReplyByName;
  final DateTime? adminRepliedAt;

  // Réponses imbriquées
  final List<Comment> replies;

  bool get hasAdminReply => adminReply != null && adminReply!.isNotEmpty;

  Comment({
    required this.id,
    required this.authorName,
    this.authorEmail,
    required this.content,
    this.isApproved = true,
    required this.createdAt,
    this.user,
    this.adminReply,
    this.adminReplyByName,
    this.adminRepliedAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      authorName: json['author_name'] ?? 'Anonyme',
      authorEmail: json['author_email'],
      content: json['content'],
      isApproved: json['is_approved'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
      adminReply: json['admin_reply'],
      adminReplyByName: json['admin_reply_by_name'],
      adminRepliedAt: json['admin_replied_at'] != null
          ? DateTime.parse(json['admin_replied_at'])
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => Comment.fromJson(r)).toList()
          : [],
    );
  }
}

class CommentUser {
  final int id;
  final String name;

  CommentUser({required this.id, required this.name});

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(id: json['id'], name: json['name']);
  }
}

// ===== Recipe Instruction Model =====
class RecipeInstruction {
  final int stepNumber;
  final String? title;
  final String step; // Contenu HTML
  final String? audioGuideUrl;

  bool get hasAudioGuide => audioGuideUrl != null && audioGuideUrl!.isNotEmpty;

  RecipeInstruction({
    required this.stepNumber,
    this.title,
    required this.step,
    this.audioGuideUrl,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) {
    return RecipeInstruction(
      stepNumber: json['step_number'] ?? 1,
      title: json['title'],
      step: json['step'] ?? '',
      audioGuideUrl: json['audio_guide_url'],
    );
  }
}

// ===== Recipe Model =====
class Recipe {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final String? featuredImageUrl;
  final List<String> galleryUrls;
  final String? videoUrl;
  final String? summaryVideoUrl;
  final String? audioGuideUrl; // 🎧 Guide audio global
  final int cookingTime;
  final int preparationTime;
  final int restingTime;
  final int servings;
  final String? difficulty;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isFavorited;
  final List<RecipeInstruction> instructions;
  final List<Comment> approvedComments;

  bool get hasGlobalAudioGuide =>
      audioGuideUrl != null && audioGuideUrl!.isNotEmpty;

  bool get hasAnyAudioGuide =>
      hasGlobalAudioGuide ||
      instructions.any((i) => i.hasAudioGuide);

  Recipe({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.featuredImageUrl,
    this.galleryUrls = const [],
    this.videoUrl,
    this.summaryVideoUrl,
    this.audioGuideUrl,
    this.cookingTime = 0,
    this.preparationTime = 0,
    this.restingTime = 0,
    this.servings = 1,
    this.difficulty,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.instructions = const [],
    this.approvedComments = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'],
      description: json['description'],
      featuredImageUrl: json['featured_image_url'],
      galleryUrls: json['gallery_urls'] != null
          ? List<String>.from(json['gallery_urls'])
          : [],
      videoUrl: json['video_url'],
      summaryVideoUrl: json['summary_video_url'],
      audioGuideUrl: json['audio_guide_url'],
      cookingTime: json['cooking_time'] ?? 0,
      preparationTime: json['preparation_time'] ?? 0,
      restingTime: json['resting_time'] ?? 0,
      servings: json['servings'] ?? 1,
      difficulty: json['difficulty'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isFavorited: json['is_favorited'] ?? false,
      instructions: json['instructions'] != null
          ? (json['instructions'] as List)
              .map((i) => RecipeInstruction.fromJson(i))
              .toList()
          : [],
      approvedComments: json['approved_comments'] != null
          ? (json['approved_comments'] as List)
              .map((c) => Comment.fromJson(c))
              .toList()
          : [],
    );
  }
}
```

---

## 📋 Résumé des endpoints

### Recettes

| Méthode | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/recipes` | ❌ | Liste paginée des recettes |
| `GET` | `/recipes/{id}` | ⭕ | Détail avec audio, commentaires, instructions |
| `GET` | `/recipes/featured/list` | ❌ | Top 10 recettes mises en avant |
| `GET` | `/recipes/categories/list` | ❌ | Catégories avec nombre de recettes |

### Commentaires

| Méthode | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/comments?type=recipe&id=1` | ❌ | Commentaires avec réponses admin |
| `GET` | `/comments/{id}/replies` | ❌ | Réponses à un commentaire |
| `POST` | `/comments` | ⭕ | Créer un commentaire |
| `PUT` | `/comments/{id}` | 🔒 | Modifier son commentaire |
| `DELETE` | `/comments/{id}` | 🔒 | Supprimer son commentaire |
| `POST` | `/comments/{id}/admin-reply` | 🔒🛡️ | Répondre en tant qu'admin |

**Légende :** ❌ = non requis · ⭕ = optionnel · 🔒 = requis · 🛡️ = admin uniquement

---

## ⚠️ Gestion des erreurs

Toutes les erreurs suivent le même format :

```json
{
  "success": false,
  "message": "Description de l'erreur"
}
```

### Codes HTTP courants

| Code | Signification |
|---|---|
| `200` | Succès |
| `201` | Ressource créée (commentaire, etc.) |
| `400` | Requête invalide (type/id manquant ou incorrect) |
| `401` | Non authentifié (token manquant ou expiré) |
| `403` | Non autorisé (pas admin, pas propriétaire) |
| `404` | Ressource non trouvée |
| `422` | Erreur de validation (champs requis manquants) |
| `429` | Rate limit atteint (trop de requêtes) |

### Erreur de validation (422)

```json
{
  "success": false,
  "message": "Erreur de validation",
  "errors": {
    "content": ["Le champ contenu est obligatoire."],
    "admin_reply": ["Le champ admin_reply doit contenir au moins 3 caractères."]
  }
}
```

---

## 🧪 Exemples cURL rapides

### Récupérer une recette avec audio
```bash
curl -s https://new.dinorapp.com/api/v1/recipes/1 | jq '.data.audio_guide_url, .data.instructions[].audio_guide_url'
```

### Lister les commentaires d'une recette
```bash
curl -s "https://new.dinorapp.com/api/v1/comments?type=recipe&id=1" | jq '.data[] | {author: .author_name, reply: .admin_reply}'
```

### Publier une réponse admin
```bash
curl -X POST https://new.dinorapp.com/api/v1/comments/1/admin-reply \
  -H "Authorization: Bearer {ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"admin_reply": "Merci pour votre commentaire !"}'
```

---

> **Contact technique :** Pour toute question sur l'API, consulter les fichiers source :  
> - `app/Http/Controllers/Api/RecipeController.php`  
> - `app/Http/Controllers/Api/CommentController.php`  
> - `routes/api.php`
