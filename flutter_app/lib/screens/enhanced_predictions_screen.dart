/**
 * ENHANCED_PREDICTIONS_SCREEN.DART - ÉCRAN DE PRONOSTICS COMPLET
 * 
 * FONCTIONNALITÉS (basées sur la PWA) :
 * - Liste des tournois avec statuts
 * - Matchs par tournoi avec équipes et logos
 * - Interface de pronostics en temps réel
 * - Sauvegarde automatique avec feedback visuel
 * - Règles de points (3 points score exact, 1 point bon vainqueur)
 * - Authentification intégrée
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/predictions_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

class EnhancedPredictionsScreen extends ConsumerStatefulWidget {
  const EnhancedPredictionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedPredictionsScreen> createState() => _EnhancedPredictionsScreenState();
}

class _EnhancedPredictionsScreenState extends ConsumerState<EnhancedPredictionsScreen> {
  bool _showAuthModal = false;
  Tournament? _selectedTournament;
  Map<String, Map<String, int>> _predictions = {}; // matchId -> {homeScore, awayScore}
  Set<String> _savingMatches = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(predictionsServiceProvider.notifier).loadTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final predictionsState = ref.watch(predictionsServiceProvider);
    final authState = ref.watch(useAuthHandlerProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Pronostics',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFE53E3E),
            elevation: 0,
            toolbarHeight: 56,
            actions: [
              if (_selectedTournament != null)
                IconButton(
                  onPressed: () => setState(() {
                    _selectedTournament = null;
                    _predictions.clear();
                    _savingMatches.clear();
                  }),
                  icon: const Icon(LucideIcons.x),
                ),
            ],
          ),
          body: _selectedTournament == null
              ? _buildTournamentsList(predictionsState, authState)
              : _buildTournamentMatches(predictionsState, authState),
        ),

        // Modal d'authentification
        if (_showAuthModal) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () => setState(() => _showAuthModal = false),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned.fill(
            child: AuthModal(
              isOpen: _showAuthModal,
              onClose: () => setState(() => _showAuthModal = false),
              onAuthenticated: () async {
                setState(() => _showAuthModal = false);
                // Recharger les données utilisateur si nécessaire
                if (_selectedTournament != null) {
                  await ref.read(predictionsServiceProvider.notifier).loadTournamentMatches(_selectedTournament!.id);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTournamentsList(PredictionsState state, dynamic authState) {
    if (state.isLoading) {
      return _buildLoadingState('Chargement des tournois...');
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, () {
        ref.read(predictionsServiceProvider.notifier).loadTournaments();
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(predictionsServiceProvider.notifier).loadTournaments();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Tournaments List
            if (state.tournaments.isNotEmpty)
              _buildTournamentCards(state.tournaments)
            else
              _buildEmptyTournaments(),

            const SizedBox(height: 24),

            // Rules Section
            _buildRulesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentMatches(PredictionsState state, dynamic authState) {
    if (state.isLoading) {
      return _buildLoadingState('Chargement des matchs...');
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, () {
        ref.read(predictionsServiceProvider.notifier).loadTournamentMatches(_selectedTournament!.id);
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(predictionsServiceProvider.notifier).loadTournamentMatches(_selectedTournament!.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Header
            _buildTournamentHeader(),
            const SizedBox(height: 24),

            // Matches List
            if (state.matches.isNotEmpty)
              _buildMatchesList(state.matches, authState)
            else
              _buildEmptyMatches(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Pronostics',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Participez aux tournois et gagnez des points en prédisant les résultats !',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTournamentCards(List<Tournament> tournaments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openTournament(tournament),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tournament.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(tournament.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tournament.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(tournament.status),
                      ),
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: Color(0xFF4A5568),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tournament Info
              Text(
                tournament.name,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tournament.description,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Tournament Stats
              Row(
                children: [
                  _buildStatItem(LucideIcons.users, '${tournament.participantsCount} participants'),
                  const SizedBox(width: 20),
                  if (tournament.prizePool != null)
                    _buildStatItem(LucideIcons.trophy, tournament.prizePool!),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatItem(LucideIcons.calendar, _formatTournamentDate(tournament.startDate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A5568)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentHeader() {
    if (_selectedTournament == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedTournament!.name,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedTournament!.description,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(List<Match> matches, dynamic authState) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(match, authState);
      },
    );
  }

  Widget _buildMatchCard(Match match, dynamic authState) {
    final isSaving = _savingMatches.contains(match.id);
    final prediction = _predictions[match.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSaving ? const Color(0xFFE53E3E) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Match Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatMatchDate(match.matchDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5568),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: match.canPredict 
                        ? const Color(0xFF38A169).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.canPredict ? 'Ouvert' : 'Fermé',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: match.canPredict 
                          ? const Color(0xFF38A169)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Teams
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        match.homeTeam,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A5568),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        match.awayTeam,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Prediction Form
            if (match.canPredict) ...[
              if (authState.isAuthenticated)
                _buildPredictionForm(match)
              else
                _buildAuthRequiredButton(),
            ] else ...[
              if (prediction != null)
                _buildPredictionResult(prediction)
              else
                const Text(
                  'Pronostics fermés',
                  style: TextStyle(
                    color: Color(0xFF4A5568),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionForm(Match match) {
    final prediction = _predictions[match.id] ?? {'homeScore': 0, 'awayScore': 0};
    final isSaving = _savingMatches.contains(match.id);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Home Score
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                initialValue: prediction['homeScore'].toString(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updatePrediction(match.id, 'homeScore', value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Text('-', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(width: 20),
            // Away Score
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                initialValue: prediction['awayScore'].toString(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updatePrediction(match.id, 'awayScore', value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isSaving)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Sauvegarde...', style: TextStyle(color: Color(0xFF4A5568))),
            ],
          ),
      ],
    );
  }

  Widget _buildAuthRequiredButton() {
    return ElevatedButton.icon(
      onPressed: () => setState(() => _showAuthModal = true),
      icon: const Icon(LucideIcons.user),
      label: const Text('Se connecter pour pronostiquer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildPredictionResult(Map<String, int> prediction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE53E3E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Votre pronostic: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${prediction['homeScore']} - ${prediction['awayScore']}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.info, size: 20, color: Color(0xFFE53E3E)),
              SizedBox(width: 8),
              Text(
                'Règles des pronostics',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleItem('3 points', 'Score exact'),
          const SizedBox(height: 8),
          _buildRuleItem('1 point', 'Bon vainqueur'),
          const SizedBox(height: 8),
          _buildRuleItem('0 point', 'Pronostic incorrect'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String points, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              points.split(' ')[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _openTournament(Tournament tournament) async {
    setState(() => _selectedTournament = tournament);
    await ref.read(predictionsServiceProvider.notifier).loadTournamentMatches(tournament.id);
  }

  void _updatePrediction(String matchId, String scoreType, String value) {
    final score = int.tryParse(value) ?? 0;
    if (!_predictions.containsKey(matchId)) {
      _predictions[matchId] = {'homeScore': 0, 'awayScore': 0};
    }
    _predictions[matchId]![scoreType] = score;

    // Auto-save après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      _savePrediction(matchId);
    });
  }

  Future<void> _savePrediction(String matchId) async {
    final prediction = _predictions[matchId];
    if (prediction == null) return;

    setState(() => _savingMatches.add(matchId));

    try {
      final success = await ref.read(predictionsServiceProvider.notifier).submitPrediction(
        matchId,
        prediction['homeScore']!,
        prediction['awayScore']!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pronostic sauvegardé'),
            backgroundColor: Color(0xFF38A169),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Échec de la sauvegarde');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _savingMatches.remove(matchId));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'registration_open':
        return const Color(0xFF38A169);
      case 'upcoming':
        return const Color(0xFF3182CE);
      case 'finished':
        return const Color(0xFF4A5568);
      default:
        return const Color(0xFFE53E3E);
    }
  }

  String _formatTournamentDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays < 0) {
      return 'Terminé';
    } else if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Demain';
    } else if (difference.inDays < 7) {
      return 'Dans ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatMatchDate(DateTime date) {
    return '${date.day}/${date.month} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              error,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
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

  Widget _buildEmptyTournaments() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              LucideIcons.trophy,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun tournoi disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les nouveaux tournois apparaîtront ici dès qu\'ils seront disponibles.',
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

  Widget _buildEmptyMatches() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              LucideIcons.target,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun match disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les matchs apparaîtront ici dès qu\'ils seront programmés.',
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