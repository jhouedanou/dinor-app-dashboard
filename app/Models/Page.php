<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Page extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'content',
        'slug',
        'meta_title',
        'meta_description',
        'meta_keywords',
        'template',
        'is_published',
        'is_homepage',
        'order',
        'parent_id',
        'featured_image'
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'is_homepage' => 'boolean',
        'order' => 'integer'
    ];

    public function parent()
    {
        return $this->belongsTo(Page::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(Page::class, 'parent_id')->orderBy('order');
    }

    public function getFeaturedImageUrlAttribute()
    {
        return $this->featured_image ? asset('storage/' . $this->featured_image) : null;
    }

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeRootPages($query)
    {
        return $query->whereNull('parent_id');
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }

    public function getUrlAttribute()
    {
        return url('/page/' . $this->slug);
    }
} 