<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use App\Traits\Favoritable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class DinorTv extends Model implements HasMedia
{
    use HasFactory, SoftDeletes, Likeable, Commentable, Favoritable, InteractsWithMedia;

    protected $table = 'dinor_tv';

    protected $fillable = [
        'title',
        'description',
        'short_description',
        'video_url',
        'thumbnail',
        'featured_image',
        'gallery',
        'poster_image',
        'banner_image',
        'image_metadata',
        'is_featured',
        'is_published',
        'view_count'
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'view_count' => 'integer',
        'gallery' => 'array',
        'image_metadata' => 'array',
    ];

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    /**
     * Define media collections for Spatie Media Library
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('featured_images')
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('gallery')
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('posters')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('banners')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }

    /**
     * Configure media conversions
     */
    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('thumbnail')
            ->width(400)
            ->height(300)
            ->optimize()
            ->nonQueued();

        $this->addMediaConversion('mobile')
            ->width(800)
            ->height(600)
            ->optimize()
            ->nonQueued();

        $this->addMediaConversion('banner')
            ->width(1200)
            ->height(400)
            ->optimize()
            ->nonQueued();
    }

    /**
     * Get featured image URL with fallback
     */
    public function getFeaturedImageUrlAttribute(): ?string
    {
        // Prioriser les images uploadées via Spatie
        $media = $this->getFirstMedia('featured_images');
        if ($media) {
            return $media->getUrl('mobile');
        }

        // Fallback sur le champ featured_image
        if ($this->featured_image) {
            return $this->featured_image;
        }

        // Fallback sur thumbnail existant
        return $this->thumbnail;
    }

    /**
     * Get gallery images URLs
     */
    public function getGalleryImagesAttribute(): array
    {
        $images = [];

        // Images depuis Spatie Media Library
        $mediaImages = $this->getMedia('gallery');
        foreach ($mediaImages as $media) {
            $images[] = [
                'url' => $media->getUrl(),
                'thumbnail' => $media->getUrl('thumbnail'),
                'alt' => $media->name,
            ];
        }

        // Images depuis le champ JSON gallery
        if ($this->gallery && is_array($this->gallery)) {
            foreach ($this->gallery as $imageUrl) {
                $images[] = [
                    'url' => $imageUrl,
                    'thumbnail' => $imageUrl,
                    'alt' => $this->title,
                ];
            }
        }

        return $images;
    }

    /**
     * Get poster image URL
     */
    public function getPosterImageUrlAttribute(): ?string
    {
        $media = $this->getFirstMedia('posters');
        if ($media) {
            return $media->getUrl('mobile');
        }

        return $this->poster_image;
    }

    /**
     * Get banner image URL
     */
    public function getBannerImageUrlAttribute(): ?string
    {
        $media = $this->getFirstMedia('banners');
        if ($media) {
            return $media->getUrl('banner');
        }

        return $this->banner_image;
    }
} 