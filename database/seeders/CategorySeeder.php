<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Entrées',
                'slug' => 'entrees',
                'description' => 'Plats d\'entrée et apéritifs',
                'color' => '#FF6B6B',
                'icon' => 'heroicon-o-sparkles',
                'is_active' => true,
            ],
            [
                'name' => 'Plats Principaux',
                'slug' => 'plats-principaux',
                'description' => 'Plats de résistance et repas complets',
                'color' => '#4ECDC4',
                'icon' => 'heroicon-o-cake',
                'is_active' => true,
            ],
            [
                'name' => 'Desserts',
                'slug' => 'desserts',
                'description' => 'Pâtisseries et desserts sucrés',
                'color' => '#FFE66D',
                'icon' => 'heroicon-o-heart',
                'is_active' => true,
            ],
            [
                'name' => 'Soupes',
                'slug' => 'soupes',
                'description' => 'Soupes et potages',
                'color' => '#95E1D3',
                'icon' => 'heroicon-o-fire',
                'is_active' => true,
            ],
            [
                'name' => 'Salades',
                'slug' => 'salades',
                'description' => 'Salades et plats frais',
                'color' => '#A8E6CF',
                'icon' => 'heroicon-o-leaf',
                'is_active' => true,
            ],
            [
                'name' => 'Pâtes',
                'slug' => 'pates',
                'description' => 'Recettes de pâtes et nouilles',
                'color' => '#FFB3BA',
                'icon' => 'heroicon-o-rectangle-stack',
                'is_active' => true,
            ],
            [
                'name' => 'Viandes',
                'slug' => 'viandes',
                'description' => 'Recettes à base de viande',
                'color' => '#DDA0DD',
                'icon' => 'heroicon-o-trophy',
                'is_active' => true,
            ],
            [
                'name' => 'Poissons',
                'slug' => 'poissons',
                'description' => 'Recettes à base de poisson et fruits de mer',
                'color' => '#87CEEB',
                'icon' => 'heroicon-o-water',
                'is_active' => true,
            ],
            [
                'name' => 'Végétarien',
                'slug' => 'vegetarien',
                'description' => 'Recettes végétariennes',
                'color' => '#98FB98',
                'icon' => 'heroicon-o-tree',
                'is_active' => true,
            ],
            [
                'name' => 'Petit Déjeuner',
                'slug' => 'petit-dejeuner',
                'description' => 'Recettes pour le petit déjeuner',
                'color' => '#F0E68C',
                'icon' => 'heroicon-o-sun',
                'is_active' => true,
            ],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(
                ['slug' => $category['slug']],
                $category
            );
        }

        $this->command->info('Catégories créées avec succès !');
    }
} 