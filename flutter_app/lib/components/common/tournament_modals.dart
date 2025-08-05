/**
 * TOURNAMENT_MODALS.DART - MODALES POUR LES TOURNOIS ET CLASSEMENTS
 * 
 * FONCTIONNALITÉS :
 * - Modal pour afficher les matches d'un tournoi
 * - Modal pour faire des prédictions
 * - Modal pour afficher les classements par tournoi avec accordéons
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import 'accordion.dart';

class TournamentMatchesModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback? onPredictionSubmitted;

  const TournamentMatchesModal({
    super.key,
    required this.tournament,
    this.onPredictionSubmitted,
  });

  @override
  ConsumerState<TournamentMatchesModal> createState() => _TournamentMatchesModalState();
}

class _TournamentMatchesModalState extends ConsumerState<TournamentMatchesModal> {
  List<dynamic> _matches = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getTournamentMatches(widget.tournament['id'].toString());
      
      setState(() {
        _matches = response['success'] ? (response['data'] ?? []) : [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tournament['name'] ?? 'Tournoi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.tournament['participants_count'] ?? 0} participants',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Erreur: $_error'))
                    : _matches.isEmpty
                        ? _buildEmptyMatches()
                        : _buildMatchesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.calendar,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun match disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les matches apparaîtront bientôt',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    // Extract team names from complex objects if needed
    String getTeamName(dynamic team) {
      if (team is String) {
        return team;
      } else if (team is Map<String, dynamic>) {
        return team['name'] ?? team['title'] ?? 'Équipe';
      }
      return 'Équipe';
    }

    String getMatchDate(dynamic date) {
      if (date is String) {
        return date;
      } else if (date is Map<String, dynamic>) {
        return date['formatted'] ?? date['date'] ?? 'Date à définir';
      }
      return 'Date à définir';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Teams
            Row(
              children: [
                Expanded(
                  child: Text(
                    getTeamName(match['home_team']) ?? 'Équipe 1',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Text(' VS '),
                Expanded(
                  child: Text(
                    getTeamName(match['away_team']) ?? 'Équipe 2',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date
            Text(
              getMatchDate(match['match_date']),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: match['can_predict'] == true
                    ? () => _showPredictionDialog(match)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  match['can_predict'] == true
                      ? 'Faire un pronostic'
                      : match['user_prediction'] != null
                          ? 'Pronostic fait'
                          : 'Pronostic fermé',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPredictionDialog(Map<String, dynamic> match) {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    // Helper to extract team name
    String getTeamName(dynamic team) {
      if (team is String) {
        return team;
      } else if (team is Map<String, dynamic>) {
        return team['name'] ?? team['title'] ?? 'Équipe';
      }
      return 'Équipe';
    }

    final homeTeamName = getTeamName(match['home_team']);
    final awayTeamName = getTeamName(match['away_team']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faire un pronostic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$homeTeamName vs $awayTeamName'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: homeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: homeTeamName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: awayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: awayTeamName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _submitPrediction(
              match,
              homeController.text,
              awayController.text,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPrediction(
    Map<String, dynamic> match,
    String homeScore,
    String awayScore,
  ) async {
    if (homeScore.isEmpty || awayScore.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir les deux scores')),
      );
      return;
    }

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.submitPrediction(
        matchId: match['id'].toString(),
        homeScore: homeScore,
        awayScore: awayScore,
      );

      Navigator.pop(context); // Fermer le dialog
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pronostic enregistré !')),
        );
        widget.onPredictionSubmitted?.call();
        _loadMatches(); // Recharger les matches
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Erreur')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}

class LeaderboardModal extends ConsumerWidget {
  final List<dynamic> tournaments;

  const LeaderboardModal({
    super.key,
    required this.tournaments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Classements des Tournois',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: tournaments.isEmpty
                ? _buildEmptyLeaderboard()
                : _buildTournamentAccordions(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboard() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.trophy,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Aucun classement disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Participez aux tournois pour voir les classements',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentAccordions(WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return Accordion(
          title: '${tournament['name'] ?? 'Tournoi'} - ${tournament['participants_count'] ?? 0} participants',
          child: _buildTournamentLeaderboard(tournament, ref),
        );
      },
    );
  }

  Widget _buildTournamentLeaderboard(Map<String, dynamic> tournament, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(apiServiceProvider).getTournamentLeaderboard(tournament['id'].toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final response = snapshot.data;
        if (response == null || response['success'] != true) {
          return const Center(child: Text('Aucun classement disponible'));
        }
        
        final leaderboard = response['data'] ?? [];
        if (leaderboard.isEmpty) {
          return const Center(child: Text('Aucun participant'));
        }
        
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Joueur', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 60, child: Text('Points', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 60, child: Text('Précision', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            
            // Leaderboard entries
            ...leaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index < 3 ? const Color(0xFFE53E3E) : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(player['user_name'] ?? 'Joueur'),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${player['total_points'] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${player['accuracy'] ?? 0}%'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}