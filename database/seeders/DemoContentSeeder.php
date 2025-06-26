<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Recipe;
use App\Models\Tip;
use App\Models\Event;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Ingredient;
use Carbon\Carbon;

class DemoContentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('🚀 Création du contenu de démonstration...');

        // Créer les catégories si elles n'existent pas
        $this->createCategories();
        
        // Créer quelques ingrédients
        $this->createIngredients();
        
        // Créer 4 recettes
        $this->createRecipes();
        
        // Créer 4 astuces
        $this->createTips();
        
        // Créer 4 événements
        $this->createEvents();
        
        // Créer des bannières pour la page d'accueil
        $this->createBanners();

        $this->command->info('✅ Contenu de démonstration créé avec succès !');
    }

    private function createCategories()
    {
        $categories = [
            ['name' => 'Plats principaux', 'slug' => 'plats-principaux', 'type' => 'recipe'],
            ['name' => 'Desserts', 'slug' => 'desserts', 'type' => 'recipe'],
            ['name' => 'Cuisine traditionnelle', 'slug' => 'cuisine-traditionnelle', 'type' => 'recipe'],
            ['name' => 'Cuisine moderne', 'slug' => 'cuisine-moderne', 'type' => 'recipe'],
            ['name' => 'Préparation', 'slug' => 'preparation', 'type' => 'tip'],
            ['name' => 'Conservation', 'slug' => 'conservation', 'type' => 'tip'],
            ['name' => 'Festivals', 'slug' => 'festivals', 'type' => 'event'],
            ['name' => 'Ateliers', 'slug' => 'ateliers', 'type' => 'event'],
        ];

        foreach ($categories as $categoryData) {
            Category::firstOrCreate(
                ['slug' => $categoryData['slug']],
                $categoryData
            );
        }
    }

    private function createIngredients()
    {
        $ingredients = [
            'Igname', 'Plantain', 'Manioc', 'Riz', 'Poulet', 'Poisson', 
            'Tomate', 'Oignon', 'Piment', 'Gingembre', 'Ail', 'Huile de palme',
            'Feuilles de manioc', 'Gombo', 'Aubergine', 'Noix de coco'
        ];

        foreach ($ingredients as $ingredientName) {
            Ingredient::firstOrCreate(
                ['name' => $ingredientName],
                [
                    'name' => $ingredientName,
                    'category' => 'Ingrédient de base',
                    'is_available' => true
                ]
            );
        }
    }

    private function createRecipes()
    {
        $recipes = [
            [
                'title' => 'Attiéké au Poisson Braisé',
                'slug' => 'attieke-au-poisson-braise',
                'short_description' => 'Un plat traditionnel ivoirien savoureux avec de l\'attiéké et du poisson grillé aux épices locales.',
                'content' => $this->getRecipeContent('attiéké'),
                'ingredients' => json_encode([
                    ['name' => 'Attiéké', 'quantity' => '200g'],
                    ['name' => 'Poisson (dorade)', 'quantity' => '1 entier'],
                    ['name' => 'Tomates', 'quantity' => '3 moyennes'],
                    ['name' => 'Oignons', 'quantity' => '2 moyens'],
                    ['name' => 'Piment', 'quantity' => '2 pièces'],
                    ['name' => 'Gingembre', 'quantity' => '1 morceau'],
                    ['name' => 'Ail', 'quantity' => '3 gousses']
                ]),
                'instructions' => json_encode([
                    'Nettoyer et vider le poisson, faire des entailles',
                    'Préparer la marinade avec les épices pilées',
                    'Mariner le poisson pendant 30 minutes',
                    'Griller le poisson sur charbon de bois',
                    'Préparer la sauce tomate avec oignons et piment',
                    'Servir l\'attiéké avec le poisson et la sauce'
                ]),
                'preparation_time' => 45,
                'cooking_time' => 30,
                'difficulty' => 'medium',
                'category_id' => Category::where('slug', 'plats-principaux')->first()?->id,
                'featured_image_url' => '/images/recipes/attieke-poisson.jpg',
                'is_featured' => true,
            ],
            [
                'title' => 'Kedjenou de Poulet',
                'slug' => 'kedjenou-de-poulet',
                'short_description' => 'Poulet mijoté dans sa propre vapeur avec des légumes, cuit dans une canari traditionnelle.',
                'content' => $this->getRecipeContent('kedjenou'),
                'ingredients' => json_encode([
                    ['name' => 'Poulet', 'quantity' => '1 entier découpé'],
                    ['name' => 'Oignons', 'quantity' => '3 gros'],
                    ['name' => 'Tomates', 'quantity' => '4 moyennes'],
                    ['name' => 'Piment', 'quantity' => '3 pièces'],
                    ['name' => 'Gingembre', 'quantity' => '1 gros morceau'],
                    ['name' => 'Ail', 'quantity' => '5 gousses'],
                    ['name' => 'Aubergines', 'quantity' => '2 moyennes']
                ]),
                'instructions' => json_encode([
                    'Découper le poulet en morceaux moyens',
                    'Éplucher et couper grossièrement tous les légumes',
                    'Dans une canari, disposer le poulet et les légumes en couches',
                    'Ajouter les épices sans eau ni huile',
                    'Fermer hermétiquement et cuire 1h à feu doux',
                    'Secouer délicatement de temps en temps'
                ]),
                'preparation_time' => 20,
                'cooking_time' => 60,
                'difficulty' => 'easy',
                'category_id' => Category::where('slug', 'cuisine-traditionnelle')->first()?->id,
                'featured_image_url' => '/images/recipes/kedjenou.jpg',
                'is_featured' => true,
            ],
            [
                'title' => 'Sauce Graine aux Boulettes',
                'slug' => 'sauce-graine-aux-boulettes',
                'short_description' => 'Sauce traditionnelle à base de graines de palme avec des boulettes de poisson fumé.',
                'content' => $this->getRecipeContent('sauce-graine'),
                'ingredients' => json_encode([
                    ['name' => 'Graines de palme', 'quantity' => '1 kg'],
                    ['name' => 'Poisson fumé', 'quantity' => '300g'],
                    ['name' => 'Viande de bœuf', 'quantity' => '400g'],
                    ['name' => 'Feuilles de manioc', 'quantity' => '500g'],
                    ['name' => 'Gombo', 'quantity' => '200g'],
                    ['name' => 'Piment', 'quantity' => '3 pièces'],
                    ['name' => 'Oignon', 'quantity' => '1 gros']
                ]),
                'instructions' => json_encode([
                    'Faire bouillir les graines de palme et les piler',
                    'Extraire l\'huile rouge en pressant avec de l\'eau chaude',
                    'Faire cuire la viande avec les épices',
                    'Ajouter l\'huile rouge et laisser mijoter',
                    'Incorporer le poisson fumé émietté',
                    'Ajouter les légumes et cuire 30 minutes'
                ]),
                'preparation_time' => 60,
                'cooking_time' => 90,
                'difficulty' => 'hard',
                'category_id' => Category::where('slug', 'cuisine-traditionnelle')->first()?->id,
                'featured_image_url' => '/images/recipes/sauce-graine.jpg',
                'is_featured' => false,
            ],
            [
                'title' => 'Bananes Flambées au Rhum',
                'slug' => 'bananes-flambees-au-rhum',
                'short_description' => 'Dessert exotique avec des bananes caramélisées et flambées au rhum local.',
                'content' => $this->getRecipeContent('bananes-flambees'),
                'ingredients' => json_encode([
                    ['name' => 'Bananes mûres', 'quantity' => '6 grosses'],
                    ['name' => 'Beurre', 'quantity' => '80g'],
                    ['name' => 'Sucre roux', 'quantity' => '100g'],
                    ['name' => 'Rhum', 'quantity' => '6 cl'],
                    ['name' => 'Cannelle', 'quantity' => '1 cuillère café'],
                    ['name' => 'Vanille', 'quantity' => '1 gousse'],
                    ['name' => 'Jus de citron', 'quantity' => '2 cuillères soupe']
                ]),
                'instructions' => json_encode([
                    'Éplucher et couper les bananes en rondelles épaisses',
                    'Faire fondre le beurre dans une poêle',
                    'Ajouter le sucre et caraméliser légèrement',
                    'Disposer les bananes et les dorer des deux côtés',
                    'Saupoudrer de cannelle et ajouter la vanille',
                    'Arroser de rhum et flamber délicatement'
                ]),
                'preparation_time' => 15,
                'cooking_time' => 15,
                'difficulty' => 'easy',
                'category_id' => Category::where('slug', 'desserts')->first()?->id,
                'featured_image_url' => '/images/recipes/bananes-flambees.jpg',
                'is_featured' => false,
            ]
        ];

        foreach ($recipes as $recipeData) {
            Recipe::create(array_merge($recipeData, [
                'status' => 'published',
                'created_at' => Carbon::now()->subDays(rand(1, 30)),
                'updated_at' => Carbon::now()
            ]));
        }

        $this->command->info('✅ 4 recettes créées');
    }

    private function createTips()
    {
        $tips = [
            [
                'title' => 'Comment bien choisir son plantain',
                'content' => 'Pour un plantain parfait, choisissez-le selon votre usage : vert pour les alloco croustillants, jaune pour la douceur, noir pour les desserts. La peau doit être ferme sans taches molles.',
                'difficulty_level' => 'easy',
                'estimated_time' => 5,
                'category_id' => Category::where('slug', 'preparation')->first()?->id,
                'is_featured' => true,
            ],
            [
                'title' => 'Conservation du poisson fumé',
                'content' => 'Pour conserver votre poisson fumé, enveloppez-le dans du papier journal puis dans un sac plastique. Placez au réfrigérateur. Il se garde ainsi 2 semaines. Évitez les contenants hermétiques qui créent de l\'humidité.',
                'difficulty_level' => 'easy',
                'estimated_time' => 10,
                'category_id' => Category::where('slug', 'conservation')->first()?->id,
                'is_featured' => true,
            ],
            [
                'title' => 'Secret d\'un bon kedjenou',
                'content' => 'Le secret d\'un kedjenou réussi : ne jamais ouvrir la canari pendant la cuisson ! La vapeur doit rester emprisonnée. Utilisez de l\'argile de bonne qualité et scellez bien le couvercle avec de la pâte.',
                'difficulty_level' => 'medium',
                'estimated_time' => 15,
                'category_id' => Category::where('slug', 'preparation')->first()?->id,
                'is_featured' => false,
            ],
            [
                'title' => 'Préparer l\'huile de palme rouge',
                'content' => 'Pour extraire une huile de palme pure : faites bouillir les noix 30 min, pilez-les, ajoutez de l\'eau chaude et malaxez. L\'huile rouge remonte à la surface. Filtrez avec un tissu propre.',
                'difficulty_level' => 'hard',
                'estimated_time' => 120,
                'category_id' => Category::where('slug', 'preparation')->first()?->id,
                'is_featured' => false,
            ]
        ];

        foreach ($tips as $tipData) {
            Tip::create(array_merge($tipData, [
                'status' => 'published',
                'created_at' => Carbon::now()->subDays(rand(1, 20)),
                'updated_at' => Carbon::now()
            ]));
        }

        $this->command->info('✅ 4 astuces créées');
    }

    private function createEvents()
    {
        $events = [
            [
                'title' => 'Festival de la Gastronomie Ivoirienne',
                'slug' => 'festival-gastronomie-ivoirienne',
                'short_description' => 'Découvrez les saveurs authentiques de Côte d\'Ivoire lors de ce festival culinaire exceptionnel.',
                'content' => 'Un festival unique célébrant la richesse de la gastronomie ivoirienne. Au programme : démonstrations culinaires, dégustations, stands de producteurs locaux, concours de cuisine traditionnelle et spectacles culturels.',
                'start_date' => Carbon::now()->addDays(30),
                'end_date' => Carbon::now()->addDays(33),
                'location' => 'Palais de la Culture, Abidjan',
                'price' => '5000',
                'max_participants' => 500,
                'status' => 'upcoming',
                'category_id' => Category::where('slug', 'festivals')->first()?->id,
                'featured_image_url' => '/images/events/festival-gastronomie.jpg',
                'is_featured' => true,
            ],
            [
                'title' => 'Atelier Cuisine du Kedjenou',
                'slug' => 'atelier-cuisine-kedjenou',
                'short_description' => 'Apprenez à préparer le kedjenou traditionnel avec un chef expert.',
                'content' => 'Atelier pratique pour maîtriser l\'art du kedjenou. Vous apprendrez les techniques traditionnelles, le choix des ingrédients, l\'utilisation de la canari et tous les secrets pour réussir ce plat emblématique.',
                'start_date' => Carbon::now()->addDays(15),
                'end_date' => Carbon::now()->addDays(15),
                'location' => 'École de Cuisine Dinor, Cocody',
                'price' => '15000',
                'max_participants' => 20,
                'status' => 'upcoming',
                'category_id' => Category::where('slug', 'ateliers')->first()?->id,
                'featured_image_url' => '/images/events/atelier-kedjenou.jpg',
                'is_featured' => true,
            ],
            [
                'title' => 'Marché des Saveurs Locales',
                'slug' => 'marche-saveurs-locales',
                'short_description' => 'Rencontrez les producteurs locaux et découvrez les ingrédients authentiques.',
                'content' => 'Un marché exceptionnel réunissant les meilleurs producteurs de Côte d\'Ivoire. Découvrez des épices rares, des légumes traditionnels, des condiments artisanaux et échangez avec les cultivateurs.',
                'start_date' => Carbon::now()->addDays(7),
                'end_date' => Carbon::now()->addDays(9),
                'location' => 'Place de la République, Yamoussoukro',
                'price' => '0',
                'max_participants' => 1000,
                'status' => 'upcoming',
                'category_id' => Category::where('slug', 'festivals')->first()?->id,
                'featured_image_url' => '/images/events/marche-saveurs.jpg',
                'is_featured' => false,
            ],
            [
                'title' => 'Concours du Meilleur Attiéké',
                'slug' => 'concours-meilleur-attieke',
                'short_description' => 'Participez au grand concours national du meilleur attiéké de Côte d\'Ivoire.',
                'content' => 'Concours national pour élire le meilleur attiéké du pays. Ouvert aux professionnels et amateurs. Critères : goût, texture, présentation et respect de la tradition. Prix exceptionnels à gagner.',
                'start_date' => Carbon::now()->addDays(45),
                'end_date' => Carbon::now()->addDays(47),
                'location' => 'Centre Culturel, Bouaké',
                'price' => '2000',
                'max_participants' => 100,
                'status' => 'upcoming',
                'category_id' => Category::where('slug', 'festivals')->first()?->id,
                'featured_image_url' => '/images/events/concours-attieke.jpg',
                'is_featured' => false,
            ]
        ];

        foreach ($events as $eventData) {
            Event::create(array_merge($eventData, [
                'created_at' => Carbon::now()->subDays(rand(1, 10)),
                'updated_at' => Carbon::now()
            ]));
        }

        $this->command->info('✅ 4 événements créés');
    }

    private function createBanners()
    {
        $banners = [
            [
                'title' => 'Bienvenue sur Dinor',
                'description' => 'Découvrez les saveurs authentiques de la Côte d\'Ivoire',
                'background_color' => '#E1251B',
                'text_color' => '#FFFFFF',
                'button_text' => 'Découvrir nos recettes',
                'button_url' => '/recipes',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'is_active' => true,
                'order' => 1,
            ],
            [
                'title' => 'Nouveau : Festival Gastronomique',
                'description' => 'Rejoignez-nous pour célébrer la cuisine ivoirienne',
                'background_color' => '#FF6B35',
                'text_color' => '#FFFFFF',
                'button_text' => 'S\'inscrire maintenant',
                'button_url' => '/events',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'is_active' => true,
                'order' => 2,
            ]
        ];

        foreach ($banners as $bannerData) {
            Banner::create($bannerData);
        }

        $this->command->info('✅ Bannières créées');
    }

    private function getRecipeContent($type)
    {
        $contents = [
            'attiéké' => 'L\'attiéké est un accompagnement traditionnel ivoirien fait à partir de manioc râpé et fermenté. Ce plat, véritable symbole de la cuisine ivoirienne, se marie parfaitement avec le poisson grillé aux épices locales. La préparation demande du savoir-faire et de la patience pour obtenir cette texture granuleuse si caractéristique.',
            'kedjenou' => 'Le kedjenou est un plat emblématique de la Côte d\'Ivoire, traditionnellement cuit dans une canari en terre cuite. Cette méthode de cuisson unique permet aux aliments de mijoter dans leur propre vapeur, concentrant ainsi toutes les saveurs. C\'est un plat convivial parfait pour les grandes occasions.',
            'sauce-graine' => 'La sauce graine est l\'une des sauces les plus appréciées en Côte d\'Ivoire. Préparée à partir de graines de palme, elle accompagne traditionnellement le riz blanc ou le foutou. Sa couleur rouge orangé caractéristique et son goût unique en font un incontournable de la gastronomie locale.',
            'bananes-flambees' => 'Ce dessert exotique met en valeur la richesse des bananes locales. Le flambage au rhum apporte une note festive et parfume délicatement les fruits caramélisés. C\'est un dessert parfait pour terminer un repas traditionnel ivoirien.'
        ];

        return $contents[$type] ?? 'Délicieuse recette de la cuisine ivoirienne.';
    }
}
