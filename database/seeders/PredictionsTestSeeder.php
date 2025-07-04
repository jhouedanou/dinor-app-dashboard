<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\FootballMatch;
use App\Models\Prediction;
use Carbon\Carbon;

class PredictionsTestSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🎯 Création de prédictions de test...');
        
        $this->createTestPredictions();
        $this->calculatePointsForFinishedMatches();
        $this->displayStatistics();
        
        $this->command->info('\n✅ Prédictions de test créées avec succès!');
    }

    private function createTestPredictions(): void
    {
        // Récupérer les utilisateurs existants
        $users = User::all();
        
        if ($users->count() === 0) {
            $this->command->warn('Aucun utilisateur trouvé. Création d\'utilisateurs de test...');
            $this->createTestUsers();
            $users = User::all();
        }

        // Récupérer tous les matchs (finis et à venir)
        $matches = FootballMatch::all();
        
        if ($matches->count() === 0) {
            $this->command->error('Aucun match trouvé. Exécutez d\'abord FootballTestDataSeeder.');
            return;
        }

        $predictions = [];

        // Créer des prédictions pour chaque match
        foreach ($matches as $match) {
            // Pour chaque match, créer des prédictions pour 3-5 utilisateurs aléatoires
            $selectedUsers = $users->random(rand(3, min(5, $users->count())));
            
            foreach ($selectedUsers as $user) {
                // Éviter les doublons
                $existingPrediction = Prediction::where('user_id', $user->id)
                    ->where('football_match_id', $match->id)
                    ->first();
                    
                if ($existingPrediction) {
                    continue;
                }

                // Générer des scores réalistes
                $homeScore = $this->generateRealisticScore();
                $awayScore = $this->generateRealisticScore();
                
                // Déterminer le gagnant prédit
                $predictedWinner = 'draw';
                if ($homeScore > $awayScore) {
                    $predictedWinner = 'home';
                } elseif ($awayScore > $homeScore) {
                    $predictedWinner = 'away';
                }

                $predictions[] = [
                    'user_id' => $user->id,
                    'football_match_id' => $match->id,
                    'predicted_home_score' => $homeScore,
                    'predicted_away_score' => $awayScore,
                    'predicted_winner' => $predictedWinner,
                    'points_earned' => 0,
                    'is_calculated' => false,
                    'ip_address' => $this->generateRandomIP(),
                    'user_agent' => 'Dinor PWA Test Agent',
                    'created_at' => $this->generatePredictionDate($match),
                    'updated_at' => now()
                ];
            }
        }

        // Insérer toutes les prédictions
        foreach ($predictions as $prediction) {
            Prediction::create($prediction);
        }

        $this->command->info('- ' . count($predictions) . ' prédictions créées');
    }

    private function createTestUsers(): void
    {
        $testUsers = [
            [
                'name' => 'Koffi Pronostiqueur',
                'email' => 'koffi@test.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Aya Football Fan',
                'email' => 'aya@test.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Mamadou Expert',
                'email' => 'mamadou@test.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Fatou Predictions',
                'email' => 'fatou@test.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Ibrahim Score Master',
                'email' => 'ibrahim@test.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ]
        ];

        foreach ($testUsers as $userData) {
            User::firstOrCreate(['email' => $userData['email']], $userData);
        }

        $this->command->info('- 5 utilisateurs de test créés');
    }

    private function generateRealisticScore(): int
    {
        // Scores plus réalistes pour le football
        $scores = [0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4]; // 0-1 plus fréquents
        return $scores[array_rand($scores)];
    }

    private function generateRandomIP(): string
    {
        return rand(192, 223) . '.' . rand(1, 254) . '.' . rand(1, 254) . '.' . rand(1, 254);
    }

    private function generatePredictionDate($match): Carbon
    {
        // Les prédictions sont faites quelques heures à quelques jours avant le match
        $matchDate = Carbon::parse($match->match_date);
        
        if ($match->status === 'finished') {
            // Pour les matchs finis, prédiction faite 1-24h avant
            return $matchDate->subHours(rand(1, 24));
        } else {
            // Pour les matchs à venir, prédiction faite récemment
            return now()->subHours(rand(1, 48));
        }
    }

    private function calculatePointsForFinishedMatches(): void
    {
        $finishedMatches = FootballMatch::where('status', 'finished')->get();
        $calculatedPredictions = 0;

        foreach ($finishedMatches as $match) {
            $predictions = Prediction::where('football_match_id', $match->id)
                ->where('is_calculated', false)
                ->get();

            foreach ($predictions as $prediction) {
                $points = $prediction->calculatePoints();
                $calculatedPredictions++;
            }
        }

        $this->command->info('- Points calculés pour ' . $calculatedPredictions . ' prédictions');
    }

    private function displayStatistics(): void
    {
        $totalPredictions = Prediction::count();
        $calculatedPredictions = Prediction::where('is_calculated', true)->count();
        $pendingPredictions = Prediction::where('is_calculated', false)->count();
        
        $this->command->info('\n=== STATISTIQUES DES PRÉDICTIONS ===');
        $this->command->info('- Total des prédictions: ' . $totalPredictions);
        $this->command->info('- Prédictions calculées: ' . $calculatedPredictions);
        $this->command->info('- Prédictions en attente: ' . $pendingPredictions);

        // Top 3 des pronostiqueurs
        $topPredictors = User::select('users.*')
            ->join('predictions', 'users.id', '=', 'predictions.user_id')
            ->where('predictions.is_calculated', true)
            ->selectRaw('users.*, COUNT(predictions.id) as predictions_count, SUM(predictions.points_earned) as total_points')
            ->groupBy('users.id', 'users.name', 'users.email', 'users.email_verified_at', 'users.password', 'users.remember_token', 'users.created_at', 'users.updated_at', 'users.role', 'users.is_active')
            ->orderByDesc('total_points')
            ->limit(3)
            ->get();

        if ($topPredictors->count() > 0) {
            $this->command->info('\n=== TOP PRONOSTIQUEURS ===');
            foreach ($topPredictors as $index => $user) {
                $position = $index + 1;
                $points = $user->total_points ?? 0;
                $predictions = $user->predictions_count ?? 0;
                $this->command->info("{$position}. {$user->name}: {$points} points ({$predictions} prédictions)");
            }
        }

        // Statistiques par compétition
        $competitionStats = FootballMatch::join('predictions', 'football_matches.id', '=', 'predictions.football_match_id')
            ->selectRaw('competition, COUNT(predictions.id) as prediction_count')
            ->groupBy('competition')
            ->get();

        if ($competitionStats->count() > 0) {
            $this->command->info('\n=== PRÉDICTIONS PAR COMPÉTITION ===');
            foreach ($competitionStats as $stat) {
                $this->command->info('- ' . $stat->competition . ': ' . $stat->prediction_count . ' prédictions');
            }
        }
    }
}