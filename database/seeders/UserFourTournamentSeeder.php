<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Tournament;
use App\Models\Team;
use App\Models\FootballMatch;
use App\Models\TournamentParticipant;
use App\Models\User;
use Carbon\Carbon;

class UserFourTournamentSeeder extends Seeder
{
    /**
     * Run the database seeder.
     */
    public function run(): void
    {
        // Vérifier que l'utilisateur ID 4 existe
        $user = User::find(4);
        if (!$user) {
            $this->command->warn('Utilisateur ID 4 introuvable. Création d\'un utilisateur...');
            $user = User::create([
                'name' => 'Parieur Expert',
                'email' => 'expert@dinor.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
                'role' => 'user',
                'status' => 'active'
            ]);
            $this->command->info("Utilisateur créé avec l'ID: {$user->id}");
        }

        // Créer le tournoi spécial pour l'utilisateur 4
        $tournament = Tournament::create([
            'name' => 'Championnat Elite Dinor 2025',
            'slug' => 'championnat-elite-dinor-2025',
            'description' => 'Tournoi exclusif réservé aux meilleurs parieurs. Rejoignez ce championnat prestigieux et montrez vos compétences en prédiction !',
            'start_date' => Carbon::now()->addDays(2),
            'end_date' => Carbon::now()->addDays(30),
            'registration_start' => Carbon::now()->subDay(),
            'registration_end' => Carbon::now()->addDay(),
            'prediction_deadline' => Carbon::now()->addDays(25),
            'max_participants' => 50,
            'entry_fee' => 100.00,
            'currency' => 'EUR',
            'prize_pool' => 5000.00,
            'status' => 'registration_open',
            'rules' => [
                'scoring' => [
                    'exact_score' => 3,
                    'correct_winner' => 1,
                    'wrong_prediction' => 0
                ],
                'betting' => [
                    'min_bet' => 10,
                    'max_bet' => 500,
                    'currency' => 'points'
                ],
                'restrictions' => [
                    'max_predictions_per_day' => 5,
                    'late_predictions_allowed' => false
                ]
            ],
            'image' => 'tournaments/elite-championship.jpg',
            'is_featured' => true,
            'is_public' => true,
            'created_by' => 1 // Admin user
        ]);

        $this->command->info("Tournoi créé : {$tournament->name} (ID: {$tournament->id})");

        // Créer des équipes si elles n'existent pas déjà
        $teams = collect([
            ['name' => 'Paris Saint-Germain', 'short_name' => 'PSG', 'country' => 'France', 'logo' => 'teams/psg.png'],
            ['name' => 'Real Madrid', 'short_name' => 'RMA', 'country' => 'Espagne', 'logo' => 'teams/real.png'],
            ['name' => 'Bayern Munich', 'short_name' => 'BAY', 'country' => 'Allemagne', 'logo' => 'teams/bayern.png'],
            ['name' => 'Manchester City', 'short_name' => 'MCI', 'country' => 'Angleterre', 'logo' => 'teams/city.png'],
            ['name' => 'Barcelona', 'short_name' => 'BAR', 'country' => 'Espagne', 'logo' => 'teams/barca.png'],
            ['name' => 'Liverpool', 'short_name' => 'LIV', 'country' => 'Angleterre', 'logo' => 'teams/liverpool.png'],
            ['name' => 'Juventus', 'short_name' => 'JUV', 'country' => 'Italie', 'logo' => 'teams/juventus.png'],
            ['name' => 'AC Milan', 'short_name' => 'MIL', 'country' => 'Italie', 'logo' => 'teams/milan.png']
        ])->map(function ($teamData) {
            return Team::firstOrCreate(
                ['name' => $teamData['name']],
                $teamData
            );
        });

        $this->command->info("Équipes créées/récupérées : {$teams->count()} équipes");

        // Inscrire automatiquement l'utilisateur 4 au tournoi
        TournamentParticipant::create([
            'tournament_id' => $tournament->id,
            'user_id' => $user->id,
            'registration_date' => Carbon::now(),
            'status' => 'confirmed',
            'points' => 0,
            'rank' => null
        ]);

        $this->command->info("Utilisateur {$user->name} inscrit au tournoi");

        // Créer des matchs pour le tournoi
        $matches = [
            // Phase de groupes - Semaine 1
            [
                'home_team' => $teams->where('short_name', 'PSG')->first(),
                'away_team' => $teams->where('short_name', 'RMA')->first(),
                'match_date' => Carbon::now()->addDays(3)->setTime(20, 0),
                'round' => 'Phase de groupes - J1'
            ],
            [
                'home_team' => $teams->where('short_name', 'BAY')->first(),
                'away_team' => $teams->where('short_name', 'MCI')->first(),
                'match_date' => Carbon::now()->addDays(3)->setTime(22, 0),
                'round' => 'Phase de groupes - J1'
            ],
            [
                'home_team' => $teams->where('short_name', 'BAR')->first(),
                'away_team' => $teams->where('short_name', 'LIV')->first(),
                'match_date' => Carbon::now()->addDays(4)->setTime(20, 0),
                'round' => 'Phase de groupes - J1'
            ],
            [
                'home_team' => $teams->where('short_name', 'JUV')->first(),
                'away_team' => $teams->where('short_name', 'MIL')->first(),
                'match_date' => Carbon::now()->addDays(4)->setTime(22, 0),
                'round' => 'Phase de groupes - J1'
            ],

            // Phase de groupes - Semaine 2
            [
                'home_team' => $teams->where('short_name', 'RMA')->first(),
                'away_team' => $teams->where('short_name', 'BAY')->first(),
                'match_date' => Carbon::now()->addDays(10)->setTime(20, 0),
                'round' => 'Phase de groupes - J2'
            ],
            [
                'home_team' => $teams->where('short_name', 'MCI')->first(),
                'away_team' => $teams->where('short_name', 'PSG')->first(),
                'match_date' => Carbon::now()->addDays(10)->setTime(22, 0),
                'round' => 'Phase de groupes - J2'
            ],
            [
                'home_team' => $teams->where('short_name', 'LIV')->first(),
                'away_team' => $teams->where('short_name', 'JUV')->first(),
                'match_date' => Carbon::now()->addDays(11)->setTime(20, 0),
                'round' => 'Phase de groupes - J2'
            ],
            [
                'home_team' => $teams->where('short_name', 'MIL')->first(),
                'away_team' => $teams->where('short_name', 'BAR')->first(),
                'match_date' => Carbon::now()->addDays(11)->setTime(22, 0),
                'round' => 'Phase de groupes - J2'
            ],

            // Demi-finales
            [
                'home_team' => $teams->where('short_name', 'PSG')->first(),
                'away_team' => $teams->where('short_name', 'BAR')->first(),
                'match_date' => Carbon::now()->addDays(20)->setTime(20, 0),
                'round' => 'Demi-finale 1'
            ],
            [
                'home_team' => $teams->where('short_name', 'RMA')->first(),
                'away_team' => $teams->where('short_name', 'MCI')->first(),
                'match_date' => Carbon::now()->addDays(20)->setTime(22, 0),
                'round' => 'Demi-finale 2'
            ],

            // Finale
            [
                'home_team' => $teams->where('short_name', 'PSG')->first(),
                'away_team' => $teams->where('short_name', 'RMA')->first(),
                'match_date' => Carbon::now()->addDays(28)->setTime(21, 0),
                'round' => 'Finale'
            ]
        ];

        foreach ($matches as $matchData) {
            FootballMatch::create([
                'home_team_id' => $matchData['home_team']->id,
                'away_team_id' => $matchData['away_team']->id,
                'tournament_id' => $tournament->id,
                'match_date' => $matchData['match_date'],
                'predictions_close_at' => $matchData['match_date']->copy()->subMinutes(30),
                'status' => 'scheduled',
                'round' => $matchData['round'],
                'venue' => $this->getRandomVenue(),
                'competition' => $tournament->name,
                'is_active' => true,
                'predictions_enabled' => true,
                'home_score' => null,
                'away_score' => null
            ]);
        }

        $this->command->info("Créé {$tournament->matches()->count()} matchs pour le tournoi");

        // Ajouter quelques autres participants pour rendre le tournoi plus intéressant
        $otherUsers = User::where('id', '!=', $user->id)->limit(10)->get();
        foreach ($otherUsers as $otherUser) {
            TournamentParticipant::firstOrCreate([
                'tournament_id' => $tournament->id,
                'user_id' => $otherUser->id
            ], [
                'registration_date' => Carbon::now()->subHours(rand(1, 24)),
                'status' => 'confirmed',
                'points' => rand(0, 50),
                'rank' => null
            ]);
        }

        $this->command->info("Ajouté {$tournament->participants()->count()} participants au total");

        // Mettre à jour le statut du tournoi et calculer les rangs
        $tournament->updateStatus();
        $tournament->calculateRanks();

        $this->command->info("✅ Tournoi Elite créé avec succès pour l'utilisateur ID {$user->id}!");
        $this->command->info("🏆 Nom: {$tournament->name}");
        $this->command->info("💰 Cagnotte: {$tournament->prize_pool} {$tournament->currency}");
        $this->command->info("👥 Participants: {$tournament->participants()->count()}/{$tournament->max_participants}");
        $this->command->info("⚽ Matchs: {$tournament->matches()->count()}");
        $this->command->info("📅 Début: {$tournament->start_date->format('d/m/Y H:i')}");
        $this->command->info("🔚 Fin: {$tournament->end_date->format('d/m/Y H:i')}");
    }

    /**
     * Get a random venue for matches
     */
    private function getRandomVenue(): string
    {
        $venues = [
            'Parc des Princes - Paris',
            'Santiago Bernabéu - Madrid',
            'Allianz Arena - Munich',
            'Etihad Stadium - Manchester',
            'Camp Nou - Barcelone',
            'Anfield - Liverpool',
            'Allianz Stadium - Turin',
            'San Siro - Milan',
            'Old Trafford - Manchester',
            'Emirates Stadium - Londres'
        ];

        return $venues[array_rand($venues)];
    }
}
