<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;
use Illuminate\Support\Str;

class EventCategoriesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $eventCategories = [
            [
                'name' => 'Ateliers de cuisine',
                'description' => 'Apprenez à cuisiner des plats traditionnels ivoiriens',
                'color' => '#f59e0b',
                'icon' => 'heroicon-o-academic-cap'
            ],
            [
                'name' => 'Dégustations',
                'description' => 'Découvrez de nouveaux saveurs et plats',
                'color' => '#10b981',
                'icon' => 'heroicon-o-heart'
            ],
            [
                'name' => 'Marchés et foires',
                'description' => 'Événements dans les marchés locaux',
                'color' => '#8b5cf6',
                'icon' => 'heroicon-o-shopping-bag'
            ],
            [
                'name' => 'Festivals culinaires',
                'description' => 'Grands festivals de la gastronomie ivoirienne',
                'color' => '#ef4444',
                'icon' => 'heroicon-o-sparkles'
            ],
            [
                'name' => 'Conférences',
                'description' => 'Conférences sur la nutrition et la gastronomie',
                'color' => '#3b82f6',
                'icon' => 'heroicon-o-microphone'
            ],
            [
                'name' => 'Rencontres communautaires',
                'description' => 'Événements de la communauté culinaire',
                'color' => '#06b6d4',
                'icon' => 'heroicon-o-users'
            ],
            [
                'name' => 'Concours culinaires',
                'description' => 'Compétitions de cuisine et challenges',
                'color' => '#f97316',
                'icon' => 'heroicon-o-trophy'
            ],
            [
                'name' => 'Formations professionnelles',
                'description' => 'Formations pour professionnels de la restauration',
                'color' => '#84cc16',
                'icon' => 'heroicon-o-briefcase'
            ]
        ];

        foreach ($eventCategories as $category) {
            Category::updateOrCreate(
                [
                    'name' => $category['name'],
                    'type' => 'event'
                ],
                [
                    'slug' => Str::slug($category['name']),
                    'type' => 'event',
                    'description' => $category['description'],
                    'color' => $category['color'],
                    'icon' => $category['icon'],
                    'is_active' => true
                ]
            );
        }
    }
}
