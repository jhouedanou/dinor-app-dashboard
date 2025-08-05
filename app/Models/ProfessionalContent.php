<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProfessionalContent extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'content_type',
        'title',
        'description',
        'content',
        'images',
        'video_url',
        'difficulty',
        'category',
        'preparation_time',
        'cooking_time',
        'servings',
        'ingredients',
        'steps',
        'tags',
        'status',
        'admin_notes',
        'submitted_at',
        'reviewed_at',
        'reviewed_by',
    ];

    protected $casts = [
        'images' => 'array',
        'ingredients' => 'array',
        'steps' => 'array',
        'tags' => 'array',
        'submitted_at' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';
    const STATUS_PUBLISHED = 'published';

    const CONTENT_TYPES = [
        'recipe' => 'Recette',
        'tip' => 'Astuce',
        'event' => 'Événement',
        'video' => 'Vidéo',
    ];

    const DIFFICULTIES = [
        'beginner' => 'Débutant',
        'easy' => 'Facile',
        'medium' => 'Intermédiaire',
        'hard' => 'Difficile',
        'expert' => 'Expert',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeApproved($query)
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    public function scopePublished($query)
    {
        return $query->where('status', self::STATUS_PUBLISHED);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('content_type', $type);
    }

    public function getStatusLabelAttribute()
    {
        return match($this->status) {
            self::STATUS_PENDING => 'En attente',
            self::STATUS_APPROVED => 'Approuvé',
            self::STATUS_REJECTED => 'Rejeté',
            self::STATUS_PUBLISHED => 'Publié',
            default => 'Inconnu',
        };
    }

    public function getContentTypeLabelAttribute()
    {
        return self::CONTENT_TYPES[$this->content_type] ?? $this->content_type;
    }

    public function getDifficultyLabelAttribute()
    {
        return $this->difficulty ? (self::DIFFICULTIES[$this->difficulty] ?? $this->difficulty) : null;
    }
}
