<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TournamentParticipant extends Model
{
    use HasFactory;

    protected $fillable = [
        'tournament_id',
        'user_id',
        'registered_at',
        'status',
        'notes'
    ];

    protected $casts = [
        'registered_at' => 'datetime'
    ];

    // Statuts possibles
    const STATUS_ACTIVE = 'active';
    const STATUS_DISQUALIFIED = 'disqualified';
    const STATUS_WITHDRAWN = 'withdrawn';

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function predictions()
    {
        return $this->hasMany(Prediction::class, 'user_id', 'user_id')
            ->whereHas('footballMatch', function($query) {
                $query->where('tournament_id', $this->tournament_id);
            });
    }

    public function leaderboardEntry()
    {
        return $this->hasOne(TournamentLeaderboard::class, 'user_id', 'user_id')
            ->where('tournament_id', $this->tournament_id);
    }

    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    public function scopeForTournament($query, $tournamentId)
    {
        return $query->where('tournament_id', $tournamentId);
    }

    public function getTotalPointsAttribute()
    {
        return $this->leaderboardEntry?->total_points ?? 0;
    }

    public function getRankAttribute()
    {
        return $this->leaderboardEntry?->rank ?? 0;
    }
}