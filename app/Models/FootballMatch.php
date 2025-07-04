<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FootballMatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'home_team_id',
        'away_team_id',
        'match_date',
        'predictions_close_at',
        'status',
        'home_score',
        'away_score',
        'competition',
        'round',
        'venue',
        'notes',
        'is_active',
        'predictions_enabled'
    ];

    protected $casts = [
        'match_date' => 'datetime',
        'predictions_close_at' => 'datetime',
        'home_score' => 'integer',
        'away_score' => 'integer',
        'is_active' => 'boolean',
        'predictions_enabled' => 'boolean'
    ];

    protected $appends = [
        'winner',
        'is_finished',
        'can_predict',
        'match_result'
    ];

    public function homeTeam()
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam()
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function predictions()
    {
        return $this->hasMany(Prediction::class);
    }

    public function getWinnerAttribute()
    {
        if ($this->home_score === null || $this->away_score === null) {
            return null;
        }

        if ($this->home_score > $this->away_score) {
            return 'home';
        } elseif ($this->away_score > $this->home_score) {
            return 'away';
        } else {
            return 'draw';
        }
    }

    public function getIsFinishedAttribute()
    {
        return $this->status === 'finished';
    }

    public function getCanPredictAttribute()
    {
        if (!$this->predictions_enabled || !$this->is_active) {
            return false;
        }

        if ($this->predictions_close_at) {
            return now() < $this->predictions_close_at;
        }

        return now() < $this->match_date;
    }

    public function getMatchResultAttribute()
    {
        if (!$this->is_finished) {
            return null;
        }

        return [
            'home_score' => $this->home_score,
            'away_score' => $this->away_score,
            'winner' => $this->winner
        ];
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', 'scheduled')
                    ->where('match_date', '>', now());
    }

    public function scopeFinished($query)
    {
        return $query->where('status', 'finished');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePredictionsOpen($query)
    {
        return $query->where('predictions_enabled', true)
                    ->where(function($q) {
                        $q->whereNull('predictions_close_at')
                          ->where('match_date', '>', now())
                          ->orWhere('predictions_close_at', '>', now());
                    });
    }
}
