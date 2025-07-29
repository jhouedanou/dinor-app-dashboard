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
    return Match(
      id: json['id']?.toString() ?? '',
      tournamentId: json['tournament_id']?.toString() ?? '',
      homeTeam: json['home_team'] ?? '',
      awayTeam: json['away_team'] ?? '',
      homeTeamLogo: json['home_team_logo'],
      awayTeamLogo: json['away_team_logo'],
      matchDate: DateTime.tryParse(json['match_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      homeScore: json['home_score'],
      awayScore: json['away_score'],
      canPredict: json['can_predict'] ?? false,
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
            .map((json) => Tournament.fromJson(json))
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
        final matchesData = data['data'] ?? [];

        final matches = (matchesData as List)
            .map((json) => Match.fromJson(json))
            .toList();

        state = state.copyWith(matches: matches);

        print('✅ [PredictionsService] ${matches.length} matchs chargés');
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
            .map((json) => Prediction.fromJson(json))
            .toList();
        
        state = state.copyWith(userPredictions: predictions);
        print('📋 [PredictionsService] ${predictions.length} pronostics depuis le cache');
      }

      // Puis charger depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/user/predictions'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictionsData = data['data'] ?? [];

        final predictions = (predictionsData as List)
            .map((json) => Prediction.fromJson(json))
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
        Uri.parse('$baseUrl/user/predictions/stats'),
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
}

// Provider pour le service de pronostics
final predictionsServiceProvider = StateNotifierProvider<PredictionsService, PredictionsState>((ref) {
  final localDB = ref.read(localDatabaseServiceProvider);
  return PredictionsService(localDB);
});