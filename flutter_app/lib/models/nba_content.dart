/**
 * NBA_CONTENT.DART - MODÈLES DE DONNÉES POUR LE CONTENU NBA
 * 
 * FONCTIONNALITÉS :
 * - Modèles pour différents types de contenu NBA
 * - Système de tags hiérarchisé (principal vs secondaire)
 * - Métadonnées pour l'algorithme de recommandation
 * - Support pour équipes, joueurs, statistiques, matchs
 */

import 'dart:convert';

// Énumération des types de contenu NBA
enum NBAContentType {
  video('video'),
  article('article'),
  highlight('highlight'),
  analysis('analysis'),
  news('news'),
  interview('interview'),
  recap('recap');

  const NBAContentType(this.value);
  final String value;

  static NBAContentType fromString(String value) {
    return NBAContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NBAContentType.article,
    );
  }
}

// Énumération des priorités de tags
enum TagPriority {
  primary(1.0),    // Tag principal (équipe, joueur star)
  secondary(0.7),  // Tag secondaire (position, saison)
  tertiary(0.4);   // Tag tertiaire (statistique générale)

  const TagPriority(this.weight);
  final double weight;
}

// Modèle pour un tag NBA
class NBATag {
  final String id;
  final String name;
  final String category; // 'team', 'player', 'stat', 'season', 'position'
  final TagPriority priority;
  final Map<String, dynamic>? metadata; // Infos supplémentaires

  const NBATag({
    required this.id,
    required this.name,
    required this.category,
    required this.priority,
    this.metadata,
  });

  factory NBATag.fromJson(Map<String, dynamic> json) {
    return NBATag(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'general',
      priority: _parsePriority(json['priority']),
      metadata: json['metadata'],
    );
  }

  static TagPriority _parsePriority(dynamic priority) {
    if (priority is String) {
      switch (priority.toLowerCase()) {
        case 'primary':
          return TagPriority.primary;
        case 'secondary':
          return TagPriority.secondary;
        case 'tertiary':
          return TagPriority.tertiary;
        default:
          return TagPriority.secondary;
      }
    }
    return TagPriority.secondary;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'priority': priority.name,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NBATag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Modèle pour le contenu NBA
class NBAContent {
  final String id;
  final String title;
  final String description;
  final NBAContentType type;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? galleryUrls;
  final List<NBATag> tags;
  final DateTime publishedAt;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final Duration? duration; // Pour les vidéos
  final String? author;
  final double popularityScore; // Score de popularité (0-100)
  final bool isViewed; // Si l'utilisateur a déjà vu
  final bool isLiked; // Si l'utilisateur a liké

  const NBAContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    this.videoUrl,
    this.galleryUrls,
    required this.tags,
    required this.publishedAt,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.duration,
    this.author,
    this.popularityScore = 0.0,
    this.isViewed = false,
    this.isLiked = false,
  });

  factory NBAContent.fromJson(Map<String, dynamic> json) {
    return NBAContent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? json['content'] ?? '',
      type: NBAContentType.fromString(json['type'] ?? json['content_type'] ?? 'article'),
      imageUrl: json['image_url'] ?? json['featured_image_url'] ?? json['thumbnail'],
      videoUrl: json['video_url'] ?? json['url'],
      galleryUrls: _parseGalleryUrls(json['gallery_urls']),
      tags: _parseTags(json['tags']),
      publishedAt: DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      views: json['views'] ?? 0,
      likes: json['likes_count'] ?? json['likes'] ?? 0,
      comments: json['comments_count'] ?? json['comments'] ?? 0,
      shares: json['shares_count'] ?? json['shares'] ?? 0,
      duration: _parseDuration(json['duration']),
      author: json['author'] ?? json['user_name'],
      popularityScore: (json['popularity_score'] ?? 0.0).toDouble(),
      isViewed: json['is_viewed'] ?? false,
      isLiked: json['is_liked'] ?? false,
    );
  }

  static List<NBATag> _parseTags(dynamic tagsData) {
    if (tagsData == null) return [];
    
    List<NBATag> tags = [];
    
    if (tagsData is List) {
      for (var tagData in tagsData) {
        if (tagData is Map<String, dynamic>) {
          tags.add(NBATag.fromJson(tagData));
        } else if (tagData is String) {
          // Tag simple en string - convertir en NBATag
          tags.add(NBATag(
            id: tagData.toLowerCase().replaceAll(' ', '_'),
            name: tagData,
            category: _inferTagCategory(tagData),
            priority: TagPriority.secondary,
          ));
        }
      }
    } else if (tagsData is String) {
      // Tag unique
      tags.add(NBATag(
        id: tagsData.toLowerCase().replaceAll(' ', '_'),
        name: tagsData,
        category: _inferTagCategory(tagsData),
        priority: TagPriority.secondary,
      ));
    }
    
    return tags;
  }

  static List<String>? _parseGalleryUrls(dynamic galleryUrls) {
    if (galleryUrls == null) return null;
    
    if (galleryUrls is List) {
      return galleryUrls.map((url) => url.toString()).toList();
    }
    
    return null;
  }

  static String _inferTagCategory(String tagName) {
    final lowerTag = tagName.toLowerCase();
    
    // Équipes NBA (quelques exemples)
    if (lowerTag.contains('lakers') || lowerTag.contains('warriors') || 
        lowerTag.contains('celtics') || lowerTag.contains('bulls') ||
        lowerTag.contains('heat') || lowerTag.contains('nets')) {
      return 'team';
    }
    
    // Joueurs (détection basique)
    if (lowerTag.contains('lebron') || lowerTag.contains('curry') || 
        lowerTag.contains('durant') || lowerTag.contains('james') ||
        lowerTag.contains('davis') || lowerTag.contains('leonard')) {
      return 'player';
    }
    
    // Statistiques
    if (lowerTag.contains('points') || lowerTag.contains('rebounds') || 
        lowerTag.contains('assists') || lowerTag.contains('blocks') ||
        lowerTag.contains('steals') || lowerTag.contains('shooting')) {
      return 'stat';
    }
    
    // Positions
    if (lowerTag.contains('guard') || lowerTag.contains('forward') || 
        lowerTag.contains('center') || lowerTag.contains('pg') ||
        lowerTag.contains('sg') || lowerTag.contains('sf') ||
        lowerTag.contains('pf') || lowerTag.contains('c')) {
      return 'position';
    }
    
    // Saisons
    if (lowerTag.contains('2024') || lowerTag.contains('2023') || 
        lowerTag.contains('season') || lowerTag.contains('playoff')) {
      return 'season';
    }
    
    return 'general';
  }

  static Duration? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    
    if (duration is int) {
      return Duration(seconds: duration);
    }
    
    if (duration is String) {
      // Format "5:30" ou "120"
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          return Duration(minutes: minutes, seconds: seconds);
        }
      } else {
        final seconds = int.tryParse(duration) ?? 0;
        return Duration(seconds: seconds);
      }
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'gallery_urls': galleryUrls,
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'published_at': publishedAt.toIso8601String(),
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'duration': duration?.inSeconds,
      'author': author,
      'popularity_score': popularityScore,
      'is_viewed': isViewed,
      'is_liked': isLiked,
    };
  }

  // Obtenir les tags par catégorie
  List<NBATag> getTagsByCategory(String category) {
    return tags.where((tag) => tag.category == category).toList();
  }

  // Obtenir les tags par priorité
  List<NBATag> getTagsByPriority(TagPriority priority) {
    return tags.where((tag) => tag.priority == priority).toList();
  }

  // Calculer le score de fraîcheur (0-100)
  double get freshnessScore {
    final now = DateTime.now();
    final daysSincePublished = now.difference(publishedAt).inDays;
    
    if (daysSincePublished <= 1) return 100.0;
    if (daysSincePublished <= 7) return 80.0;
    if (daysSincePublished <= 30) return 60.0;
    if (daysSincePublished <= 90) return 40.0;
    return 20.0;
  }

  // Calculer le score total pour l'algorithme de recommandation
  double calculateRecommendationScore({
    double similarityScore = 0.0,
    double popularityWeight = 0.2,
    double freshnessWeight = 0.1,
    double similarityWeight = 0.7,
  }) {
    final popularity = popularityScore;
    final freshness = freshnessScore;
    
    return (similarityScore * similarityWeight) +
           (popularity * popularityWeight) +
           (freshness * freshnessWeight);
  }

  // Obtenir une représentation courte de la durée
  String get formattedDuration {
    if (duration == null) return '';
    
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }

  // Obtenir le nom de l'équipe principale (premier tag équipe)
  String? get primaryTeam {
    final teamTags = getTagsByCategory('team');
    return teamTags.isNotEmpty ? teamTags.first.name : null;
  }

  // Obtenir le joueur principal (premier tag joueur)
  String? get primaryPlayer {
    final playerTags = getTagsByCategory('player');
    return playerTags.isNotEmpty ? playerTags.first.name : null;
  }

  NBAContent copyWith({
    String? id,
    String? title,
    String? description,
    NBAContentType? type,
    String? imageUrl,
    String? videoUrl,
    List<String>? galleryUrls,
    List<NBATag>? tags,
    DateTime? publishedAt,
    int? views,
    int? likes,
    int? comments,
    int? shares,
    Duration? duration,
    String? author,
    double? popularityScore,
    bool? isViewed,
    bool? isLiked,
  }) {
    return NBAContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      tags: tags ?? this.tags,
      publishedAt: publishedAt ?? this.publishedAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      duration: duration ?? this.duration,
      author: author ?? this.author,
      popularityScore: popularityScore ?? this.popularityScore,
      isViewed: isViewed ?? this.isViewed,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

// Modèle pour les recommandations
class NBARecommendation {
  final NBAContent content;
  final double score;
  final double similarityScore;
  final List<String> matchingTags;
  final String reason; // Raison de la recommandation

  const NBARecommendation({
    required this.content,
    required this.score,
    required this.similarityScore,
    required this.matchingTags,
    required this.reason,
  });

  factory NBARecommendation.fromContent({
    required NBAContent content,
    required double similarityScore,
    required List<String> matchingTags,
    String? reason,
  }) {
    final score = content.calculateRecommendationScore(
      similarityScore: similarityScore,
    );
    
    final defaultReason = _generateReason(content, matchingTags);
    
    return NBARecommendation(
      content: content,
      score: score,
      similarityScore: similarityScore,
      matchingTags: matchingTags,
      reason: reason ?? defaultReason,
    );
  }

  static String _generateReason(NBAContent content, List<String> matchingTags) {
    if (matchingTags.isEmpty) return 'Contenu populaire';
    
    if (matchingTags.length == 1) {
      return 'Basé sur ${matchingTags.first}';
    } else if (matchingTags.length <= 3) {
      return 'Basé sur ${matchingTags.join(', ')}';
    } else {
      return 'Basé sur ${matchingTags.take(2).join(', ')} et ${matchingTags.length - 2} autres';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
      'score': score,
      'similarity_score': similarityScore,
      'matching_tags': matchingTags,
      'reason': reason,
    };
  }
} 