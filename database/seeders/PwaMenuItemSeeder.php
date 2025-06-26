<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PwaMenuItem;

class PwaMenuItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        $menuItems = [
            [
                'title' => 'Accueil',
                'url' => '/',
                'icon' => 'home',
                'order' => 1,
                'is_active' => true,
                'description' => 'Page d\'accueil de l\'application'
            ],
            [
                'title' => 'Recettes',
                'url' => '/recipes',
                'icon' => 'restaurant',
                'order' => 2,
                'is_active' => true,
                'description' => 'Découvrez nos recettes authentiques'
            ],
            [
                'title' => 'Astuces',
                'url' => '/tips',
                'icon' => 'lightbulb',
                'order' => 3,
                'is_active' => true,
                'description' => 'Conseils et astuces culinaires'
            ],
            [
                'title' => 'Événements',
                'url' => '/events',
                'icon' => 'event',
                'order' => 4,
                'is_active' => true,
                'description' => 'Événements culinaires à venir'
            ],
            [
                'title' => 'Dinor TV',
                'url' => '/dinor-tv',
                'icon' => 'play_circle',
                'order' => 5,
                'is_active' => true,
                'description' => 'Vidéos culinaires et émissions'
            ],
            [
                'title' => 'Pages',
                'url' => '/pages',
                'icon' => 'article',
                'order' => 6,
                'is_active' => true,
                'description' => 'Pages d\'information'
            ]
        ];

        foreach ($menuItems as $item) {
            PwaMenuItem::updateOrCreate(
                ['url' => $item['url']],
                $item
            );
        }

        $this->command->info('Menu PWA créé avec succès !');
    }
}