<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Prediction;
use App\Models\FootballMatch;
use App\Models\Leaderboard;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class PredictionController extends Controller
{
    public function index(Request $request)
    {
        $userId = Auth::id();
        
        $query = Prediction::with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc');

        if ($request->has('match_id')) {
            $query->where('football_match_id', $request->match_id);
        }

        $predictions = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $predictions->items(),
            'pagination' => [
                'current_page' => $predictions->currentPage(),
                'last_page' => $predictions->lastPage(),
                'per_page' => $predictions->perPage(),
                'total' => $predictions->total(),
            ]
        ]);
    }

    /**
     * Create or update a prediction in one operation (upsert)
     */
    public function upsert(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'football_match_id' => 'required|exists:football_matches,id',
            'predicted_home_score' => 'required|integer|min:0|max:20',
            'predicted_away_score' => 'required|integer|min:0|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $userId = Auth::id();
        $matchId = $request->football_match_id;

        // Use cache to avoid repeated database queries for the same match
        $cacheKey = "match_prediction_check_{$matchId}";
        $match = Cache::remember($cacheKey, 300, function () use ($matchId) {
            return FootballMatch::select(['id', 'predictions_close_at', 'match_date', 'predictions_enabled', 'is_active'])
                ->find($matchId);
        });

        if (!$match) {
            return response()->json([
                'success' => false,
                'message' => 'Match non trouvé'
            ], 404);
        }

        // Vérifier si les prédictions sont ouvertes
        if (!$match->can_predict) {
            return response()->json([
                'success' => false,
                'message' => 'Les pronostics sont fermés pour ce match'
            ], 422);
        }

        // Déterminer le gagnant prédit
        $predictedWinner = 'draw';
        if ($request->predicted_home_score > $request->predicted_away_score) {
            $predictedWinner = 'home';
        } elseif ($request->predicted_away_score > $request->predicted_home_score) {
            $predictedWinner = 'away';
        }

        try {
            DB::beginTransaction();

            // Utiliser updateOrCreate pour un upsert efficace
            $prediction = Prediction::updateOrCreate(
                [
                    'user_id' => $userId,
                    'football_match_id' => $matchId
                ],
                [
                    'predicted_home_score' => $request->predicted_home_score,
                    'predicted_away_score' => $request->predicted_away_score,
                    'predicted_winner' => $predictedWinner,
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'is_calculated' => false,
                    'points_earned' => 0
                ]
            );

            // Invalider le cache des prédictions utilisateur
            Cache::forget("user_predictions_{$userId}");
            Cache::forget("user_prediction_{$userId}_{$matchId}");

            DB::commit();

            // Charger les relations pour la réponse
            $prediction->load(['footballMatch.homeTeam', 'footballMatch.awayTeam']);

            return response()->json([
                'success' => true,
                'data' => $prediction,
                'message' => $prediction->wasRecentlyCreated ? 'Pronostic créé avec succès' : 'Pronostic mis à jour avec succès'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la sauvegarde du pronostic'
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'football_match_id' => 'required|exists:football_matches,id',
            'predicted_home_score' => 'required|integer|min:0|max:20',
            'predicted_away_score' => 'required|integer|min:0|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $match = FootballMatch::findOrFail($request->football_match_id);

        // Vérifier si les prédictions sont ouvertes
        if (!$match->can_predict) {
            return response()->json([
                'success' => false,
                'message' => 'Les pronostics sont fermés pour ce match'
            ], 422);
        }

        // Déterminer le gagnant prédit
        $predictedWinner = 'draw';
        if ($request->predicted_home_score > $request->predicted_away_score) {
            $predictedWinner = 'home';
        } elseif ($request->predicted_away_score > $request->predicted_home_score) {
            $predictedWinner = 'away';
        }

        $userId = Auth::id();

        // Créer ou mettre à jour la prédiction
        $prediction = Prediction::updateOrCreate(
            [
                'user_id' => $userId,
                'football_match_id' => $request->football_match_id
            ],
            [
                'predicted_home_score' => $request->predicted_home_score,
                'predicted_away_score' => $request->predicted_away_score,
                'predicted_winner' => $predictedWinner,
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'is_calculated' => false,
                'points_earned' => 0
            ]
        );

        return response()->json([
            'success' => true,
            'data' => $prediction->load(['footballMatch.homeTeam', 'footballMatch.awayTeam']),
            'message' => 'Pronostic enregistré avec succès'
        ]);
    }

    public function show(Prediction $prediction)
    {
        // Vérifier que la prédiction appartient à l'utilisateur connecté
        if ($prediction->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Non autorisé'
            ], 403);
        }

        $prediction->load(['footballMatch.homeTeam', 'footballMatch.awayTeam']);

        return response()->json([
            'success' => true,
            'data' => $prediction
        ]);
    }

    public function update(Request $request, Prediction $prediction)
    {
        // Vérifier que la prédiction appartient à l'utilisateur connecté
        if ($prediction->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Non autorisé'
            ], 403);
        }

        $match = $prediction->footballMatch;

        // Vérifier si les prédictions sont encore ouvertes
        if (!$match->can_predict) {
            return response()->json([
                'success' => false,
                'message' => 'Les pronostics sont fermés pour ce match'
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'predicted_home_score' => 'required|integer|min:0|max:20',
            'predicted_away_score' => 'required|integer|min:0|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        // Déterminer le gagnant prédit
        $predictedWinner = 'draw';
        if ($request->predicted_home_score > $request->predicted_away_score) {
            $predictedWinner = 'home';
        } elseif ($request->predicted_away_score > $request->predicted_home_score) {
            $predictedWinner = 'away';
        }

        $prediction->update([
            'predicted_home_score' => $request->predicted_home_score,
            'predicted_away_score' => $request->predicted_away_score,
            'predicted_winner' => $predictedWinner,
            'is_calculated' => false,
            'points_earned' => 0
        ]);

        return response()->json([
            'success' => true,
            'data' => $prediction->load(['footballMatch.homeTeam', 'footballMatch.awayTeam']),
            'message' => 'Pronostic mis à jour avec succès'
        ]);
    }

    public function getUserPredictionForMatch(Request $request, $matchId)
    {
        $userId = Auth::id();
        
        // Use cache for frequently accessed predictions
        $cacheKey = "user_prediction_{$userId}_{$matchId}";
        $prediction = Cache::remember($cacheKey, 600, function () use ($userId, $matchId) {
            return Prediction::where('user_id', $userId)
                ->where('football_match_id', $matchId)
                ->with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
                ->first();
        });

        return response()->json([
            'success' => true,
            'data' => $prediction
        ]);
    }

    public function userRecentPredictions(Request $request)
    {
        $userId = Auth::id();
        $limit = min($request->get('limit', 5), 20);
        
        $predictions = Prediction::with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $predictions
        ]);
    }

    /**
     * Get predictions for multiple matches (batch operation)
     */
    public function batchGetPredictions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'match_ids' => 'required|array',
            'match_ids.*' => 'integer|exists:football_matches,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $userId = Auth::id();
        $matchIds = $request->match_ids;
        
        $predictions = Prediction::with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
            ->where('user_id', $userId)
            ->whereIn('football_match_id', $matchIds)
            ->get()
            ->keyBy('football_match_id');

        return response()->json([
            'success' => true,
            'data' => $predictions
        ]);
    }

    /**
     * Get user prediction statistics
     */
    public function userStats()
    {
        $userId = Auth::id();
        
        if (!$userId) {
            return response()->json([
                'success' => false,
                'error' => 'Non authentifié'
            ], 401);
        }

        try {
            // Récupérer les prédictions de l'utilisateur avec les matches terminés
            $predictions = Prediction::with(['footballMatch'])
                ->where('user_id', $userId)
                ->whereHas('footballMatch', function($query) {
                    $query->where('status', 'finished');
                })
                ->get();

            $totalPredictions = $predictions->count();
            $correctPredictions = 0;
            $totalPoints = 0;

            foreach ($predictions as $prediction) {
                $match = $prediction->footballMatch;
                
                if ($match && $match->home_score !== null && $match->away_score !== null) {
                    // Calculer si la prédiction est correcte
                    $actualResult = $this->getMatchResult($match->home_score, $match->away_score);
                    $predictedResult = $this->getMatchResult($prediction->predicted_home_score, $prediction->predicted_away_score);
                    
                    if ($actualResult === $predictedResult) {
                        $correctPredictions++;
                        
                        // Score exact = 3 points, bon résultat = 1 point
                        if ($match->home_score == $prediction->predicted_home_score && 
                            $match->away_score == $prediction->predicted_away_score) {
                            $totalPoints += 3;
                        } else {
                            $totalPoints += 1;
                        }
                    }
                }
            }

            // Calculer le pourcentage de précision
            $accuracyPercentage = $totalPredictions > 0 ? round(($correctPredictions / $totalPredictions) * 100, 1) : 0;

            // Récupérer le classement de l'utilisateur (optionnel)
            $currentRank = null;
            try {
                $leaderboard = Leaderboard::where('user_id', $userId)->first();
                $currentRank = $leaderboard ? $leaderboard->rank : null;
            } catch (\Exception $e) {
                // Classement non disponible
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'total_predictions' => $totalPredictions,
                    'correct_predictions' => $correctPredictions,
                    'total_points' => $totalPoints,
                    'accuracy_percentage' => $accuracyPercentage,
                    'current_rank' => $currentRank,
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors du calcul des statistiques: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Helper method to determine match result (win/draw/loss)
     */
    private function getMatchResult($homeScore, $awayScore)
    {
        if ($homeScore > $awayScore) {
            return 'home_win';
        } elseif ($homeScore < $awayScore) {
            return 'away_win';
        } else {
            return 'draw';
        }
    }
}
