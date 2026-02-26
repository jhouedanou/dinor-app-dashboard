import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class BannersNotifier extends StateNotifier<List<dynamic>> {
  final ApiService _apiService;
  
  BannersNotifier(this._apiService) : super([]);

  Future<List<dynamic>> loadBannersForContentType(String contentType, {bool forceRefresh = false}) async {
    try {
      print('🖼️ [BannersNotifier] Chargement bannières pour type: $contentType');
      
      final response = forceRefresh 
        ? await _apiService.request('/banners', forceRefresh: true, params: {'content_type': contentType})
        : await _apiService.get('/banners', params: {'content_type': contentType});
      
      if (response['success']) {
        final banners = response['data'] as List<dynamic>;
        state = banners;
        print('✅ [BannersNotifier] ${banners.length} bannières chargées pour $contentType');
        return banners;
      }
      
      return [];
    } catch (error) {
      print('❌ [BannersNotifier] Erreur chargement bannières: $error');
      return [];
    }
  }

  Future<List<dynamic>> loadBannersForSection(String contentType, String section, {bool forceRefresh = false}) async {
    try {
      print('🖼️ [BannersNotifier] Chargement bannières pour $contentType:$section');
      
      final response = forceRefresh 
        ? await _apiService.request('/banners', forceRefresh: true, params: {
            'content_type': contentType,
            'section': section,
          })
        : await _apiService.get('/banners', params: {
            'content_type': contentType,
            'section': section,
          });
      
      if (response['success']) {
        final banners = response['data'] as List<dynamic>;
        state = banners;
        print('✅ [BannersNotifier] ${banners.length} bannières chargées pour $contentType:$section');
        return banners;
      }
      
      return [];
    } catch (error) {
      print('❌ [BannersNotifier] Erreur chargement bannières: $error');
      return [];
    }
  }

  List<dynamic> getBannersForContentType(String contentType) {
    return state.where((banner) => banner['content_type'] == contentType).toList();
  }

  List<dynamic> getBannersForSection(String contentType, String section) {
    return state.where((banner) => 
      banner['content_type'] == contentType && 
      banner['section'] == section
    ).toList();
  }

  void clearCache() {
    state = [];
    print('🧹 [BannersNotifier] Cache bannières vidé');
  }
}

final useBannersProvider = StateNotifierProvider<BannersNotifier, List<dynamic>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return BannersNotifier(apiService);
}); 