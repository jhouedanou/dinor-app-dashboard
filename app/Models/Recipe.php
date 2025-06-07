<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Recipe extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'ingredients',
        'instructions',
        'preparation_time',
        'cooking_time',
        'servings',
        'difficulty',
        'category_id',
        'image',
        'video_url',
        'tags',
        'is_featured',
        'is_published',
        'meta_description',
        'slug'
    ];

    protected $casts = [
        'ingredients' => 'array',
        'instructions' => 'array',
        'tags' => 'array',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'preparation_time' => 'integer',
        'cooking_time' => 'integer',
        'servings' => 'integer'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getTotalTimeAttribute()
    {
        return $this->preparation_time + $this->cooking_time;
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
} 