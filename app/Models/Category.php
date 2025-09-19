<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'type',
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

    public function recipes()
    {
        return $this->hasMany(Recipe::class);
    }

    public function tips()
    {
        return $this->hasMany(Tip::class);
    }

    public function events()
    {
        return $this->hasMany(Event::class);
    }

    public function getImageUrlAttribute()
    {
        return $this->image ? asset('storage/' . $this->image) : null;
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeForEvents($query)
    {
        return $query->where('type', 'event');
    }

    public function scopeForRecipes($query)
    {
        return $query->where('type', 'recipe');
    }

    public function scopeGeneral($query)
    {
        return $query->where('type', 'general');
    }

    /**
     * Générer automatiquement le slug si pas fourni
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($category) {
            if (empty($category->slug)) {
                $category->slug = Str::slug($category->name);
                
                // Vérifier l'unicité du slug
                $originalSlug = $category->slug;
                $counter = 1;
                
                while (static::where('slug', $category->slug)->exists()) {
                    $category->slug = $originalSlug . '-' . $counter;
                    $counter++;
                }
            }
        });

        static::updating(function ($category) {
            if (empty($category->slug)) {
                $category->slug = Str::slug($category->name);
                
                // Vérifier l'unicité du slug (exclure l'enregistrement actuel)
                $originalSlug = $category->slug;
                $counter = 1;
                
                while (static::where('slug', $category->slug)->where('id', '!=', $category->id)->exists()) {
                    $category->slug = $originalSlug . '-' . $counter;
                    $counter++;
                }
            }
        });
    }
} 