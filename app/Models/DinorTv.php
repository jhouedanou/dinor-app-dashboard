<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DinorTv extends Model
{
    use HasFactory, SoftDeletes, Likeable, Commentable;

    protected $table = 'dinor_tv';

    protected $fillable = [
        'title',
        'description',
        'video_url',
        'thumbnail',
        'duration',
        'category_id',
        'tags',
        'is_featured',
        'is_published',
        'is_live',
        'scheduled_at',
        'view_count',
        'like_count',
        'slug'
    ];

    protected $casts = [
        'tags' => 'array',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'is_live' => 'boolean',
        'scheduled_at' => 'datetime',
        'view_count' => 'integer',
        'like_count' => 'integer',
        'duration' => 'integer'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getThumbnailUrlAttribute()
    {
        return $this->thumbnail ? asset('storage/' . $this->thumbnail) : null;
    }

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeLive($query)
    {
        return $query->where('is_live', true);
    }

    public function scopeScheduled($query)
    {
        return $query->whereNotNull('scheduled_at')
                    ->where('scheduled_at', '>', now());
    }

    public function getDurationFormattedAttribute()
    {
        if (!$this->duration) return null;
        
        $minutes = floor($this->duration / 60);
        $seconds = $this->duration % 60;
        
        return sprintf('%d:%02d', $minutes, $seconds);
    }
} 