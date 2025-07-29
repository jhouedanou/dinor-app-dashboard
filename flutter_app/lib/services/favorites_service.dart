/**
 * FAVORITES_SERVICE.DART - SERVICE DE GESTION DES FAVORIS
 * 
 * FONCTIONNALITÉS :
 * - Récupération des favoris avec cache
 * - Ajout/suppression de favoris
 * - Synchronisation avec le serveur
 * - Gestion des états de chargement
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Favorite {
  final String id;
  final String type;
  final Map<String, dynamic> content;
  final DateTime favoritedAt;

  Favorite({
    required this.id,
    required this.type,
    required this.content,
    required this.favoritedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? {},
      favoritedAt: DateTime.tryParse(json['favorited_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'favorited_at': favoritedAt.toIso8601String(),
    };
  }
}

class FavoritesState {
  final List<Favorite> favorites;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  FavoritesState copyWith({
    List<Favorite>? favorites,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FavoritesService extends StateNotifier<FavoritesState> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';

  FavoritesService() : super(FavoritesState());

  // Charger les favoris
  Future<void> loadFavorites({bool refresh = false}) async {
    if (refresh) {
      state = FavoritesState(isLoading: true);
    } else {
      final currentState = state;
      if (currentState.isLoading) return;
      
      state = currentState.copyWith(isLoading: true, error: null);
    }

    try {
      print('🔍 [FavoritesService] Chargement des favoris...');
      
      // Vérifier le cache d'abord
      if (!refresh) {
        final cachedFavorites = await _getCachedFavorites();
        if (cachedFavorites.isNotEmpty) {
          state = FavoritesState(
            favorites: cachedFavorites,
            isLoading: false,
            hasMore: false,
          );
          print('✅ [FavoritesService] Favoris chargés depuis le cache: ${cachedFavorites.length}');
          return;
        }
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('🟦 [FavoritesService] Réponse brute API: ${response.body}'); // <-- LOG DEBUG

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final favoritesData = data['data'] ?? [];
        
        final favorites = (favoritesData as List)
            .map((json) => Favorite.fromJson(json))
            .toList();

        // Mettre en cache
        await _cacheFavorites(favorites);

        state = FavoritesState(
          favorites: favorites,
          isLoading: false,
          hasMore: false,
        );
        
        print('✅ [FavoritesService] Favoris chargés depuis l\'API: ${favorites.length}');
      } else if (response.statusCode == 401) {
        state = FavoritesState(
          isLoading: false,
          error: 'Authentification requise',
        );
        print('❌ [FavoritesService] Authentification requise');
      } else {
        state = FavoritesState(
          isLoading: false,
          error: 'Erreur lors du chargement des favoris',
        );
        print('❌ [FavoritesService] Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [FavoritesService] Erreur chargement: $e');
      state = FavoritesState(
        isLoading: false,
        error: 'Erreur de connexion',
      );
    }
  }

  // Ajouter un favori
  Future<bool> addFavorite(String type, String id) async {
    try {
      print('➕ [FavoritesService] Ajout favori: $type/$id');
      
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: await _getHeaders(),
        body: json.encode({
          'type': type,
          'id': id,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['is_favorited'] == true) {
          // Recharger les favoris
          await loadFavorites(refresh: true);
          print('✅ [FavoritesService] Favori ajouté avec succès');
          return true;
        }
      } else if (response.statusCode == 401) {
        print('❌ [FavoritesService] Erreur 401: Authentication requise');
        throw Exception('Authentication required (401)');
      } else {
        print('❌ [FavoritesService] Erreur HTTP ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
      return false;
    } catch (e) {
      print('❌ [FavoritesService] Erreur ajout favori: $e');
      // Relancer les exceptions d'authentification
      if (e.toString().contains('401') || e.toString().contains('Authentication')) {
        rethrow;
      }
      return false;
    }
  }

  // Supprimer un favori
  Future<bool> removeFavorite(String favoriteId) async {
    try {
      print('➖ [FavoritesService] Suppression favori: $favoriteId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$favoriteId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Retirer le favori de la liste locale
        final updatedFavorites = state.favorites
            .where((favorite) => favorite.id != favoriteId)
            .toList();
        
        state = state.copyWith(favorites: updatedFavorites);
        
        // Mettre à jour le cache
        await _cacheFavorites(updatedFavorites);
        
        print('✅ [FavoritesService] Favori supprimé avec succès');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ [FavoritesService] Erreur 401: Authentication requise');
        throw Exception('Authentication required (401)');
      } else {
        print('❌ [FavoritesService] Erreur HTTP ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ [FavoritesService] Erreur suppression favori: $e');
      // Relancer les exceptions d'authentification
      if (e.toString().contains('401') || e.toString().contains('Authentication')) {
        rethrow;
      }
      return false;
    }
  }

  // Vérifier si un item est en favori
  Future<bool> checkFavorite(String type, String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/check?type=$type&id=$id'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_favorited'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ [FavoritesService] Erreur vérification favori: $e');
      return false;
    }
  }

  // Filtrer les favoris par type
  List<Favorite> getFavoritesByType(String type) {
    if (type == 'all') return state.favorites;
    return state.favorites.where((favorite) => favorite.type == type).toList();
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

  Future<List<Favorite>> _getCachedFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_favorites');
      
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => Favorite.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ [FavoritesService] Erreur cache: $e');
    }
    
    return [];
  }

  Future<void> _cacheFavorites(List<Favorite> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = favorites.map((favorite) => favorite.toJson()).toList();
      await prefs.setString('cached_favorites', json.encode(jsonList));
      print('💾 [FavoritesService] Favoris mis en cache: ${favorites.length}');
    } catch (e) {
      print('❌ [FavoritesService] Erreur sauvegarde cache: $e');
    }
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_favorites');
      print('🧹 [FavoritesService] Cache nettoyé');
    } catch (e) {
      print('❌ [FavoritesService] Erreur nettoyage cache: $e');
    }
  }
}

// Provider pour le service de favoris
final favoritesServiceProvider = StateNotifierProvider<FavoritesService, FavoritesState>((ref) {
  return FavoritesService();
});