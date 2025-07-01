<?php

namespace App\Traits;

use App\Models\Like;
use Illuminate\Database\Eloquent\Relations\MorphMany;

trait Likeable
{
    /**
     * Get all likes for this model
     */
    public function likes(): MorphMany
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get likes count attribute
     */
    public function getLikesCountAttribute()
    {
        return $this->likes()->count();
    }

    /**
     * Check if current user/IP has liked this content
     */
    public function isLikedBy($userId = null, $ipAddress = null)
    {
        return Like::isLiked($this, $userId, $ipAddress);
    }

    /**
     * Toggle like for this content
     */
    public function toggleLike($userId = null, $ipAddress = null, $userAgent = null)
    {
        return Like::toggle($this, $userId, $ipAddress, $userAgent);
    }

    /**
     * Add like to this content
     */
    public function addLike($userId = null, $ipAddress = null, $userAgent = null)
    {
        if (!$this->isLikedBy($userId, $ipAddress)) {
            $like = $this->likes()->create([
                'user_id' => $userId,
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
            ]);

            // Increment likes_count if like was created
            if ($like) {
                $this->increment('likes_count');
            }

            return $like;
        }
        
        return false;
    }

    /**
     * Remove like from this content
     */
    public function removeLike($userId = null, $ipAddress = null)
    {
        $query = $this->likes();

        if ($userId) {
            $query->where('user_id', $userId);
        } else {
            $query->where('ip_address', $ipAddress);
        }

        $deleted = $query->delete();

        // Decrement likes_count if a like was actually deleted
        if ($deleted > 0) {
            $this->decrement('likes_count');
        }

        return $deleted;
    }

    /**
     * Scope to order by likes count
     */
    public function scopeOrderByLikes($query, $direction = 'desc')
    {
        return $query->withCount('likes')
                    ->orderBy('likes_count', $direction);
    }

    /**
     * Scope to get most liked content
     */
    public function scopeMostLiked($query, $limit = 10)
    {
        return $query->withCount('likes')
                    ->orderBy('likes_count', 'desc')
                    ->limit($limit);
    }
} 