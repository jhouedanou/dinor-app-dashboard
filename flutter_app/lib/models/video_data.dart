/**
 * VIDEO_DATA.DART - MODÈLE DE DONNÉES VIDÉO
 * 
 * Modèle pour représenter les données vidéo de Dinor TV
 * Extrait de tiktok_style_video_screen.dart pour une meilleure modularité
 */

class VideoData {
  final String id;
  final String title;
  final String description;
  final String author;
  final String? authorAvatar;
  final String videoUrl;
  final String? thumbnailUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int views;
  final bool isLiked;
  final bool isFavorited;
  final Duration? duration;
  final List<String> tags;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    this.authorAvatar,
    required this.videoUrl,
    this.thumbnailUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.views = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.duration,
    this.tags = const [],
    required this.createdAt,
    this.metadata,
  });

  // Factory constructor pour créer depuis JSON API
  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? json['user_name'] ?? json['channel_name'] ?? 'Dinor',
      authorAvatar: json['author_avatar'] ?? json['user_avatar'],
      videoUrl: json['video_url'] ?? json['url'] ?? '',
      thumbnailUrl: json['thumbnail'] ?? 
                    json['thumbnail_url'] ?? 
                    json['image'] ?? 
                    json['image_url'] ?? 
                    json['featured_image'] ?? 
                    json['featured_image_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      views: json['views'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isFavorited: json['is_favorited'] ?? false,
      duration: json['duration'] != null ? 
        Duration(seconds: int.tryParse(json['duration'].toString()) ?? 0) : null,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  // Converter vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'author_avatar': authorAvatar,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views': views,
      'is_liked': isLiked,
      'is_favorited': isFavorited,
      'duration': duration?.inSeconds,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // CopyWith pour modifications immutables
  VideoData copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? authorAvatar,
    String? videoUrl,
    String? thumbnailUrl,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? views,
    bool? isLiked,
    bool? isFavorited,
    Duration? duration,
    List<String>? tags,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return VideoData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'VideoData(id: $id, title: $title, author: $author, views: $views, likes: $likesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 