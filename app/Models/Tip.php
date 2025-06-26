<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Tip extends Model
{
    use HasFactory, Likeable, Commentable;

    protected $fillable = [
        'title',
        'content',
        'category_id',
        'image',
        'gallery',
        'video_url',
        'tags',
        'is_featured',
        'is_published',
        'difficulty_level',
        'estimated_time',
        'slug',
        'views_count',
        'likes_count',
        'favorites_count'
    ];

    protected $casts = [
        'tags' => 'array',
        'gallery' => 'array',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'estimated_time' => 'integer',
        'views_count' => 'integer',
        'likes_count' => 'integer',
        'favorites_count' => 'integer'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getImageUrlAttribute()
    {
        return $this->image ? asset('storage/' . $this->image) : null;
    }

    public function getGalleryUrlsAttribute()
    {
        if (!$this->gallery) return [];
        
        return array_map(function($image) {
            return asset('storage/' . $image);
        }, $this->gallery);
    }

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function incrementViews()
    {
        $this->increment('views_count');
    }

    public function incrementLikes()
    {
        $this->increment('likes_count');
    }

    public function incrementFavorites()
    {
        $this->increment('favorites_count');
    }

    /**
     * Get current likes count
     */
    public function getCurrentLikesCountAttribute()
    {
        return $this->likes()->count();
    }

    /**
     * Get approved comments count
     */
    public function getApprovedCommentsCountAttribute()
    {
        return $this->approvedComments()->count();
    }

    /**
     * Check if user has liked this tip
     */
    public function isLikedBy($userIdentifier)
    {
        return Like::hasLiked($this, $userIdentifier);
    }

    /**
     * Toggle like for this tip
     */
    public function toggleLike($userId = null, $ipAddress = null, $userAgent = null)
    {
        return Like::toggle($this, $userId, $ipAddress, $userAgent);
    }

    /**
     * Get all likes for this tip
     */
    public function likes()
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get all comments for this tip
     */
    public function comments()
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    /**
     * Get approved comments only
     */
    public function approvedComments()
    {
        return $this->morphMany(Comment::class, 'commentable')->approved();
    }
} 