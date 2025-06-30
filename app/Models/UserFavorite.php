<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserFavorite extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'favoritable_id',
        'favoritable_type',
        'favorited_at',
    ];

    protected $casts = [
        'favorited_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the favoritable entity (Recipe, Event, Tip, DinorTv)
     */
    public function favoritable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get the user who favorited
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope for a specific user
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope for a specific favoritable type
     */
    public function scopeForType($query, $type)
    {
        return $query->where('favoritable_type', $type);
    }

    /**
     * Get user's favorites by type
     */
    public static function getUserFavoritesByType($userId, $type)
    {
        return static::forUser($userId)
                     ->forType($type)
                     ->with('favoritable')
                     ->orderBy('favorited_at', 'desc')
                     ->get();
    }

    /**
     * Check if user has favorited an item
     */
    public static function isFavorited($userId, $favoritableId, $favoritableType)
    {
        return static::where('user_id', $userId)
                     ->where('favoritable_id', $favoritableId)
                     ->where('favoritable_type', $favoritableType)
                     ->exists();
    }

    /**
     * Toggle favorite status
     */
    public static function toggleFavorite($userId, $favoritableId, $favoritableType)
    {
        $favorite = static::where('user_id', $userId)
                          ->where('favoritable_id', $favoritableId)
                          ->where('favoritable_type', $favoritableType)
                          ->first();

        if ($favorite) {
            $favorite->delete();
            return false; // Removed from favorites
        } else {
            static::create([
                'user_id' => $userId,
                'favoritable_id' => $favoritableId,
                'favoritable_type' => $favoritableType,
                'favorited_at' => now(),
            ]);
            return true; // Added to favorites
        }
    }
}