/**
 * COMMENTS_SERVICE.DART - SERVICE DE GESTION DES COMMENTAIRES
 * 
 * FONCTIONNALITÉS :
 * - Récupération des commentaires par type de contenu (tips, recipes, events)
 * - Ajout de nouveaux commentaires avec authentification
 * - Mise en cache des commentaires pour performance
 * - Pagination et chargement progressif
 * - Gestion des erreurs et états de chargement
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Comment {
  final String id;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final bool isOwner;
  final int likesCount;
  final bool isLiked;

  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    this.isOwner = false,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? json['user_name'] ?? 'Utilisateur anonyme',
      authorAvatar: json['author_avatar'] ?? json['user_avatar'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isOwner: json['is_owner'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'is_owner': isOwner,
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }
}

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;

  CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class CommentsService extends StateNotifier<Map<String, CommentsState>> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  static const int perPage = 10;

  CommentsService() : super({});

  // Récupérer les commentaires pour un contenu spécifique
  Future<void> loadComments(String contentType, String contentId, {bool refresh = false}) async {
    final key = '${contentType}_$contentId';
    
    if (refresh) {
      state = {
        ...state,
        key: CommentsState(isLoading: true),
      };
    } else {
      final currentState = state[key] ?? CommentsState();
      if (currentState.isLoading) return;
      
      state = {
        ...state,
        key: currentState.copyWith(isLoading: true, error: null),
      };
    }

    try {
      print('📝 [CommentsService] Chargement des commentaires pour $contentType:$contentId');
      
      // Vérifier le cache d'abord
      if (!refresh) {
        final cachedComments = await _getCachedComments(contentType, contentId);
        if (cachedComments.isNotEmpty) {
          state = {
            ...state,
            key: CommentsState(
              comments: cachedComments,
              isLoading: false,
              hasMore: false,
            ),
          };
          print('✅ [CommentsService] Commentaires chargés depuis le cache: ${cachedComments.length}');
          return;
        }
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/comments?commentable_type=App\\\\Models\\\\${contentType.substring(0, 1).toUpperCase() + contentType.substring(1)}&commentable_id=$contentId&page=1&per_page=$perPage'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final commentsData = data['data'] ?? data['comments'] ?? [];
        
        final comments = (commentsData as List)
            .map((json) => Comment.fromJson(json))
            .toList();

        // Mettre en cache
        await _cacheComments(contentType, contentId, comments);

        state = {
          ...state,
          key: CommentsState(
            comments: comments,
            isLoading: false,
            hasMore: comments.length >= perPage,
          ),
        };

        print('✅ [CommentsService] Commentaires chargés: ${comments.length}');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [CommentsService] Erreur chargement commentaires: $e');
      state = {
        ...state,
        key: (state[key] ?? CommentsState()).copyWith(
          isLoading: false,
          error: 'Erreur de chargement des commentaires',
        ),
      };
    }
  }

  // Charger plus de commentaires (pagination)
  Future<void> loadMoreComments(String contentType, String contentId) async {
    final key = '${contentType}_$contentId';
    final currentState = state[key];
    
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = {
      ...state,
      key: currentState.copyWith(isLoadingMore: true),
    };

    try {
      final nextPage = currentState.currentPage + 1;
      
      final response = await http.get(
        Uri.parse('$baseUrl/comments?commentable_type=App\\\\Models\\\\${contentType.substring(0, 1).toUpperCase() + contentType.substring(1)}&commentable_id=$contentId&page=$nextPage&per_page=$perPage'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final commentsData = data['data'] ?? data['comments'] ?? [];
        
        final newComments = (commentsData as List)
            .map((json) => Comment.fromJson(json))
            .toList();

        final allComments = [...currentState.comments, ...newComments];

        state = {
          ...state,
          key: currentState.copyWith(
            comments: allComments,
            isLoadingMore: false,
            hasMore: newComments.length >= perPage,
            currentPage: nextPage,
          ),
        };

        print('✅ [CommentsService] Commentaires additionnels chargés: ${newComments.length}');
      }
    } catch (e) {
      print('❌ [CommentsService] Erreur chargement commentaires supplémentaires: $e');
      state = {
        ...state,
        key: currentState.copyWith(isLoadingMore: false),
      };
    }
  }

  // Ajouter un nouveau commentaire
  Future<bool> addComment(String contentType, String contentId, String content) async {
    try {
      print('📝 [CommentsService] Ajout commentaire pour $contentType:$contentId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: await _getHeaders(),
        body: json.encode({
          'commentable_type': 'App\\Models\\${contentType.substring(0, 1).toUpperCase() + contentType.substring(1)}',
          'commentable_id': contentId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['success'] == true || data['comment'] != null) {
          // Recharger les commentaires pour avoir la liste à jour
          await loadComments(contentType, contentId, refresh: true);
          print('✅ [CommentsService] Commentaire ajouté avec succès');
          return true;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      }
      
      throw Exception('Erreur lors de l\'ajout du commentaire');
    } catch (e) {
      print('❌ [CommentsService] Erreur ajout commentaire: $e');
      return false;
    }
  }

  // Supprimer un commentaire
  Future<bool> deleteComment(String contentType, String contentId, String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Retirer le commentaire de la liste locale
        final key = '${contentType}_$contentId';
        final currentState = state[key];
        
        if (currentState != null) {
          final updatedComments = currentState.comments
              .where((comment) => comment.id != commentId)
              .toList();
          
          state = {
            ...state,
            key: currentState.copyWith(comments: updatedComments),
          };
        }
        
        print('✅ [CommentsService] Commentaire supprimé');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ [CommentsService] Erreur suppression commentaire: $e');
      return false;
    }
  }

  // Obtenir l'état des commentaires pour un contenu
  CommentsState getCommentsState(String contentType, String contentId) {
    final key = '${contentType}_$contentId';
    return state[key] ?? CommentsState();
  }

  // Méthodes privées pour le cache et les headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<List<Comment>> _getCachedComments(String contentType, String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'comments_${contentType}_$contentId';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => Comment.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ [CommentsService] Erreur lecture cache: $e');
    }
    
    return [];
  }

  Future<void> _cacheComments(String contentType, String contentId, List<Comment> comments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'comments_${contentType}_$contentId';
      final jsonList = comments.map((comment) => comment.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jsonList));
    } catch (e) {
      print('❌ [CommentsService] Erreur mise en cache: $e');
    }
  }
}

// Provider pour le service de commentaires
final commentsServiceProvider = StateNotifierProvider<CommentsService, Map<String, CommentsState>>((ref) {
  return CommentsService();
});

// Provider helper pour obtenir l'état des commentaires d'un contenu spécifique
final commentsProvider = Provider.family<CommentsState, String>((ref, key) {
  final commentsState = ref.watch(commentsServiceProvider);
  return commentsState[key] ?? CommentsState();
});