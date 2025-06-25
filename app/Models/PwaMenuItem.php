<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PwaMenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'label',
        'icon',
        'route',
        'order',
        'is_active',
        'color',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    protected static function booted()
    {
        static::creating(function ($item) {
            if (is_null($item->order)) {
                $item->order = static::max('order') + 1;
            }
        });
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }
} 