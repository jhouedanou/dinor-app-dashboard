<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Comment extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'commentable_id',
        'commentable_type',
        'author_name',
        'author_email',
        'content',
        'is_approved',
        'ip_address',
        'user_agent',
        'parent_id',
    ];

    protected $casts = [
        'is_approved' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $dates = ['deleted_at'];

    /**
     * Get the commentable entity (Recipe, DinorTv, Event, etc.)
     */
    public function commentable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get the user who commented (if authenticated)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the parent comment (for replies)
     */
    public function parent()
    {
        return $this->belongsTo(Comment::class, 'parent_id');
    }

    /**
     * Get replies to this comment
     */
    public function replies()
    {
        return $this->hasMany(Comment::class, 'parent_id')
                   ->where('is_approved', true)
                   ->orderBy('created_at', 'asc');
    }

    /**
     * Get all replies (including unapproved) - for admin
     */
    public function allReplies()
    {
        return $this->hasMany(Comment::class, 'parent_id')
                   ->orderBy('created_at', 'asc');
    }

    /**
     * Scope for approved comments only
     */
    public function scopeApproved($query)
    {
        return $query->where('is_approved', true);
    }

    /**
     * Scope for pending approval
     */
    public function scopePending($query)
    {
        return $query->where('is_approved', false);
    }

    /**
     * Scope for top-level comments (not replies)
     */
    public function scopeTopLevel($query)
    {
        return $query->whereNull('parent_id');
    }

    /**
     * Get author display name
     */
    public function getAuthorNameAttribute($value)
    {
        if ($this->user) {
            return $this->user->name;
        }
        
        return $value ?: 'Utilisateur anonyme';
    }

    /**
     * Check if comment can be edited/deleted by user
     */
    public function canModify($userId = null, $ipAddress = null)
    {
        if ($this->user_id && $userId) {
            return $this->user_id === $userId;
        }
        
        if (!$this->user_id && $ipAddress) {
            return $this->ip_address === $ipAddress;
        }
        
        return false;
    }

    /**
     * Get the admin who moderated this comment
     */
    public function moderatedBy(): BelongsTo
    {
        return $this->belongsTo(AdminUser::class, 'moderated_by');
    }

    /**
     * Get status label in French
     */
    public function getStatusLabelAttribute(): string
    {
        return match($this->is_approved) {
            true => 'Approuvé',
            false => 'En attente',
            default => 'Inconnu'
        };
    }
} 