/// NBA_RECOMMENDATION_SERVICE.DART - SERVICE DE RECOMMANDATION DE CONTENU NBA
/// 
/// FONCTIONNALITÉS :
/// - Algorithme de similarité basé sur les tags (70%)
/// - Pondération selon la popularité (20%) et fraîcheur (10%)
/// - Filtrage intelligent (contenu vu/liké, récence, équilibrage)
/// - Système de fallback pour contenu populaire
/// - Tracking des interactions pour amélioration
/// - Cache des recommandations pour performance
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/nba_content.dart';
import 'local_database_service.dart';

// État des recommandations
class RecommendationState {
  final List<NBARecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const RecommendationState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  RecommendationState copyWith({
    List<NBARecommendation>? recommendations,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Service de recommandation NBA
class NBARecommendationService extends StateNotifier<RecommendationState> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  final LocalDatabaseService _localDB;

  // Poids pour l'algorithme de recommandation
  static const double _similarityWeight = 0.7;
  static const double _popularityWeight = 0.2;
  static const double _freshnessWeight = 0.1;

  // Paramètres de filtrage
  static const int _maxRecommendations = 10;
  static const int _minRecommendations = 4;
  static const int _maxDaysForFreshContent = 30;

  NBARecommendationService(this._localDB) : super(const RecommendationState());

  // Générer des recommandations pour un contenu donné
  Future<void> generateRecommendations(NBAContent currentContent) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🏀 [NBARecommendation] Génération recommandations pour: ${currentContent.title}');

      // 1. Charger tout le contenu disponible
      final allContent = await _loadAllContent();
      
      // 2. Filtrer le contenu non pertinent
      final candidateContent = _filterCandidates(allContent, currentContent);
      
      // 3. Calculer les scores de similarité
      final scoredContent = _calculateSimilarityScores(candidateContent, currentContent);
      
      // 4. Équilibrer les types de contenu
      final balancedContent = _balanceContentTypes(scoredContent);
      
      // 5. Fallback si pas assez de contenu similaire
      final finalRecommendations = await _applyFallbackIfNeeded(
        balancedContent, 
        currentContent, 
        allContent
      );
      
      // 6. Trier par score et limiter
      finalRecommendations.sort((a, b) => b.score.compareTo(a.score));
      final topRecommendations = finalRecommendations.take(_maxRecommendations).toList();
      
      // 7. Sauvegarder en cache
      await _cacheRecommendations(currentContent.id, topRecommendations);
      
      state = state.copyWith(
        recommendations: topRecommendations,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      print('✅ [NBARecommendation] ${topRecommendations.length} recommandations générées');
      
      // 8. Marquer le contenu comme vu
      await _markContentAsViewed(currentContent.id);

    } catch (e) {
      print('❌ [NBARecommendation] Erreur génération: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Charger tout le contenu depuis l'API
  Future<List<NBAContent>> _loadAllContent() async {
    try {
      final headers = await _getHeaders();
      
      // Charger différents types de contenu en parallèle
      final futures = [
        _loadContentByType('videos', headers),
        _loadContentByType('articles', headers),
        _loadContentByType('highlights', headers),
      ];
      
      final results = await Future.wait(futures);
      
      // Combiner tous les contenus
      final allContent = <NBAContent>[];
      for (final contentList in results) {
        allContent.addAll(contentList);
      }
      
      print('📚 [NBARecommendation] ${allContent.length} contenus chargés');
      return allContent;
      
    } catch (e) {
      print('❌ [NBARecommendation] Erreur chargement contenu: $e');
      return [];
    }
  }

  // Charger un type de contenu spécifique
  Future<List<NBAContent>> _loadContentByType(String type, Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$type?limit=50&sort=created_at&order=desc'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] ?? [];
        
        return (items as List).map((item) => NBAContent.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ [NBARecommendation] Erreur chargement $type: $e');
      return [];
    }
  }

  // Filtrer les candidats selon les critères
  List<NBAContent> _filterCandidates(List<NBAContent> allContent, NBAContent currentContent) {
    final userViewedContent = _getUserViewedContent();
    final userLikedContent = _getUserLikedContent();
    
    return allContent.where((content) {
      // Exclure le contenu actuel
      if (content.id == currentContent.id) return false;
      
      // Exclure le contenu déjà vu (optionnel - peut être paramétrable)
      // if (userViewedContent.contains(content.id)) return false;
      
      // Priorité au contenu récent (moins de 30 jours par défaut)
      final daysSincePublished = DateTime.now().difference(content.publishedAt).inDays;
      if (daysSincePublished > _maxDaysForFreshContent && content.popularityScore < 70) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Calculer les scores de similarité
  List<NBARecommendation> _calculateSimilarityScores(
    List<NBAContent> candidates, 
    NBAContent currentContent
  ) {
    final recommendations = <NBARecommendation>[];
    
    for (final candidate in candidates) {
      final similarityResult = _calculateTagSimilarity(candidate, currentContent);
      final similarityScore = similarityResult['score'] as double;
      final matchingTags = similarityResult['matching_tags'] as List<String>;
      
      // Ne recommander que si similarité minimale
      if (similarityScore > 0.1) {
        final recommendation = NBARecommendation.fromContent(
          content: candidate,
          similarityScore: similarityScore,
          matchingTags: matchingTags,
        );
        
        recommendations.add(recommendation);
      }
    }
    
    return recommendations;
  }

  // Calculer la similarité entre deux contenus basée sur les tags
  Map<String, dynamic> _calculateTagSimilarity(NBAContent candidate, NBAContent current) {
    final currentTags = current.tags;
    final candidateTags = candidate.tags;
    
    if (currentTags.isEmpty || candidateTags.isEmpty) {
      return {'score': 0.0, 'matching_tags': <String>[]};
    }
    
    double totalSimilarity = 0.0;
    final matchingTags = <String>[];
    
    // Calculer la similarité pour chaque tag du contenu actuel
    for (final currentTag in currentTags) {
      for (final candidateTag in candidateTags) {
        final similarity = _calculateIndividualTagSimilarity(currentTag, candidateTag);
        
        if (similarity > 0) {
          // Appliquer la pondération selon la priorité
          final weightedSimilarity = similarity * currentTag.priority.weight;
          totalSimilarity += weightedSimilarity;
          
          if (similarity >= 0.8) { // Match exact ou très proche
            matchingTags.add(currentTag.name);
          }
        }
      }
    }
    
    // Normaliser le score (0-1)
    final normalizedScore = (totalSimilarity / currentTags.length).clamp(0.0, 1.0);
    
    return {
      'score': normalizedScore,
      'matching_tags': matchingTags.toSet().toList(), // Éliminer doublons
    };
  }

  // Calculer la similarité entre deux tags individuels
  double _calculateIndividualTagSimilarity(NBATag tag1, NBATag tag2) {
    // Match exact
    if (tag1.id == tag2.id) return 1.0;
    
    // Match par catégorie avec bonus si même nom
    if (tag1.category == tag2.category) {
      if (tag1.name.toLowerCase() == tag2.name.toLowerCase()) {
        return 1.0;
      }
      
      // Similarité partielle pour même catégorie
      switch (tag1.category) {
        case 'team':
          return 0.3; // Équipes de même ligue
        case 'player':
          return _calculatePlayerSimilarity(tag1, tag2);
        case 'position':
          return 0.6; // Positions similaires
        case 'season':
          return 0.4; // Saisons proches
        case 'stat':
          return 0.5; // Statistiques reliées
        default:
          return 0.2;
      }
    }
    
    return 0.0;
  }

  // Calculer similarité entre joueurs (basic)
  double _calculatePlayerSimilarity(NBATag player1, NBATag player2) {
    final p1Lower = player1.name.toLowerCase();
    final p2Lower = player2.name.toLowerCase();
    
    // Même nom de famille
    final p1Parts = p1Lower.split(' ');
    final p2Parts = p2Lower.split(' ');
    
    if (p1Parts.isNotEmpty && p2Parts.isNotEmpty) {
      if (p1Parts.last == p2Parts.last) {
        return 0.7; // Même nom de famille
      }
    }
    
    // Même équipe (si metadata disponible)
    final p1Team = player1.metadata?['team'];
    final p2Team = player2.metadata?['team'];
    
    if (p1Team != null && p2Team != null && p1Team == p2Team) {
      return 0.5; // Coéquipiers
    }
    
    return 0.1; // Joueurs différents
  }

  // Équilibrer les types de contenu
  List<NBARecommendation> _balanceContentTypes(List<NBARecommendation> recommendations) {
    // Trier par score d'abord
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    
    final balanced = <NBARecommendation>[];
    final typeCount = <NBAContentType, int>{};
    
    // Limite par type pour éviter la monotonie
    const maxPerType = 4;
    
    for (final rec in recommendations) {
      final type = rec.content.type;
      final currentCount = typeCount[type] ?? 0;
      
      if (currentCount < maxPerType || balanced.length < _minRecommendations) {
        balanced.add(rec);
        typeCount[type] = currentCount + 1;
      }
      
      if (balanced.length >= _maxRecommendations) break;
    }
    
    return balanced;
  }

  // Appliquer fallback si pas assez de contenu similaire
  Future<List<NBARecommendation>> _applyFallbackIfNeeded(
    List<NBARecommendation> recommendations,
    NBAContent currentContent,
    List<NBAContent> allContent,
  ) async {
    if (recommendations.length >= _minRecommendations) {
      return recommendations;
    }
    
    print('🔄 [NBARecommendation] Fallback: pas assez de contenu similaire');
    
    // Fallback 1: Contenu de la même équipe/joueur principal
    final fallbackByTeam = _getFallbackByCategory(
      allContent, 
      currentContent, 
      'team'
    );
    
    final fallbackByPlayer = _getFallbackByCategory(
      allContent, 
      currentContent, 
      'player'
    );
    
    // Fallback 2: Contenu populaire général
    final popularContent = _getPopularContent(allContent);
    
    // Combiner avec priorité
    final combined = <NBARecommendation>[];
    combined.addAll(recommendations);
    combined.addAll(fallbackByTeam);
    combined.addAll(fallbackByPlayer);
    combined.addAll(popularContent);
    
    // Éliminer doublons et retourner
    final seen = <String>{};
    final unique = combined.where((rec) {
      if (seen.contains(rec.content.id)) return false;
      seen.add(rec.content.id);
      return true;
    }).toList();
    
    return unique;
  }

  // Fallback par catégorie
  List<NBARecommendation> _getFallbackByCategory(
    List<NBAContent> allContent,
    NBAContent currentContent,
    String category,
  ) {
    final currentCategoryTags = currentContent.getTagsByCategory(category);
    if (currentCategoryTags.isEmpty) return [];
    
    final fallback = <NBARecommendation>[];
    
    for (final content in allContent) {
      if (content.id == currentContent.id) continue;
      
      final contentCategoryTags = content.getTagsByCategory(category);
      final hasMatch = contentCategoryTags.any((tag) =>
        currentCategoryTags.any((currentTag) => currentTag.id == tag.id)
      );
      
      if (hasMatch) {
        final rec = NBARecommendation.fromContent(
          content: content,
          similarityScore: 0.3, // Score fallback
          matchingTags: [currentCategoryTags.first.name],
          reason: 'Même ${category == 'team' ? 'équipe' : 'joueur'}',
        );
        
        fallback.add(rec);
      }
    }
    
    // Trier par popularité et prendre les meilleurs
    fallback.sort((a, b) => b.content.popularityScore.compareTo(a.content.popularityScore));
    return fallback.take(3).toList();
  }

  // Contenu populaire général
  List<NBARecommendation> _getPopularContent(List<NBAContent> allContent) {
    final popular = allContent
        .where((content) => content.popularityScore > 60)
        .toList();
        
    popular.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    
    return popular.take(5).map((content) => NBARecommendation.fromContent(
      content: content,
      similarityScore: 0.1,
      matchingTags: [],
      reason: 'Contenu populaire',
    )).toList();
  }

  // Tracking des interactions
  Future<void> trackInteraction(String contentId, String interactionType) async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/analytics/interaction'),
        headers: headers,
        body: json.encode({
          'content_id': contentId,
          'interaction_type': interactionType, // 'view', 'like', 'share', 'click'
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      print('📊 [NBARecommendation] Interaction trackée: $interactionType pour $contentId');
    } catch (e) {
      print('❌ [NBARecommendation] Erreur tracking: $e');
    }
  }

  // Marquer contenu comme vu
  Future<void> _markContentAsViewed(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const viewedKey = 'viewed_content_v1';
      final viewed = prefs.getStringList(viewedKey) ?? [];
      
      if (!viewed.contains(contentId)) {
        viewed.add(contentId);
        
        // Garder seulement les 1000 derniers
        if (viewed.length > 1000) {
          viewed.removeRange(0, viewed.length - 1000);
        }
        
        await prefs.setStringList(viewedKey, viewed);
      }
    } catch (e) {
      print('❌ [NBARecommendation] Erreur marquage vu: $e');
    }
  }

  // Obtenir contenu vu par l'utilisateur
  Set<String> _getUserViewedContent() {
    // Implementation basique - peut être étendue
    return {};
  }

  // Obtenir contenu liké par l'utilisateur
  Set<String> _getUserLikedContent() {
    // Implementation basique - peut être étendue
    return {};
  }

  // Obtenir headers authentifiés
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

  // Cache des recommandations
  Future<void> _cacheRecommendations(String contentId, List<NBARecommendation> recommendations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'recommendations_$contentId';
      
      final jsonData = recommendations.map((rec) => rec.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jsonData));
      await prefs.setInt('${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      print('💾 [NBARecommendation] Recommandations cached pour $contentId');
    } catch (e) {
      print('❌ [NBARecommendation] Erreur cache: $e');
    }
  }

  // Charger recommandations depuis le cache
  Future<List<NBARecommendation>?> _loadCachedRecommendations(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'recommendations_$contentId';
      
      final cached = prefs.getString(cacheKey);
      final timestamp = prefs.getInt('${cacheKey}_timestamp') ?? 0;
      
      // Cache valide 1h
      final isValid = DateTime.now().millisecondsSinceEpoch - timestamp < 3600000;
      
      if (cached != null && isValid) {
        final jsonList = json.decode(cached) as List;
        return jsonList.map((json) => NBARecommendation(
          content: NBAContent.fromJson(json['content']),
          score: json['score'].toDouble(),
          similarityScore: json['similarity_score'].toDouble(),
          matchingTags: List<String>.from(json['matching_tags']),
          reason: json['reason'],
        )).toList();
      }
    } catch (e) {
      print('❌ [NBARecommendation] Erreur lecture cache: $e');
    }
    
    return null;
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('recommendations_'));
      
      for (final key in keys) {
        await prefs.remove(key);
        await prefs.remove('${key}_timestamp');
      }
      
      print('🗑️ [NBARecommendation] Cache nettoyé');
    } catch (e) {
      print('❌ [NBARecommendation] Erreur nettoyage cache: $e');
    }
  }
}

// Provider pour le service de recommandation
final nbaRecommendationServiceProvider = StateNotifierProvider<NBARecommendationService, RecommendationState>((ref) {
  final localDB = ref.read(localDatabaseServiceProvider);
  return NBARecommendationService(localDB);
}); 