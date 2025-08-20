/**
 * PREDICTIONS_SCREEN.DART - ÉCRAN DE PRONOSTICS COMPLET
 * 
 * FONCTIONNALITÉS :
 * - Liste des tournois avec statuts
 * - Matchs par tournoi avec équipes
 * - Interface de pronostics en temps réel
 * - Sauvegarde automatique avec feedback visuel
 * - Règles de points et statistiques
 * - Authentification intégrée
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/predictions_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';
import '../services/navigation_service.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> 
    with SingleTickerProviderStateMixin {
  
  // État de l'interface
  bool _showAuthModal = false;
  Tournament? _selectedTournament;
  TabController? _tabController;
  
  // Pronostics et état de sauvegarde
  Map<String, Map<String, int>> _predictions = {}; // matchId -> {homeScore, awayScore}
  Set<String> _savingMatches = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les données initiales
    Future.microtask(() {
      ref.read(predictionsServiceProvider.notifier).loadTournaments();
      ref.read(predictionsServiceProvider.notifier).loadUserStats();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predictionsState = ref.watch(predictionsServiceProvider);
    final authState = ref.watch(useAuthHandlerProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Pronostics',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFE53E3E),
            elevation: 0,
            toolbarHeight: 48,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => NavigationService.pop(),
            ),
            actions: [
              if (_selectedTournament != null)
                IconButton(
                  onPressed: () => setState(() {
                    _selectedTournament = null;
                    _predictions.clear();
                    _savingMatches.clear();
                  }),
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                ),
              IconButton(
                onPressed: () => _showStatsDialog(predictionsState.stats),
                icon: const Icon(LucideIcons.barChart, color: Colors.white),
              ),
            ],
            bottom: _selectedTournament == null ? TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Tournois', icon: Icon(LucideIcons.trophy)),
                Tab(text: 'Mes Pronostics', icon: Icon(LucideIcons.target)),
                Tab(text: 'Classement', icon: Icon(LucideIcons.award)),
              ],
            ) : null,
          ),
          body: _selectedTournament == null
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTournamentsTab(predictionsState, authState),
                    _buildUserPredictionsTab(predictionsState, authState),
                    _buildLeaderboardTab(predictionsState, authState),
                  ],
                )
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
                // Recharger les données utilisateur
                await ref.read(predictionsServiceProvider.notifier).loadUserPredictions();
                await ref.read(predictionsServiceProvider.notifier).loadUserStats();
                if (_selectedTournament != null) {
                  await ref.read(predictionsServiceProvider.notifier)
                      .loadTournamentMatches(_selectedTournament!.id);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  // Onglet des tournois
  Widget _buildTournamentsTab(PredictionsState state, dynamic authState) {
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
            // Header avec statistiques
            _buildStatsCard(state.stats),
            const SizedBox(height: 24),

            // Liste des tournois
            if (state.tournaments.isNotEmpty) ...[
              const Text(
                'Tournois disponibles',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              ...state.tournaments.map((tournament) => _buildTournamentCard(tournament)),
            ] else
              _buildEmptyTournaments(),

            const SizedBox(height: 24),

            // Section des règles
            _buildRulesSection(),
          ],
        ),
      ),
    );
  }

  // Onglet des pronostics utilisateur
  Widget _buildUserPredictionsTab(PredictionsState state, dynamic authState) {
    if (!authState.isAuthenticated) {
      return _buildAuthRequired();
    }

    if (state.userPredictions.isEmpty) {
      return _buildEmptyPredictions();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(predictionsServiceProvider.notifier).loadUserPredictions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.userPredictions.length,
        itemBuilder: (context, index) {
          final prediction = state.userPredictions[index];
          return _buildUserPredictionCard(prediction);
        },
      ),
    );
  }

  // Onglet du classement
  Widget _buildLeaderboardTab(PredictionsState state, dynamic authState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.award,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Classement Général',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consultez le classement général et votre position parmi tous les pronostiqueurs !',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => NavigationService.navigateTo('/leaderboard'),
              icon: const Icon(LucideIcons.externalLink),
              label: const Text('Voir le classement complet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carte des statistiques utilisateur
  Widget _buildStatsCard(PredictionsStats? stats) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'Mes Statistiques',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${stats.totalPredictions}',
                'Pronostics',
                LucideIcons.target,
              ),
              _buildStatItem(
                '${stats.totalPoints}',
                'Points',
                LucideIcons.star,
              ),
              _buildStatItem(
                '${stats.accuracyPercentage.toStringAsFixed(1)}%',
                'Précision',
                LucideIcons.trendingUp,
              ),
              _buildStatItem(
                '#${stats.currentRank}',
                'Rang',
                LucideIcons.award,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
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

  // Carte de tournoi
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
              // Header avec statut
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

              // Informations du tournoi
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

              // Statistiques du tournoi
              Row(
                children: [
                  _buildTournamentStatItem(
                    LucideIcons.users, 
                    '${tournament.participantsCount} participants'
                  ),
                  const SizedBox(width: 20),
                  if (tournament.prizePool != null)
                    _buildTournamentStatItem(
                      LucideIcons.trophy, 
                      tournament.prizePool!
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTournamentStatItem(
                LucideIcons.calendar, 
                _formatTournamentDate(tournament.startDate)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentStatItem(IconData icon, String text) {
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

  // Section des matchs d'un tournoi
  Widget _buildTournamentMatches(PredictionsState state, dynamic authState) {
    if (state.isLoading) {
      return _buildLoadingState('Chargement des matchs...');
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, () {
        ref.read(predictionsServiceProvider.notifier)
            .loadTournamentMatches(_selectedTournament!.id);
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(predictionsServiceProvider.notifier)
            .loadTournamentMatches(_selectedTournament!.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du tournoi
            _buildTournamentHeader(),
            const SizedBox(height: 24),

            // Liste des matchs
            if (state.matches.isNotEmpty)
              ...state.matches.map((match) => _buildMatchCard(match, authState))
            else
              _buildEmptyMatches(),
          ],
        ),
      ),
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

  // Carte de match avec formulaire de pronostic
  Widget _buildMatchCard(Match match, dynamic authState) {
    final isSaving = _savingMatches.contains(match.id);
    final prediction = _predictions[match.id];
    final userPrediction = ref.read(predictionsServiceProvider.notifier)
        .getUserPredictionForMatch(match.id);

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
            // En-tête du match
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

            // Équipes
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Logo équipe domicile si disponible
                      if (match.homeTeamLogo != null)
                        Image.network(
                          match.homeTeamLogo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(LucideIcons.shield, size: 40),
                        )
                      else
                        const Icon(LucideIcons.shield, size: 40),
                      const SizedBox(height: 8),
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
                      // Logo équipe extérieure si disponible
                      if (match.awayTeamLogo != null)
                        Image.network(
                          match.awayTeamLogo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(LucideIcons.shield, size: 40),
                        )
                      else
                        const Icon(LucideIcons.shield, size: 40),
                      const SizedBox(height: 8),
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

            // Score final si le match est terminé
            if (match.status == 'finished' && match.homeScore != null && match.awayScore != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Score final: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF38A169),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Formulaire de pronostic ou résultat
            if (match.canPredict) ...[
              if (authState.isAuthenticated)
                _buildPredictionForm(match)
              else
                _buildAuthRequiredButton(),
            ] else ...[
              if (userPrediction != null)
                _buildPredictionResult(userPrediction)
              else
                const Text(
                  'Pronostics fermés',
                  style: TextStyle(
                    color: Color(0xFF4A5568),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],

            // Indicateur de sauvegarde
            if (isSaving)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
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
              ),
          ],
        ),
      ),
    );
  }

  // Formulaire de pronostic
  Widget _buildPredictionForm(Match match) {
    final prediction = _predictions[match.id] ?? {'homeScore': 0, 'awayScore': 0};

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score équipe domicile
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
            // Score équipe extérieure
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

  Widget _buildPredictionResult(Prediction prediction) {
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
            '${prediction.homeScore} - ${prediction.awayScore}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFE53E3E),
            ),
          ),
          if (prediction.points > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF38A169),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${prediction.points} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Carte de pronostic utilisateur
  Widget _buildUserPredictionCard(Prediction prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match #${prediction.matchId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pronostic: ${prediction.homeScore} - ${prediction.awayScore}',
                  style: const TextStyle(
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: prediction.points > 0 
                  ? const Color(0xFF38A169) 
                  : const Color(0xFF4A5568),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${prediction.points} pts',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section des règles
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

  // États vides et d'erreur
  Widget _buildAuthRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.user,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connexion requise',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connectez-vous pour voir vos pronostics',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _showAuthModal = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPredictions() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.target,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun pronostic',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore fait de pronostics',
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              LucideIcons.target,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun match disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
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

  // Méthodes utilitaires
  void _openTournament(Tournament tournament) async {
    setState(() => _selectedTournament = tournament);
    await ref.read(predictionsServiceProvider.notifier)
        .loadTournamentMatches(tournament.id);
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
      final success = await ref.read(predictionsServiceProvider.notifier)
          .submitPrediction(
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

  void _showStatsDialog(PredictionsStats? stats) {
    if (stats == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Mes Statistiques',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogStatRow('Total des pronostics', '${stats.totalPredictions}'),
            _buildDialogStatRow('Points totaux', '${stats.totalPoints}'),
            _buildDialogStatRow('Précision', '${stats.accuracyPercentage.toStringAsFixed(1)}%'),
            _buildDialogStatRow('Classement actuel', '#${stats.currentRank}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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
}