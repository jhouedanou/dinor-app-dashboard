<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'abbreviation',
        'type',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order')->orderBy('name');
    }

    /**
     * Retourne les unités actives sous forme de tableau [abbreviation => "Nom (abbreviation)"]
     * Compatible avec l'ancien format de Ingredient::getUnits()
     */
    public static function getOptions(): array
    {
        return static::active()
            ->ordered()
            ->get()
            ->mapWithKeys(fn (Unit $unit) => [
                $unit->abbreviation => "{$unit->name} ({$unit->abbreviation})",
            ])
            ->toArray();
    }

    /**
     * Types d'unités disponibles
     */
    public static function getTypes(): array
    {
        return [
            'poids' => 'Poids',
            'volume' => 'Volume',
            'quantite' => 'Quantité',
            'autre' => 'Autre',
        ];
    }

    /**
     * Label lisible du type
     */
    public function getTypeLabelAttribute(): string
    {
        return static::getTypes()[$this->type] ?? $this->type;
    }
}
