<?php

/*
 * Script pour créer un tournoi de paris pour l'utilisateur ID 4
 * À exécuter avec : php create_tournament_betting.php
 */

require_once 'vendor/autoload.php';

// Configuration de base Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Tournament;
use App\Models\User;
use App\Models\Team;
use App\Models\FootballMatch;
use App\Models\TournamentParticipant;
use Carbon\Carbon;

echo "🏆 Création d'un tournoi de paris pour l'utilisateur ID 4...\n\n";

// Vérifier que l'utilisateur ID 4 existe
$user = User::find(4);
if (!$user) {
    echo "❌ Erreur: L'utilisateur ID 4 n'existe pas.\n";
    exit(1);
}

echo "✅ Utilisateur trouvé: {$user->name} (ID: {$user->id})\n";

// Créer ou trouver des équipes
$teams = [];
$teamData = [
    ['name' => 'FC Barcelone', 'country' => 'ESP', 'logo' => '/images/teams/barcelona.png'],
    ['name' => 'Real Madrid', 'country' => 'ESP', 'logo' => '/images/teams/real_madrid.png'],
    ['name' => 'Manchester City', 'country' => 'ENG', 'logo' => '/images/teams/man_city.png'],
    ['name' => 'Bayern Munich', 'country' => 'GER', 'logo' => '/images/teams/bayern.png'],
    ['name' => 'Paris Saint-Germain', 'country' => 'FRA', 'logo' => '/images/teams/psg.png'],
    ['name' => 'Liverpool', 'country' => 'ENG', 'logo' => '/images/teams/liverpool.png'],
    ['name' => 'AC Milan', 'country' => 'ITA', 'logo' => '/images/teams/milan.png'],
    ['name' => 'Juventus', 'country' => 'ITA', 'logo' => '/images/teams/juventus.png'],
];

echo "\n📋 Création des équipes...\n";
foreach ($teamData as $teamInfo) {
    $team = Team::firstOrCreate(
        ['name' => $teamInfo['name']],
        [
            'country' => $teamInfo['country'],
            'logo' => $teamInfo['logo'],
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now()
        ]
    );
    $teams[] = $team;
    echo "  ✅ {$team->name} (ID: {$team->id})\n";
}

// Créer le tournoi
echo "\n🏆 Création du tournoi...\n";
$tournament = Tournament::create([
    'name' => 'Tournoi de Paris Champions League 2024',
    'slug' => 'tournoi-paris-champions-league-2024',
    'description' => 'Tournoi de pronostics pour la Champions League 2024. Pariez sur vos équipes favorites et gagnez des prix !',
    'start_date' => Carbon::now()->addDays(1),
    'end_date' => Carbon::now()->addDays(30),
    'registration_start' => Carbon::now()->subDays(1),
    'registration_end' => Carbon::now()->addDays(7),
    'prediction_deadline' => Carbon::now()->addDays(25),
    'max_participants' => 100,
    'entry_fee' => 5000.00, // 5000 XOF
    'currency' => 'XOF',
    'prize_pool' => 500000.00, // 500,000 XOF
    'status' => Tournament::STATUS_REGISTRATION_OPEN,
    'rules' => [
        'scoring' => [
            'exact_score' => 3,
            'correct_winner' => 1,
            'wrong_prediction' => 0
        ],
        'betting_rules' => [
            'min_predictions' => 3,
            'max_predictions_per_match' => 1,
            'prediction_deadline' => '15 minutes avant le match'
        ]
    ],
    'image' => '/images/tournaments/champions_league_2024.jpg',
    'is_featured' => true,
    'is_public' => true,
    'created_by' => 1 // Admin user
]);

echo "✅ Tournoi créé: {$tournament->name} (ID: {$tournament->id})\n";

// Enregistrer l'utilisateur ID 4 au tournoi
echo "\n👤 Inscription de l'utilisateur au tournoi...\n";
$participant = $tournament->registerUser($user);

if ($participant) {
    echo "✅ {$user->name} inscrit au tournoi avec succès!\n";
} else {
    echo "❌ Erreur lors de l'inscription de {$user->name} au tournoi.\n";
}

// Créer des matchs pour le tournoi
echo "\n⚽ Création des matchs...\n";
$matches = [];
$matchData = [
    ['home' => 0, 'away' => 1, 'date' => Carbon::now()->addDays(2), 'round' => 'Quart de finale'],
    ['home' => 2, 'away' => 3, 'date' => Carbon::now()->addDays(3), 'round' => 'Quart de finale'],
    ['home' => 4, 'away' => 5, 'date' => Carbon::now()->addDays(4), 'round' => 'Quart de finale'],
    ['home' => 6, 'away' => 7, 'date' => Carbon::now()->addDays(5), 'round' => 'Quart de finale'],
    ['home' => 0, 'away' => 2, 'date' => Carbon::now()->addDays(10), 'round' => 'Demi-finale'],
    ['home' => 4, 'away' => 6, 'date' => Carbon::now()->addDays(11), 'round' => 'Demi-finale'],
    ['home' => 0, 'away' => 4, 'date' => Carbon::now()->addDays(20), 'round' => 'Finale'],
];

foreach ($matchData as $matchInfo) {
    $homeTeam = $teams[$matchInfo['home']];
    $awayTeam = $teams[$matchInfo['away']];
    
    $match = FootballMatch::create([
        'tournament_id' => $tournament->id,
        'home_team_id' => $homeTeam->id,
        'away_team_id' => $awayTeam->id,
        'match_date' => $matchInfo['date'],
        'predictions_close_at' => $matchInfo['date']->copy()->subMinutes(15),
        'status' => 'scheduled',
        'competition' => 'Champions League',
        'round' => $matchInfo['round'],
        'venue' => 'Stade Olympique',
        'is_active' => true,
        'predictions_enabled' => true,
        'created_at' => now(),
        'updated_at' => now()
    ]);
    
    $matches[] = $match;
    echo "  ✅ {$homeTeam->name} vs {$awayTeam->name} - {$matchInfo['round']} ({$matchInfo['date']->format('d/m/Y H:i')})\n";
}

// Afficher le résumé
echo "\n🎯 RÉSUMÉ DU TOURNOI CRÉÉ\n";
echo "==========================================\n";
echo "📛 Nom: {$tournament->name}\n";
echo "📅 Dates: {$tournament->start_date->format('d/m/Y')} - {$tournament->end_date->format('d/m/Y')}\n";
echo "💰 Frais d'inscription: {$tournament->entry_fee} {$tournament->currency}\n";
echo "🏆 Cagnotte: {$tournament->prize_pool} {$tournament->currency}\n";
echo "👥 Participants max: {$tournament->max_participants}\n";
echo "⚽ Nombre de matchs: " . count($matches) . "\n";
echo "🎮 Statut: {$tournament->status_label}\n";
echo "👤 Utilisateur inscrit: {$user->name} (ID: {$user->id})\n";

echo "\n🔗 LIENS UTILES\n";
echo "==========================================\n";
echo "🌐 Interface de paris: http://localhost:8000/predictions\n";
echo "📊 Classement: http://localhost:8000/predictions/leaderboard\n";
echo "🏆 Détails du tournoi: http://localhost:8000/tournaments/{$tournament->id}\n";
echo "⚽ Liste des matchs: http://localhost:8000/predictions/teams\n";

echo "\n✅ Tournoi créé avec succès ! L'utilisateur ID 4 peut maintenant parier sur les matchs.\n";
echo "📱 Pour tester les paris, connectez-vous avec l'utilisateur ID 4 et allez sur /predictions\n";