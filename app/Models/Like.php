<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class Like extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'likeable_id',
        'likeable_type',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the likeable entity (Recipe, DinorTv, Event, etc.)
     */
    public function likeable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get the user who liked (if authenticated)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if a specific content is liked by user/IP
     */
    public static function isLiked($likeable, $userId = null, $ipAddress = null)
    {
        $query = static::where('likeable_id', $likeable->id)
                      ->where('likeable_type', get_class($likeable));

        if ($userId) {
            $query->where('user_id', $userId);
        } else {
            $query->where('ip_address', $ipAddress);
        }

        return $query->exists();
    }

    /**
     * Toggle like for a content
     */
    public static function toggle($likeable, $userId = null, $ipAddress = null, $userAgent = null)
    {
        $query = static::where('likeable_id', $likeable->id)
                      ->where('likeable_type', get_class($likeable));

        if ($userId) {
            $query->where('user_id', $userId);
        } else {
            $query->where('ip_address', $ipAddress);
        }

        $existingLike = $query->first();

        if ($existingLike) {
            $existingLike->delete();
            return ['action' => 'unliked', 'likes_count' => $likeable->likes_count - 1];
        } else {
            static::create([
                'user_id' => $userId,
                'likeable_id' => $likeable->id,
                'likeable_type' => get_class($likeable),
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
            ]);
            return ['action' => 'liked', 'likes_count' => $likeable->likes_count + 1];
        }
    }
} 