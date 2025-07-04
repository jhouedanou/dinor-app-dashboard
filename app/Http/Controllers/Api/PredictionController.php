<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Prediction;
use App\Models\FootballMatch;
use App\Models\Leaderboard;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

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
        
        $prediction = Prediction::where('user_id', $userId)
            ->where('football_match_id', $matchId)
            ->with(['footballMatch.homeTeam', 'footballMatch.awayTeam'])
            ->first();

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
}
