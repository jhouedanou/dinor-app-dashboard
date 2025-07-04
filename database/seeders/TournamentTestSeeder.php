<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Tournament;
use App\Models\FootballMatch;
use App\Models\User;
use Carbon\Carbon;

class TournamentTestSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🏆 Création des tournois de test...');
        
        $this->createTournaments();
        $this->linkMatchesToTournaments();
        $this->registerUsersToTournaments();
        
        $this->command->info('✅ Tournois de test créés avec succès!');
    }

    private function createTournaments(): void
    {
        $admin = User::where('email', 'admin@dinor.com')->first();
        $creatorId = $admin ? $admin->id : User::first()->id;

        $tournaments = [
            [
                'name' => 'Coupe Dinor 2025',
                'slug' => 'coupe-dinor-2025',
                'description' => 'Le grand tournoi de pronostics Dinor 2025. Participez et gagnez des prix exceptionnels !',
                'start_date' => Carbon::now()->subDays(10),
                'end_date' => Carbon::now()->addDays(40),
                'registration_start' => Carbon::now()->subDays(20),
                'registration_end' => Carbon::now()->addDays(5),
                'prediction_deadline' => Carbon::now()->addDays(35),
                'max_participants' => 1000,
                'entry_fee' => 0,
                'currency' => 'XOF',
                'prize_pool' => 500000,
                'status' => 'registration_open',
                'rules' => [
                    'Score exact: 3 points',
                    'Bon gagnant seulement: 1 point',
                    'Mauvais pronostic: 0 point',
                    'Les prédictions doivent être faites avant le début du match',
                    'En cas d\'égalité, le nombre de prédictions correctes départage'
                ],
                'is_featured' => true,
                'is_public' => true,
                'created_by' => $creatorId
            ],
            [
                'name' => 'Ligue des Champions Africaine',
                'slug' => 'ligue-champions-africaine',
                'description' => 'Pronostiquez sur les matchs de la Ligue des Champions de la CAF',
                'start_date' => Carbon::now()->addDays(5),
                'end_date' => Carbon::now()->addDays(60),
                'registration_start' => Carbon::now()->subDays(5),
                'registration_end' => Carbon::now()->addDays(10),
                'prediction_deadline' => Carbon::now()->addDays(55),
                'max_participants' => 500,
                'entry_fee' => 1000,
                'currency' => 'XOF',
                'prize_pool' => 250000,
                'status' => 'registration_open',
                'rules' => [
                    'Score exact: 3 points',
                    'Bon gagnant: 1 point',
                    'Tournoi payant: 1000 XOF d\'inscription'
                ],
                'is_featured' => true,
                'is_public' => true,
                'created_by' => $creatorId
            ],
            [
                'name' => 'Championnat Côte d\'Ivoire',
                'slug' => 'championnat-cote-ivoire',
                'description' => 'Suivez et pronostiquez le championnat ivoirien',
                'start_date' => Carbon::now()->addDays(15),
                'end_date' => Carbon::now()->addDays(120),
                'registration_start' => Carbon::now(),
                'registration_end' => Carbon::now()->addDays(20),
                'prediction_deadline' => Carbon::now()->addDays(115),
                'max_participants' => null, // Pas de limite
                'entry_fee' => 0,
                'currency' => 'XOF',
                'prize_pool' => 100000,
                'status' => 'registration_open',
                'rules' => [
                    'Tournoi gratuit',
                    'Ouvert à tous',
                    'Score exact: 3 points',
                    'Bon gagnant: 1 point'
                ],
                'is_featured' => false,
                'is_public' => true,
                'created_by' => $creatorId
            ],
            [
                'name' => 'Mini Tournoi Express',
                'slug' => 'mini-tournoi-express',
                'description' => 'Un petit tournoi sur 3 matchs pour tester vos compétences',
                'start_date' => Carbon::now()->subDays(2),
                'end_date' => Carbon::now()->addDays(3),
                'registration_start' => Carbon::now()->subDays(5),
                'registration_end' => Carbon::now()->subHours(12),
                'prediction_deadline' => Carbon::now()->addHours(12),
                'max_participants' => 50,
                'entry_fee' => 0,
                'currency' => 'XOF',
                'prize_pool' => 25000,
                'status' => 'active',
                'rules' => [
                    'Tournoi express sur 3 matchs',
                    'Durée limitée',
                    'Score exact: 3 points'
                ],
                'is_featured' => false,
                'is_public' => true,
                'created_by' => $creatorId
            ],
            [
                'name' => 'Tournoi VIP Fermé',
                'slug' => 'tournoi-vip-ferme',
                'description' => 'Tournoi privé réservé aux membres VIP',
                'start_date' => Carbon::now()->addDays(30),
                'end_date' => Carbon::now()->addDays(90),
                'registration_start' => Carbon::now()->addDays(20),
                'registration_end' => Carbon::now()->addDays(35),
                'prediction_deadline' => Carbon::now()->addDays(85),
                'max_participants' => 20,
                'entry_fee' => 10000,
                'currency' => 'XOF',
                'prize_pool' => 1000000,
                'status' => 'upcoming',
                'rules' => [
                    'Tournoi VIP exclusif',
                    'Inscription sur invitation uniquement',
                    'Gros prix à gagner'
                ],
                'is_featured' => true,
                'is_public' => false, // Tournoi privé
                'created_by' => $creatorId
            ]
        ];

        foreach ($tournaments as $tournamentData) {
            Tournament::firstOrCreate(
                ['slug' => $tournamentData['slug']], 
                $tournamentData
            );
        }

        $this->command->info('- ' . count($tournaments) . ' tournois créés');
    }

    private function linkMatchesToTournaments(): void
    {
        // Associer les matchs existants aux tournois
        $coupeDinor = Tournament::where('slug', 'coupe-dinor-2025')->first();
        if ($coupeDinor) {
            // Associer tous les matchs "Coupe Dinor 2025"
            $matches = FootballMatch::where('competition', 'Coupe Dinor 2025')->get();
            foreach ($matches as $match) {
                $match->update(['tournament_id' => $coupeDinor->id]);
            }
            $this->command->info('- ' . $matches->count() . ' matchs associés à la Coupe Dinor 2025');
        }

        $ligueChampions = Tournament::where('slug', 'ligue-champions-africaine')->first();
        if ($ligueChampions) {
            // Associer les matchs "Ligue des Champions CAF"
            $matches = FootballMatch::where('competition', 'Ligue des Champions CAF')->get();
            foreach ($matches as $match) {
                $match->update(['tournament_id' => $ligueChampions->id]);
            }
            $this->command->info('- ' . $matches->count() . ' matchs associés à la Ligue des Champions Africaine');
        }

        $championnatCI = Tournament::where('slug', 'championnat-cote-ivoire')->first();
        if ($championnatCI) {
            // Associer les matchs "Championnat de Côte d'Ivoire"
            $matches = FootballMatch::where('competition', 'Championnat de Côte d\'Ivoire')->get();
            foreach ($matches as $match) {
                $match->update(['tournament_id' => $championnatCI->id]);
            }
            $this->command->info('- ' . $matches->count() . ' matchs associés au Championnat CI');
        }

        $miniTournoi = Tournament::where('slug', 'mini-tournoi-express')->first();
        if ($miniTournoi) {
            // Prendre quelques matchs récents pour le mini tournoi
            $matches = FootballMatch::where('tournament_id', null)
                ->orderBy('match_date')
                ->limit(3)
                ->get();
            foreach ($matches as $match) {
                $match->update(['tournament_id' => $miniTournoi->id]);
            }
            $this->command->info('- ' . $matches->count() . ' matchs associés au Mini Tournoi Express');
        }
    }

    private function registerUsersToTournaments(): void
    {
        $users = User::all();
        $tournaments = Tournament::where('is_public', true)
            ->whereIn('status', ['registration_open', 'active'])
            ->get();

        $registrations = 0;

        foreach ($tournaments as $tournament) {
            // Inscrire entre 30% et 80% des utilisateurs à chaque tournoi
            $participantsCount = rand(
                (int)($users->count() * 0.3), 
                (int)($users->count() * 0.8)
            );
            
            $selectedUsers = $users->random(min($participantsCount, $users->count()));
            
            foreach ($selectedUsers as $user) {
                if ($tournament->canUserRegister($user)) {
                    $tournament->registerUser($user);
                    $registrations++;
                }
            }
        }

        $this->command->info('- ' . $registrations . ' inscriptions d\'utilisateurs créées');

        // Mettre à jour les leaderboards
        foreach ($tournaments as $tournament) {
            $tournament->updateLeaderboard();
        }

        $this->command->info('- Leaderboards mis à jour pour tous les tournois');
    }
}