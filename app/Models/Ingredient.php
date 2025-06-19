<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Ingredient extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'subcategory',
        'unit',
        'recommended_brand',
        'average_price',
        'description',
        'image',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'average_price' => 'decimal:2'
    ];

    public function getImageUrlAttribute()
    {
        return $this->image ? asset('storage/' . $this->image) : null;
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeBySubcategory($query, $subcategory)
    {
        return $query->where('subcategory', $subcategory);
    }

    public static function getUnits()
    {
        return [
            'kg' => 'Kilogramme (kg)',
            'g' => 'Gramme (g)',
            'mg' => 'Milligramme (mg)',
            'l' => 'Litre (l)',
            'ml' => 'Millilitre (ml)',
            'cl' => 'Centilitre (cl)',
            'dl' => 'Décilitre (dl)',
            'pièce' => 'Pièce',
            'cuillère à soupe' => 'Cuillère à soupe',
            'cuillère à café' => 'Cuillère à café',
            'tasse' => 'Tasse',
            'verre' => 'Verre',
            'pincée' => 'Pincée',
            'botte' => 'Botte',
            'sachet' => 'Sachet',
            'boîte' => 'Boîte',
            'tranche' => 'Tranche',
            'gousse' => 'Gousse',
            'brin' => 'Brin',
            'feuille' => 'Feuille'
        ];
    }

    public static function getCategories()
    {
        return [
            'Légumes' => [
                'Légumes racines',
                'Légumes feuilles',
                'Légumes fruits',
                'Légumes bulbes',
                'Champignons',
                'Légumineuses fraîches'
            ],
            'Fruits' => [
                'Fruits frais',
                'Fruits secs',
                'Fruits exotiques',
                'Agrumes',
                'Baies'
            ],
            'Viandes' => [
                'Bœuf',
                'Porc',
                'Agneau',
                'Volaille',
                'Gibier',
                'Charcuterie'
            ],
            'Poissons et fruits de mer' => [
                'Poissons blancs',
                'Poissons gras',
                'Crustacés',
                'Mollusques',
                'Poissons fumés'
            ],
            'Produits laitiers' => [
                'Lait',
                'Fromages',
                'Yaourts',
                'Crème',
                'Beurre'
            ],
            'Céréales et féculents' => [
                'Riz',
                'Pâtes',
                'Farines',
                'Pain',
                'Pommes de terre',
                'Légumineuses sèches'
            ],
            'Épices et aromates' => [
                'Épices',
                'Herbes fraîches',
                'Herbes séchées',
                'Condiments',
                'Sels'
            ],
            'Huiles et matières grasses' => [
                'Huiles végétales',
                'Huiles d\'olive',
                'Beurres végétaux',
                'Graisses animales'
            ],
            'Sucres et édulcorants' => [
                'Sucres blancs',
                'Sucres roux',
                'Miels',
                'Sirops',
                'Édulcorants'
            ],
            'Boissons' => [
                'Eaux',
                'Jus',
                'Vins',
                'Alcools',
                'Thés et tisanes'
            ]
        ];
    }
} 