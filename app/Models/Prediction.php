<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'football_match_id',
        'predicted_home_score',
        'predicted_away_score',
        'predicted_winner',
        'points_earned',
        'is_calculated',
        'ip_address',
        'user_agent'
    ];

    protected $casts = [
        'predicted_home_score' => 'integer',
        'predicted_away_score' => 'integer',
        'points_earned' => 'integer',
        'is_calculated' => 'boolean'
    ];

    protected $appends = [
        'prediction_summary'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function footballMatch()
    {
        return $this->belongsTo(FootballMatch::class);
    }

    public function getPredictionSummaryAttribute()
    {
        return [
            'score' => $this->predicted_home_score . '-' . $this->predicted_away_score,
            'winner' => $this->predicted_winner,
            'points' => $this->points_earned
        ];
    }

    public function calculatePoints()
    {
        $match = $this->footballMatch;
        
        if (!$match->is_finished) {
            return 0;
        }

        $points = 0;
        $actualWinner = $match->winner;
        $exactScore = ($this->predicted_home_score == $match->home_score && 
                      $this->predicted_away_score == $match->away_score);
        $correctWinner = ($this->predicted_winner == $actualWinner);

        if ($exactScore && $correctWinner) {
            // Score exact + gagnant = 3 points
            $points = 3;
        } elseif ($exactScore && !$correctWinner) {
            // Score exact mais mauvais gagnant = 3 points quand même
            $points = 3;
        } elseif (!$exactScore && $correctWinner) {
            // Bon gagnant seulement = 1 point
            $points = 1;
        }

        $this->update([
            'points_earned' => $points,
            'is_calculated' => true
        ]);

        return $points;
    }

    public function scopeCalculated($query)
    {
        return $query->where('is_calculated', true);
    }

    public function scopePending($query)
    {
        return $query->where('is_calculated', false);
    }
}
