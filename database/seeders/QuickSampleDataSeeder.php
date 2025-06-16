<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\Tip;
use App\Models\Category;

class QuickSampleDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer des utilisateurs de test
        $users = [];
        for ($i = 1; $i <= 10; $i++) {
            $users[] = User::create([
                'name' => "Utilisateur Test $i",
                'email' => "user$i@dinor.app",
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ]);
        }

        $this->command->info('Utilisateurs créés: ' . count($users));

        // Récupérer les catégories existantes
        $categories = Category::all();
        if ($categories->count() == 0) {
            $this->command->error('Aucune catégorie trouvée. Exécutez d\'abord DatabaseSeeder.');
            return;
        }

        // Créer des recettes supplémentaires
        $recipes = [
            [
                'title' => 'Kedjenou de Poulet',
                'slug' => 'kedjenou-poulet-' . time(),
                'description' => 'Poulet traditionnel cuit à l\'étouffée avec des légumes dans une canari',
                'short_description' => 'Spécialité ivoirienne authentique',
                'category_id' => $categories->first()->id,
                'preparation_time' => 25,
                'cooking_time' => 60,
                'servings' => 6,
                'difficulty' => 'medium',
                'meal_type' => 'lunch',
                'is_published' => true,
                'is_featured' => true,
                'chef_name' => 'Chef Konaté',
                'ingredients' => [
                    ['name' => 'Poulet fermier', 'quantity' => '1.5', 'unit' => 'kg'],
                    ['name' => 'Gingembre frais', 'quantity' => '30', 'unit' => 'g'],
                    ['name' => 'Oignons', 'quantity' => '3', 'unit' => 'pièces'],
                    ['name' => 'Tomates', 'quantity' => '4', 'unit' => 'pièces'],
                    ['name' => 'Piment', 'quantity' => '2', 'unit' => 'pièces']
                ],
                'instructions' => [
                    ['step' => 'Découper le poulet en morceaux moyens'],
                    ['step' => 'Assaisonner avec gingembre râpé et épices'],
                    ['step' => 'Disposer dans une canari avec légumes'],
                    ['step' => 'Cuire à l\'étouffée pendant 1 heure']
                ],
                'tags' => ['kedjenou', 'poulet', 'traditionnel', 'canari'],
                'origin_country' => 'Côte d\'Ivoire',
            ],
            [
                'title' => 'Sauce Graine Authentique',
                'slug' => 'sauce-graine-' . time(),
                'description' => 'Sauce traditionnelle à base de graines de palme, un délice ivoirien',
                'short_description' => 'Délicieuse sauce rouge traditionnelle',
                'category_id' => $categories->first()->id,
                'preparation_time' => 45,
                'cooking_time' => 120,
                'servings' => 8,
                'difficulty' => 'hard',
                'meal_type' => 'lunch',
                'is_published' => true,
                'chef_name' => 'Chef Aminata',
                'ingredients' => [
                    ['name' => 'Graines de palme fraîches', 'quantity' => '1', 'unit' => 'kg'],
                    ['name' => 'Viande de bœuf', 'quantity' => '800', 'unit' => 'g'],
                    ['name' => 'Poisson fumé', 'quantity' => '200', 'unit' => 'g'],
                    ['name' => 'Gombo frais', 'quantity' => '300', 'unit' => 'g'],
                    ['name' => 'Épinards', 'quantity' => '250', 'unit' => 'g']
                ],
                'instructions' => [
                    ['step' => 'Écraser les graines de palme avec un pilon'],
                    ['step' => 'Extraire l\'huile rouge en ajoutant de l\'eau chaude'],
                    ['step' => 'Cuire la viande avec les épices et assaisonnements'],
                    ['step' => 'Ajouter l\'huile rouge et laisser mijoter'],
                    ['step' => 'Incorporer les légumes et cuire 30 minutes']
                ],
                'tags' => ['sauce', 'graine', 'traditionnel', 'rouge'],
                'origin_country' => 'Côte d\'Ivoire',
            ],
            [
                'title' => 'Alloco Parfait',
                'slug' => 'alloco-parfait-' . time(),
                'description' => 'Bananes plantains dorées à la perfection, accompagnées d\'une sauce pimentée',
                'short_description' => 'Bananes plantains frites croustillantes',
                'category_id' => $categories->first()->id,
                'preparation_time' => 15,
                'cooking_time' => 20,
                'servings' => 4,
                'difficulty' => 'easy',
                'meal_type' => 'snack',
                'is_published' => true,
                'is_featured' => true,
                'chef_name' => 'Chef Adjoua',
                'ingredients' => [
                    ['name' => 'Bananes plantains mûres', 'quantity' => '6', 'unit' => 'pièces'],
                    ['name' => 'Huile de palme', 'quantity' => '200', 'unit' => 'ml'],
                    ['name' => 'Gingembre', 'quantity' => '1', 'unit' => 'morceau'],
                    ['name' => 'Piment rouge', 'quantity' => '2', 'unit' => 'pièces'],
                    ['name' => 'Sel', 'quantity' => '1', 'unit' => 'pincée']
                ],
                'instructions' => [
                    ['step' => 'Éplucher et couper les bananes en biais'],
                    ['step' => 'Chauffer l\'huile de palme dans une poêle'],
                    ['step' => 'Faire frire les bananes jusqu\'à dorure'],
                    ['step' => 'Préparer la sauce avec gingembre et piment'],
                    ['step' => 'Servir chaud avec la sauce']
                ],
                'tags' => ['alloco', 'banane', 'frit', 'collation'],
                'origin_country' => 'Côte d\'Ivoire',
            ]
        ];

        foreach ($recipes as $recipeData) {
            Recipe::create($recipeData);
        }

        $this->command->info('Recettes créées: ' . count($recipes));

        // Créer des événements
        $events = [
            [
                'title' => 'Concours de Cuisine Ivoirienne 2024',
                'slug' => 'concours-cuisine-2024-' . time(),
                'description' => 'Participez au grand concours de cuisine traditionnelle et remportez des prix exceptionnels',
                'short_description' => 'Concours culinaire avec prix',
                'start_date' => now()->addDays(20),
                'end_date' => now()->addDays(21),
                'start_time' => '10:00:00',
                'end_time' => '16:00:00',
                'location' => 'Centre Culturel de Cocody',
                'address' => 'Boulevard Lagunaire, Cocody',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => $categories->first()->id,
                'event_type' => 'competition',
                'event_format' => 'in_person',
                'max_participants' => 50,
                'price' => 2000,
                'currency' => 'XOF',
                'is_free' => false,
                'requires_registration' => true,
                'status' => 'active',
                'is_published' => true,
                'tags' => ['concours', 'cuisine', 'prix', 'tradition']
            ],
            [
                'title' => 'Marché des Saveurs Locales',
                'slug' => 'marche-saveurs-' . time(),
                'description' => 'Découvrez les produits locaux et épices traditionnelles de nos régions',
                'short_description' => 'Marché spécialisé produits locaux',
                'start_date' => now()->addDays(10),
                'start_time' => '07:00:00',
                'end_time' => '14:00:00',
                'location' => 'Marché de Treichville',
                'address' => 'Avenue Chardy, Treichville',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => $categories->first()->id,
                'event_type' => 'exhibition',
                'event_format' => 'in_person',
                'is_free' => true,
                'status' => 'active',
                'is_published' => true,
                'tags' => ['marché', 'produits', 'local', 'épices']
            ]
        ];

        foreach ($events as $eventData) {
            Event::create($eventData);
        }

        $this->command->info('Événements créés: ' . count($events));

        // Créer des vidéos Dinor TV
        $videos = [
            [
                'title' => 'Les Secrets du Garba Traditionnel',
                'slug' => 'secrets-garba-' . time(),
                'description' => 'Apprenez à préparer le garba comme nos grands-mères avec tous les secrets de famille',
                'video_url' => 'https://www.youtube.com/watch?v=demo1',
                'duration' => 720,
                'category_id' => $categories->first()->id,
                'is_published' => true,
                'is_featured' => true,
                'tags' => ['garba', 'technique', 'expert', 'tradition']
            ],
            [
                'title' => 'Live Cooking Show - Vendredi Soir',
                'slug' => 'live-cooking-' . time(),
                'description' => 'Émission culinaire en direct tous les vendredis soir avec nos chefs',
                'video_url' => 'https://www.youtube.com/watch?v=demo2',
                'duration' => 3600,
                'category_id' => $categories->first()->id,
                'is_live' => true,
                'scheduled_at' => now()->addDays(5),
                'is_published' => true,
                'tags' => ['live', 'show', 'vendredi', 'direct']
            ]
        ];

        foreach ($videos as $videoData) {
            DinorTv::create($videoData);
        }

        $this->command->info('Vidéos créées: ' . count($videos));

        // Créer des astuces
        $tips = [
            [
                'title' => 'Comment bien nettoyer et préparer le poisson',
                'slug' => 'nettoyer-poisson-' . time(),
                'content' => 'Pour bien nettoyer un poisson, commencez par écailler sous l\'eau froide courante en allant de la queue vers la tête. Retirez ensuite les nageoires avec des ciseaux, puis procédez au vidage en faisant une incision ventrale. Rincez abondamment à l\'eau froide.',
                'category_id' => $categories->first()->id,
                'difficulty_level' => 'beginner',
                'estimated_time' => 10,
                'is_published' => true,
                'is_featured' => true,
                'tags' => ['poisson', 'nettoyage', 'base', 'technique']
            ],
            [
                'title' => 'Conservation optimale de l\'huile de palme rouge',
                'slug' => 'conservation-huile-palme-' . time(),
                'content' => 'L\'huile de palme rouge se conserve mieux dans un endroit frais et sec, à l\'abri de la lumière directe. Utilisez un récipient en verre ou en plastique alimentaire hermétique. Elle peut se solidifier par temps froid, c\'est normal.',
                'category_id' => $categories->first()->id,
                'difficulty_level' => 'beginner',
                'estimated_time' => 5,
                'is_published' => true,
                'tags' => ['huile', 'palme', 'conservation', 'stockage']
            ]
        ];

        foreach ($tips as $tipData) {
            Tip::create($tipData);
        }

        $this->command->info('Astuces créées: ' . count($tips));

        $this->command->info('✅ Toutes les données d\'exemple ont été créées avec succès !');
    }
}
