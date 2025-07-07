<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Leaderboard extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'total_points',
        'total_predictions',
        'correct_scores',
        'correct_winners',
        'perfect_predictions',
        'accuracy_percentage',
        'rank',
        'current_rank',
        'previous_rank',
        'last_updated'
    ];

    protected $casts = [
        'total_points' => 'integer',
        'total_predictions' => 'integer',
        'correct_scores' => 'integer',
        'correct_winners' => 'integer',
        'perfect_predictions' => 'integer',
        'accuracy_percentage' => 'decimal:2',
        'current_rank' => 'integer',
        'previous_rank' => 'integer',
        'last_updated' => 'date'
    ];

    protected $appends = [
        'rank_change',
        'points_per_prediction'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getRankChangeAttribute()
    {
        if ($this->previous_rank === null || $this->current_rank === null) {
            return 0;
        }
        
        return $this->previous_rank - $this->current_rank;
    }

    public function getPointsPerPredictionAttribute()
    {
        if ($this->total_predictions === 0) {
            return 0;
        }
        
        return round($this->total_points / $this->total_predictions, 2);
    }

    public function updateStats()
    {
        $userPredictions = Prediction::where('user_id', $this->user_id)
                                   ->calculated()
                                   ->get();

        $totalPoints = $userPredictions->sum('points_earned');
        $totalPredictions = $userPredictions->count();
        $correctScores = 0;
        $correctWinners = 0;
        $perfectPredictions = 0;

        foreach ($userPredictions as $prediction) {
            $match = $prediction->footballMatch;
            if (!$match->is_finished) continue;

            $exactScore = ($prediction->predicted_home_score == $match->home_score && 
                          $prediction->predicted_away_score == $match->away_score);
            $correctWinner = ($prediction->predicted_winner == $match->winner);

            if ($exactScore) {
                $correctScores++;
            }
            
            if ($correctWinner) {
                $correctWinners++;
            }

            if ($exactScore && $correctWinner) {
                $perfectPredictions++;
            }
        }

        $accuracyPercentage = $totalPredictions > 0 ? 
            round(($correctWinners / $totalPredictions) * 100, 2) : 0;

        $this->update([
            'total_points' => $totalPoints,
            'total_predictions' => $totalPredictions,
            'correct_scores' => $correctScores,
            'correct_winners' => $correctWinners,
            'perfect_predictions' => $perfectPredictions,
            'accuracy_percentage' => $accuracyPercentage,
            'last_updated' => now()->toDateString()
        ]);

        return $this;
    }

    public static function updateRankings()
    {
        $leaderboards = self::orderBy('total_points', 'desc')
                           ->orderBy('accuracy_percentage', 'desc')
                           ->orderBy('total_predictions', 'desc')
                           ->get();

        foreach ($leaderboards as $index => $leaderboard) {
            $newRank = $index + 1;
            $leaderboard->update([
                'previous_rank' => $leaderboard->current_rank,
                'current_rank' => $newRank,
                'rank' => $newRank
            ]);
        }
    }

    public function scopeTopUsers($query, $limit = 10)
    {
        return $query->orderBy('total_points', 'desc')
                    ->orderBy('accuracy_percentage', 'desc')
                    ->orderBy('total_predictions', 'desc')
                    ->limit($limit);
    }
}
