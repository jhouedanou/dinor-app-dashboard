/**
 * LEADERBOARD_SCREEN.DART - ÉCRAN DE CLASSEMENT GÉNÉRAL
 * 
 * FONCTIONNALITÉS :
 * - Classement général des pronostiqueurs
 * - Statistiques utilisateur personnelles
 * - Filtres par période
 * - Actualisation en temps réel
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/predictions_service.dart';
import '../services/local_database_service.dart';
import '../composables/use_auth_handler.dart';
import '../services/navigation_service.dart';

class LeaderboardEntry {
  final String id;
  final String userName;
  final String? userAvatar;
  final int totalPoints;
  final int totalPredictions;
  final double accuracyPercentage;
  final int rank;

  LeaderboardEntry({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.totalPoints,
    required this.totalPredictions,
    required this.accuracyPercentage,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id']?.toString() ?? '',
      userName: json['user_name'] ?? json['name'] ?? 'Anonyme',
      userAvatar: json['user_avatar'] ?? json['avatar'],
      totalPoints: json['total_points'] ?? 0,
      totalPredictions: json['total_predictions'] ?? 0,
      accuracyPercentage: (json['accuracy_percentage'] ?? 0).toDouble(),
      rank: json['rank'] ?? 0,
    );
  }
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'all'; // all, week, month

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final localDB = ref.read(localDatabaseServiceProvider);
      final authState = await localDB.getAuthState();
      
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      if (authState != null && authState['token'] != null) {
        headers['Authorization'] = 'Bearer ${authState['token']}';
      }

      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/leaderboard'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final leaderboardData = data['data'] as List;
          setState(() {
            _leaderboard = leaderboardData
                .map((json) => LeaderboardEntry.fromJson(json))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Erreur de chargement');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionsState = ref.watch(predictionsServiceProvider);
    final authState = ref.watch(useAuthHandlerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Classement',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE53E3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.pop(),
        ),
        actions: [
          IconButton(
            onPressed: _loadLeaderboard,
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques personnelles
              if (authState.isAuthenticated && predictionsState.stats != null)
                _buildUserStatsCard(predictionsState.stats!),
              
              const SizedBox(height: 24),

              // Filtres de période
              _buildPeriodFilter(),
              
              const SizedBox(height: 24),

              // Titre du classement
              const Text(
                'Classement Général',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              
              const SizedBox(height: 16),

              // Classement
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else if (_leaderboard.isNotEmpty)
                _buildLeaderboardList()
              else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStatsCard(PredictionsStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53E3E),
            Color(0xFFD53F8C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53E3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre Position',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '#${stats.currentRank}',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                '${stats.totalPoints}',
                'Points',
                LucideIcons.star,
              ),
              _buildStatColumn(
                '${stats.totalPredictions}',
                'Pronostics',
                LucideIcons.target,
              ),
              _buildStatColumn(
                '${stats.accuracyPercentage.toStringAsFixed(1)}%',
                'Précision',
                LucideIcons.trendingUp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return Row(
      children: [
        _buildFilterChip('Tout temps', 'all'),
        const SizedBox(width: 8),
        _buildFilterChip('Cette semaine', 'week'),
        const SizedBox(width: 8),
        _buildFilterChip('Ce mois', 'month'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = period);
          // TODO: Implémenter le filtrage par période
          _loadLeaderboard();
        }
      },
      selectedColor: const Color(0xFFE53E3E).withOpacity(0.2),
      checkmarkColor: const Color(0xFFE53E3E),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFE53E3E) : const Color(0xFF4A5568),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        return _buildLeaderboardCard(entry, index);
      },
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, int index) {
    final isTopThree = index < 3;
    final rankColors = [
      const Color(0xFFFFD700), // Or
      const Color(0xFFC0C0C0), // Argent
      const Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isTopThree ? Border.all(
          color: rankColors[index],
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rang avec icône pour le top 3
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? rankColors[index] : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: isTopThree
                ? Icon(
                    index == 0 ? LucideIcons.crown : LucideIcons.medal,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '${entry.rank}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A5568),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar utilisateur
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage: entry.userAvatar != null 
                ? NetworkImage(entry.userAvatar!)
                : null,
            child: entry.userAvatar == null
                ? const Icon(LucideIcons.user, size: 20)
                : null,
          ),
          const SizedBox(width: 16),

          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.totalPredictions} pronostics • ${entry.accuracyPercentage.toStringAsFixed(1)}% précision',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${entry.totalPoints} pts',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53E3E),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement du classement...',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Une erreur est survenue',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              LucideIcons.award,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun classement disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Le classement apparaîtra dès que les utilisateurs commenceront à faire des pronostics.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 