<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Team;
use App\Models\FootballMatch;
use Carbon\Carbon;

class FootballTestDataSeeder extends Seeder
{
    public function run(): void
    {
        $this->createTeams();
        $this->createMatches();
    }

    private function createTeams(): void
    {
        $teams = [
            [
                'name' => 'Paris Saint-Germain',
                'short_name' => 'PSG',
                'country' => 'FRA',
                'color_primary' => '#004170',
                'color_secondary' => '#FF0000',
                'is_active' => true,
                'founded_year' => 1970,
                'description' => 'Club de football français basé à Paris'
            ],
            [
                'name' => 'Real Madrid',
                'short_name' => 'RMA',
                'country' => 'ESP',
                'color_primary' => '#FFFFFF',
                'color_secondary' => '#FFD700',
                'is_active' => true,
                'founded_year' => 1902,
                'description' => 'Club de football espagnol basé à Madrid'
            ],
            [
                'name' => 'FC Barcelona',
                'short_name' => 'BAR',
                'country' => 'ESP',
                'color_primary' => '#A50044',
                'color_secondary' => '#004D98',
                'is_active' => true,
                'founded_year' => 1899,
                'description' => 'Club de football espagnol basé à Barcelone'
            ],
            [
                'name' => 'Manchester City',
                'short_name' => 'MCI',
                'country' => 'ENG',
                'color_primary' => '#6CABDD',
                'color_secondary' => '#1C2C5B',
                'is_active' => true,
                'founded_year' => 1880,
                'description' => 'Club de football anglais basé à Manchester'
            ],
            [
                'name' => 'Bayern Munich',
                'short_name' => 'BAY',
                'country' => 'GER',
                'color_primary' => '#DC052D',
                'color_secondary' => '#FFFFFF',
                'is_active' => true,
                'founded_year' => 1900,
                'description' => 'Club de football allemand basé à Munich'
            ],
            [
                'name' => 'Liverpool FC',
                'short_name' => 'LIV',
                'country' => 'ENG',
                'color_primary' => '#C8102E',
                'color_secondary' => '#00B2A9',
                'is_active' => true,
                'founded_year' => 1892,
                'description' => 'Club de football anglais basé à Liverpool'
            ],
            [
                'name' => 'AC Milan',
                'short_name' => 'MIL',
                'country' => 'ITA',
                'color_primary' => '#FB090B',
                'color_secondary' => '#000000',
                'is_active' => true,
                'founded_year' => 1899,
                'description' => 'Club de football italien basé à Milan'
            ],
            [
                'name' => 'Juventus',
                'short_name' => 'JUV',
                'country' => 'ITA',
                'color_primary' => '#000000',
                'color_secondary' => '#FFFFFF',
                'is_active' => true,
                'founded_year' => 1897,
                'description' => 'Club de football italien basé à Turin'
            ]
        ];

        foreach ($teams as $teamData) {
            Team::firstOrCreate(['name' => $teamData['name']], $teamData);
        }
    }

    private function createMatches(): void
    {
        $teams = Team::all();
        
        if ($teams->count() < 4) {
            $this->command->error('Pas assez d\'équipes pour créer des matchs');
            return;
        }

        $competitions = [
            'Ligue des Champions',
            'Ligue Europa',
            'Championnat National',
            'Coupe du Monde'
        ];

        $venues = [
            'Stade de France',
            'Camp Nou',
            'Santiago Bernabéu',
            'Old Trafford',
            'Allianz Arena',
            'San Siro',
            'Anfield',
            'Parc des Princes'
        ];

        $matches = [];
        
        // Matchs passés (avec résultats)
        for ($i = 0; $i < 5; $i++) {
            $homeTeam = $teams->random();
            $awayTeam = $teams->where('id', '!=', $homeTeam->id)->random();
            
            $matchDate = Carbon::now()->subDays(rand(1, 30));
            $homeScore = rand(0, 4);
            $awayScore = rand(0, 4);
            
            $matches[] = [
                'home_team_id' => $homeTeam->id,
                'away_team_id' => $awayTeam->id,
                'match_date' => $matchDate,
                'predictions_close_at' => $matchDate->copy()->subHours(2),
                'status' => 'finished',
                'home_score' => $homeScore,
                'away_score' => $awayScore,
                'competition' => $competitions[array_rand($competitions)],
                'round' => 'Phase de groupes',
                'venue' => $venues[array_rand($venues)],
                'is_active' => true,
                'predictions_enabled' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // Matchs à venir (prédictions ouvertes)
        for ($i = 0; $i < 8; $i++) {
            $homeTeam = $teams->random();
            $awayTeam = $teams->where('id', '!=', $homeTeam->id)->random();
            
            $matchDate = Carbon::now()->addDays(rand(1, 14));
            
            $matches[] = [
                'home_team_id' => $homeTeam->id,
                'away_team_id' => $awayTeam->id,
                'match_date' => $matchDate,
                'predictions_close_at' => $matchDate->copy()->subHours(2),
                'status' => 'scheduled',
                'home_score' => null,
                'away_score' => null,
                'competition' => $competitions[array_rand($competitions)],
                'round' => 'Phase de groupes',
                'venue' => $venues[array_rand($venues)],
                'is_active' => true,
                'predictions_enabled' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // Matchs live (en cours)
        for ($i = 0; $i < 2; $i++) {
            $homeTeam = $teams->random();
            $awayTeam = $teams->where('id', '!=', $homeTeam->id)->random();
            
            $matchDate = Carbon::now()->subMinutes(rand(10, 90));
            
            $matches[] = [
                'home_team_id' => $homeTeam->id,
                'away_team_id' => $awayTeam->id,
                'match_date' => $matchDate,
                'predictions_close_at' => $matchDate->copy()->subHours(2),
                'status' => 'live',
                'home_score' => rand(0, 3),
                'away_score' => rand(0, 3),
                'competition' => $competitions[array_rand($competitions)],
                'round' => 'Phase de groupes',
                'venue' => $venues[array_rand($venues)],
                'is_active' => true,
                'predictions_enabled' => false, // Pas de prédictions pendant le match
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // Insérer tous les matchs
        foreach ($matches as $match) {
            FootballMatch::firstOrCreate(
                [
                    'home_team_id' => $match['home_team_id'],
                    'away_team_id' => $match['away_team_id'],
                    'match_date' => $match['match_date']
                ],
                $match
            );
        }

        $this->command->info('Données de test créées avec succès:');
        $this->command->info('- ' . Team::count() . ' équipes');
        $this->command->info('- ' . FootballMatch::count() . ' matchs');
        $this->command->info('- ' . FootballMatch::where('status', 'scheduled')->count() . ' matchs à venir');
        $this->command->info('- ' . FootballMatch::where('status', 'live')->count() . ' matchs en cours');
        $this->command->info('- ' . FootballMatch::where('status', 'finished')->count() . ' matchs terminés');
    }
}