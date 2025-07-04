<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TournamentLeaderboard extends Model
{
    use HasFactory;

    protected $fillable = [
        'tournament_id',
        'user_id',
        'rank',
        'total_points',
        'total_predictions',
        'correct_predictions',
        'accuracy',
        'last_updated'
    ];

    protected $casts = [
        'accuracy' => 'decimal:1',
        'last_updated' => 'datetime'
    ];

    protected $appends = [
        'position_change',
        'performance_trend'
    ];

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function participant()
    {
        return $this->hasOne(TournamentParticipant::class, 'user_id', 'user_id')
            ->where('tournament_id', $this->tournament_id);
    }

    // Calculer le changement de position depuis la dernière mise à jour
    public function getPositionChangeAttribute()
    {
        $previousEntry = static::where('tournament_id', $this->tournament_id)
            ->where('user_id', $this->user_id)
            ->where('last_updated', '<', $this->last_updated)
            ->orderByDesc('last_updated')
            ->first();

        if (!$previousEntry) {
            return 0;
        }

        return $previousEntry->rank - $this->rank;
    }

    // Calculer la tendance de performance
    public function getPerformanceTrendAttribute()
    {
        $recentPredictions = Prediction::whereHas('footballMatch', function($query) {
                $query->where('tournament_id', $this->tournament_id);
            })
            ->where('user_id', $this->user_id)
            ->where('is_calculated', true)
            ->orderByDesc('created_at')
            ->limit(5)
            ->get();

        if ($recentPredictions->count() < 3) {
            return 'neutral';
        }

        $recentAverage = $recentPredictions->avg('points_earned');
        $overallAverage = $this->total_predictions > 0 ? $this->total_points / $this->total_predictions : 0;

        if ($recentAverage > $overallAverage + 0.5) {
            return 'up';
        } elseif ($recentAverage < $overallAverage - 0.5) {
            return 'down';
        }

        return 'neutral';
    }

    public function scopeForTournament($query, $tournamentId)
    {
        return $query->where('tournament_id', $tournamentId);
    }

    public function scopeTopRanked($query, $limit = 10)
    {
        return $query->orderBy('rank')->limit($limit);
    }

    public function scopeByRank($query)
    {
        return $query->orderBy('rank');
    }

    public function getPositionSuffix()
    {
        switch ($this->rank) {
            case 1:
                return 'er';
            default:
                return 'ème';
        }
    }

    public function getRankDisplayAttribute()
    {
        return $this->rank . $this->getPositionSuffix();
    }

    public function getBadgeColorAttribute()
    {
        switch ($this->rank) {
            case 1:
                return '#FFD700'; // Or
            case 2:
                return '#C0C0C0'; // Argent
            case 3:
                return '#CD7F32'; // Bronze
            default:
                return '#6B7280'; // Gris
        }
    }

    public function getBadgeIconAttribute()
    {
        switch ($this->rank) {
            case 1:
                return 'emoji_events';
            case 2:
                return 'workspace_premium';
            case 3:
                return 'military_tech';
            default:
                return 'person';
        }
    }
}