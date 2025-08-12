<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Page;
use App\Models\Tip;
use App\Models\DinorTv;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Exécuter les seeders de base
        $this->call([
            AdminUserSeeder::class,
            UserSeeder::class,
            CategorySeeder::class,
            PwaMenuItemSeeder::class,
            EventCategoriesSeeder::class,
            IngredientsSeeder::class,
            ProductionDataSeeder::class,
            BannerSeeder::class,
            FootballTestDataSeeder::class,
            PredictionsTestSeeder::class,
        ]);

        // Créer des catégories
        $categories = [
            ['name' => 'Plats Principaux', 'slug' => 'plats-principaux', 'description' => 'Plats de résistance', 'color' => '#ef4444'],
            ['name' => 'Desserts', 'slug' => 'desserts', 'description' => 'Douceurs et pâtisseries', 'color' => '#f59e0b'],
            ['name' => 'Entrées', 'slug' => 'entrees', 'description' => 'Amuse-bouches et hors-d\'œuvre', 'color' => '#10b981'],
            ['name' => 'Boissons', 'slug' => 'boissons', 'description' => 'Cocktails et breuvages', 'color' => '#3b82f6'],
            ['name' => 'Cuisine Ivoirienne', 'slug' => 'cuisine-ivoirienne', 'description' => 'Spécialités de Côte d\'Ivoire', 'color' => '#8b5cf6'],
            ['name' => 'Cuisine Internationale', 'slug' => 'cuisine-internationale', 'description' => 'Saveurs du monde', 'color' => '#ec4899'],
        ];

        foreach ($categories as $categoryData) {
            Category::firstOrCreate(['slug' => $categoryData['slug']], $categoryData);
        }

        // Créer des recettes
        $recipes = [
            [
                'title' => 'Attiéké au Poisson Braisé',
                'slug' => 'attieke-poisson-braise',
                'description' => 'Plat traditionnel ivoirien avec attiéké et poisson grillé aux épices',
                'short_description' => 'Délicieux plat traditionnel de Côte d\'Ivoire',
                'category_id' => 1,
                'preparation_time' => 30,
                'cooking_time' => 45,
                'servings' => 4,
                'difficulty' => 'medium',
                'meal_type' => 'lunch',
                'diet_type' => 'none',
                'origin_country' => 'Côte d\'Ivoire',
                'season' => 'all',
                'ingredients' => [
                    ['name' => 'Attiéké', 'quantity' => '500', 'unit' => 'g'],
                    ['name' => 'Poisson rouge', 'quantity' => '1', 'unit' => 'kg'],
                    ['name' => 'Tomates', 'quantity' => '3', 'unit' => 'pièces'],
                    ['name' => 'Oignons', 'quantity' => '2', 'unit' => 'pièces'],
                    ['name' => 'Piment', 'quantity' => '2', 'unit' => 'pièces'],
                ],
                'dinor_ingredients' => [
                    [
                        'name' => 'Huile Dinor Classique',
                        'quantity' => '3 c. à soupe',
                        'purchase_url' => 'https://new.dinorapp.com/shop/huile-dinor-classique',
                        'description' => 'Idéale pour les fritures croustillantes',
                    ],
                ],
                'instructions' => [
                    ['step' => 'Nettoyer et assaisonner le poisson'],
                    ['step' => 'Faire griller le poisson sur le charbon'],
                    ['step' => 'Préparer la sauce avec tomates, oignons et piment'],
                    ['step' => 'Servir l\'attiéké avec le poisson et la sauce'],
                ],
                'chef_name' => 'Chef Aya',
                'tags' => ['ivoirien', 'traditionnel', 'poisson', 'attiéké'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Alloco aux Crevettes',
                'slug' => 'alloco-aux-crevettes',
                'description' => 'Bananes plantains frites accompagnées de crevettes sautées',
                'short_description' => 'Délicieuses bananes plantains aux crevettes',
                'category_id' => 1,
                'preparation_time' => 20,
                'cooking_time' => 25,
                'servings' => 3,
                'difficulty' => 'easy',
                'meal_type' => 'dinner',
                'diet_type' => 'none',
                'origin_country' => 'Côte d\'Ivoire',
                'ingredients' => [
                    ['name' => 'Bananes plantains', 'quantity' => '4', 'unit' => 'pièces'],
                    ['name' => 'Crevettes', 'quantity' => '300', 'unit' => 'g'],
                    ['name' => 'Huile de palme', 'quantity' => '3', 'unit' => 'cuillères à soupe'],
                    ['name' => 'Gingembre', 'quantity' => '1', 'unit' => 'morceau'],
                ],
                'dinor_ingredients' => [
                    [
                        'name' => 'Riz Vietnamien Dinor Jasmine',
                        'quantity' => '1 tasse (en accompagnement)',
                        'purchase_url' => 'https://new.dinorapp.com/shop/riz-dinor-vietnamien-jasmine',
                        'description' => 'Grains longs, parfumés, parfaits avec alloco',
                    ],
                ],
                'instructions' => [
                    ['step' => 'Éplucher et couper les bananes plantains'],
                    ['step' => 'Faire frire les bananes dans l\'huile chaude'],
                    ['step' => 'Nettoyer et assaisonner les crevettes'],
                    ['step' => 'Faire sauter les crevettes avec les épices'],
                    ['step' => 'Servir chaud ensemble'],
                ],
                'tags' => ['alloco', 'crevettes', 'banane', 'frit'],
                'is_published' => true,
            ],
        ];

        foreach ($recipes as $recipeData) {
            Recipe::create($recipeData);
        }

        // Créer des événements
        $events = [
            [
                'title' => 'Festival Gastronomique de Dinor',
                'slug' => 'festival-gastronomique-dinor',
                'description' => 'Découvrez les saveurs de la Côte d\'Ivoire lors de notre grand festival culinaire',
                'short_description' => 'Festival culinaire avec dégustations et ateliers',
                'content' => '<p>Rejoignez-nous pour une célébration exceptionnelle de la gastronomie ivoirienne...</p>',
                'start_date' => now()->addDays(30),
                'end_date' => now()->addDays(32),
                'start_time' => '09:00:00',
                'end_time' => '18:00:00',
                'location' => 'Parc des Sports de Treichville',
                'address' => 'Boulevard de la République, Treichville',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => 1,
                'event_type' => 'festival',
                'event_format' => 'in_person',
                'max_participants' => 500,
                'price' => 5000,
                'currency' => 'XOF',
                'is_free' => false,
                'status' => 'active',
                'tags' => ['festival', 'gastronomie', 'culture', 'dégustation'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Atelier Cuisine : Les Secrets de l\'Attiéké',
                'slug' => 'atelier-cuisine-attieke',
                'description' => 'Apprenez à préparer l\'attiéké traditionnel avec nos chefs experts',
                'short_description' => 'Cours de cuisine pour maîtriser l\'attiéké',
                'start_date' => now()->addDays(15),
                'start_time' => '14:00:00',
                'end_time' => '17:00:00',
                'location' => 'École de Cuisine Dinor',
                'address' => 'Rue de la Cuisine, Cocody',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => 1,
                'event_type' => 'cooking_class',
                'event_format' => 'in_person',
                'max_participants' => 20,
                'price' => 15000,
                'currency' => 'XOF',
                'is_free' => false,
                'requires_registration' => true,
                'status' => 'active',
                'tags' => ['atelier', 'cuisine', 'attiéké', 'apprentissage'],
                'is_published' => true,
            ],
        ];

        foreach ($events as $eventData) {
            Event::create($eventData);
        }

        // Créer des pages
        $pages = [
            [
                'title' => 'À Propos de Dinor',
                'slug' => 'a-propos',
                'content' => '<h2>Notre Histoire</h2><p>Dinor est né de la passion pour la cuisine ivoirienne...</p>',
                'template' => 'about',
                'is_published' => true,
                'order' => 1,
            ],
            [
                'title' => 'Contact',
                'slug' => 'contact',
                'content' => '<h2>Contactez-nous</h2><p>Vous avez des questions ? N\'hésitez pas à nous contacter...</p>',
                'template' => 'contact',
                'is_published' => true,
                'order' => 2,
            ],
            [
                'title' => 'Conditions d\'utilisation',
                'slug' => 'conditions-utilisation',
                'content' => '<h2>Conditions d\'utilisation de l\'application Dinor</h2><p>En utilisant notre application...</p>',
                'template' => 'default',
                'is_published' => true,
                'order' => 3,
            ],
        ];

        foreach ($pages as $pageData) {
            Page::create($pageData);
        }

        // Créer des astuces
        $tips = [
            [
                'title' => 'Comment bien choisir son attiéké',
                'slug' => 'choisir-attieke',
                'content' => 'Pour choisir un bon attiéké, vérifiez la couleur qui doit être bien blanche...',
                'category_id' => 1,
                'difficulty_level' => 'beginner',
                'estimated_time' => 5,
                'tags' => ['attiéké', 'conseils', 'achat'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Conservation des épices africaines',
                'slug' => 'conservation-epices',
                'content' => 'Les épices africaines se conservent mieux dans des contenants hermétiques...',
                'category_id' => 1,
                'difficulty_level' => 'beginner',
                'estimated_time' => 3,
                'tags' => ['épices', 'conservation', 'astuces'],
                'is_published' => true,
            ],
        ];

        foreach ($tips as $tipData) {
            Tip::create($tipData);
        }

        // Créer des contenus Dinor TV
        $videos = [
            [
                'title' => 'Préparation de l\'Attiéké - Étape par étape',
                'slug' => 'preparation-attieke-video',
                'description' => 'Découvrez comment préparer l\'attiéké traditionnel en vidéo',
                'video_url' => 'https://www.youtube.com/watch?v=example1',
                'duration' => 480, // 8 minutes
                'category_id' => 1,
                'tags' => ['attiéké', 'tutoriel', 'traditionnel'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Live : Cuisine avec Chef Aya',
                'slug' => 'live-chef-aya',
                'description' => 'Session de cuisine en direct avec notre chef expert',
                'video_url' => 'https://www.youtube.com/watch?v=example2',
                'duration' => 3600, // 1 heure
                'category_id' => 1,
                'is_live' => true,
                'scheduled_at' => now()->addDays(7),
                'tags' => ['live', 'chef', 'interactif'],
                'is_published' => true,
            ],
        ];

        foreach ($videos as $videoData) {
            DinorTv::create($videoData);
        }
    }
} 