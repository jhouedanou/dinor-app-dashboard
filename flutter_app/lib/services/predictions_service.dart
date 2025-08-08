/**
 * PREDICTIONS_SERVICE.DART - SERVICE DE GESTION DES PRONOSTICS
 * 
 * FONCTIONNALITÉS :
 * - Récupération des tournois et matchs
 * - Gestion des pronostics utilisateur
 * - Calcul des points et statistiques
 * - Classements et leaderboards
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database_service.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final String status;
  final String statusLabel;
  final int participantsCount;
  final String? prizePool;
  final String? currency;
  final DateTime startDate;
  final DateTime? endDate;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.statusLabel,
    required this.participantsCount,
    this.prizePool,
    this.currency,
    required this.startDate,
    this.endDate,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      participantsCount: json['participants_count'] ?? 0,
      prizePool: json['prize_pool'],
      currency: json['currency'],
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? ''),
    );
  }
}

class Match {
  final String id;
  final String tournamentId;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final DateTime matchDate;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final bool canPredict;

  Match({
    required this.id,
    required this.tournamentId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.matchDate,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.canPredict,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    // Helper pour extraire le nom d'équipe (peut être un string ou un objet)
    String extractTeamName(dynamic teamData) {
      if (teamData == null) return '';
      if (teamData is String) return teamData;
      if (teamData is Map<String, dynamic>) {
        return teamData['name']?.toString() ?? 
               teamData['title']?.toString() ?? 
               teamData['team_name']?.toString() ?? '';
      }
      return teamData.toString();
    }

    // Helper pour extraire le logo d'équipe
    String? extractTeamLogo(dynamic teamData) {
      if (teamData == null) return null;
      if (teamData is String) return teamData;
      if (teamData is Map<String, dynamic>) {
        return teamData['logo']?.toString() ?? 
               teamData['image']?.toString() ?? 
               teamData['team_logo']?.toString();
      }
      return null;
    }

    return Match(
      id: json['id']?.toString() ?? '',
      tournamentId: json['tournament_id']?.toString() ?? '',
      homeTeam: extractTeamName(json['home_team']),
      awayTeam: extractTeamName(json['away_team']),
      homeTeamLogo: extractTeamLogo(json['home_team']) ?? json['home_team_logo']?.toString(),
      awayTeamLogo: extractTeamLogo(json['away_team']) ?? json['away_team_logo']?.toString(),
      matchDate: DateTime.tryParse(json['match_date']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? '',
      homeScore: json['home_score'] is int ? json['home_score'] : int.tryParse(json['home_score']?.toString() ?? ''),
      awayScore: json['away_score'] is int ? json['away_score'] : int.tryParse(json['away_score']?.toString() ?? ''),
      canPredict: json['can_predict'] == true || json['can_predict']?.toString().toLowerCase() == 'true',
    );
  }
}

class Prediction {
  final String id;
  final String matchId;
  final int homeScore;
  final int awayScore;
  final int points;
  final String status;
  final DateTime createdAt;

  Prediction({
    required this.id,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    required this.points,
    required this.status,
    required this.createdAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id']?.toString() ?? '',
      matchId: json['match_id']?.toString() ?? '',
      homeScore: json['home_score'] ?? 0,
      awayScore: json['away_score'] ?? 0,
      points: json['points'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'home_score': homeScore,
      'away_score': awayScore,
      'points': points,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PredictionsStats {
  final int totalPredictions;
  final int totalPoints;
  final double accuracyPercentage;
  final int currentRank;

  PredictionsStats({
    required this.totalPredictions,
    required this.totalPoints,
    required this.accuracyPercentage,
    required this.currentRank,
  });

  factory PredictionsStats.fromJson(Map<String, dynamic> json) {
    return PredictionsStats(
      totalPredictions: json['total_predictions'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      accuracyPercentage: (json['accuracy_percentage'] ?? 0).toDouble(),
      currentRank: json['current_rank'] ?? 0,
    );
  }
}

class PredictionsState {
  final List<Tournament> tournaments;
  final List<Match> matches;
  final List<Prediction> userPredictions;
  final PredictionsStats? stats;
  final bool isLoading;
  final String? error;

  PredictionsState({
    this.tournaments = const [],
    this.matches = const [],
    this.userPredictions = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  PredictionsState copyWith({
    List<Tournament>? tournaments,
    List<Match>? matches,
    List<Prediction>? userPredictions,
    PredictionsStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return PredictionsState(
      tournaments: tournaments ?? this.tournaments,
      matches: matches ?? this.matches,
      userPredictions: userPredictions ?? this.userPredictions,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PredictionsService extends StateNotifier<PredictionsState> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  final LocalDatabaseService _localDB;

  PredictionsService(this._localDB) : super(PredictionsState());

  // Récupérer les tournois
  Future<void> loadTournaments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🏆 [PredictionsService] Chargement des tournois...');

      final response = await http.get(
        Uri.parse('$baseUrl/tournaments'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tournamentsData = data['data'] ?? [];

        final tournaments = (tournamentsData as List)
            .where((item) => item is Map<String, dynamic>) // Vérification de type
            .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          tournaments: tournaments,
          isLoading: false,
        );

        print('✅ [PredictionsService] ${tournaments.length} tournois chargés');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PredictionsService] Erreur chargement tournois: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de chargement des tournois',
      );
    }
  }

  // Récupérer les matchs d'un tournoi
  Future<void> loadTournamentMatches(String tournamentId) async {
    try {
      print('⚽ [PredictionsService] Chargement matchs tournoi $tournamentId...');

      final response = await http.get(
        Uri.parse('$baseUrl/tournaments/$tournamentId/matches'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 [PredictionsService] Réponse API matchs: $data');
        
        final matchesData = data['data'] ?? [];
        print('📋 [PredictionsService] Données matchs brutes: $matchesData');

        if (matchesData is! List) {
          throw Exception('Les données de matchs ne sont pas une liste: ${matchesData.runtimeType}');
        }

        final matches = <Match>[];
        for (int i = 0; i < matchesData.length; i++) {
          final matchData = matchesData[i];
          try {
            if (matchData is Map<String, dynamic>) {
              print('🔍 [PredictionsService] Traitement match $i: $matchData');
              final match = Match.fromJson(matchData);
              matches.add(match);
              print('✅ [PredictionsService] Match $i traité: ${match.homeTeam} vs ${match.awayTeam}');
            } else {
              print('⚠️ [PredictionsService] Match $i ignoré (type: ${matchData.runtimeType}): $matchData');
            }
          } catch (e) {
            print('❌ [PredictionsService] Erreur traitement match $i: $e');
            print('📋 [PredictionsService] Données du match problématique: $matchData');
          }
        }

        state = state.copyWith(matches: matches);

        print('✅ [PredictionsService] ${matches.length} matchs chargés sur ${matchesData.length} reçus');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PredictionsService] Erreur chargement matchs: $e');
      state = state.copyWith(error: 'Erreur de chargement des matchs');
    }
  }

  // Soumettre un pronostic
  Future<bool> submitPrediction(String matchId, int homeScore, int awayScore) async {
    try {
      print('🎯 [PredictionsService] Soumission pronostic $matchId: $homeScore-$awayScore');

      final response = await http.post(
        Uri.parse('$baseUrl/predictions'),
        headers: await _getHeaders(),
        body: json.encode({
          'match_id': matchId,
          'home_score': homeScore,
          'away_score': awayScore,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Recharger les pronostics utilisateur
          await loadUserPredictions();
          print('✅ [PredictionsService] Pronostic soumis avec succès');
          return true;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      }

      return false;
    } catch (e) {
      print('❌ [PredictionsService] Erreur soumission pronostic: $e');
      return false;
    }
  }

  // Récupérer les pronostics de l'utilisateur
  Future<void> loadUserPredictions() async {
    try {
      print('📊 [PredictionsService] Chargement pronostics utilisateur...');

      // Charger depuis le cache local d'abord
      final cachedPredictions = await _localDB.getUserPredictions();
      if (cachedPredictions.isNotEmpty) {
        final predictions = cachedPredictions
            .where((item) => item is Map<String, dynamic>) // Vérification de type
            .map((json) => Prediction.fromJson(json as Map<String, dynamic>))
            .toList();
        
        state = state.copyWith(userPredictions: predictions);
        print('📋 [PredictionsService] ${predictions.length} pronostics depuis le cache');
      }

      // Puis charger depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/predictions'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictionsData = data['data'] ?? [];

        final predictions = (predictionsData as List)
            .where((item) => item is Map<String, dynamic>) // Vérification de type
            .map((json) => Prediction.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sauvegarder en cache local
        await _localDB.saveUserPredictions(
          predictions.map((p) => p.toJson()).toList(),
        );

        state = state.copyWith(userPredictions: predictions);
        print('✅ [PredictionsService] ${predictions.length} pronostics chargés');
      }
    } catch (e) {
      print('❌ [PredictionsService] Erreur chargement pronostics: $e');
    }
  }

  // Récupérer les statistiques utilisateur
  Future<void> loadUserStats() async {
    try {
      print('📈 [PredictionsService] Chargement statistiques...');

      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/my-stats'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final stats = PredictionsStats.fromJson(data['data']);
          state = state.copyWith(stats: stats);
          
          print('✅ [PredictionsService] Statistiques chargées');
          print('   - Pronostics: ${stats.totalPredictions}');
          print('   - Points: ${stats.totalPoints}');
          print('   - Précision: ${stats.accuracyPercentage}%');
          print('   - Rang: ${stats.currentRank}');
        }
      }
    } catch (e) {
      print('❌ [PredictionsService] Erreur chargement stats: $e');
    }
  }

  // Récupérer le classement utilisateur
  Future<void> loadUserRank() async {
    try {
      print('🏆 [PredictionsService] Chargement rang utilisateur...');

      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/my-rank'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && state.stats != null) {
          final rank = data['data']['rank'] ?? state.stats!.currentRank;
          final updatedStats = PredictionsStats(
            totalPredictions: state.stats!.totalPredictions,
            totalPoints: state.stats!.totalPoints,
            accuracyPercentage: state.stats!.accuracyPercentage,
            currentRank: rank,
          );
          
          state = state.copyWith(stats: updatedStats);
          print('✅ [PredictionsService] Rang mis à jour: #$rank');
        }
      }
    } catch (e) {
      print('❌ [PredictionsService] Erreur chargement rang: $e');
    }
  }

  // Méthodes utilitaires
  Future<Map<String, String>> _getHeaders() async {
    // Récupérer le token depuis le local storage
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

  // Vérifier si l'utilisateur a déjà fait un pronostic pour un match
  bool hasUserPredictedMatch(String matchId) {
    return state.userPredictions.any((p) => p.matchId == matchId);
  }

  // Obtenir le pronostic de l'utilisateur pour un match
  Prediction? getUserPredictionForMatch(String matchId) {
    try {
      return state.userPredictions.firstWhere((p) => p.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  // Méthode de test pour valider la correction de type
  Future<void> testTypeSafety() async {
    try {
      print('🧪 [PredictionsService] Test de sécurité de type...');
      
      // Simuler des données avec des types mixtes
      final testData = [
        {'id': '1', 'home_team': 'Team A', 'away_team': 'Team B', 'match_date': '2024-01-01'},
        'invalid_string_data', // Ceci devrait être filtré
        {'id': '2', 'home_team': 'Team C', 'away_team': 'Team D', 'match_date': '2024-01-02'},
        null, // Ceci devrait être filtré
      ];
      
      final validMatches = testData
          .where((item) => item is Map<String, dynamic>)
          .map((json) => Match.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [PredictionsService] Test réussi: ${validMatches.length} matchs valides sur ${testData.length} données');
      return;
    } catch (e) {
      print('❌ [PredictionsService] Test échoué: $e');
      rethrow;
    }
  }
}

// Provider pour le service de pronostics
final predictionsServiceProvider = StateNotifierProvider<PredictionsService, PredictionsState>((ref) {
  final localDB = ref.read(localDatabaseServiceProvider);
  return PredictionsService(localDB);
});