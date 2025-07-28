import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class TipsNotifier extends StateNotifier<List<dynamic>> {
  final ApiService _apiService;
  
  TipsNotifier(this._apiService) : super([]);

  Future<List<dynamic>> fetchTips() async {
    try {
      print('💡 [TipsNotifier] Chargement astuces');
      
      final response = await _apiService.get('/tips');
      
      if (response['success']) {
        final tips = response['data'] as List<dynamic>;
        state = tips;
        print('✅ [TipsNotifier] ${tips.length} astuces chargées');
        return tips;
      }
      
      return [];
    } catch (error) {
      print('❌ [TipsNotifier] Erreur chargement astuces:', error);
      return [];
    }
  }

  Future<List<dynamic>> fetchTipsFresh() async {
    try {
      print('🔄 [TipsNotifier] Rechargement astuces');
      
      final response = await _apiService.request('/tips', forceRefresh: true);
      
      if (response['success']) {
        final tips = response['data'] as List<dynamic>;
        state = tips;
        print('✅ [TipsNotifier] ${tips.length} astuces rechargées');
        return tips;
      }
      
      return [];
    } catch (error) {
      print('❌ [TipsNotifier] Erreur rechargement astuces:', error);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchTip(String id) async {
    try {
      print('💡 [TipsNotifier] Chargement astuce ID: $id');
      
      final response = await _apiService.get('/tips/$id');
      
      if (response['success']) {
        final tip = response['data'] as Map<String, dynamic>;
        print('✅ [TipsNotifier] Astuce chargée: ${tip['title']}');
        return tip;
      }
      
      return null;
    } catch (error) {
      print('❌ [TipsNotifier] Erreur chargement astuce:', error);
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchTipFresh(String id) async {
    try {
      print('🔄 [TipsNotifier] Rechargement astuce ID: $id');
      
      final response = await _apiService.request('/tips/$id', forceRefresh: true);
      
      if (response['success']) {
        final tip = response['data'] as Map<String, dynamic>;
        print('✅ [TipsNotifier] Astuce rechargée: ${tip['title']}');
        return tip;
      }
      
      return null;
    } catch (error) {
      print('❌ [TipsNotifier] Erreur rechargement astuce:', error);
      return null;
    }
  }

  List<dynamic> searchTips(String query) {
    if (query.trim().isEmpty) {
      return state;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((tip) {
      final title = tip['title']?.toString().toLowerCase() ?? '';
      final description = tip['short_description']?.toString().toLowerCase() ?? '';
      final content = tip['content']?.toString().toLowerCase() ?? '';
      final tags = (tip['tags'] as List?)?.map((tag) => tag.toString().toLowerCase()).toList() ?? [];
      
      return title.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery) ||
             content.contains(lowercaseQuery) ||
             tags.any((tag) => tag.contains(lowercaseQuery));
    }).toList();
  }

  List<dynamic> filterTipsByCategory(String categoryId) {
    return state.where((tip) => tip['category_id'] == categoryId).toList();
  }

  List<dynamic> filterTipsByDifficulty(String difficulty) {
    return state.where((tip) => tip['difficulty'] == difficulty).toList();
  }

  List<dynamic> filterTipsByType(String type) {
    return state.where((tip) => tip['type'] == type).toList();
  }

  List<dynamic> getLatestTips({int limit = 4}) {
    final sortedTips = List.from(state);
    sortedTips.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });
    
    return sortedTips.take(limit).toList();
  }

  List<dynamic> getPopularTips({int limit = 4}) {
    final sortedTips = List.from(state);
    sortedTips.sort((a, b) {
      final likesA = a['likes_count'] ?? 0;
      final likesB = b['likes_count'] ?? 0;
      return likesB.compareTo(likesA);
    });
    
    return sortedTips.take(limit).toList();
  }

  void clearCache() {
    state = [];
    print('🧹 [TipsNotifier] Cache astuces vidé');
  }

  void updateTip(String id, Map<String, dynamic> updatedData) {
    final index = state.indexWhere((tip) => tip['id'].toString() == id);
    if (index != -1) {
      final updatedTips = List.from(state);
      updatedTips[index] = {...updatedTips[index], ...updatedData};
      state = updatedTips;
      print('🔄 [TipsNotifier] Astuce mise à jour: $id');
    }
  }
}

final useTipsProvider = StateNotifierProvider<TipsNotifier, List<dynamic>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TipsNotifier(apiService);
}); 