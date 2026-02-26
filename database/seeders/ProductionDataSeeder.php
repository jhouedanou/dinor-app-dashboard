<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Page;
use App\Models\Tip;
use App\Models\DinorTv;
use App\Models\User;
use App\Models\Like;
use App\Models\Comment;

class ProductionDataSeeder extends Seeder
{
    /**
     * Seed the application's database for production.
     */
    public function run(): void
    {
        // Créer des utilisateurs de démonstration (mots de passe aléatoires)
        $users = [
            [
                'name' => 'Marie Kouassi',
                'email' => 'marie.kouassi@example.com',
                'password' => bcrypt(\Illuminate\Support\Str::random(24)),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Jean-Baptiste Traoré',
                'email' => 'jean.traore@example.com',
                'password' => bcrypt(\Illuminate\Support\Str::random(24)),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Fatou Diallo',
                'email' => 'fatou.diallo@example.com',
                'password' => bcrypt(\Illuminate\Support\Str::random(24)),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
        ];

        foreach ($users as $userData) {
            User::firstOrCreate(['email' => $userData['email']], $userData);
        }

        // Créer plus de recettes variées
        $additionalRecipes = [
            [
                'title' => 'Riz au Gras Ivoirien',
                'slug' => 'riz-au-gras-ivoirien',
                'description' => 'Riz cuit dans une sauce tomate riche avec viande et légumes',
                'short_description' => 'Plat emblématique de la cuisine ivoirienne',
                'category_id' => Category::where('slug', 'cuisine-ivoirienne')->first()?->id ?? 1,
                'preparation_time' => 25,
                'cooking_time' => 60,
                'servings' => 6,
                'difficulty' => 'medium',
                'meal_type' => 'lunch',
                'diet_type' => 'none',
                'origin_country' => 'Côte d\'Ivoire',
                'ingredients' => [
                    ['name' => 'Riz jasmin', 'quantity' => '500', 'unit' => 'g'],
                    ['name' => 'Viande de bœuf', 'quantity' => '400', 'unit' => 'g'],
                    ['name' => 'Concentré de tomate', 'quantity' => '3', 'unit' => 'cuillères à soupe'],
                    ['name' => 'Aubergines', 'quantity' => '2', 'unit' => 'pièces'],
                    ['name' => 'Courgettes', 'quantity' => '1', 'unit' => 'pièce'],
                    ['name' => 'Huile de palme', 'quantity' => '4', 'unit' => 'cuillères à soupe'],
                ],
                'instructions' => [
                    ['step' => 'Faire revenir la viande avec les oignons'],
                    ['step' => 'Ajouter le concentré de tomate et faire cuire'],
                    ['step' => 'Incorporer les légumes et l\'eau'],
                    ['step' => 'Ajouter le riz et laisser cuire 25 minutes'],
                ],
                'chef_name' => 'Chef Adjoua',
                'tags' => ['riz', 'viande', 'légumes', 'traditionnel'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Bangui (Sauce Palme)',
                'slug' => 'bangui-sauce-palme',
                'description' => 'Sauce à base d\'huile de palme avec poisson et légumes',
                'short_description' => 'Sauce traditionnelle onctueuse',
                'category_id' => Category::where('slug', 'cuisine-ivoirienne')->first()?->id ?? 1,
                'preparation_time' => 20,
                'cooking_time' => 40,
                'servings' => 4,
                'difficulty' => 'medium',
                'meal_type' => 'lunch',
                'diet_type' => 'none',
                'origin_country' => 'Côte d\'Ivoire',
                'ingredients' => [
                    ['name' => 'Huile de palme rouge', 'quantity' => '200', 'unit' => 'ml'],
                    ['name' => 'Poisson fumé', 'quantity' => '300', 'unit' => 'g'],
                    ['name' => 'Épinards', 'quantity' => '500', 'unit' => 'g'],
                    ['name' => 'Gombos', 'quantity' => '200', 'unit' => 'g'],
                    ['name' => 'Ail', 'quantity' => '3', 'unit' => 'gousses'],
                ],
                'instructions' => [
                    ['step' => 'Chauffer l\'huile de palme dans une casserole'],
                    ['step' => 'Ajouter le poisson fumé émietté'],
                    ['step' => 'Incorporer les légumes et l\'ail'],
                    ['step' => 'Laisser mijoter 30 minutes'],
                ],
                'tags' => ['sauce', 'palme', 'poisson', 'légumes'],
                'is_published' => true,
            ],
            [
                'title' => 'Tiep Bou Dien (Style Ivoirien)',
                'slug' => 'tiep-bou-dien-ivoirien',
                'description' => 'Riz au poisson adapté aux goûts ivoiriens',
                'short_description' => 'Riz au poisson aux saveurs locales',
                'category_id' => Category::where('slug', 'cuisine-ivoirienne')->first()?->id ?? 1,
                'preparation_time' => 30,
                'cooking_time' => 50,
                'servings' => 5,
                'difficulty' => 'hard',
                'meal_type' => 'dinner',
                'diet_type' => 'none',
                'origin_country' => 'Côte d\'Ivoire',
                'ingredients' => [
                    ['name' => 'Riz brisé', 'quantity' => '600', 'unit' => 'g'],
                    ['name' => 'Poisson capitaine', 'quantity' => '800', 'unit' => 'g'],
                    ['name' => 'Sauce tomate', 'quantity' => '4', 'unit' => 'cuillères à soupe'],
                    ['name' => 'Carottes', 'quantity' => '3', 'unit' => 'pièces'],
                    ['name' => 'Chou', 'quantity' => '1/2', 'unit' => 'pièce'],
                ],
                'instructions' => [
                    ['step' => 'Préparer et assaisonner le poisson'],
                    ['step' => 'Faire revenir avec la sauce tomate'],
                    ['step' => 'Ajouter les légumes et l\'eau'],
                    ['step' => 'Incorporer le riz et cuire jusqu\'à tendreté'],
                ],
                'tags' => ['riz', 'poisson', 'légumes', 'festif'],
                'is_published' => true,
            ],
        ];

        foreach ($additionalRecipes as $recipeData) {
            Recipe::firstOrCreate(['slug' => $recipeData['slug']], $recipeData);
        }

        // Créer plus d'astuces
        $additionalTips = [
            [
                'title' => 'Réussir la cuisson du riz parfaitement',
                'slug' => 'cuisson-riz-parfait',
                'content' => '<p>Pour un riz parfaitement cuit :</p><ul><li>Rincer le riz jusqu\'à ce que l\'eau soit claire</li><li>Utiliser le ratio 1:1.5 (riz:eau)</li><li>Porter à ébullition puis réduire le feu</li><li>Couvrir et laisser cuire 18 minutes</li><li>Laisser reposer 5 minutes avant de servir</li></ul>',
                'category_id' => Category::first()->id,
                'difficulty_level' => 'beginner',
                'estimated_time' => 3,
                'tags' => ['riz', 'cuisson', 'base', 'technique'],
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Préparer ses épices africaines maison',
                'slug' => 'epices-africaines-maison',
                'content' => '<p>Créez vos mélanges d\'épices authentiques :</p><ul><li>Mélange 4 épices : muscade, clou de girofle, poivre, cannelle</li><li>Mélange curry ivoirien : curcuma, coriandre, cumin, fenugrec</li><li>Conservez dans des bocaux hermétiques</li><li>Étiquetez avec la date de préparation</li></ul>',
                'category_id' => Category::first()->id,
                'difficulty_level' => 'intermediate',
                'estimated_time' => 15,
                'tags' => ['épices', 'mélange', 'conservation', 'authentique'],
                'is_published' => true,
            ],
            [
                'title' => 'Nettoyer et préparer le poisson',
                'slug' => 'nettoyer-preparer-poisson',
                'content' => '<p>Étapes pour bien préparer le poisson :</p><ul><li>Écailler sous l\'eau froide</li><li>Vider en faisant une incision ventrale</li><li>Rincer abondamment</li><li>Assaisonner avec citron et sel</li><li>Laisser mariner 30 minutes minimum</li></ul>',
                'category_id' => Category::first()->id,
                'difficulty_level' => 'intermediate',
                'estimated_time' => 10,
                'tags' => ['poisson', 'préparation', 'nettoyage', 'technique'],
                'is_published' => true,
            ],
        ];

        foreach ($additionalTips as $tipData) {
            Tip::firstOrCreate(['slug' => $tipData['slug']], $tipData);
        }

        // Créer plus d'événements
        $additionalEvents = [
            [
                'title' => 'Marché des Saveurs Ivoiriennes',
                'slug' => 'marche-saveurs-ivoiriennes',
                'description' => 'Découvrez les produits locaux et rencontrez les producteurs',
                'short_description' => 'Marché de producteurs locaux',
                'content' => '<p>Un marché exceptionnel pour découvrir la richesse des produits ivoiriens...</p>',
                'start_date' => now()->addDays(20),
                'end_date' => now()->addDays(20),
                'start_time' => '08:00:00',
                'end_time' => '16:00:00',
                'location' => 'Place de la République',
                'address' => 'Place de la République, Plateau',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => Category::first()->id,
                'event_type' => 'exhibition',
                'event_format' => 'in_person',
                'max_participants' => 1000,
                'is_free' => true,
                'status' => 'active',
                'tags' => ['marché', 'producteurs', 'local', 'découverte'],
                'is_published' => true,
            ],
            [
                'title' => 'Concours du Meilleur Attiéké',
                'slug' => 'concours-meilleur-attieke',
                'description' => 'Participez au grand concours de préparation d\'attiéké',
                'short_description' => 'Concours culinaire d\'attiéké',
                'start_date' => now()->addDays(45),
                'start_time' => '10:00:00',
                'end_time' => '15:00:00',
                'location' => 'Centre Culturel de Cocody',
                'address' => 'Boulevard Lagunaire, Cocody',
                'city' => 'Abidjan',
                'country' => 'Côte d\'Ivoire',
                'category_id' => Category::first()->id,
                'event_type' => 'competition',
                'event_format' => 'in_person',
                'max_participants' => 30,
                'price' => 10000,
                'currency' => 'XOF',
                'is_free' => false,
                'requires_registration' => true,
                'status' => 'active',
                'tags' => ['concours', 'attiéké', 'compétition', 'prix'],
                'is_published' => true,
                'is_featured' => true,
            ],
        ];

        foreach ($additionalEvents as $eventData) {
            Event::firstOrCreate(['slug' => $eventData['slug']], $eventData);
        }

        // Créer plus de contenus Dinor TV
        $additionalVideos = [
            [
                'title' => 'Les Secrets du Riz au Gras',
                'description' => 'Découvrez tous les secrets pour réussir un riz au gras parfait',
                'video_url' => 'https://www.youtube.com/embed/dQw4w9WgXcQ',
                'is_published' => true,
                'is_featured' => true,
            ],
            [
                'title' => 'Visite de Marché à Adjamé',
                'description' => 'Suivez-nous dans une visite guidée du marché d\'Adjamé',
                'video_url' => 'https://www.youtube.com/embed/dQw4w9WgXcQ',
                'is_published' => true,
            ],
            [
                'title' => 'Cours en Direct : Bangui aux Épinards',
                'description' => 'Cours de cuisine en direct pour apprendre le bangui',
                'video_url' => 'https://www.youtube.com/embed/dQw4w9WgXcQ',
                'is_published' => true,
            ],
        ];

        foreach ($additionalVideos as $videoData) {
            DinorTv::firstOrCreate(['title' => $videoData['title']], $videoData);
        }

        // Créer des likes et commentaires pour rendre l'application vivante
        $this->createLikesAndComments();
    }

    private function createLikesAndComments()
    {
        $users = User::all();
        $recipes = Recipe::all();
        $tips = Tip::all();
        $events = Event::all();

        // Créer des likes (éviter les doublons)
        foreach ($recipes as $recipe) {
            $likeCount = rand(5, 25);
            $usedUsers = [];
            for ($i = 0; $i < $likeCount; $i++) {
                $user = $users->random();
                // Éviter les doublons d'utilisateur pour le même contenu
                if (in_array($user->id, $usedUsers)) {
                    continue;
                }
                $usedUsers[] = $user->id;
                
                try {
                    Like::firstOrCreate([
                        'user_id' => $user->id,
                        'likeable_id' => $recipe->id,
                        'likeable_type' => Recipe::class,
                    ], [
                        'ip_address' => '192.168.1.' . rand(1, 254),
                        'user_agent' => 'Mozilla/5.0 (Mobile App)',
                    ]);
                } catch (\Exception $e) {
                    // Ignorer les erreurs de contrainte unique
                    continue;
                }
            }
            // Mettre à jour le compteur
            $recipe->update(['likes_count' => $recipe->likes()->count()]);
        }

        foreach ($tips as $tip) {
            $likeCount = rand(3, 15);
            $usedUsers = [];
            for ($i = 0; $i < $likeCount; $i++) {
                $user = $users->random();
                // Éviter les doublons d'utilisateur pour le même contenu
                if (in_array($user->id, $usedUsers)) {
                    continue;
                }
                $usedUsers[] = $user->id;
                
                try {
                    Like::firstOrCreate([
                        'user_id' => $user->id,
                        'likeable_id' => $tip->id,
                        'likeable_type' => Tip::class,
                    ], [
                        'ip_address' => '192.168.1.' . rand(1, 254),
                        'user_agent' => 'Mozilla/5.0 (Mobile App)',
                    ]);
                } catch (\Exception $e) {
                    // Ignorer les erreurs de contrainte unique
                    continue;
                }
            }
            $tip->update(['likes_count' => $tip->likes()->count()]);
        }

        // Créer des commentaires
        $comments = [
            'Excellente recette ! Merci pour le partage.',
            'J\'ai testé hier, c\'était délicieux !',
            'Merci pour ces conseils pratiques.',
            'Ma famille a adoré ce plat.',
            'Simple et efficace, parfait !',
            'Très bon conseil, je recommande.',
            'Ça donne envie d\'essayer !',
            'Bravo pour cette belle présentation.',
            'J\'adore cette approche traditionnelle.',
            'Merci Chef pour ces astuces !',
        ];

        foreach ($recipes as $recipe) {
            $commentCount = rand(2, 8);
            for ($i = 0; $i < $commentCount; $i++) {
                $user = $users->random();
                Comment::firstOrCreate([
                    'user_id' => $user->id,
                    'commentable_id' => $recipe->id,
                    'commentable_type' => Recipe::class,
                    'content' => $comments[array_rand($comments)],
                ], [
                    'author_name' => $user->name,
                    'author_email' => $user->email,
                    'is_approved' => true,
                    'ip_address' => '192.168.1.' . rand(1, 254),
                ]);
            }
        }

        foreach ($tips as $tip) {
            $commentCount = rand(1, 5);
            for ($i = 0; $i < $commentCount; $i++) {
                $user = $users->random();
                Comment::firstOrCreate([
                    'user_id' => $user->id,
                    'commentable_id' => $tip->id,
                    'commentable_type' => Tip::class,
                    'content' => $comments[array_rand($comments)],
                ], [
                    'author_name' => $user->name,
                    'author_email' => $user->email,
                    'is_approved' => true,
                    'ip_address' => '192.168.1.' . rand(1, 254),
                ]);
            }
        }
    }
}