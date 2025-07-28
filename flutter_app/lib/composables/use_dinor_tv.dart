/**
 * USE_DINOR_TV.DART - COMPOSABLE POUR DINOR TV
 * 
 * FIDÉLITÉ VUE :
 * - Même structure que useRecipes, useTips
 * - Même gestion d'état : loading, error, data
 * - Même système de rafraîchissement
 * - Même gestion des paramètres de requête
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class DinorTVState {
  final List<dynamic> videos;
  final bool loading;
  final String? error;
  final Map<String, dynamic> meta;

  DinorTVState({
    required this.videos,
    required this.loading,
    this.error,
    required this.meta,
  });

  DinorTVState copyWith({
    List<dynamic>? videos,
    bool? loading,
    String? error,
    Map<String, dynamic>? meta,
  }) {
    return DinorTVState(
      videos: videos ?? this.videos,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      meta: meta ?? this.meta,
    );
  }
}

class DinorTVNotifier extends StateNotifier<DinorTVState> {
  DinorTVNotifier() : super(DinorTVState(
    videos: [],
    loading: false,
    meta: {},
  ));

  Future<void> loadVideos({
    Map<String, dynamic>? params,
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      print('📺 [DinorTV] Chargement des vidéos...');
      
      final data = await ApiService.instance.getVideos(
        params: params,
        forceRefresh: forceRefresh,
      );

      if (data['success'] == true) {
        state = state.copyWith(
          videos: data['data'] ?? [],
          meta: data['meta'] ?? {},
          loading: false,
        );
        print('✅ [DinorTV] ${state.videos.length} vidéos chargées');
      } else {
        throw Exception(data['message'] ?? 'Erreur lors du chargement des vidéos');
      }
    } catch (error) {
      print('❌ [DinorTV] Erreur: $error');
      state = state.copyWith(
        error: error.toString(),
        loading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadVideos(forceRefresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final dinorTVProvider = StateNotifierProvider<DinorTVNotifier, DinorTVState>((ref) {
  return DinorTVNotifier();
}); 