/// VIDEO_SERVICE.DART - SERVICE DE GESTION DES VIDÉOS
/// 
/// FONCTIONNALITÉS :
/// - Récupération des vidéos depuis l'API Dinor TV
/// - Conversion en modèle VideoData
/// - Cache intelligent des vidéos
/// - Préchargement des thumbnails YouTube pour affichage instantané
/// - Gestion des interactions (likes, vues, partages)
/// - Optimisation pour performance et préchargement
library;

import 'dart:convert';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Models
import '../models/video_data.dart';

import 'local_database_service.dart';

class VideoState {
  final List<VideoData> videos;
  final bool isLoading;
  final String? error;
  final int? currentIndex;

  const VideoState({
    this.videos = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex,
  });

  VideoState copyWith({
    List<VideoData>? videos,
    bool? isLoading,
    String? error,
    int? currentIndex,
  }) {
    return VideoState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class VideoService extends StateNotifier<VideoState> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  final LocalDatabaseService _localDB;

  VideoService(this._localDB) : super(const VideoState());

  // Charger les vidéos depuis l'API
  Future<void> loadVideos({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🎥 [VideoService] Chargement des vidéos...');

      // Charger depuis le cache d'abord si pas de refresh forcé
      if (!forceRefresh) {
        final cachedVideos = await _loadFromCache();
        if (cachedVideos.isNotEmpty) {
          state = state.copyWith(
            videos: cachedVideos,
            isLoading: false,
          );
          print('📱 [VideoService] ${cachedVideos.length} vidéos chargées depuis le cache');
        }
      }

      // Charger depuis l'API
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dinor-tv'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videosData = data['data'] ?? [];

        final videos = await _convertToVideoData(videosData);
        
        // Filtrer les vidéos sans URL valide
        final validVideos = videos.where((video) => 
          video.videoUrl.isNotEmpty && _isValidVideoUrl(video.videoUrl)
        ).toList();

        state = state.copyWith(
          videos: validVideos,
          isLoading: false,
          error: null,
        );

        // Sauvegarder en cache
        await _saveToCache(validVideos);
        
        // Précharger les thumbnails YouTube pour un affichage instantané
        _precacheYouTubeThumbnails(validVideos);

        print('✅ [VideoService] ${validVideos.length} vidéos chargées et mises en cache');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [VideoService] Erreur chargement vidéos: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Convertir les données API en VideoData
  Future<List<VideoData>> _convertToVideoData(List<dynamic> apiData) async {
    final videos = <VideoData>[];

    for (final item in apiData) {
      try {
        // Extraire l'URL vidéo depuis différents champs possibles
        String? videoUrl = _extractVideoUrl(item);
        
        if (videoUrl == null || videoUrl.isEmpty) {
          print('⚠️ [VideoService] Vidéo sans URL valide: ${item['title']}');
          continue;
        }

        // Convertir les URLs YouTube embed en URLs normales si nécessaire
        videoUrl = _convertYouTubeUrl(videoUrl);

        final video = VideoData(
          id: item['id']?.toString() ?? '',
          title: item['title'] ?? 'Vidéo sans titre',
          description: item['description'] ?? item['excerpt'] ?? '',
          author: item['author'] ?? item['user_name'] ?? 'Dinor',
          authorAvatar: item['author_avatar'] ?? item['user_avatar'],
          videoUrl: videoUrl,
          thumbnailUrl: item['thumbnail'] ?? item['image'] ?? item['featured_image'],
          likesCount: item['likes_count'] ?? 0,
          commentsCount: item['comments_count'] ?? 0,
          sharesCount: item['shares_count'] ?? 0,
          views: item['views'] ?? 0,
          isLiked: item['is_liked'] ?? false,
          isFavorited: item['is_favorited'] ?? false,
          duration: _parseDuration(item['duration']),
          tags: List<String>.from(item['tags'] ?? []),
          createdAt: item['created_at'] != null 
            ? DateTime.parse(item['created_at']) 
            : DateTime.now(),
          metadata: item, // Store the entire API response in metadata for custom image access
        );

        videos.add(video);
      } catch (e) {
        print('❌ [VideoService] Erreur conversion vidéo: $e');
        continue;
      }
    }

    return videos;
  }

  // Extraire l'URL vidéo depuis différents champs
  String? _extractVideoUrl(Map<String, dynamic> item) {
    // Essayer différents champs possibles
    final possibleFields = [
      'video_url',
      'url',
      'youtube_url',
      'embed_url',
      'media_url',
    ];

    for (final field in possibleFields) {
      final url = item[field];
      if (url != null && url.toString().trim().isNotEmpty) {
        return url.toString().trim();
      }
    }

    return null;
  }

  // Convertir les URLs YouTube
  String _convertYouTubeUrl(String url) {
    // Si c'est une URL embed YouTube, la convertir
    if (url.contains('youtube.com/embed/') || url.contains('youtu.be/')) {
      final videoIdRegex = RegExp(r'(?:youtube\.com\/embed\/|youtu\.be\/)([a-zA-Z0-9_-]+)');
      final match = videoIdRegex.firstMatch(url);
      
      if (match != null) {
        final videoId = match.group(1);
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }

    return url;
  }

  // Précharger les thumbnails YouTube pour un affichage instantané dans les listes
  void _precacheYouTubeThumbnails(List<VideoData> videos) {
    for (final video in videos) {
      final videoId = YoutubePlayer.convertUrlToId(video.videoUrl);
      if (videoId != null) {
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        // Précharger l'image dans le cache Flutter (NetworkImage)
        // Cela permet un affichage instantané quand le widget s'affiche
        final imageProvider = NetworkImage(thumbnailUrl);
        imageProvider.resolve(const ImageConfiguration());
      }
    }
    print('🖼️ [VideoService] Thumbnails YouTube préchargées pour ${videos.length} vidéos');
  }

  // Vérifier si l'URL vidéo est valide
  bool _isValidVideoUrl(String url) {
    // Supporter les URLs YouTube, Vimeo et vidéos directes
    final patterns = [
      r'youtube\.com\/watch\?v=',
      r'youtu\.be\/',
      r'vimeo\.com\/',
      r'\.mp4$',
      r'\.mov$',
      r'\.avi$',
      r'\.mkv$',
    ];

    return patterns.any((pattern) => RegExp(pattern, caseSensitive: false).hasMatch(url));
  }

  // Parser la durée
  Duration? _parseDuration(dynamic duration) {
    if (duration == null) return null;

    if (duration is int) {
      return Duration(seconds: duration);
    }

    if (duration is String) {
      // Format possible: "5:30" ou "120" (secondes)
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

  // Obtenir les headers d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final authState = await _localDB.getAuthState();
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (authState != null && authState['token'] != null) {
      headers['Authorization'] = 'Bearer ${authState['token']}';
    }
    
    return headers;
  }

  // Charger depuis le cache
  Future<List<VideoData>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const cacheKey = 'videos_cache_v1';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        // Vérifier la validité du cache (24h)
        final cacheTime = prefs.getInt('${cacheKey}_timestamp') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        if (now - cacheTime < 24 * 60 * 60 * 1000) { // 24h en ms
          final List<dynamic> jsonList = json.decode(cachedData);
          return jsonList.map((json) => _videoDataFromCacheJson(json)).toList();
        }
      }
    } catch (e) {
      print('❌ [VideoService] Erreur lecture cache: $e');
    }
    
    return [];
  }

  // Sauvegarder en cache
  Future<void> _saveToCache(List<VideoData> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const cacheKey = 'videos_cache_v1';
      
      final jsonList = videos.map((video) => _videoDataToCacheJson(video)).toList();
      await prefs.setString(cacheKey, json.encode(jsonList));
      await prefs.setInt('${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      print('💾 [VideoService] ${videos.length} vidéos sauvegardées en cache');
    } catch (e) {
      print('❌ [VideoService] Erreur sauvegarde cache: $e');
    }
  }

  // Conversion vers JSON pour cache
  Map<String, dynamic> _videoDataToCacheJson(VideoData video) {
    return {
      'id': video.id,
      'title': video.title,
      'description': video.description,
      'author': video.author,
      'authorAvatar': video.authorAvatar,
      'videoUrl': video.videoUrl,
      'thumbnailUrl': video.thumbnailUrl,
      'likesCount': video.likesCount,
      'commentsCount': video.commentsCount,
      'sharesCount': video.sharesCount,
      'views': video.views,
      'isLiked': video.isLiked,
      'isFavorited': video.isFavorited,
      'duration': video.duration?.inSeconds,
      'tags': video.tags,
      'createdAt': video.createdAt.toIso8601String(),
      'metadata': video.metadata, // Preserve the full API response data
    };
  }

  // Conversion depuis JSON du cache
  VideoData _videoDataFromCacheJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? 'Dinor',
      authorAvatar: json['authorAvatar'],
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      views: json['views'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isFavorited: json['isFavorited'] ?? false,
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  // Incrémenter les vues d'une vidéo
  Future<void> incrementViews(String videoId) async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/dinor-tv/$videoId/view'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      print('👀 [VideoService] Vue incrémentée pour vidéo $videoId');
    } catch (e) {
      print('❌ [VideoService] Erreur incrément vue: $e');
    }
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('videos_cache_v1');
      await prefs.remove('videos_cache_v1_timestamp');
      print('🗑️ [VideoService] Cache vidéos nettoyé');
    } catch (e) {
      print('❌ [VideoService] Erreur nettoyage cache: $e');
    }
  }

  // Mettre à jour l'index courant
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  // Obtenir la vidéo courante
  VideoData? get currentVideo {
    if (state.currentIndex != null && 
        state.currentIndex! >= 0 && 
        state.currentIndex! < state.videos.length) {
      return state.videos[state.currentIndex!];
    }
    return null;
  }

  // Rechercher des vidéos
  List<VideoData> searchVideos(String query) {
    if (query.isEmpty) return state.videos;
    
    final lowerQuery = query.toLowerCase();
    return state.videos.where((video) =>
      video.title.toLowerCase().contains(lowerQuery) ||
      video.description.toLowerCase().contains(lowerQuery) ||
      video.author.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

// Provider pour le service vidéo
final videoServiceProvider = StateNotifierProvider<VideoService, VideoState>((ref) {
  final localDB = ref.read(localDatabaseServiceProvider);
  return VideoService(localDB);
});

// Helper pour créer des vidéos de test
class VideoTestHelper {
  static List<VideoData> createTestVideos() {
    return [
      VideoData(
        id: 'test1',
        title: 'Vidéo Test 1',
        description: 'Description de la première vidéo test',
        author: 'Dinor Chef',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=1',
        likesCount: 42,
        commentsCount: 12,
        sharesCount: 5,
        views: 1234,
        createdAt: DateTime.now(),
      ),
      VideoData(
        id: 'test2',
        title: 'Vidéo Test 2',
        description: 'Description de la deuxième vidéo test avec du contenu plus long pour tester l\'affichage',
        author: 'Dinor Pro',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=2',
        likesCount: 87,
        commentsCount: 23,
        sharesCount: 8,
        views: 2567,
        createdAt: DateTime.now(),
      ),
    ];
  }
} 