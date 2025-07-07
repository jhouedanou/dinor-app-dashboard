<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Leaderboard;
use App\Models\User;
use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LeaderboardController extends Controller
{
    public function index(Request $request)
    {
        $query = Leaderboard::with('user:id,name')
            ->orderBy('total_points', 'desc')
            ->orderBy('accuracy_percentage', 'desc')
            ->orderBy('total_predictions', 'desc');

        $limit = $request->get('limit', 50);
        $leaderboard = $query->limit($limit)->get();

        return response()->json([
            'success' => true,
            'data' => $leaderboard,
            'total' => $leaderboard->count()
        ]);
    }

    public function top(Request $request)
    {
        $limit = $request->get('limit', 10);
        
        $topUsers = Leaderboard::with('user:id,name')
            ->topUsers($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $topUsers
        ]);
    }

    public function userStats(Request $request)
    {
        $userId = Auth::id();
        
        $userStats = Leaderboard::where('user_id', $userId)->first();

        if (!$userStats) {
            // Créer une entrée vide pour l'utilisateur
            $userStats = Leaderboard::create([
                'user_id' => $userId,
                'total_points' => 0,
                'total_predictions' => 0,
                'correct_scores' => 0,
                'correct_winners' => 0,
                'perfect_predictions' => 0,
                'accuracy_percentage' => 0,
                'current_rank' => null,
                'previous_rank' => null
            ]);
        }

        $userStats->load('user:id,name');

        // Calculer la position dans le classement global
        $higherRanked = Leaderboard::where('total_points', '>', $userStats->total_points)
            ->orWhere(function($query) use ($userStats) {
                $query->where('total_points', $userStats->total_points)
                      ->where('accuracy_percentage', '>', $userStats->accuracy_percentage);
            })
            ->orWhere(function($query) use ($userStats) {
                $query->where('total_points', $userStats->total_points)
                      ->where('accuracy_percentage', $userStats->accuracy_percentage)
                      ->where('total_predictions', '>', $userStats->total_predictions);
            })
            ->count();

        $userStats->current_position = $higherRanked + 1;

        return response()->json([
            'success' => true,
            'data' => $userStats
        ]);
    }

    public function userRank(Request $request)
    {
        $userId = Auth::id();
        
        $userStats = Leaderboard::where('user_id', $userId)->first();
        
        if (!$userStats) {
            return response()->json([
                'success' => true,
                'rank' => null,
                'total_participants' => Leaderboard::count()
            ]);
        }

        // Calculer le rang exact
        $rank = Leaderboard::where('total_points', '>', $userStats->total_points)
            ->orWhere(function($query) use ($userStats) {
                $query->where('total_points', $userStats->total_points)
                      ->where('accuracy_percentage', '>', $userStats->accuracy_percentage);
            })
            ->orWhere(function($query) use ($userStats) {
                $query->where('total_points', $userStats->total_points)
                      ->where('accuracy_percentage', $userStats->accuracy_percentage)
                      ->where('total_predictions', '>', $userStats->total_predictions);
            })
            ->count() + 1;

        return response()->json([
            'success' => true,
            'rank' => $rank,
            'total_participants' => Leaderboard::count(),
            'points' => $userStats->total_points,
            'accuracy' => $userStats->accuracy_percentage
        ]);
    }

    public function refresh(Request $request)
    {
        // Mettre à jour tous les classements
        $leaderboards = Leaderboard::all();
        
        foreach ($leaderboards as $leaderboard) {
            $leaderboard->updateStats();
        }

        // Recalculer les rangs
        Leaderboard::updateRankings();

        return response()->json([
            'success' => true,
            'message' => 'Classement mis à jour avec succès'
        ]);
    }



    /**
     * Obtenir le classement global
     */
    public function getGlobalLeaderboard(Request $request)
    {
        try {
            $limit = $request->get('limit', 10);
            $offset = $request->get('offset', 0);

            $leaderboards = Leaderboard::with('user')
                ->orderBy('total_points', 'desc')
                ->orderBy('accuracy_percentage', 'desc')
                ->orderBy('total_predictions', 'desc')
                ->limit($limit)
                ->offset($offset)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $leaderboards
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement du classement: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour les statistiques d'un utilisateur
     */
    private function updateUserStats(User $user, Leaderboard $leaderboard)
    {
        $predictions = Prediction::where('user_id', $user->id)->get();
        
        $totalPredictions = $predictions->count();
        $totalPoints = $predictions->sum('points_earned');
        $correctScores = $predictions->where('is_correct_score', true)->count();
        $correctWinners = $predictions->where('is_correct_winner', true)->count();
        $perfectPredictions = $predictions->where('is_perfect_prediction', true)->count();
        
        $accuracyPercentage = $totalPredictions > 0 
            ? round(($correctWinners / $totalPredictions) * 100, 2)
            : 0;

        $leaderboard->update([
            'total_points' => $totalPoints,
            'total_predictions' => $totalPredictions,
            'correct_scores' => $correctScores,
            'correct_winners' => $correctWinners,
            'perfect_predictions' => $perfectPredictions,
            'accuracy_percentage' => $accuracyPercentage,
            'last_updated' => now()
        ]);

        // Mettre à jour le rang
        $this->updateUserRank($leaderboard);
    }

    /**
     * Mettre à jour le rang d'un utilisateur
     */
    private function updateUserRank(Leaderboard $leaderboard)
    {
        $rank = Leaderboard::where('total_points', '>', $leaderboard->total_points)
            ->orWhere(function($query) use ($leaderboard) {
                $query->where('total_points', $leaderboard->total_points)
                      ->where('accuracy_percentage', '>', $leaderboard->accuracy_percentage);
            })
            ->orWhere(function($query) use ($leaderboard) {
                $query->where('total_points', $leaderboard->total_points)
                      ->where('accuracy_percentage', $leaderboard->accuracy_percentage)
                      ->where('total_predictions', '>', $leaderboard->total_predictions);
            })
            ->count() + 1;

        $leaderboard->update([
            'previous_rank' => $leaderboard->current_rank,
            'current_rank' => $rank,
            'rank' => $rank
        ]);
    }
}
