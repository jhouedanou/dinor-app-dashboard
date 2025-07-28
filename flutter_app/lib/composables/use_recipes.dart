import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class RecipesNotifier extends StateNotifier<List<dynamic>> {
  final ApiService _apiService;
  
  RecipesNotifier(this._apiService) : super([]);

  Future<List<dynamic>> fetchRecipes() async {
    try {
      print('🍳 [RecipesNotifier] Chargement recettes');
      
      final response = await _apiService.get('/recipes');
      
      if (response['success']) {
        final recipes = response['data'] as List<dynamic>;
        state = recipes;
        print('✅ [RecipesNotifier] ${recipes.length} recettes chargées');
        return recipes;
      }
      
      return [];
    } catch (error) {
      print('❌ [RecipesNotifier] Erreur chargement recettes:', error);
      return [];
    }
  }

  Future<List<dynamic>> fetchRecipesFresh() async {
    try {
      print('🔄 [RecipesNotifier] Rechargement recettes');
      
      final response = await _apiService.request('/recipes', forceRefresh: true);
      
      if (response['success']) {
        final recipes = response['data'] as List<dynamic>;
        state = recipes;
        print('✅ [RecipesNotifier] ${recipes.length} recettes rechargées');
        return recipes;
      }
      
      return [];
    } catch (error) {
      print('❌ [RecipesNotifier] Erreur rechargement recettes:', error);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchRecipe(String id) async {
    try {
      print('🍳 [RecipesNotifier] Chargement recette ID: $id');
      
      final response = await _apiService.get('/recipes/$id');
      
      if (response['success']) {
        final recipe = response['data'] as Map<String, dynamic>;
        print('✅ [RecipesNotifier] Recette chargée: ${recipe['title']}');
        return recipe;
      }
      
      return null;
    } catch (error) {
      print('❌ [RecipesNotifier] Erreur chargement recette:', error);
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchRecipeFresh(String id) async {
    try {
      print('🔄 [RecipesNotifier] Rechargement recette ID: $id');
      
      final response = await _apiService.request('/recipes/$id', forceRefresh: true);
      
      if (response['success']) {
        final recipe = response['data'] as Map<String, dynamic>;
        print('✅ [RecipesNotifier] Recette rechargée: ${recipe['title']}');
        return recipe;
      }
      
      return null;
    } catch (error) {
      print('❌ [RecipesNotifier] Erreur rechargement recette:', error);
      return null;
    }
  }

  List<dynamic> searchRecipes(String query) {
    if (query.trim().isEmpty) {
      return state;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((recipe) {
      final title = recipe['title']?.toString().toLowerCase() ?? '';
      final description = recipe['short_description']?.toString().toLowerCase() ?? '';
      final tags = (recipe['tags'] as List?)?.map((tag) => tag.toString().toLowerCase()).toList() ?? [];
      
      return title.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery) ||
             tags.any((tag) => tag.contains(lowercaseQuery));
    }).toList();
  }

  List<dynamic> filterRecipesByCategory(String categoryId) {
    return state.where((recipe) => recipe['category_id'] == categoryId).toList();
  }

  List<dynamic> filterRecipesByDifficulty(String difficulty) {
    return state.where((recipe) => recipe['difficulty'] == difficulty).toList();
  }

  List<dynamic> getLatestRecipes({int limit = 4}) {
    final sortedRecipes = List.from(state);
    sortedRecipes.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });
    
    return sortedRecipes.take(limit).toList();
  }

  void clearCache() {
    state = [];
    print('🧹 [RecipesNotifier] Cache recettes vidé');
  }

  void updateRecipe(String id, Map<String, dynamic> updatedData) {
    final index = state.indexWhere((recipe) => recipe['id'].toString() == id);
    if (index != -1) {
      final updatedRecipes = List.from(state);
      updatedRecipes[index] = {...updatedRecipes[index], ...updatedData};
      state = updatedRecipes;
      print('🔄 [RecipesNotifier] Recette mise à jour: $id');
    }
  }
}

final useRecipesProvider = StateNotifierProvider<RecipesNotifier, List<dynamic>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return RecipesNotifier(apiService);
}); 