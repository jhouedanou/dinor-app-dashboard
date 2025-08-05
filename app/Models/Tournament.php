<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Tournament extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'start_date',
        'end_date',
        'registration_start',
        'registration_end',
        'prediction_deadline',
        'max_participants',
        'entry_fee',
        'currency',
        'prize_pool',
        'status',
        'rules',
        'image',
        'is_featured',
        'is_public',
        'created_by'
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'registration_start' => 'datetime',
        'registration_end' => 'datetime',
        'prediction_deadline' => 'datetime',
        'entry_fee' => 'decimal:2',
        'prize_pool' => 'decimal:2',
        'rules' => 'array',
        'is_featured' => 'boolean',
        'is_public' => 'boolean',
    ];

    protected $appends = [
        'status_label',
        'can_register',
        'can_predict',
        'is_expired',
        'participants_count',
        'progress_percentage'
    ];

    protected $attributes = [
        'created_by' => 1,
    ];

    // Statuts possibles
    const STATUS_UPCOMING = 'upcoming';
    const STATUS_REGISTRATION_OPEN = 'registration_open';
    const STATUS_REGISTRATION_CLOSED = 'registration_closed';
    const STATUS_ACTIVE = 'active';
    const STATUS_FINISHED = 'finished';
    const STATUS_CANCELLED = 'cancelled';

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function participants()
    {
        return $this->hasMany(TournamentParticipant::class);
    }

    public function matches()
    {
        return $this->hasMany(FootballMatch::class, 'tournament_id');
    }

    public function predictions()
    {
        return $this->hasManyThrough(Prediction::class, FootballMatch::class, 'tournament_id', 'football_match_id');
    }

    public function leaderboard()
    {
        return $this->hasMany(TournamentLeaderboard::class);
    }

    // Getters calculés
    public function getStatusLabelAttribute()
    {
        switch ($this->status) {
            case self::STATUS_UPCOMING:
                return 'À venir';
            case self::STATUS_REGISTRATION_OPEN:
                return 'Inscriptions ouvertes';
            case self::STATUS_REGISTRATION_CLOSED:
                return 'Inscriptions fermées';
            case self::STATUS_ACTIVE:
                return 'En cours';
            case self::STATUS_FINISHED:
                return 'Terminé';
            case self::STATUS_CANCELLED:
                return 'Annulé';
            default:
                return 'Inconnu';
        }
    }

    public function getCanRegisterAttribute()
    {
        if ($this->status !== self::STATUS_REGISTRATION_OPEN) {
            return false;
        }

        $now = now();
        
        if ($this->registration_start && $now < $this->registration_start) {
            return false;
        }

        if ($this->registration_end && $now > $this->registration_end) {
            return false;
        }

        if ($this->max_participants && $this->participants_count >= $this->max_participants) {
            return false;
        }

        return true;
    }

    public function getCanPredictAttribute()
    {
        if (!in_array($this->status, [self::STATUS_REGISTRATION_CLOSED, self::STATUS_ACTIVE])) {
            return false;
        }

        if ($this->prediction_deadline && now() > $this->prediction_deadline) {
            return false;
        }

        return true;
    }

    public function getIsExpiredAttribute()
    {
        return $this->end_date && now() > $this->end_date;
    }

    public function getParticipantsCountAttribute()
    {
        return $this->participants()->count();
    }

    public function getProgressPercentageAttribute()
    {
        if (!$this->start_date || !$this->end_date) {
            return 0;
        }

        $now = now();
        $start = $this->start_date;
        $end = $this->end_date;

        if ($now < $start) {
            return 0;
        }

        if ($now > $end) {
            return 100;
        }

        $total = $end->diffInSeconds($start);
        $elapsed = $now->diffInSeconds($start);

        return round(($elapsed / $total) * 100, 1);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', self::STATUS_UPCOMING);
    }

    public function scopeRegistrationOpen($query)
    {
        return $query->where('status', self::STATUS_REGISTRATION_OPEN);
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeNotExpired($query)
    {
        return $query->where(function($q) {
            $q->whereNull('end_date')
              ->orWhere('end_date', '>', now());
        });
    }

    // Méthodes utilitaires
    public function updateStatus()
    {
        $now = now();

        // Vérifier si le tournoi est expiré
        if ($this->end_date && $now > $this->end_date) {
            $this->status = self::STATUS_FINISHED;
        }
        // Vérifier si le tournoi a commencé
        elseif ($this->start_date && $now >= $this->start_date) {
            $this->status = self::STATUS_ACTIVE;
        }
        // Vérifier si les inscriptions sont fermées
        elseif ($this->registration_end && $now > $this->registration_end) {
            $this->status = self::STATUS_REGISTRATION_CLOSED;
        }
        // Vérifier si les inscriptions sont ouvertes
        elseif ($this->registration_start && $now >= $this->registration_start) {
            $this->status = self::STATUS_REGISTRATION_OPEN;
        }
        // Sinon, le tournoi est à venir
        else {
            $this->status = self::STATUS_UPCOMING;
        }

        $this->save();
        return $this->status;
    }

    public function canUserRegister(User $user)
    {
        if (!$this->can_register) {
            return false;
        }

        // Vérifier si l'utilisateur est déjà inscrit
        if ($this->participants()->where('user_id', $user->id)->exists()) {
            return false;
        }

        return true;
    }

    public function registerUser(User $user)
    {
        if (!$this->canUserRegister($user)) {
            return false;
        }

        $participant = TournamentParticipant::create([
            'tournament_id' => $this->id,
            'user_id' => $user->id,
            'registered_at' => now(),
            'status' => 'active'
        ]);

        // Mettre à jour le leaderboard
        $this->updateLeaderboard($user);

        return $participant;
    }

    public function updateLeaderboard(User $user = null)
    {
        $query = $this->participants();
        
        if ($user) {
            $query->where('user_id', $user->id);
        }

        foreach ($query->get() as $participant) {
            $predictions = $this->predictions()
                ->where('user_id', $participant->user_id)
                ->where('is_calculated', true)
                ->get();

            $totalPoints = $predictions->sum('points_earned');
            $totalPredictions = $predictions->count();
            $correctPredictions = $predictions->where('points_earned', '>', 0)->count();
            $accuracy = $totalPredictions > 0 ? round(($correctPredictions / $totalPredictions) * 100, 1) : 0;

            TournamentLeaderboard::updateOrCreate(
                [
                    'tournament_id' => $this->id,
                    'user_id' => $participant->user_id
                ],
                [
                    'total_points' => $totalPoints,
                    'total_predictions' => $totalPredictions,
                    'correct_predictions' => $correctPredictions,
                    'accuracy' => $accuracy,
                    'last_updated' => now()
                ]
            );
        }

        // Calculer les rangs
        $this->calculateRanks();
    }

    public function calculateRanks()
    {
        $leaderboard = $this->leaderboard()
            ->orderByDesc('total_points')
            ->orderByDesc('accuracy')
            ->orderByDesc('total_predictions')
            ->get();

        foreach ($leaderboard as $index => $entry) {
            $entry->update(['rank' => $index + 1]);
        }
    }

    public function getTopParticipants($limit = 10)
    {
        return $this->leaderboard()
            ->with('user')
            ->orderBy('rank')
            ->limit($limit)
            ->get();
    }
}