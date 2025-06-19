<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Ingredient;

class IngredientsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        $ingredients = [
            // Légumes
            [
                'name' => 'Tomate',
                'category' => 'Légumes',
                'subcategory' => 'Légumes fruits',
                'unit' => 'pièce',
                'recommended_brand' => null,
                'average_price' => 0.50,
                'description' => 'Tomate fraîche rouge',
                'is_active' => true,
            ],
            [
                'name' => 'Carotte',
                'category' => 'Légumes',
                'subcategory' => 'Légumes racines',
                'unit' => 'g',
                'recommended_brand' => null,
                'average_price' => 0.80,
                'description' => 'Carotte fraîche orange',
                'is_active' => true,
            ],
            [
                'name' => 'Oignon',
                'category' => 'Légumes',
                'subcategory' => 'Légumes bulbes',
                'unit' => 'pièce',
                'recommended_brand' => null,
                'average_price' => 0.30,
                'description' => 'Oignon jaune',
                'is_active' => true,
            ],
            
            // Viandes
            [
                'name' => 'Escalope de poulet',
                'category' => 'Viandes',
                'subcategory' => 'Volaille',
                'unit' => 'g',
                'recommended_brand' => 'Label Rouge',
                'average_price' => 12.50,
                'description' => 'Escalope de poulet fermier',
                'is_active' => true,
            ],
            
            // Produits laitiers
            [
                'name' => 'Lait entier',
                'category' => 'Produits laitiers',
                'subcategory' => 'Lait',
                'unit' => 'ml',
                'recommended_brand' => 'Lactel',
                'average_price' => 1.20,
                'description' => 'Lait entier UHT',
                'is_active' => true,
            ],
            [
                'name' => 'Gruyère râpé',
                'category' => 'Produits laitiers',
                'subcategory' => 'Fromages',
                'unit' => 'g',
                'recommended_brand' => 'Entremont',
                'average_price' => 8.50,
                'description' => 'Gruyère AOP râpé',
                'is_active' => true,
            ],
            
            // Épices et aromates
            [
                'name' => 'Sel fin',
                'category' => 'Épices et aromates',
                'subcategory' => 'Sels',
                'unit' => 'pincée',
                'recommended_brand' => 'La Baleine',
                'average_price' => 0.80,
                'description' => 'Sel fin de mer',
                'is_active' => true,
            ],
            [
                'name' => 'Poivre noir moulu',
                'category' => 'Épices et aromates',
                'subcategory' => 'Épices',
                'unit' => 'pincée',
                'recommended_brand' => 'Ducros',
                'average_price' => 2.50,
                'description' => 'Poivre noir fraîchement moulu',
                'is_active' => true,
            ],
            [
                'name' => 'Persil plat',
                'category' => 'Épices et aromates',
                'subcategory' => 'Herbes fraîches',
                'unit' => 'botte',
                'recommended_brand' => null,
                'average_price' => 1.50,
                'description' => 'Persil plat frais',
                'is_active' => true,
            ],
            
            // Huiles et matières grasses
            [
                'name' => 'Huile d\'olive extra vierge',
                'category' => 'Huiles et matières grasses',
                'subcategory' => 'Huiles d\'olive',
                'unit' => 'cuillère à soupe',
                'recommended_brand' => 'Puget',
                'average_price' => 4.50,
                'description' => 'Huile d\'olive extra vierge première pression à froid',
                'is_active' => true,
            ],
            [
                'name' => 'Beurre doux',
                'category' => 'Produits laitiers',
                'subcategory' => 'Beurre',
                'unit' => 'g',
                'recommended_brand' => 'Président',
                'average_price' => 3.20,
                'description' => 'Beurre doux moulé',
                'is_active' => true,
            ],
            
            // Céréales et féculents
            [
                'name' => 'Farine de blé T65',
                'category' => 'Céréales et féculents',
                'subcategory' => 'Farines',
                'unit' => 'g',
                'recommended_brand' => 'Francine',
                'average_price' => 1.80,
                'description' => 'Farine de blé type 65',
                'is_active' => true,
            ],
            [
                'name' => 'Riz basmati',
                'category' => 'Céréales et féculents',
                'subcategory' => 'Riz',
                'unit' => 'g',
                'recommended_brand' => 'Taureau Ailé',
                'average_price' => 3.50,
                'description' => 'Riz basmati parfumé',
                'is_active' => true,
            ],
        ];

        foreach ($ingredients as $ingredient) {
            Ingredient::create($ingredient);
        }
    }
} 