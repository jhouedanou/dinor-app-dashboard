<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class EventCategory extends Model
{
    use HasFactory;

    protected $table = 'event_categories';

    protected $fillable = [
        'name',
        'slug',
        'description',
        'image',
        'color',
        'icon',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean'
    ];

    public function events()
    {
        return $this->hasMany(Event::class, 'event_category_id');
    }

    public function getImageUrlAttribute()
    {
        return $this->image ? asset('storage/' . $this->image) : null;
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Générer automatiquement le slug si pas fourni
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($eventCategory) {
            if (empty($eventCategory->slug)) {
                $eventCategory->slug = Str::slug($eventCategory->name);
                
                // Vérifier l'unicité du slug
                $originalSlug = $eventCategory->slug;
                $counter = 1;
                
                while (static::where('slug', $eventCategory->slug)->exists()) {
                    $eventCategory->slug = $originalSlug . '-' . $counter;
                    $counter++;
                }
            }
        });

        static::updating(function ($eventCategory) {
            if (empty($eventCategory->slug)) {
                $eventCategory->slug = Str::slug($eventCategory->name);
                
                // Vérifier l'unicité du slug (exclure l'enregistrement actuel)
                $originalSlug = $eventCategory->slug;
                $counter = 1;
                
                while (static::where('slug', $eventCategory->slug)->where('id', '!=', $eventCategory->id)->exists()) {
                    $eventCategory->slug = $originalSlug . '-' . $counter;
                    $counter++;
                }
            }
        });
    }
} 