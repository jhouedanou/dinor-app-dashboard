<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class Recipe extends Model
{
    use HasFactory, SoftDeletes, Likeable, Commentable;

    protected $fillable = [
        'title',
        'description',
        'short_description',
        'ingredients',
        'instructions',
        'preparation_time',
        'cooking_time',
        'resting_time',
        'servings',
        'difficulty',
        'meal_type',
        'diet_type',
        'category_id',
        'featured_image',
        'gallery',
        'video_url',
        'video_thumbnail',
        'calories_per_serving',
        'protein_grams',
        'carbs_grams',
        'fat_grams',
        'fiber_grams',
        'cost_level',
        'season',
        'origin_country',
        'region',
        'required_equipment',
        'cooking_methods',
        'tags',
        'is_featured',
        'is_published',
        'meta_description',
        'slug',
        'chef_name',
        'chef_notes',
        'views_count',
        'likes_count',
        'favorites_count',
        'rating_average',
        'rating_count'
    ];

    protected $casts = [
        'ingredients' => 'array',
        'instructions' => 'array',
        'gallery' => 'array',
        'required_equipment' => 'array',
        'cooking_methods' => 'array',
        'tags' => 'array',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'preparation_time' => 'integer',
        'cooking_time' => 'integer',
        'resting_time' => 'integer',
        'servings' => 'integer',
        'calories_per_serving' => 'integer',
        'protein_grams' => 'decimal:2',
        'carbs_grams' => 'decimal:2',
        'fat_grams' => 'decimal:2',
        'fiber_grams' => 'decimal:2',
        'views_count' => 'integer',
        'likes_count' => 'integer',
        'favorites_count' => 'integer',
        'rating_average' => 'decimal:2',
        'rating_count' => 'integer'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function mediaFiles()
    {
        return $this->morphMany(MediaFile::class, 'model');
    }

    /**
     * Get all likes for this recipe
     */
    public function likes()
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get all comments for this recipe
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

    public function featuredImage()
    {
        return $this->morphOne(MediaFile::class, 'model')->where('collection_name', 'featured_image');
    }

    public function galleryImages()
    {
        return $this->morphMany(MediaFile::class, 'model')->where('collection_name', 'gallery');
    }

    public function videoFiles()
    {
        return $this->morphMany(MediaFile::class, 'model')->where('collection_name', 'videos');
    }

    public function getTotalTimeAttribute()
    {
        return $this->preparation_time + $this->cooking_time + $this->resting_time;
    }

    public function getFeaturedImageUrlAttribute()
    {
        return $this->featured_image ? asset('storage/' . $this->featured_image) : null;
    }

    public function getGalleryUrlsAttribute()
    {
        if (!$this->gallery) return [];
        
        return array_map(function($image) {
            return asset('storage/' . $image);
        }, $this->gallery);
    }

    public function getVideoThumbnailUrlAttribute()
    {
        return $this->video_thumbnail ? asset('storage/' . $this->video_thumbnail) : null;
    }

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeByMealType($query, $mealType)
    {
        return $query->where('meal_type', $mealType);
    }

    public function scopeByDifficulty($query, $difficulty)
    {
        return $query->where('difficulty', $difficulty);
    }

    public function scopeByDietType($query, $dietType)
    {
        return $query->where('diet_type', $dietType);
    }

    public function scopeBySeason($query, $season)
    {
        return $query->where('season', $season);
    }

    public function scopeQuickRecipes($query, $maxTime = 30)
    {
        return $query->whereRaw('(preparation_time + cooking_time) <= ?', [$maxTime]);
    }

    public function getDifficultyLabelAttribute()
    {
        return match($this->difficulty) {
            'easy' => 'Facile',
            'medium' => 'Moyen',
            'hard' => 'Difficile',
            default => 'Non défini'
        };
    }

    public function getMealTypeLabelAttribute()
    {
        return match($this->meal_type) {
            'breakfast' => 'Petit déjeuner',
            'lunch' => 'Déjeuner',
            'dinner' => 'Dîner',
            'snack' => 'Collation',
            'dessert' => 'Dessert',
            'aperitif' => 'Apéritif',
            default => 'Non défini'
        };
    }

    public function getDietTypeLabelAttribute()
    {
        return match($this->diet_type) {
            'none' => 'Aucun régime spécial',
            'vegetarian' => 'Végétarien',
            'vegan' => 'Végétalien',
            'gluten_free' => 'Sans gluten',
            'dairy_free' => 'Sans lactose',
            'keto' => 'Keto',
            'paleo' => 'Paléo',
            default => 'Non défini'
        };
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
    public function getCurrentLikesCountAttribute(): int
    {
        return $this->likes()->count();
    }

    /**
     * Get approved comments count
     */
    public function getApprovedCommentsCountAttribute(): int
    {
        return $this->approvedComments()->count();
    }

    /**
     * Get average rating from comments
     */
    public function getAverageRatingAttribute(): float
    {
        return $this->approvedComments()->whereNotNull('rating')->avg('rating') ?: 0;
    }

    /**
     * Check if user has liked this recipe
     */
    public function isLikedBy(string $userIdentifier): bool
    {
        return Like::hasLiked($this, $userIdentifier);
    }
} 