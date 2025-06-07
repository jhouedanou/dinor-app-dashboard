<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Event extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'content',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'location',
        'address',
        'latitude',
        'longitude',
        'category_id',
        'image',
        'gallery',
        'video_url',
        'registration_url',
        'contact_info',
        'max_participants',
        'current_participants',
        'price',
        'currency',
        'is_free',
        'is_featured',
        'is_published',
        'status',
        'tags',
        'slug'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'gallery' => 'array',
        'contact_info' => 'array',
        'tags' => 'array',
        'is_free' => 'boolean',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'max_participants' => 'integer',
        'current_participants' => 'integer',
        'price' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8'
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

    public function scopeUpcoming($query)
    {
        return $query->where('start_date', '>=', now()->toDateString());
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function getIsFullAttribute()
    {
        return $this->max_participants && $this->current_participants >= $this->max_participants;
    }

    public function getAvailableSpotsAttribute()
    {
        return $this->max_participants ? $this->max_participants - $this->current_participants : null;
    }
} 