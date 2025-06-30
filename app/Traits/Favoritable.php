<?php

namespace App\Traits;

use App\Models\UserFavorite;
use Illuminate\Database\Eloquent\Relations\MorphMany;

trait Favoritable
{
    /**
     * Get all favorites for this model
     */
    public function favorites(): MorphMany
    {
        return $this->morphMany(UserFavorite::class, 'favoritable');
    }

    /**
     * Get favorites count attribute
     */
    public function getFavoritesCountAttribute()
    {
        return $this->favorites()->count();
    }

    /**
     * Check if user has favorited this item
     */
    public function isFavoritedByUser($userId)
    {
        if (!$userId) return false;
        
        return $this->favorites()
                   ->where('user_id', $userId)
                   ->exists();
    }

    /**
     * Add to user's favorites
     */
    public function addToFavorites($userId)
    {
        return UserFavorite::firstOrCreate([
            'user_id' => $userId,
            'favoritable_id' => $this->id,
            'favoritable_type' => get_class($this),
        ], [
            'favorited_at' => now(),
        ]);
    }

    /**
     * Remove from user's favorites
     */
    public function removeFromFavorites($userId)
    {
        return $this->favorites()
                   ->where('user_id', $userId)
                   ->delete();
    }

    /**
     * Toggle favorite status for user
     */
    public function toggleFavorite($userId)
    {
        if ($this->isFavoritedByUser($userId)) {
            $this->removeFromFavorites($userId);
            return false; // Removed
        } else {
            $this->addToFavorites($userId);
            return true; // Added
        }
    }

    /**
     * Scope to order by favorites count
     */
    public function scopeOrderByFavorites($query, $direction = 'desc')
    {
        return $query->withCount('favorites')
                    ->orderBy('favorites_count', $direction);
    }

    /**
     * Scope to get most favorited content
     */
    public function scopeMostFavorited($query, $limit = 10)
    {
        return $query->withCount('favorites')
                    ->orderBy('favorites_count', 'desc')
                    ->limit($limit);
    }

    /**
     * Get users who favorited this item
     */
    public function favoritedBy()
    {
        return $this->hasManyThrough(
            'App\Models\User',
            'App\Models\UserFavorite',
            'favoritable_id',
            'id',
            'id',
            'user_id'
        )->where('favoritable_type', get_class($this));
    }
}