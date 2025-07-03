<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'type_contenu',
        'titre',
        'sous_titre',
        'section',
        'image_url',
        'demo_video_url',
        'background_color',
        'text_color',
        'button_text',
        'button_url',
        'button_color',
        'is_active',
        'order',
        'position'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeForHome($query)
    {
        return $query->where('position', 'home');
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order', 'asc');
    }
}
