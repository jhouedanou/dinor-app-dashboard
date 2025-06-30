<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use App\Traits\Favoritable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DinorTv extends Model
{
    use HasFactory, SoftDeletes, Likeable, Commentable, Favoritable;

    protected $table = 'dinor_tv';

    protected $fillable = [
        'title',
        'description',
        'video_url',
        'is_featured',
        'is_published',
        'view_count'
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'view_count' => 'integer'
    ];

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }
} 