import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class CommentsNotifier extends StateNotifier<List<dynamic>> {
  final ApiService _apiService;
  
  CommentsNotifier(this._apiService) : super([]);

  Future<List<dynamic>> loadComments(String contextType, String contextId) async {
    try {
      print('📝 [CommentsNotifier] Chargement commentaires pour $contextType:$contextId');
      
      final response = await _apiService.get('/comments', params: {
        'commentable_type': contextType,
        'commentable_id': contextId,
      });
      
      if (response['success']) {
        final comments = response['data'] as List<dynamic>;
        state = comments;
        print('✅ [CommentsNotifier] ${comments.length} commentaires chargés');
        return comments;
      }
      
      return [];
    } catch (error) {
      print('❌ [CommentsNotifier] Erreur chargement commentaires: $error');
      return [];
    }
  }

  Future<List<dynamic>> loadCommentsFresh(String contextType, String contextId) async {
    try {
      print('🔄 [CommentsNotifier] Rechargement commentaires pour $contextType:$contextId');
      
      final response = await _apiService.request('/comments', forceRefresh: true, params: {
        'commentable_type': contextType,
        'commentable_id': contextId,
      });
      
      if (response['success']) {
        final comments = response['data'] as List<dynamic>;
        state = comments;
        print('✅ [CommentsNotifier] ${comments.length} commentaires rechargés');
        return comments;
      }
      
      return [];
    } catch (error) {
      print('❌ [CommentsNotifier] Erreur rechargement commentaires: $error');
      return [];
    }
  }

  Future<bool> addComment(String contextType, String contextId, String content) async {
    try {
      print('📝 [CommentsNotifier] Ajout commentaire pour $contextType:$contextId');
      
      final response = await _apiService.post('/comments', {
        'commentable_type': contextType,
        'commentable_id': contextId,
        'content': content,
      });
      
      if (response['success']) {
        // Recharger les commentaires après ajout
        await loadComments(contextType, contextId);
        print('✅ [CommentsNotifier] Commentaire ajouté avec succès');
        return true;
      }
      
      return false;
    } catch (error) {
      print('❌ [CommentsNotifier] Erreur ajout commentaire: $error');
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      print('🗑️ [CommentsNotifier] Suppression commentaire ID: $commentId');
      
      final response = await _apiService.delete('/comments/$commentId');
      
      if (response['success']) {
        // Retirer le commentaire de la liste
        state = state.where((comment) => comment['id'].toString() != commentId).toList();
        print('✅ [CommentsNotifier] Commentaire supprimé avec succès');
        return true;
      }
      
      return false;
    } catch (error) {
      print('❌ [CommentsNotifier] Erreur suppression commentaire: $error');
      return false;
    }
  }

  void setContext(String contextType, String contextId) {
    // Cette méthode peut être utilisée pour stocker le contexte actuel
    print('📋 [CommentsNotifier] Contexte défini: $contextType:$contextId');
  }

  bool canDeleteComment(dynamic comment) {
    // Logique pour vérifier si l'utilisateur peut supprimer le commentaire
    // À implémenter selon votre logique d'authentification
    return false;
  }

  void clearCache() {
    state = [];
    print('🧹 [CommentsNotifier] Cache commentaires vidé');
  }
}

final useCommentsProvider = StateNotifierProvider<CommentsNotifier, List<dynamic>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return CommentsNotifier(apiService);
}); 