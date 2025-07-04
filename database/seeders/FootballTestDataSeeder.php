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
        $this->command->info('🏆 Création du tournoi de test avec équipes et matchs...');
        
        $this->createTeams();
        $this->createMatches();
        $this->displayStatistics();
        
        $this->command->info('\n✅ Tournoi de test créé avec succès!');
        $this->command->info('🎯 Vous pouvez maintenant tester les pronostics sur les matchs à venir.');
    }

    private function createTeams(): void
    {
        $teams = [
            // Équipes européennes
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
            ],
            // Équipes africaines
            [
                'name' => 'ASEC Mimosas',
                'short_name' => 'ASE',
                'country' => 'CIV',
                'color_primary' => '#FFFF00',
                'color_secondary' => '#000000',
                'is_active' => true,
                'founded_year' => 1948,
                'description' => 'Club de football ivoirien basé à Abidjan'
            ],
            [
                'name' => 'Africa Sports',
                'short_name' => 'AFS',
                'country' => 'CIV',
                'color_primary' => '#008000',
                'color_secondary' => '#FFFFFF',
                'is_active' => true,
                'founded_year' => 1947,
                'description' => 'Club de football ivoirien basé à Abidjan'
            ],
            [
                'name' => 'Stade d\'Abidjan',
                'short_name' => 'STA',
                'country' => 'CIV',
                'color_primary' => '#FF0000',
                'color_secondary' => '#0000FF',
                'is_active' => true,
                'founded_year' => 1936,
                'description' => 'Club de football ivoirien basé à Abidjan'
            ],
            [
                'name' => 'Al Ahly',
                'short_name' => 'AHL',
                'country' => 'EGY',
                'color_primary' => '#DC143C',
                'color_secondary' => '#FFFFFF',
                'is_active' => true,
                'founded_year' => 1907,
                'description' => 'Club de football égyptien basé au Caire'
            ],
            [
                'name' => 'Wydad Casablanca',
                'short_name' => 'WAC',
                'country' => 'MAR',
                'color_primary' => '#DC143C',
                'color_secondary' => '#FFFFFF',
                'is_active' => true,
                'founded_year' => 1937,
                'description' => 'Club de football marocain basé à Casablanca'
            ],
            [
                'name' => 'Kaizer Chiefs',
                'short_name' => 'KAI',
                'country' => 'RSA',
                'color_primary' => '#FFD700',
                'color_secondary' => '#000000',
                'is_active' => true,
                'founded_year' => 1970,
                'description' => 'Club de football sud-africain basé à Johannesburg'
            ],
            [
                'name' => 'TP Mazembe',
                'short_name' => 'TPM',
                'country' => 'COD',
                'color_primary' => '#000000',
                'color_secondary' => '#FFFF00',
                'is_active' => true,
                'founded_year' => 1939,
                'description' => 'Club de football congolais basé à Lubumbashi'
            ],
            [
                'name' => 'Espérance Tunis',
                'short_name' => 'EST',
                'country' => 'TUN',
                'color_primary' => '#DC143C',
                'color_secondary' => '#FFD700',
                'is_active' => true,
                'founded_year' => 1919,
                'description' => 'Club de football tunisien basé à Tunis'
            ]
        ];

        foreach ($teams as $teamData) {
            Team::firstOrCreate(['name' => $teamData['name']], $teamData);
        }
    }

    private function createMatches(): void
    {
        $teams = Team::all();
        
        if ($teams->count() < 8) {
            $this->command->error('Pas assez d\'équipes pour créer un tournoi');
            return;
        }

        $this->createTournamentMatches($teams);
        $this->createRandomMatches($teams);
    }

    private function createTournamentMatches($teams): void
    {
        // Créer un tournoi "Coupe Dinor 2025" avec phase de groupes et élimination directe
        $competition = 'Coupe Dinor 2025';
        $venues = [
            'Stade Houphouët-Boigny',
            'Stade de la Paix',
            'Stade Robert Champroux',
            'Stade Laurent Pokou',
            'Complexe Sportif de Marcory',
            'Stade de Yamoussoukro',
            'Stade Municipal de Bouaké',
            'Parc des Sports de Treichville'
        ];

        $matches = [];
        $teamsArray = $teams->toArray();
        shuffle($teamsArray);

        // Phase de groupes - 4 groupes de 4 équipes
        $groups = array_chunk($teamsArray, 4);
        $groupNames = ['Groupe A', 'Groupe B', 'Groupe C', 'Groupe D'];

        foreach ($groups as $groupIndex => $groupTeams) {
            if (count($groupTeams) < 4) continue;
            
            $groupName = $groupNames[$groupIndex] ?? "Groupe " . ($groupIndex + 1);
            
            // Chaque équipe joue contre chaque autre équipe du groupe
            for ($i = 0; $i < 4; $i++) {
                for ($j = $i + 1; $j < 4; $j++) {
                    $homeTeam = $groupTeams[$i];
                    $awayTeam = $groupTeams[$j];
                    
                    // Match aller (passé - avec résultats)
                    $matchDate = Carbon::now()->subDays(rand(20, 35));
                    $homeScore = rand(0, 3);
                    $awayScore = rand(0, 3);
                    
                    $matches[] = [
                        'home_team_id' => $homeTeam['id'],
                        'away_team_id' => $awayTeam['id'],
                        'match_date' => $matchDate,
                        'predictions_close_at' => $matchDate->copy()->subHours(2),
                        'status' => 'finished',
                        'home_score' => $homeScore,
                        'away_score' => $awayScore,
                        'competition' => $competition,
                        'round' => $groupName,
                        'venue' => $venues[array_rand($venues)],
                        'is_active' => true,
                        'predictions_enabled' => true,
                        'created_at' => now(),
                        'updated_at' => now()
                    ];
                    
                    // Match retour (à venir - pour pronostics)
                    $returnMatchDate = Carbon::now()->addDays(rand(5, 15));
                    
                    $matches[] = [
                        'home_team_id' => $awayTeam['id'],
                        'away_team_id' => $homeTeam['id'],
                        'match_date' => $returnMatchDate,
                        'predictions_close_at' => $returnMatchDate->copy()->subHours(2),
                        'status' => 'scheduled',
                        'home_score' => null,
                        'away_score' => null,
                        'competition' => $competition,
                        'round' => $groupName,
                        'venue' => $venues[array_rand($venues)],
                        'is_active' => true,
                        'predictions_enabled' => true,
                        'created_at' => now(),
                        'updated_at' => now()
                    ];
                }
            }
        }

        // Quarts de finale (à venir)
        $quarterFinalTeams = array_slice($teamsArray, 0, 8);
        for ($i = 0; $i < 8; $i += 2) {
            $matchDate = Carbon::now()->addDays(rand(18, 25));
            
            $matches[] = [
                'home_team_id' => $quarterFinalTeams[$i]['id'],
                'away_team_id' => $quarterFinalTeams[$i + 1]['id'],
                'match_date' => $matchDate,
                'predictions_close_at' => $matchDate->copy()->subHours(2),
                'status' => 'scheduled',
                'home_score' => null,
                'away_score' => null,
                'competition' => $competition,
                'round' => 'Quart de finale',
                'venue' => $venues[array_rand($venues)],
                'is_active' => true,
                'predictions_enabled' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // Demi-finales (à venir)
        $semiFinalTeams = array_slice($teamsArray, 0, 4);
        for ($i = 0; $i < 4; $i += 2) {
            $matchDate = Carbon::now()->addDays(rand(30, 35));
            
            $matches[] = [
                'home_team_id' => $semiFinalTeams[$i]['id'],
                'away_team_id' => $semiFinalTeams[$i + 1]['id'],
                'match_date' => $matchDate,
                'predictions_close_at' => $matchDate->copy()->subHours(2),
                'status' => 'scheduled',
                'home_score' => null,
                'away_score' => null,
                'competition' => $competition,
                'round' => 'Demi-finale',
                'venue' => 'Stade Houphouët-Boigny',
                'is_active' => true,
                'predictions_enabled' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // Finale (à venir)
        $finalTeams = array_slice($teamsArray, 0, 2);
        $finalDate = Carbon::now()->addDays(40);
        
        $matches[] = [
            'home_team_id' => $finalTeams[0]['id'],
            'away_team_id' => $finalTeams[1]['id'],
            'match_date' => $finalDate,
            'predictions_close_at' => $finalDate->copy()->subHours(3),
            'status' => 'scheduled',
            'home_score' => null,
            'away_score' => null,
            'competition' => $competition,
            'round' => 'FINALE',
            'venue' => 'Stade Houphouët-Boigny',
            'is_active' => true,
            'predictions_enabled' => true,
            'created_at' => now(),
            'updated_at' => now()
        ];

        // Insérer tous les matchs du tournoi
        foreach ($matches as $match) {
            FootballMatch::firstOrCreate(
                [
                    'home_team_id' => $match['home_team_id'],
                    'away_team_id' => $match['away_team_id'],
                    'match_date' => $match['match_date'],
                    'competition' => $match['competition'],
                    'round' => $match['round']
                ],
                $match
            );
        }

        $this->command->info('Tournoi "Coupe Dinor 2025" créé avec succès!');
    }

    private function createRandomMatches($teams): void
    {
        $competitions = [
            'Ligue des Champions CAF',
            'Coupe de la Confédération CAF',
            'Championnat de Côte d\'Ivoire',
            'Coupe de Côte d\'Ivoire',
            'Champions League UEFA',
            'Ligue Europa UEFA'
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
        for ($i = 0; $i < 8; $i++) {
            $homeTeam = $teams->random();
            $awayTeam = $teams->where('id', '!=', $homeTeam->id)->random();
            
            $matchDate = Carbon::now()->subDays(rand(1, 15));
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
        for ($i = 0; $i < 12; $i++) {
            $homeTeam = $teams->random();
            $awayTeam = $teams->where('id', '!=', $homeTeam->id)->random();
            
            $matchDate = Carbon::now()->addDays(rand(1, 20));
            
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
        for ($i = 0; $i < 3; $i++) {
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

        // Insérer tous les matchs aléatoires
        foreach ($matches as $match) {
            FootballMatch::firstOrCreate(
                [
                    'home_team_id' => $match['home_team_id'],
                    'away_team_id' => $match['away_team_id'],
                    'match_date' => $match['match_date'],
                    'competition' => $match['competition']
                ],
                $match
            );
        }
    }

    private function displayStatistics(): void
    {
        $this->command->info('\n=== STATISTIQUES DU TOURNOI ===');
        $this->command->info('- ' . Team::count() . ' équipes créées');
        $this->command->info('- ' . FootballMatch::count() . ' matchs au total');
        $this->command->info('- ' . FootballMatch::where('status', 'scheduled')->count() . ' matchs à venir (prédictions ouvertes)');
        $this->command->info('- ' . FootballMatch::where('status', 'live')->count() . ' matchs en cours');
        $this->command->info('- ' . FootballMatch::where('status', 'finished')->count() . ' matchs terminés');
        
        $tournamentMatches = FootballMatch::where('competition', 'Coupe Dinor 2025')->count();
        $this->command->info('- ' . $tournamentMatches . ' matchs pour la Coupe Dinor 2025');
        
        $this->command->info('\n=== PHASES DU TOURNOI ===');
        $phases = FootballMatch::where('competition', 'Coupe Dinor 2025')
            ->selectRaw('round, COUNT(*) as count')
            ->groupBy('round')
            ->get();
            
        foreach ($phases as $phase) {
            $this->command->info('- ' . $phase->round . ': ' . $phase->count . ' matchs');
        }
        
        $this->command->info('\n=== PRÉDICTIONS DISPONIBLES ===');
        $openPredictions = FootballMatch::where('predictions_enabled', true)
            ->where('status', 'scheduled')
            ->where('predictions_close_at', '>', now())
            ->count();
        $this->command->info('- ' . $openPredictions . ' matchs ouverts aux prédictions');
    }
}