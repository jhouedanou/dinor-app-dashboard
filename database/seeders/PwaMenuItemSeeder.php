<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PwaMenuItem;

class PwaMenuItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $menuItems = [
            [
                'name' => 'home',
                'label' => 'Accueil',
                'icon' => 'home',
                'route' => 'home',
                'path' => '/',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 1,
                'description' => 'Page d\'accueil de l\'application'
            ],
            [
                'name' => 'recipes',
                'label' => 'Recettes',
                'icon' => 'restaurant',
                'route' => 'recipes',
                'path' => '/recipes',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 2,
                'description' => 'Liste des recettes disponibles'
            ],
            [
                'name' => 'tips',
                'label' => 'Astuces',
                'icon' => 'lightbulb',
                'route' => 'tips',
                'path' => '/tips',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 3,
                'description' => 'Conseils et astuces culinaires'
            ],
            [
                'name' => 'events',
                'label' => 'Événements',
                'icon' => 'event',
                'route' => 'events',
                'path' => '/events',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 4,
                'description' => 'Événements et activités'
            ],
            [
                'name' => 'dinor-tv',
                'label' => 'Dinor TV',
                'icon' => 'play_circle',
                'route' => 'dinor-tv',
                'path' => '/dinor-tv',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 5,
                'description' => 'Contenu vidéo et médias'
            ],
            [
                'name' => 'web',
                'label' => 'Web',
                'icon' => 'web',
                'route' => 'web',
                'path' => null,
                'action_type' => 'web_embed',
                'web_url' => null,
                'is_active' => true,
                'order' => 6,
                'description' => 'Accès au contenu web depuis les Pages Filament'
            ],
            [
                'name' => 'profile',
                'label' => 'Profil',
                'icon' => 'person',
                'route' => 'profile',
                'path' => '/profile',
                'action_type' => 'route',
                'web_url' => null,
                'is_active' => true,
                'order' => 7,
                'description' => 'Profil utilisateur et paramètres'
            ]
        ];

        foreach ($menuItems as $item) {
            PwaMenuItem::updateOrCreate(
                ['name' => $item['name']],
                $item
            );
        }
    }
} 