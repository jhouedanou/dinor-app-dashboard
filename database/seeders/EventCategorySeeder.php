<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\EventCategory;
use Illuminate\Support\Str;

class EventCategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $eventCategories = [
            [
                'name' => 'Séminaire',
                'description' => 'Événements de formation et d\'apprentissage culinaire',
                'color' => '#3b82f6',
                'icon' => 'heroicon-o-academic-cap'
            ],
            [
                'name' => 'Conférence',
                'description' => 'Conférences sur la nutrition et la gastronomie',
                'color' => '#1e40af',
                'icon' => 'heroicon-o-microphone'
            ],
            [
                'name' => 'Atelier',
                'description' => 'Ateliers pratiques de cuisine ivoirienne',
                'color' => '#f59e0b',
                'icon' => 'heroicon-o-wrench-screwdriver'
            ],
            [
                'name' => 'Cours de cuisine',
                'description' => 'Cours d\'apprentissage des techniques culinaires',
                'color' => '#10b981',
                'icon' => 'heroicon-o-book-open'
            ],
            [
                'name' => 'Dégustation',
                'description' => 'Événements de dégustation de plats traditionnels',
                'color' => '#ef4444',
                'icon' => 'heroicon-o-heart'
            ],
            [
                'name' => 'Festival',
                'description' => 'Festivals culinaires et célébrations gastronomiques',
                'color' => '#8b5cf6',
                'icon' => 'heroicon-o-sparkles'
            ],
            [
                'name' => 'Concours',
                'description' => 'Compétitions et concours culinaires',
                'color' => '#f97316',
                'icon' => 'heroicon-o-trophy'
            ],
            [
                'name' => 'Networking',
                'description' => 'Événements de réseautage pour professionnels',
                'color' => '#06b6d4',
                'icon' => 'heroicon-o-users'
            ],
            [
                'name' => 'Exposition',
                'description' => 'Expositions de produits et matériels culinaires',
                'color' => '#84cc16',
                'icon' => 'heroicon-o-building-storefront'
            ],
            [
                'name' => 'Fête',
                'description' => 'Événements festifs et célébrations communautaires',
                'color' => '#ec4899',
                'icon' => 'heroicon-o-gift'
            ]
        ];

        foreach ($eventCategories as $category) {
            EventCategory::updateOrCreate(
                ['slug' => Str::slug($category['name'])],
                [
                    'name' => $category['name'],
                    'slug' => Str::slug($category['name']),
                    'description' => $category['description'],
                    'color' => $category['color'],
                    'icon' => $category['icon'],
                    'is_active' => true
                ]
            );
        }

        $this->command->info('Catégories d\'événements créées avec succès !');
    }
} 