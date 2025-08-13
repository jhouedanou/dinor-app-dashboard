<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class SplashScreen extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'is_active',
        'title',
        'subtitle',
        'duration',
        'background_type',
        'background_color_start',
        'background_color_end',
        'background_gradient_direction',
        'logo_type',
        'logo_size',
        'text_color',
        'progress_bar_color',
        'animation_type',
        'meta_data',
        'schedule_start',
        'schedule_end',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'duration' => 'integer',
        'logo_size' => 'integer',
        'meta_data' => 'array',
        'schedule_start' => 'datetime',
        'schedule_end' => 'datetime',
    ];

    /**
     * Define media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('logo')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/svg+xml', 'image/webp']);

        $this->addMediaCollection('background_image')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }

    /**
     * Configure media conversions
     */
    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('logo_optimized')
            ->width(200)
            ->height(200)
            ->optimize()
            ->nonQueued();

        $this->addMediaConversion('background_mobile')
            ->width(1080)
            ->height(1920)
            ->optimize()
            ->nonQueued();
    }

    /**
     * Get logo URL
     */
    public function getLogoUrlAttribute(): ?string
    {
        $media = $this->getFirstMedia('logo');
        return $media ? $media->getUrl('logo_optimized') : null;
    }

    /**
     * Get background image URL
     */
    public function getBackgroundImageUrlAttribute(): ?string
    {
        $media = $this->getFirstMedia('background_image');
        return $media ? $media->getUrl('background_mobile') : null;
    }

    /**
     * Get the active splash screen
     */
    public static function getActive(): ?self
    {
        return static::where('is_active', true)
            ->where(function ($query) {
                $query->whereNull('schedule_start')
                    ->orWhere('schedule_start', '<=', now());
            })
            ->where(function ($query) {
                $query->whereNull('schedule_end')
                    ->orWhere('schedule_end', '>=', now());
            })
            ->first();
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeScheduled($query)
    {
        return $query->where('schedule_start', '<=', now())
            ->where('schedule_end', '>=', now());
    }
}