<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Tip extends Model
{
    use HasFactory, SoftDeletes, Likeable, Commentable;

    protected $fillable = [
        'title',
        'content',
        'category_id',
        'image',
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
} 