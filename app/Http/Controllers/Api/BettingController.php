<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BettingController extends Controller
{
    /**
     * Get tournaments available for betting
     */
    public function getAvailableTournaments()
    {
        try {
            $tournaments = Tournament::where('is_public', true)
                ->whereIn('status', ['registration_open', 'registration_closed', 'active'])
                ->with(['participants', 'matches'])
                ->get();

            $user = Auth::user();
            $tournamentData = [];

            foreach ($tournaments as $tournament) {
                $tournament->updateStatus();
                
                $data = [
                    'id' => $tournament->id,
                    'name' => $tournament->name,
                    'slug' => $tournament->slug,
                    'description' => $tournament->description,
                    'status' => $tournament->status,
                    'status_label' => $tournament->status_label,
                    'start_date' => $tournament->start_date,
                    'end_date' => $tournament->end_date,
                    'prediction_deadline' => $tournament->prediction_deadline,
                    'participants_count' => $tournament->participants_count,
                    'max_participants' => $tournament->max_participants,
                    'prize_pool' => $tournament->prize_pool,
                    'currency' => $tournament->currency,
                    'is_featured' => $tournament->is_featured,
                    'can_register' => $tournament->can_register,
                    'can_predict' => $tournament->can_predict,
                    'progress_percentage' => $tournament->progress_percentage,
                    'image' => $tournament->image,
                ];

                // Ajouter des données spécifiques à l'utilisateur connecté
                if ($user) {
                    $data['user_is_participant'] = $tournament->participants()
                        ->where('user_id', $user->id)->exists();
                    $data['user_can_register'] = $tournament->canUserRegister($user);
                } else {
                    $data['user_is_participant'] = false;
                    $data['user_can_register'] = false;
                }

                $tournamentData[] = $data;
            }

            return response()->json([
                'success' => true,
                'data' => $tournamentData,
                'message' => 'Tournois récupérés avec succès'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la récupération des tournois pour paris: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des tournois',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get matches available for betting in a tournament
     */
    public function getTournamentBettingMatches(Tournament $tournament)
    {
        try {
            $matches = $tournament->matches()
                ->with(['homeTeam', 'awayTeam'])
                ->where('is_active', true)
                ->orderBy('match_date', 'asc')
                ->get()
                ->map(function ($match) {
                    // Generate mock odds for demonstration
                    $homeOdds = round(rand(150, 350) / 100, 2);
                    $drawOdds = round(rand(280, 400) / 100, 2);
                    $awayOdds = round(rand(150, 350) / 100, 2);

                    return [
                        'id' => $match->id,
                        'home_team' => [
                            'id' => $match->homeTeam->id,
                            'name' => $match->homeTeam->name,
                            'short_name' => $match->homeTeam->short_name,
                            'country' => $match->homeTeam->country,
                            'logo_url' => $match->homeTeam->logo_url
                        ],
                        'away_team' => [
                            'id' => $match->awayTeam->id,
                            'name' => $match->awayTeam->name,
                            'short_name' => $match->awayTeam->short_name,
                            'country' => $match->awayTeam->country,
                            'logo_url' => $match->awayTeam->logo_url
                        ],
                        'match_date' => $match->match_date,
                        'predictions_close_at' => $match->predictions_close_at,
                        'status' => $match->status,
                        'round' => $match->round,
                        'venue' => $match->venue,
                        'can_predict' => $match->can_predict,
                        'is_finished' => $match->is_finished,
                        'home_score' => $match->home_score,
                        'away_score' => $match->away_score,
                        'winner' => $match->winner,
                        'odds' => [
                            'home' => $homeOdds,
                            'draw' => $drawOdds,
                            'away' => $awayOdds
                        ]
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $matches,
                'message' => 'Matchs récupérés avec succès'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la récupération des matchs pour paris: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des matchs',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Place a bet on a match
     */
    public function placeBet(Request $request, FootballMatch $match)
    {
        try {
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté pour placer un pari'
                ], 401);
            }

            if (!$match->can_predict) {
                return response()->json([
                    'success' => false,
                    'message' => 'Les paris sont fermés pour ce match'
                ], 400);
            }

            $validator = Validator::make($request->all(), [
                'predicted_home_score' => 'required|integer|min:0|max:20',
                'predicted_away_score' => 'required|integer|min:0|max:20',
                'predicted_winner' => 'required|in:home,away,draw',
                'bet_amount' => 'required|integer|min:1|max:1000'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Données invalides',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            
            // Check if user has enough balance (simulate with user points)
            $userBalance = $this->getUserBalance($user);
            if ($userBalance < $request->bet_amount) {
                return response()->json([
                    'success' => false,
                    'message' => 'Solde insuffisant pour placer ce pari'
                ], 400);
            }

            // Check if user already has a prediction for this match
            $existingPrediction = Prediction::where('user_id', $user->id)
                ->where('football_match_id', $match->id)
                ->first();

            if ($existingPrediction) {
                // Update existing prediction
                $existingPrediction->update([
                    'predicted_home_score' => $request->predicted_home_score,
                    'predicted_away_score' => $request->predicted_away_score,
                    'predicted_winner' => $request->predicted_winner,
                    'bet_amount' => $request->bet_amount,
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent()
                ]);

                $prediction = $existingPrediction;
            } else {
                // Create new prediction
                $prediction = Prediction::create([
                    'user_id' => $user->id,
                    'football_match_id' => $match->id,
                    'predicted_home_score' => $request->predicted_home_score,
                    'predicted_away_score' => $request->predicted_away_score,
                    'predicted_winner' => $request->predicted_winner,
                    'bet_amount' => $request->bet_amount,
                    'points_earned' => 0,
                    'is_calculated' => false,
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent()
                ]);
            }

            // Deduct bet amount from user balance (simulate)
            $this->updateUserBalance($user, -$request->bet_amount);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $prediction->id,
                    'predicted_home_score' => $prediction->predicted_home_score,
                    'predicted_away_score' => $prediction->predicted_away_score,
                    'predicted_winner' => $prediction->predicted_winner,
                    'bet_amount' => $prediction->bet_amount,
                    'match_id' => $match->id,
                    'created_at' => $prediction->created_at
                ],
                'message' => 'Pari placé avec succès!'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors du placement du pari: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du placement du pari',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get user's bets for a tournament
     */
    public function getUserTournamentBets(Tournament $tournament)
    {
        try {
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté'
                ], 401);
            }

            $user = Auth::user();
            
            $bets = Prediction::where('user_id', $user->id)
                ->whereHas('footballMatch', function ($query) use ($tournament) {
                    $query->where('tournament_id', $tournament->id);
                })
                ->with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
                ->get()
                ->map(function ($prediction) {
                    return [
                        'id' => $prediction->id,
                        'football_match_id' => $prediction->football_match_id,
                        'predicted_home_score' => $prediction->predicted_home_score,
                        'predicted_away_score' => $prediction->predicted_away_score,
                        'predicted_winner' => $prediction->predicted_winner,
                        'bet_amount' => $prediction->bet_amount ?? 0,
                        'points_earned' => $prediction->points_earned,
                        'is_calculated' => $prediction->is_calculated,
                        'created_at' => $prediction->created_at,
                        'match' => [
                            'id' => $prediction->footballMatch->id,
                            'home_team' => $prediction->footballMatch->homeTeam->name,
                            'away_team' => $prediction->footballMatch->awayTeam->name,
                            'match_date' => $prediction->footballMatch->match_date,
                            'status' => $prediction->footballMatch->status
                        ]
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $bets,
                'message' => 'Paris récupérés avec succès'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la récupération des paris utilisateur: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des paris',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get user betting statistics
     */
    public function getUserBettingStats()
    {
        try {
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté'
                ], 401);
            }

            $user = Auth::user();
            
            $totalBets = Prediction::where('user_id', $user->id)->count();
            $calculatedBets = Prediction::where('user_id', $user->id)
                ->where('is_calculated', true)->count();
            $winningBets = Prediction::where('user_id', $user->id)
                ->where('is_calculated', true)
                ->where('points_earned', '>', 0)->count();
            
            $winRate = $calculatedBets > 0 ? round(($winningBets / $calculatedBets) * 100, 1) : 0;
            
            $totalWinnings = Prediction::where('user_id', $user->id)
                ->where('is_calculated', true)
                ->sum('points_earned') ?? 0;

            // Calculate rank (simplified)
            $userRank = DB::table('predictions')
                ->select('user_id', DB::raw('SUM(points_earned) as total_points'))
                ->where('is_calculated', true)
                ->groupBy('user_id')
                ->orderBy('total_points', 'desc')
                ->get()
                ->search(function ($item) use ($user) {
                    return $item->user_id == $user->id;
                }) + 1;

            $stats = [
                'totalBets' => $totalBets,
                'winRate' => $winRate,
                'totalWinnings' => $totalWinnings,
                'rank' => $userRank ?: null,
                'balance' => $this->getUserBalance($user)
            ];

            return response()->json([
                'success' => true,
                'data' => $stats,
                'message' => 'Statistiques récupérées avec succès'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la récupération des statistiques: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des statistiques',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get user balance (simplified - in real app this would be in a dedicated table)
     */
    private function getUserBalance(User $user)
    {
        // Simulate user balance - in real app this would be stored in database
        $totalEarned = Prediction::where('user_id', $user->id)
            ->where('is_calculated', true)
            ->sum('points_earned') ?? 0;
            
        $totalSpent = Prediction::where('user_id', $user->id)
            ->sum('bet_amount') ?? 0;
            
        $startingBalance = 1000; // Starting points for new users
        
        return $startingBalance + $totalEarned - $totalSpent;
    }

    /**
     * Update user balance (simplified)
     */
    private function updateUserBalance(User $user, int $amount)
    {
        // In a real app, this would update a dedicated balance table
        // For now, we just track it through the predictions
        \Log::info("User {$user->id} balance updated by {$amount} points");
    }

    /**
     * Get trending betting statistics
     */
    public function getTrendingStats()
    {
        try {
            $stats = [
                'total_bets_today' => Prediction::whereDate('created_at', today())->count(),
                'total_active_tournaments' => Tournament::where('status', 'active')->count(),
                'top_betting_tournament' => Tournament::withCount(['predictions'])
                    ->where('status', 'active')
                    ->orderBy('predictions_count', 'desc')
                    ->first()?->name ?? 'Aucun',
                'average_bet_amount' => round(
                    Prediction::whereNotNull('bet_amount')->avg('bet_amount') ?? 0, 2
                )
            ];

            return response()->json([
                'success' => true,
                'data' => $stats,
                'message' => 'Statistiques tendances récupérées avec succès'
            ]);

        } catch (\Exception $e) {
            \Log::error('Erreur lors de la récupération des statistiques tendances: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des statistiques',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }
} 